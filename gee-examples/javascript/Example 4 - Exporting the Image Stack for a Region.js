
// Example 4 - Exporting the Image Stack for a Region
// This example illustrates how to export the CMRSET Landsat V2.2 imagery
// via Earth Engine for a study area in the Pilbara. Both ETa and QA bands are
// exported. We will also illustrate changing the projection of the exported
// images to GDA94 (EPSG:4283). This example can potentially generate gigabytes
// of data, so we demonstrate two different methods for exporting the data to
// suit your own storage capabilities. These methods are:

// 1) Via Google Drive - This method is the simplest, however you may not be prepared
// to pay for a monthly subscription to upgrade your Google Drive storage limits if
// your export exceeds the free storage tier (20 GB).

// 2) Via Google Cloud Storage - This method will incur a once-off fee (rather than a subscription)
// for the egress costs associated with downloading the imagery from Google Cloud Storage.
// This method is recommended when method 1) is not appropriate for your circumstances.

// Execution Time: ~3 minutes
// Storage Required: 172 MB (on Google Drive or Google Cloud Storage)

// Define a region of interest.
var region = ee.Geometry.Rectangle([117.0, -21.5, 117.5, -21.0])

Map.addLayer(region, { 'color': 'green' }, 'Study Site')
Map.centerObject(region)

// Define the period of interest.
var start = '2019-01-01'
var end = '2020-01-01'

// Access evapotranspiration from the CMRSET dataset.
var cmrset_aet = ee.ImageCollection("TERN/AET/CMRSET_LANDSAT_V2_2").filterDate(start, end)

// Define the export settings.
var site_name = 'Pilbara' // Description for your site (used in task descriptions/output file names)
var export_folder = 'CMRSET_Exports'


// A helper function to export an image band to Google Drive
function exportBandToDrive(image, band_name) {

    var task_description = site_name + '_' + eta_client.features[i].properties['system:index'].substring(0, 10) + '_ETa'
    Export.image.toDrive({
        'image': image.select(band_name),
        'region': region,
        'scale': 30,
        'crs': 'EPSG:4283',
        'description': task_description,
        'folder': export_folder
    })
}


// A helper function to export an image band to Google Cloud Storage
var myBucket = 'your-bucket-name'
function exportBandToCloudStorage(image, band_name) {

    var task_description = site_name + '_' + eta_client.features[i].properties['system:index'].substring(0, 10) + '_ETa'
    Export.image.toCloudStorage({
        'image': image.select(band_name),
        'region': region,
        'scale': 30,
        'crs': 'EPSG:4283',
        'description': task_description,
        'bucket': myBucket,
        'fileNamePrefix': export_folder + '/' + site_name + '/' + task_description
    })
}



var eta_client = cmrset_aet.getInfo()

// Create an export task for each band.
for (var i = 0; i < eta_client.features.length; i++) {

    // Get the image to export.
    var image = cmrset_aet.filterDate(eta_client.features[i].properties['system:time_start']).first()

    exportBandToDrive(image, 'ETa') // Evapotranspiration (to Google Drive)
    exportBandToDrive(image, 'pixel_qa') // Pixel QA (to Google Drive)

    //exportBandToCloudStorage(image, 'ETa')  // Evapotranspiration (to Cloud Storage)
    //exportBandToCloudStorage(image, 'pixel_qa')  // Pixel QA (to Cloud Storage)

}

// You can now execute the tasks by clicking "RUN" on each task in your Tasks panel.
// Note: Holding the Control (Ctrl) key while clicking "RUN" will launch the job
// automatically, without having to navigate the confirmation dialog window.






