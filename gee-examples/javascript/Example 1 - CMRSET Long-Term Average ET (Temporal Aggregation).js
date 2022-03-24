
// Example 1 - CMRSET Long-Term Average ET
// This example illustrates how to access the CMRSET Landsat V2.2 data product
// via Earth Engine and compute the long-term average evapotranspiration for a
// section of the Lachlan River. Finally the result is exported to Google Drive
// as a Cloud-Optimised GeoTIFF.

// Execution Time: ~20 minutes
// Storage Required: 55 MB (on Google Drive)

// Define a region of interest.
var region = ee.Geometry.Rectangle([145.0, -34.0, 146.0, -33.0])

// Define the period of interest.
var start = '2000-02-01'
var end = '2021-03-01'

// Define the export settings.
var scale = 30
var export_folder = 'CMRSET_Exports'
var task_description = 'CMRSET_' + start + '_' + end + '_' + scale + 'm'

// Access evapotranspiration from the CMRSET dataset.
var cmrset_aet = ee.ImageCollection("TERN/AET/CMRSET_LANDSAT_V2_2").filterDate(start, end).select(['ETa'])

// Calculate long-term average map over specified time period.
var mean_aet = cmrset_aet.mean().toFloat()

// Display a thumbnail of the CMRSET long-term average.
var thumbnail = ui.Thumbnail(mean_aet,
    {
        'min': 0,
        'max': 7,
        'region': region,
        'dimensions': 512,
        'palette': ["d7191c", "fdae61", "ffffbf", "abd9e9", "2c7bb6"]
    })
print('Preview:', thumbnail)

// Export the image, specifying the region and scale.
Export.image.toDrive({
    'image': mean_aet,
    'region': region,
    'scale': scale,
    'description': task_description,
    'folder': export_folder,
})

// Now click the Tasks tab (located top-right) to run your task.
// Once complete you can access the data from your Google Drive (https://drive.google.com)
