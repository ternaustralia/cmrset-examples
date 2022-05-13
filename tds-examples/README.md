[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dataset status: down](https://img.shields.io/website-up-down-green-red/http/data.tern.org.au/landscapes/aet/v2_2.svg?label=Dataset%20status)](https://data.tern.org.au/landscapes/aet/v2_2/) 
![Jupyter Notebook](https://img.shields.io/badge/jupyter-%23FA0F00.svg?style=flat&logo=jupyter&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=flat&logo=python&logoColor=ffdd54)

## TERN Data Services Code Examples

These examples allow you to download the CMRSET Actual Evapotranspiration product from the TERN Data Services Catalogue as Cloud-Optimized GeoTIFF's.
To be able to access the data you will first need to generate an API Key so these scripts can authenticate you.

### Generating an API Key

1. Firstly, please visit the TERN Accounts portal at (https://account.tern.org.au) and **Sign In**.
![alt text](./SignIn.png "Sign-In")

2. After singing in, in the **Sign In** dropdown menu, select the **API Keys** item.
![alt text](./API_Keys_Menu.png "API Keys Menu")

3. Click **Create API key** in the left hand menu, and givie your key a **name**.
![alt text](./Create_API_Key.png "Create API Key")

4. After generation the API key, you need to copy the key and store it in a secure place (Note: The API key is only displayed once in the API Key
Information page - and will not be shown or accessible after this - for security reasons)


### Script Parameters

All script languages provided here contain the same set of configuration parameters.

These parameters are:

#### API_KEY
Paste the API Key you generated in the previous steps into this parameter.

#### PRODUCT_CODE
The product code you wish to download. **CMRSET_LANDSAT_V2_2** is the latest and **recommended** version.

#### START
The start date you whish the begin downloading data from (formatted as YYYY-MM-DD)

#### END
The end date you whish to finish downloading data up to (formatted as YYYY-MM-DD)

#### PATH_OUT
The output folder you wish to save the data to.

#### TILES
The list of tile indicies you wish to download.  Indicies are shown in the figure below. i.e. if you are only interested in data for Victoria, you may put 10 and 11 in your list.

![alt text](./CMRSET_Grid_Indicies.png "CMRSET Grid Indicies")


### References

Guerschman, J.P., McVicar, T.R., Vleeshouwer, J., Van Niel, T.G., Peña-Arancibia, J.L. and Chen, Y. (2022) Estimating actual evapotranspiration at field-to-continent scales by calibrating the CMRSET algorithm with MODIS, VIIRS, Landsat and Sentinel-2 data. *Journal of Hydrology. 605, 127318*, <a href="https://doi.org/10.1016/j.jhydrol.2021.127318" target="_blank">https://doi.org/10.1016/j.jhydrol.2021.127318</a>

McVicar, T.R., Vleeshouwer, J., Van Niel, T.G., Guerschman, J.P., Peña-Arancibia, J.L. and Stenson, M.P. (2022) Generating a multi-decade gap-free high-resolution monthly actual evapotranspiration dataset for Australia using Landsat, MODIS and VIIRS data in the Google Earth Engine platform: Development and use cases. *Journal of Hydrology (In Preparation)*.
