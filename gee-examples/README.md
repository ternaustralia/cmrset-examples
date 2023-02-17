[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dataset status: down](https://img.shields.io/website-up-down-green-red/http/developers.google.com/earth-engine/datasets/catalog/TERN_AET_CMRSET_LANDSAT_V2_2.svg?label=Dataset%20status)](https://developers.google.com/earth-engine/datasets/catalog/TERN_AET_CMRSET_LANDSAT_V2_2) 
![Jupyter Notebook](https://img.shields.io/badge/jupyter-%23FA0F00.svg?style=flat&logo=jupyter&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=flat&logo=python&logoColor=ffdd54)
![JavaScript](https://img.shields.io/badge/javascript-%23323330.svg?style=flat&logo=javascript&logoColor=%23F7DF1E)
[![GitHub issues](https://img.shields.io/github/issues/ternaustralia/cmrset-examples)](https://github.com/ternaustralia/cmrset-examples/issues)
![Libraries.io dependency status for GitHub repo](https://img.shields.io/librariesio/github/ternaustralia/cmrset-examples)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/ternaustralia/cmrset-examples/Trigger%20Binder%20build)
![Snyk Vulnerabilities for GitHub Repo](https://img.shields.io/snyk/vulnerabilities/github/ternaustralia/cmrset-examples)

## Google Earth Engine Code Examples

These code examples demonstrate how you can access the <a href="https://developers.google.com/earth-engine/datasets/catalog/TERN_AET_CMRSET_LANDSAT_V2_2" target="_blank">CMRSET Landsat</a> actual evapotranspiration data product via the <a href="https://earthengine.google.com/" target="_blank">Google Earth Engine</a> catalog.

The code examples are implemented in *both* of the <a href="https://github.com/google/earthengine-api" target="_blank">Earth Engine API</a> languages available:
1. **Python** - can be run in the cloud via <a href="https://colab.research.google.com/?utm_source=scs-index" target="_blank">Google Colab</a> (in the form of <a href="https://jupyter.org/" target="_blank">Jupyter Notebooks</a>)
2. **JavaScript** - can be run in the cloud via the <a href="https://developers.google.com/earth-engine/guides/playground" target="_blank">Earth Engine Code Editor</a>

The JavaScript implementation is arguably simpler for GEE beginners (everything at your fingertips in the Earth Engine Code Editor), however in the examples provided there's more documentation within the Python notebooks (because you can with notebooks!, includes jokes too!!). Both implementations of the Earth Engine API are near identical... hence so are the code examples... perhaps cross-reference them both, but choose your flavour? 

To run these examples it is assumed you have <a href="https://signup.earthengine.google.com/#!/" target="_blank">registered</a> to Google Earth Engine. Please feel free to adapt these examples to meet your own requirements.

### Example 1 - CMRSET Long-Term Average ET (Temporal Aggregation)

<img src="./GEE-Example1.png" alt="Example 1 - CMRSET Long-Term Average ET (Temporal Aggregation)" width="600"/>

[![Python](https://img.shields.io/badge/python-3670A0?style=flat&logo=python&logoColor=ffdd54&label=try%20in%20)](https://colab.research.google.com/github/ternaustralia/cmrset-examples/blob/main/gee-examples/python/Example_1_CMRSET_Long_Term_Average_ET_(Temporal_Aggregation).ipynb)
[![JavaScript](https://img.shields.io/badge/javascript-%23323330.svg?style=flat&logo=javascript&logoColor=%23F7DF1E&label=try%20in%20)](https://code.earthengine.google.com/?scriptPath=users%2Fjamievleeshouwer%2FTERN%3AExamples%2FExample%201%20-%20CMRSET%20Long-Term%20Average%20ET%20(Temporal%20Aggregation))

This example illustrates how to access the CMRSET Landsat V2.2 data product via Earth Engine and compute the long-term average evapotranspiration for a section of the Lachlan River. Finally the result is exported to <a href="https://www.google.com/drive/" target="_blank">Google Drive</a> as a <a href="https://www.cogeo.org/" target="_blank">Cloud-Optimised GeoTIFF</a>.

**Execution Time:** ~20 minutes  
**Storage Required:** 55 MB (on Google Drive)

---

### Example 2 - Aggregating CMRSET for a set of Features (Spatial Aggregation)

<img src="./GEE-Example2.png" alt="Example 2 - Aggregating CMRSET for a set of Features (Spatial Aggregation)" width="600"/>

[![Python](https://img.shields.io/badge/python-3670A0?style=flat&logo=python&logoColor=ffdd54&label=try%20in%20)](https://colab.research.google.com/github/ternaustralia/cmrset-examples/blob/main/gee-examples/python/Example_2_Aggregating_CMRSET_for_a_set_of_Features_(Spatial_Aggregation).ipynb)
[![JavaScript](https://img.shields.io/badge/javascript-%23323330.svg?style=flat&logo=javascript&logoColor=%23F7DF1E&label=try%20in%20)](https://code.earthengine.google.com/?scriptPath=users%2Fjamievleeshouwer%2FTERN%3AExamples%2FExample%202%20-%20Aggregating%20CMRSET%20for%20a%20set%20of%20Features%20(Spatial%20Aggregation))

This example illustrates how to compute the average evapotranspiration for a set of features (such as a multi-polygon/multi-point set). In this example we will use the Australian World Herritage Sites (which cover land) as our feature set. The monthly timeseries for each feature is then exported as a CSV to <a href="https://www.google.com/drive/" target="_blank">Google Drive</a>.

**Execution Time:** ~8 minutes  
**Storage Required:** 16 kB (on Google Drive)

---

### Example 3 - Unpacking the CMRSET QA Band

<img src="./GEE-Example3.png" alt="Example 3 - Unpacking the CMRSET QA Band" width="600"/>

[![Python](https://img.shields.io/badge/python-3670A0?style=flat&logo=python&logoColor=ffdd54&label=try%20in%20)](https://colab.research.google.com/github/ternaustralia/cmrset-examples/blob/main/gee-examples/python/Example_3_Unpacking_the_CMRSET_QA_Band.ipynb)
[![JavaScript](https://img.shields.io/badge/javascript-%23323330.svg?style=flat&logo=javascript&logoColor=%23F7DF1E&label=try%20in%20)](https://code.earthengine.google.com/?scriptPath=users%2Fjamievleeshouwer%2FTERN%3AExamples%2FExample%203%20-%20Unpacking%20the%20CMRSET%20QA%20Band)

This example illustrates how to unpack the <a href="https://developers.google.com/earth-engine/datasets/catalog/TERN_AET_CMRSET_LANDSAT_V2_2#bands" target="_blank">CMRSET QA band</a>. The CMRSET QA band contains 4 pieces of extra information for each pixel which may further assist with your analysis. These 4 pieces of information are: the source of the data; condensation adjustment; the number of Landsat observations used for this pixel; and whether the pixel value was derived from Landsat SLC-Off data.

**Execution Time:** Real-time  
**Storage Required:** Nil

---

### Example 4 - Exporting the Image Stack for a Region

<img src="./GEE-Example4.png" alt="Example 4 - Exporting the Image Stack for a Region" width="600"/>

[![Python](https://img.shields.io/badge/python-3670A0?style=flat&logo=python&logoColor=ffdd54&label=try%20in%20)](https://colab.research.google.com/github/ternaustralia/cmrset-examples/blob/main/gee-examples/python/Example_4_Exporting_the_Image_Stack_for_a_Region.ipynb)
[![JavaScript](https://img.shields.io/badge/javascript-%23323330.svg?style=flat&logo=javascript&logoColor=%23F7DF1E&label=try%20in%20)](https://code.earthengine.google.com/?scriptPath=users%2Fjamievleeshouwer%2FTERN%3AExamples%2FExample%204%20-%20Exporting%20the%20Image%20Stack%20for%20a%20Region)

This example illustrates how to export the CMRSET Landsat V2.2 imagery via Earth Engine for a study area in the Pilbara. Both ETa and QA bands are exported. We will also illustrate changing the <a href="https://developers.google.com/earth-engine/guides/projections" target="_blank">projection</a> of the exported images to <a href="https://epsg.io/4283" target="_blank">GDA94</a> (EPSG:4283). This example can potentially generate gigabytes of data, so we demonstrate two different methods for exporting the data to suit your own storage capabilities. These methods are:

1. **Via Google Drive** - This method is the simplest, however you may not be prepared to pay for a monthly subscription to upgrade your Google Drive storage limits if your export exceeds the free storage tier (15 GB).

2. **Via Google Cloud Storage** - This method can incur a once-off fee (rather than a subscription) for the egress costs associated with downloading the imagery from Google Cloud Storage. This method is recommended when method 1) is not appropriate for your circumstances.

**Execution Time:** ~3 minutes  
**Storage Required:** 172 MB (on Google Drive or Google Cloud Storage)

---

### References

Guerschman, J.P., McVicar, T.R., Vleeshouwer, J., Van Niel, T.G., Peña-Arancibia, J.L. and Chen, Y. (2022) Estimating actual evapotranspiration at field-to-continent scales by calibrating the CMRSET algorithm with MODIS, VIIRS, Landsat and Sentinel-2 data. *Journal of Hydrology. 605, 127318*, <a href="https://doi.org/10.1016/j.jhydrol.2021.127318" target="_blank">https://doi.org/10.1016/j.jhydrol.2021.127318</a>

McVicar, T.R., Vleeshouwer, J., Van Niel, T.G., Guerschman, J.P., Peña-Arancibia, J.L. and Stenson, M.P. (2022) Generating a multi-decade gap-free high-resolution monthly actual evapotranspiration dataset for Australia using Landsat, MODIS and VIIRS data in the Google Earth Engine platform: Development and use cases. *Journal of Hydrology (In Preparation)*.

Gorelick, N., Hancher, M., Dixon, M., Ilyushchenko, S., Thau, D., Moore, R. (2017) Google Earth Engine: Planetary-scale geospatial analysis for everyone. *Remote Sensing of Environment, 202, Pages 18-27*,  <a href="https://doi.org/10.1016/j.rse.2017.06.031" target="_blank">https://doi.org/10.1016/j.rse.2017.06.031</a>
