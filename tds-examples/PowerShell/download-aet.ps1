# Setup variables

#$API_KEY = "<paste api key here>" # e.g. "bmRSFNPXp5KSF5aiI7OjpUM1s6eiANQmgyKF8NJjRpZFJqSGMlPWlRVQlGKndoUzI4JXhkVSYQka0xqNCohcXhVXDRmWQpCNWVJDU2o0SmtE"
$PRODUCT_CODE = "CMRSET_LANDSAT_V2_2"
$START = "2016-01-01"
$END = "2016-01-01"
$PATH_OUT = "<paste output directory path here>"  # e.g."C:/Downloads/AET/"
$TILES = 0..11 # All tiles
#$TILES = @(10,11) # Some tiles


########################################################################################


# Lookup for available products.
$ProductCodes = @{
    CMRSET_LANDSAT_V2_2 = "https://data.tern.org.au/landscapes/aet/v2_2";
    CMRSET_LANDSAT_V2_1 = "https://data.tern.org.au/landscapes/aet/v2_1" # Discontinued
}

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
    $array = @()
    while($date -le $end)
    {
        $array += $date
        $date = $date.AddMonths(1)
    }
    return $array

}

# Get the relative paths for the VRT files.
# This XML encoded file has all the metadata of the image tiles in that directory.
function get_vrt_relative_paths([string]$product_code, [string]$band, [datetime[]]$dates) {

    $hash = [ordered]@{}
    foreach ($date in $dates)
    {
        $date_str = $date.tostring("yyyy_MM_dd")
        $hash[$date] = "/$($date.Year)/$($date_str)/$($product_code)_$($date_str)_$($band).vrt"
    }
    return $hash

}

# Download a file requiring basic auth from a base64 encoded key.
function download_file([string]$url, [string]$output){

    try{
        Write-Information "Downloading: $($url)" -InformationAction continue
        $Headers = @{ "X-API-Key" = "$($API_KEY)" }
        $output_dir = Split-Path -Path $output
        New-Item -ItemType Directory -Force -Path $output_dir
        Invoke-WebRequest -Uri "$($url)" -OutFile $output -Headers $Headers
    }
    catch{
        Write-Error "Error downloading file: $($_.Exception.Message)"
        $url
        continue
    }

}

# Downloads the image tiles for the specified paths.
function download_images([string]$base_url, [string]$base_folder, [hashtable]$relative_paths) {

    Write-Information "Downloading $($relative_paths.Count) VRT Files..." -InformationAction continue
    foreach ($relative_path in $relative_paths.GetEnumerator() | Sort-Object -Property name) # need to sort keys
    {
        $date = $relative_path.Name
        $date_str = $date.tostring("yyyy_MM_dd")

        # Download VRT file that contains references to the files it mosaics together.
        # We use a system temporary file.
        $url = "$($base_url)$($relative_path.Value)"
        $tmp = New-TemporaryFile
        download_file $url $tmp

        # Load the XML file and select all the source files.
        try{
            [xml]$xml_doc = Get-Content $tmp.FullName
            $nodes = $xml_doc.selectnodes("/VRTDataset/VRTRasterBand/ComplexSource/SourceFilename")
            $files = $nodes | ForEach-Object { $_.get_InnerXml()}
        }
        catch{ continue }

        # Filter the tiles to those specified.
        $filtered_files = @()
        $tile_ids = $TileLookup[$TILES]
        foreach ($file in $files){
            foreach ($tile_id in $tile_ids){
                if ($file.Contains($tile_id)){
                    $filtered_files += $file
                }
            }
        }

        # Loop through all files and download each one.
        Write-Information "Downloading $($filtered_files.Count) Tiles for $($date_str)..." -InformationAction continue
        foreach ($file in $filtered_files) {
            
            $tile_url = "$($base_url)/$($date.Year)/$($date_str)/$($file)"
            $out_file = "$($base_folder)/$($date.Year)/$($date_str)/$($file)"

            # File doesn't exist locally, so download it.
            if (-Not (Test-Path -Path $out_file)) {
                download_file $tile_url $out_file
            }        
        }
        # Delete the temporary VRT file.
        Remove-Item $tmp.FullName     

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
    $dates

    # Get the relative paths for each the VRT files for each date.
    $vrt_relative_paths = get_vrt_relative_paths $PRODUCT_CODE "ETa" $dates
    Write-Information "Generated $($vrt_relative_paths.Count) VRT paths to download..." -InformationAction continue
    #$vrt_relative_paths

    # Download all the tiles referenced in each VRT file.
    download_images $ProductCodes[$PRODUCT_CODE] "$PATH_OUT/$PRODUCT_CODE" $vrt_relative_paths

}

# Run the script
Invoke-Command -ScriptBlock $main

Exit
