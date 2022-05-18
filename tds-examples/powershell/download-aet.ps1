# Script Parameters

$TERN_API_KEY = "your-api-key"        # e.g. "bmRSFNPXp5KSF5aiI7OjpUM1s6eiANQmgyKF8NJjRpZFJqSGMlPWlRVQlGKndoUzI4JXhkVSYQka0xqNCohcXhVXDRmWQpCNWVJDU2o0SmtE"
$PATH_OUT = "your-output-path"        # e.g. "C:/Downloads/AET"
$UPDATE_METHOD = "UPDATE_MISSING"     # e.g. "UPDATE_MISSING", "UPDATE_NEW", "UPDATE_ALL"
$PRODUCT_CODE = "CMRSET_LANDSAT_V2_2" # e.g. "CMRSET_LANDSAT_V2_2" (recommended)
$START = "2020-01-01"                 # e.g. Like: "YYYY-MM-DD"
$END = "2020-12-01"                   # e.g. Like: "YYYY-MM-DD"
$BANDS = @("ETa", "pixel_qa")         # Available values: "ETa", "pixel_qa"
$TILES = 0..11                        # All tiles
#$TILES = @(10,11)                    # Some tiles
$DRYRUN = $false                      # e.g. $true, $false


# Dataset status (up/down), and important notes for running this script:
# https://github.com/ternaustralia/cmrset-examples/tree/main/tds-examples

########################################################################################


# Lookup for available products.
$ProductCodes = @{
    CMRSET_LANDSAT_V2_2 = "https://data.tern.org.au/landscapes/aet/v2_2";
    CMRSET_LANDSAT_V2_1 = "https://data.tern.org.au/landscapes/aet/v2_1" # Discontinued
}

# Lookup for tile indicies.
$TileLookup = @{
    0 = "0000000000-0000000000";
    1 = "0000000000-0000043776";
    2 = "0000000000-0000087552";
    3 = "0000000000-0000131328";
    4 = "0000043776-0000000000";
    5 = "0000043776-0000043776";
    6 = "0000043776-0000087552";
    7 = "0000043776-0000131328";
    8 = "0000087552-0000000000";
    9 = "0000087552-0000043776";
    10 = "0000087552-0000087552";
    11 = "0000087552-0000131328"
}

# Use environment variables as preference (if defined) before script variables.
$TERN_API_KEY = if (Test-Path 'env:TERN_API_KEY') {$env:TERN_API_KEY} else {$TERN_API_KEY}
$PATH_OUT = if (Test-Path 'env:PATH_OUT') {$env:PATH_OUT} else {$PATH_OUT}
$UPDATE_METHOD = if (Test-Path 'env:UPDATE_METHOD') {$env:UPDATE_METHOD} else {$UPDATE_METHOD}
$PRODUCT_CODE = if (Test-Path 'env:PRODUCT_CODE') {$env:PRODUCT_CODE} else {$PRODUCT_CODE}
$START = if (Test-Path 'env:START') {$env:START} else {$START}
$END = if (Test-Path 'env:END') {$env:END} else {$END}
$BANDS = if (Test-Path 'env:BANDS') {$env:BANDS -split "," | ForEach-Object {$_.Trim()} } else {$BANDS}
$TILES = if (Test-Path 'env:TILES') {$env:TILES -split "," | ForEach-Object {[int]$_.Trim()} } else {$TILES}
$DRYRUN = if (Test-Path 'env:DRYRUN') {[System.Convert]::ToBoolean($env:DRYRUN)} else {$DRYRUN}

# A session which contains common settings which will be used for all web requests made.
# In particular, an X-API-Key auth from a base64 encoded key.
$key_headers = @{ "X-API-Key" = "$($TERN_API_KEY)"}
$null = Invoke-WebRequest -Uri $ProductCodes[$PRODUCT_CODE] -Method "HEAD" -SessionVariable "Session" -Headers $key_headers


# An enum for the various processing methods.
enum UpdateMethod {

    UPDATE_MISSING # Update missing files within the local archive.
    UPDATE_NEW     # Update missing/outdated files within the local archive.
    UPDATE_ALL     # Update all files within the local archive.

}

# Get a monthly array of dates between start and end.
function get_months([datetime]$start, [datetime]$end) {

    # Ensure dates are 1st of the month.
    $start = GET-DATE $start -Day 1
    $end = GET-DATE $end -Day 1

    $date = $start
    [System.Collections.ArrayList]$array = @() # Cast to ArrayList for efficiency.
    while($date -le $end)
    {
        [void]$array.Add($date)                # Cast to void to avoid inteference from .Add().
        $date = $date.AddMonths(1)
    }
    return $array

}

# Get the relative paths for the VRT files based upon product, date range and bands.
function get_vrt_relative_paths([string]$product_code, [datetime[]]$dates, [string[]]$bands) {

    $date_hash = [ordered]@{}
    foreach ($date in $dates)
    {
        $date_hash[$date] = [ordered]@{}
        foreach ($band in $bands)
        {
            $date_str = $date.tostring("yyyy_MM_dd")
            $date_hash[$date][$band] = "/$($date.Year)/$($date_str)/$($product_code)_$($date_str)_$($band).vrt"
        }
    }
    return $date_hash

}

# Get all the sources referenced within a VRT file.
function get_vrt_sources([string]$file) {

    [xml]$xml_doc = Get-Content $file
    $nodes = $xml_doc.selectnodes("/VRTDataset/VRTRasterBand/*/SourceFilename") # Use wildcard for different source types.
    $files = $nodes | ForEach-Object { $_.get_InnerXml()} | Sort-Object         # Sort the node values after searching the nodes.

    return $files

}

