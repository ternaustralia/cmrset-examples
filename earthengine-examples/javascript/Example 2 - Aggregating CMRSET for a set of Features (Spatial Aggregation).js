
// Example 2 - Aggregating CMRSET for a set of Features (Spatial Aggregation)
// This example illustrates how to compute the average evapotranspiration
// for a set of features (such as a multi-polygon/multi-point set). In this example we 
// will use the Australian World Herritage Sites (which cover land) as our feature set.
// The monthly timeseries for each feature is then exported as a CSV to Google Drive.

// Execution Time: ~8 minutes
// Storage Required: 16 kB (on Google Drive)

// Define the regions of interest.
var regions = ee.FeatureCollection("WCMC/WDPA/current/polygons")
    .filterMetadata('DESIG', 'equals', 'World Heritage Site (natural or mixed)')
    .filterMetadata('ISO3', 'equals', 'AUS') // Only Australian sites
    .filterMetadata('MARINE', 'equals', '0') // Only land sites

// Visualize the regions of interest.
Map.addLayer(regions, { 'color': 'green' }, 'Study Sites')
Map.centerObject(regions)

// Define the period of interest.
var start = '2012-02-01'
var end = '2021-03-01'

// Access evapotranspiration from the CMRSET dataset.
var cmrset_aet = ee.ImageCollection("TERN/AET/CMRSET_LANDSAT_V2_2").filterDate(start, end).select(['ETa'])

// A helper function to assist with aggregating the features.
function reduceFeaturesForImage(image) {

    // Calculate average evapotranspiration for each feature in the set.
    var mean_aet = image.reduceRegions({
        'collection': regions,
        'reducer': ee.Reducer.mean(),
        'scale': 30
    })

    // Transfer the image date across to each feature as a new attribute.
    var date = image.date().format('yyyy-MM-dd')
    return mean_aet.map(function (feature) { return feature.set('Date', date) })

}

// For each image, compute the aggregate for each feature.
var reduced_aet = cmrset_aet.map(reduceFeaturesForImage).flatten()

// Print the properties for the first feature.
var properties = reduced_aet.first().toDictionary()
print('First image properties:', properties)

// Define the export settings.
var export_folder = 'CMRSET_Exports'
var task_description = 'CMRSET_' + start + '_' + end + '_Monthly'

// Export the table, specifying the columns to be included.
Export.table.toDrive({
    'collection': reduced_aet.sort('NAME'), // Sort the records by NAME property.
    'selectors': ['NAME', 'Date', 'mean'],  // Select these properties to be exported.
    'description': task_description,
    'folder': export_folder
})


// Now click the Tasks tab (located top-right) to run your task.
// Once complete you can access the data from your Google Drive (https://drive.google.com)
