[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dataset status: down](https://img.shields.io/website-up-down-green-red/http/developers.google.com/earth-engine/datasets/catalog/TERN_AET_CMRSET_LANDSAT_V2_2.svg?label=Dataset%20status)](https://developers.google.com/earth-engine/datasets/catalog/TERN_AET_CMRSET_LANDSAT_V2_2) 
![Jupyter Notebook](https://img.shields.io/badge/jupyter-%23FA0F00.svg?style=flat&logo=jupyter&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=flat&logo=python&logoColor=ffdd54)

## Google Earth Engine Python Examples

These code examples demonstrate how you can access the <a href="https://developers.google.com/earth-engine/datasets/catalog/TERN_AET_CMRSET_LANDSAT_V2_2" target="_blank">CMRSET Landsat</a> actual evapotranspiration data product via the <a href="https://earthengine.google.com/" target="_blank">Google Earth Engine</a> catalog. To run these examples it is assumed you have  <a href="https://signup.earthengine.google.com/#!/" target="_blank">registered</a> to Google Earth Engine. Please feel free to adapt these examples to meet your own requirements.

You can run these examples in your browser via  <a href="https://colab.research.google.com/?utm_source=scs-index" target="_blank">Google Colab</a> using the direct links below. After opening a link, click **Runtime > Run all** from the menu to execute the example.

1. <a href="https://colab.research.google.com/github/ternaustralia/cmrset-examples/blob/main/gee-examples/python/Example_1_CMRSET_Long_Term_Average_ET_(Temporal_Aggregation).ipynb" target="_blank">Example 1 - CMRSET Long-Term Average ET (Temporal Aggregation)</a>
2. <a href="https://colab.research.google.com/github/ternaustralia/cmrset-examples/blob/main/gee-examples/python/Example_2_Aggregating_CMRSET_for_a_set_of_Features_(Spatial_Aggregation).ipynb" target="_blank">Example 2 - Aggregating CMRSET for a set of Features (Spatial Aggregation)</a>
3. <a href="https://colab.research.google.com/github/ternaustralia/cmrset-examples/blob/main/gee-examples/python/Example_3_Unpacking_the_CMRSET_QA_Band.ipynb" target="_blank">Example 3 - Unpacking the CMRSET QA Band</a>
4. <a href="https://colab.research.google.com/github/ternaustralia/cmrset-examples/blob/main/gee-examples/python/Example_4_Exporting_the_Image_Stack_for_a_Region.ipynb" target="_blank">Example 4 - Exporting the Image Stack for a Region</a>

If you would like to obtain these notebook examples as a *pure* python script... After clicking the links above, click **File > Download > Download .py** within Google Colab.

### Additional Notebooks

In addition to the CMRSET specific notebooks provided in this repository, you may also find the following notebook resources useful. These notebooks are ***not*** specific to the CMRSET Landsat data product, however they may assist you with any customisations you may wish to implement.

1.	**Google Earth Engine with Python (EEwPython)** - a free open source notebook course on learning GEE:  
https://colab.research.google.com/github/csaybar/EEwPython/blob/master/index.ipynb

2.	**Qiusheng Wu’s Repository** of over 360 GEE notebooks:  
https://github.com/giswqs/earthengine-py-notebooks

### Supplementary Material

Also, here are some links to additional content which we think you might find useful:

1. **Awesome Earth Engine** - A curated list of Google Earth Engine resources:  
https://github.com/giswqs/Awesome-GEE

2. **End-to-End Google Earth Engine (Full Course Material)** - Spatial Thoughts course:  
https://courses.spatialthoughts.com/end-to-end-gee.html

3. **Google Earth Engine for Water Resources Management (Full Course Material)** - Spatial Thoughts course:  
https://courses.spatialthoughts.com/gee-water-resources-management.html

4. **Earth Engine User Summits and Earth Outreach** video lectures:  
https://developers.google.com/earth-engine/tutorials/videos

5. **Earth Engine Community Tutorials**:  
https://developers.google.com/earth-engine/tutorials/community/explore

### References

Guerschman, J.P., McVicar, T.R., Vleeshouwer, J., Van Niel, T.G., Peña-Arancibia, J.L. and Chen, Y. (2022) Estimating actual evapotranspiration at field-to-continent scales by calibrating the CMRSET algorithm with MODIS, VIIRS, Landsat and Sentinel-2 data. *Journal of Hydrology. 605, 127318*, <a href="https://doi.org/10.1016/j.jhydrol.2021.127318" target="_blank">https://doi.org/10.1016/j.jhydrol.2021.127318</a>

McVicar, T.R., Vleeshouwer, J., Van Niel, T.G., Guerschman, J.P., Peña-Arancibia, J.L. and Stenson, M.P. (2022) Generating a multi-decade gap-free high-resolution monthly actual evapotranspiration dataset for Australia using Landsat, MODIS and VIIRS data in the Google Earth Engine platform: Development and use cases. *Journal of Hydrology (In Preparation)*.

Gorelick, N., Hancher, M., Dixon, M., Ilyushchenko, S., Thau, D., Moore, R. (2017) Google Earth Engine: Planetary-scale geospatial analysis for everyone. *Remote Sensing of Environment, 202, Pages 18-27*,  <a href="https://doi.org/10.1016/j.rse.2017.06.031" target="_blank">https://doi.org/10.1016/j.rse.2017.06.031</a>