# Download a file via a session.
function download_file([string]$url, [string]$out_file, [bool]$dryrun=$false) {

    Write-Information "Downloading: $($url)" -InformationAction continue
    if ($dryrun -eq $false) {
        $response = Invoke-WebRequest -Uri "$($url)" -OutFile ( New-Item -Path $out_file -Force ) -WebSession $Session  # Session accessed from global scope.
        return $response
    }

}

# Determines whether a download should take place based upon the UpdateMethod.
function confirm_download([string]$url, [string]$out_file, [UpdateMethod]$update_method) {

    switch ( $update_method )
    {

        # Update missing files within the local archive.
        UPDATE_MISSING
        { 
            $result = (-Not (Test-Path -Path $out_file)) 
            if (-Not $result) { Write-Information "Skipping existing file: $($url)" -InformationAction continue }
        }

        # Update missing/outdated files within the local archive.
        UPDATE_NEW
        {
            if (-Not (Test-Path -Path $out_file)) { $result=$true; break }     # Return true if the file is missing.
            $dt = (Get-ChildItem -Path $out_file | select CreationTimeUtc).CreationTimeUtc
            $date_str = $dt.ToString("ddd, dd MMM yyyy HH:mm:ss") + " GMT"     # File creation date in GMT, for headers.
            $headers = @{ "If-Modified-Since" = "$($date_str)"} + $key_headers # key_headers accessed from global scope.
            try{
                $response = Invoke-WebRequest -Uri "$($url)" -Method "HEAD" -Headers $headers
            }
            catch{
                $result = ($_.Exception.Response.StatusCode -ne "NotModified") # Check if response is a HTTP 304 Not Modified status code.
            }
            if (-Not $result) { Write-Information "Skipping up to date file: $($url)" -InformationAction continue }
        }

        # Update all files within the local archive.
        UPDATE_ALL { $result = $true }

    }

    return $result

}

# Downloads the image tiles for the specified paths.
function download_images([string]$base_url, [string]$base_folder, [hashtable]$relative_paths, [string[]]$tile_ids=0..11, [UpdateMethod]$update_method="UPDATE_MISSING", [bool]$dryrun=$false) {

    foreach ($date in $relative_paths.Keys.GetEnumerator() | Sort-Object) # Need to sort keys from Enumerator
    {
        Write-Information "Processing $($relative_paths.Count) bands(s) for $($date.tostring("yyyy-MM-dd"))..." -InformationAction continue
        
        foreach ($band in $relative_paths[$date].Keys.GetEnumerator() | Sort-Object) # Need to sort keys from Enumerator
        {
            Write-Information "Processing $($band) for $($date.tostring("yyyy-MM-dd"))..." -InformationAction continue
            
            # Download VRT file that contains references to the files it mosaics.
            try {
                $vrt_url = "$($base_url)$($relative_paths[$date][$band])"
                $vrt_file = New-TemporaryFile                               # Create temporary file for VRT.
                download_file $vrt_url $vrt_file                            # Download VRT contents to the temporary file.
                $files = get_vrt_sources($vrt_file.FullName)                # Read the source files referenced within the VRT.
            } catch { 
                Write-Error $_.Exception.Message
                continue 
            } finally {
                Remove-Item $vrt_file.FullName                              # Delete the temporary file.
            }

            # Filter the tiles to those specified.
            $filtered_files = $files | Select-String -Pattern $tile_ids

            # Download all the tiles for the filtered space/time/variable parameters.
            Write-Information "Processing $($filtered_files.Count) tile(s) for $($band) on $($date.tostring("yyyy-MM-dd"))..." -InformationAction continue
            foreach ($file in $filtered_files)
            {
                $date_str = $date.tostring("yyyy_MM_dd")
                $tile_url = "$($base_url)/$($date.Year)/$($date_str)/$($file)"
                $out_file = "$($base_folder)/$($date.Year)/$($date_str)/$($file)"

                # Test whether a file should be downloaded, and do so if True.
                if (confirm_download $tile_url $out_file $update_method) {
                    try { download_file $tile_url $out_file $dryrun }
                    catch { 
                        Write-Error $_.Exception.Message
                        continue 
                    }
                }     
            }
        }
    }
}

$main = {

    # Parse the period of interest.
    $start = [datetime]::ParseExact($START, 'yyyy-MM-dd', $null)
    $end = [datetime]::ParseExact($END, 'yyyy-MM-dd', $null)
    Write-Information "Start: $start" -InformationAction continue
    Write-Information "End: $end" -InformationAction continue

    # Generate the list of dates to download.
    $dates = get_months $start $end
    Write-Information "Processing data for the following dates:" -InformationAction continue
    $dates | ForEach-Object {$_.ToString("MMM yyyy")}

    # Get the relative paths for each the VRT files for each date.
    $vrt_relative_paths = get_vrt_relative_paths $PRODUCT_CODE $dates $BANDS
    $vrt_relative_paths

    # Download all the tiles referenced in each VRT file.
    download_images $ProductCodes[$PRODUCT_CODE] "$PATH_OUT/$PRODUCT_CODE" $vrt_relative_paths $TileLookup[$TILES] $UPDATE_METHOD $DRYRUN
    Write-Information "Processing complete!" -InformationAction continue

}

# Run the script
Invoke-Command -ScriptBlock $main

Exit
