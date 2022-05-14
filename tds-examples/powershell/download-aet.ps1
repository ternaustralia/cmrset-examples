# Setup variables

$API_KEY = "<paste api key here>" # e.g. "bmRSFNPXp5KSF5aiI7OjpUM1s6eiANQmgyKF8NJjRpZFJqSGMlPWlRVQlGKndoUzI4JXhkVSYQka0xqNCohcXhVXDRmWQpCNWVJDU2o0SmtE"
$PATH_OUT = "<paste output directory path here>"  # e.g."C:/Downloads/AET"
$PRODUCT_CODE = "CMRSET_LANDSAT_V2_2"
$START = "2020-01-01"
$END = "2020-12-01"
$OVERWRITE = $false
$DRYRUN = $false
$BANDS = @("ETa", "pixel_qa")
$TILES = 0..11 # All tiles
#$TILES = @(10,11) # Some tiles


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

# Get a monthly array of dates between start and end.
function get_months([datetime]$start, [datetime]$end) {

    $date = $start
    [System.Collections.ArrayList]$array = @() # Cast to ArrayList for efficiency.
    while($date -le $end)
    {
        [void]$array.Add($date) # Cast to void to avoid inteference from .Add().
        $date = $date.AddMonths(1)
    }
    return $array

}

# Get the relative paths for the VRT files.
# This XML encoded file contains all the file references it will mosaic.
function get_vrt_relative_paths([string]$product_code, [string]$band, [datetime[]]$dates) {

    $hash = [ordered]@{}
    foreach ($date in $dates)
    {
        $date_str = $date.tostring("yyyy_MM_dd")
        $hash[$date] = "/$($date.Year)/$($date_str)/$($product_code)_$($date_str)_$($band).vrt"
    }
    return $hash

}

# Get all the sources referenced within a VRT file.
function get_vrt_sources([string]$file) {

    [xml]$xml_doc = Get-Content $file
    $nodes = $xml_doc.selectnodes("/VRTDataset/VRTRasterBand/*/SourceFilename")
    $files = $nodes | ForEach-Object { $_.get_InnerXml()} | Sort-Object

    return $files

}

# Download a file requiring basic auth from a base64 encoded key.
function download_file([string]$url, [string]$output){

        Write-Information "Downloading: $($url)" -InformationAction continue
        $Headers = @{ "X-API-Key" = "$($API_KEY)" }
        $output_dir = Split-Path -Path $output
        $null = New-Item -ItemType Directory -Force -Path $output_dir # Assign to $null to avoid inteference from New-Item.
        Invoke-WebRequest -Uri "$($url)" -OutFile $output -Headers $Headers

}

# Downloads the image tiles for the specified paths.
function download_images([string]$base_url, [string]$base_folder, [hashtable]$relative_paths, [string[]]$tile_ids){

    Write-Information "Processing $($relative_paths.Count) VRT file(s)..." -InformationAction continue
    foreach ($relative_path in $relative_paths.GetEnumerator() | Sort-Object -Property name){ # Need to sort keys from Enumerator
    
        $date = $relative_path.Name
        $date_str = $date.tostring("yyyy_MM_dd")
        $vrt_url = "$($base_url)$($relative_path.Value)"
        
        # Download VRT file that contains references to the files it mosaics.
        try{
            $vrt_file = New-TemporaryFile # We use a system temporary file.
            download_file $vrt_url $vrt_file
            $files = get_vrt_sources($vrt_file.FullName)
            $filtered_files = $files | Select-String -Pattern $tile_ids # Filter the tiles to those specified.
        }catch{ 
            Write-Error $_.Exception.Message
            continue 
        }finally{
            Remove-Item $vrt_file.FullName # Delete the temporary VRT file.
        }
                
        # Loop through all files and download each one.
        Write-Information "Downloading $($filtered_files.Count) tile(s) for $($date_str)..." -InformationAction continue
        foreach ($file in $filtered_files) {
            
            $tile_url = "$($base_url)/$($date.Year)/$($date_str)/$($file)"
            $out_file = "$($base_folder)/$($date.Year)/$($date_str)/$($file)"

            # Only download files which have not already been downloaded or if forced to.
            if ((-Not (Test-Path -Path $out_file)) -or ($OVERWRITE -eq $true)) {
                if ($DRYRUN -eq $false){
                    try { download_file $tile_url $out_file }
                    catch { 
                        Write-Error $_.Exception.Message
                        continue 
                    }
                }else{
                    Write-Information "Downloading: $($tile_url)" -InformationAction continue
                }

            }   else {
                Write-Information "Skipping already existing file: $($tile_url)" -InformationAction continue
            }     
        }
 

    }
}

$main = {

    # Parse the period of interest.
    $startDate = [datetime]::ParseExact($START, 'yyyy-MM-dd', $null)
    $endDate = [datetime]::ParseExact($END, 'yyyy-MM-dd', $null)
    Write-Information "Start: $startDate" -InformationAction continue
    Write-Information "End: $endDate" -InformationAction continue

    # Generate the list of dates to download.
    $dates = get_months $startDate $endDate
    Write-Information "Processing data for the following dates:" -InformationAction continue
    $dates | ForEach-Object {$_.ToString("MMM yyyy")}

    function download_band([string]$band, [datetime[]]$dates){

        # Get the relative paths for each the VRT files for each date.
        $vrt_relative_paths = get_vrt_relative_paths $PRODUCT_CODE $band $dates
        Write-Information "Generated $($vrt_relative_paths.Count) VRT path(s) to download for band $($band)..." -InformationAction continue
        $vrt_relative_paths

        # Download all the tiles referenced in each VRT file.
        download_images $ProductCodes[$PRODUCT_CODE] "$PATH_OUT/$PRODUCT_CODE" $vrt_relative_paths $TileLookup[$TILES]
    }

    $BANDS | ForEach-Object { download_band $_ $dates }
    Write-Information "Processing complete!" -InformationAction continue

}

# Run the script
Invoke-Command -ScriptBlock $main

Exit
