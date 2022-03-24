
// Example 3 - Unpacking the CMRSET QA Band
// This example illustrates how to unpack the CMRSET QA band.  The CMRSET QA band
// contains 4 pieces of extra information for each pixel which may further assist
// with your analysis. These 4 pieces of information are: the source of the data;
// condensation adjustment;the number of Landsat observations used for this pixel;
// and whether the pixel value was derived from Landsat SLC-Off data.

// Execution Time: Real-time
// Storage Required: Nil


// Define the period of interest.
var start = '2004-07-01'

// Access the CMRSET dataset.
var cmrset_aet = ee.ImageCollection("TERN/AET/CMRSET_LANDSAT_V2_2").filterDate(start).first()

// Helper function to unpack the pixel_qa band.
function unpack_pixel_qa(image) {

    var qa = image.select("pixel_qa")

    // Unpack the bits.
    var data_source = qa.bitwiseAnd(3).rename('data_source') // Bits: 0-1
    var condensation = qa.rightShift(2).bitwiseAnd(1).rename('condensation') // Bit: 2
    var landsat_count = qa.rightShift(3).bitwiseAnd(15).rename('landsat_count') // Bits: 3-6
    var slc_off = qa.rightShift(7).rename('slc_off') // Bit: 7

    // Append to the original image.
    return image.addBands(data_source)
        .addBands(condensation)
        .addBands(landsat_count)
        .addBands(slc_off)
}

// Call the helper function to unpack the band.
var result = unpack_pixel_qa(cmrset_aet)

// Visualise the layers on the map.
Map.addLayer(result.select("ETa"), { min: 0, max: 7, palette: ["d7191c", "fdae61", "ffffbf", "abd9e9", "2c7bb6"] }, "ETa")

Map.addLayer(result.select('data_source'), { 'min': 0, 'max': 3, 'palette': 'black,red,orange,green' }, 'Data Source (pixel_qa)');
Map.addLayer(result.select('condensation'), { 'min': 0, 'max': 1, 'palette': 'black,magenta' }, 'Condensation (pixel_qa)');
Map.addLayer(result.select('landsat_count'), { 'min': 0, 'max': 7, 'palette': 'white,blue' }, 'Landsat Count (pixel_qa)');
Map.addLayer(result.select('slc_off'), { 'min': 0, 'max': 1, 'palette': 'black,magenta' }, 'SLC-Off (pixel_qa)');

Map.centerObject(result, 5)







