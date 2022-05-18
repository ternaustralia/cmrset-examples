[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dataset status: down](https://img.shields.io/website-up-down-green-red/http/data.tern.org.au/landscapes/aet/v2_2.svg?label=Dataset%20status)](https://data.tern.org.au/landscapes/aet/v2_2/) 
![Jupyter Notebook](https://img.shields.io/badge/jupyter-%23FA0F00.svg?style=flat&logo=jupyter&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=flat&logo=python&logoColor=ffdd54)

# Important Notes

## Running the script locally

To execute this script you will need to ensure you have the following 2 python packages installed:


### 1. Requests

https://docs.python-requests.org/en/latest/

To install the *requests* package run the following command:
```
pip install requests
```


### 2. dateutil

https://dateutil.readthedocs.io/en/stable/

To install the *dateutil* package run the following command:
```
pip install python-dateutil
```

Note: A requirements.txt file is also provided to assist with installation of these python packages.

## Running using Docker


### Building the Container

To build the docker container please ensure [Docker Desktop](https://www.docker.com/products/docker-desktop) is installed if using Windows or MacOS.  Linux users can install docker by issuing the following commands:

```shell
sudo apt-get install docker-engine -y
sudo service docker start
```

To build the docker container you can then issue the following command:

```shell
docker build -t tern/download_aet:v2 .
```

### Pulling the Container from GitHub Packages

The latest version of this container is also published in the docker registry on GitHub Packages. To pull this docker container locally you can issue the following command:

```shell
docker pull ghcr.io/ternaustralia/cmrset-examples:main
```

### Running the Container

To run the container you can then issue commands similar to the following (refer to available parameters in the parent readme):

```shell
docker run --rm ^
	-v C:/Downloads/AET/:/usr/data/ ^
	-e PATH_OUT=/usr/data/ ^
	-e TERN_API_KEY=your-api-key ^
	-e START=2016-01-01 ^
	-e END=2016-02-01 ^
	-e TILES=10,11 ^
	ghcr.io/ternaustralia/cmrset-examples/download-aet:main ^
```

### References

Guerschman, J.P., McVicar, T.R., Vleeshouwer, J., Van Niel, T.G., Peña-Arancibia, J.L. and Chen, Y. (2022) Estimating actual evapotranspiration at field-to-continent scales by calibrating the CMRSET algorithm with MODIS, VIIRS, Landsat and Sentinel-2 data. *Journal of Hydrology. 605, 127318*, <a href="https://doi.org/10.1016/j.jhydrol.2021.127318" target="_blank">https://doi.org/10.1016/j.jhydrol.2021.127318</a>

McVicar, T.R., Vleeshouwer, J., Van Niel, T.G., Guerschman, J.P., Peña-Arancibia, J.L. and Stenson, M.P. (2022) Generating a multi-decade gap-free high-resolution monthly actual evapotranspiration dataset for Australia using Landsat, MODIS and VIIRS data in the Google Earth Engine platform: Development and use cases. *Journal of Hydrology (In Preparation)*.
