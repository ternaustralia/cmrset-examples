[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Jupyter Notebook](https://img.shields.io/badge/jupyter-%23FA0F00.svg?style=flat&logo=jupyter&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=flat&logo=python&logoColor=ffdd54)
![JavaScript](https://img.shields.io/badge/javascript-%23323330.svg?style=flat&logo=javascript&logoColor=%23F7DF1E)
![PowerShell](https://img.shields.io/badge/-PowerShell-blue)
![GitHub issues](https://img.shields.io/github/issues/ternaustralia/cmrset-examples)
![Libraries.io dependency status for GitHub repo](https://img.shields.io/librariesio/github/ternaustralia/cmrset-examples)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/ternaustralia/cmrset-examples/Create%20and%20Publish%20download-aet%20Docker%20Image)
![Docker Build](https://img.shields.io/badge/docker%20build-automated-blue)
[![hits](https://hits.deltapapa.io/github/ternaustralia/cmrset-examples.svg)](https://github.com/jamievleeshouwer/cmrset-examples)

## CMRSET Code Examples

The CMRSET Landsat V2.2 data product provides accurate, high-resolution (30 m) / high-frequency (monthly) / continuous (no gaps due to cloud) actual evapotranspiration (AET) for Australia using the CMRSET algorithm.

This repository provides code examples of how you can access the data. The product has been made available to users via two methods:
1. TERN Data Services (TDS) - **tds-examples/wps-examples**  
   The <a href="https://portal.tern.org.au/actual-evapotranspiration-australia-cmrset-algorithm/21915" target="_blank">data on TDS</a> is provided as <a href="https://www.cogeo.org/" target="_blank">Cloud-Optimized GeoTIFF's</a> which can be downloaded over the web.
   Each monthly image (~20 GB) has been divided into 12 smaller tiles (4x3, and less than 4 GB each) in order to make downloading simpler (i.e if your study site fits within one tile you can just download that particular tile). 
   A <a href="https://gdal.org/drivers/raster/vrt.html" target="_blank">VRT</a> file (virtual dataset) has also been provided for each month which will mosaic the 12 tiles into a complete image of Australia.  
    [![Dataset status: down](https://img.shields.io/website-up-down-green-red/http/data.tern.org.au/landscapes/aet/v2_2.svg?label=Dataset%20status)](https://data.tern.org.au/landscapes/aet/v2_2/) 

2. Google Earth Engine (GEE) - **gee-examples**  
   The <a href="https://developers.google.com/earth-engine/datasets/catalog/TERN_AET_CMRSET_LANDSAT_V2_2" target="_blank">data on GEE</a> is provided as an <a href="https://developers.google.com/earth-engine/guides/ic_creating" target="_blank">Image Collection</a>, whereby each monthly asset within the collection represents the whole of Australia. 
   Using GEE, your analysis can benefit by the easy integration of the vast number of other datasets available within the <a href="https://developers.google.com/earth-engine/datasets" target="_blank">Earth Engine catalog</a>. 
   Similarly, you may also export data from GEE as <a href="https://www.cogeo.org/" target="_blank">Cloud-Optimized GeoTIFF's</a> (to Goole Drive or Google Cloud Storage).  
    [![Dataset status: down](https://img.shields.io/website-up-down-green-red/http/developers.google.com/earth-engine/datasets/catalog/TERN_AET_CMRSET_LANDSAT_V2_2.svg?label=Dataset%20status)](https://developers.google.com/earth-engine/datasets/catalog/TERN_AET_CMRSET_LANDSAT_V2_2) 

### Additional data access options

If your use case for accessing CMRSET data, happens to be the *really simple* kind... you may also be interested in the <a href="https://tern-landscapes.earthengine.app/view/cmrset-landsat-v22" target="_blank">AET Explorer</a>. 
This tool allows you to draw points/polygons/transects on a map in your web browser to extract CSV data... You can choose your favourite units as well!

![alt text](./AET_Explorer.png "AET Explorer")

### References

Guerschman, J.P., McVicar, T.R., Vleeshouwer, J., Van Niel, T.G., Peña-Arancibia, J.L. and Chen, Y. (2022) Estimating actual evapotranspiration at field-to-continent scales by calibrating the CMRSET algorithm with MODIS, VIIRS, Landsat and Sentinel-2 data. *Journal of Hydrology. 605, 127318*, <a href="https://doi.org/10.1016/j.jhydrol.2021.127318" target="_blank">https://doi.org/10.1016/j.jhydrol.2021.127318</a>

McVicar, T.R., Vleeshouwer, J., Van Niel, T.G., Guerschman, J.P., Peña-Arancibia, J.L. and Stenson, M.P. (2022) Generating a multi-decade gap-free high-resolution monthly actual evapotranspiration dataset for Australia using Landsat, MODIS and VIIRS data in the Google Earth Engine platform: Development and use cases. *Journal of Hydrology (In Preparation)*.

Gorelick, N., Hancher, M., Dixon, M., Ilyushchenko, S., Thau, D., Moore, R. (2017) Google Earth Engine: Planetary-scale geospatial analysis for everyone. *Remote Sensing of Environment, 202, Pages 18-27*,  <a href="https://doi.org/10.1016/j.rse.2017.06.031" target="_blank">https://doi.org/10.1016/j.rse.2017.06.031</a>
