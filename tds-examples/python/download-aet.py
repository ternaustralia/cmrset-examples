# Setup variables

API_KEY = "<paste api key here>" # e.g. "bmRSFNPXp5KSF5aiI7OjpUM1s6eiANQmgyKF8NJjRpZFJqSGMlPWlRVQlGKndoUzI4JXhkVSYQka0xqNCohcXhVXDRmWQpCNWVJDU2o0SmtE"
PATH_OUT = "<paste output directory path here>"  # e.g."C:/Downloads/AET"
PRODUCT_CODE = "CMRSET_LANDSAT_V2_2"
START = "2020-01-01"
END = "2020-12-01"
OVERWRITE = False
DRYRUN = False
BANDS = ["ETa", "pixel_qa"]
TILES = list(range(0, 12)) # All tiles
#TILES = [10,11] # Some tiles

# Dataset status (up/down), and important notes for running this script:
# https://github.com/ternaustralia/cmrset-examples/tree/main/tds-examples


########################################################################################


import requests
import logging
import tempfile
import datetime
import os
from dateutil.relativedelta import relativedelta
from operator import itemgetter
import xml.etree.ElementTree as ET
logging.getLogger().setLevel(logging.INFO)

# Lookup for available products.
ProductCodes = {
	"CMRSET_LANDSAT_V2_2": "https://data.tern.org.au/landscapes/aet/v2_2",
	"CMRSET_LANDSAT_V2_1": "https://data.tern.org.au/landscapes/aet/v2_1" # Discontinued
}

# Lookup for tile indicies.
TileLookup = {
	0: "0000000000-0000000000",
	1: "0000000000-0000043776",
	2: "0000000000-0000087552",
	3: "0000000000-0000131328",
	4: "0000043776-0000000000",
	5: "0000043776-0000043776",
	6: "0000043776-0000087552",
	7: "0000043776-0000131328",
	8: "0000087552-0000000000",
	9: "0000087552-0000043776",
	10: "0000087552-0000087552",
	11: "0000087552-0000131328"
}

def get_months(start, end):
	""" Get a monthly array of dates between start and end. """

	date = start
	array = []
	while(date <= end):
	
		array.append(date)
		date = date + relativedelta(months=1)
	
	return array


def get_vrt_relative_paths(product_code, band, dates):
	"""
	Get the relative paths for the VRT files.
	This XML encoded file contains all the file references it will mosaic.
	"""

	hash = {}
	for date in dates:
	
		date_str = date.strftime("%Y_%m_%d")
		hash[date] = "/{year}/{date}/{product_code}_{date}_{band}.vrt".format(year=date.year,date=date_str,product_code=product_code,band=band)
	
	return hash


def get_vrt_sources(file):
	"""	Get all the sources referenced within a VRT file. """

	file.seek(0) # Go to beginning of file.
	xml_doc = file.read()
	nodes = ET.fromstring(xml_doc).findall(".//VRTRasterBand/*/SourceFilename")
	files = sorted(list(map(lambda node: node.text, nodes)))

	return files


def download_file(url, out_file):
	""" Download a file requiring basic auth from a base64 encoded key. """

	logging.info("Downloading: {url}".format(url=url))
	headers = {"X-API-Key": API_KEY}

	is_str = isinstance(out_file, str)
	if is_str:
		os.makedirs(os.path.dirname(out_file), exist_ok=True)
		out_file = open(out_file,"wb")

	response = requests.get(url, headers=headers, stream = True)
	response.raise_for_status()
	for chunk in response.iter_content(chunk_size=1024):
		out_file.write(chunk)

	if is_str: out_file.close()


def download_images(base_url, base_folder, relative_paths, tile_ids):
	""" Downloads the image tiles for the specified paths. """

	logging.info("Processing {count} VRT file(s)...".format(count=len(relative_paths)))
	for relative_path in relative_paths:
	
		date = relative_path
		date_str = date.strftime("%Y_%m_%d")
		vrt_url = "{base_url}{relative_path}".format(base_url=base_url,relative_path=relative_paths[date])

		# Download VRT file that contains references to the files it mosaics.
		try:
			vrt_file = tempfile.TemporaryFile() # We use a system temporary file.
			download_file(vrt_url, vrt_file)
			files = get_vrt_sources(vrt_file)
			filtered_files = list(filter(lambda file: any(tile_id in file for tile_id in tile_ids), files)) # Filter the tiles to those specified.
		except Exception as error:
			logging.error(error)
			continue
		finally:
			vrt_file.close() # Delete the temporary VRT file.

		# Loop through all files and download each one.
		logging.info("Downloading {count} tile(s) for {date_str}...".format(count=len(filtered_files),date_str=date_str))
		for file in filtered_files:

			tile_url = "{base_url}/{year}/{date_str}/{file}".format(base_url=base_url,year=date.year,date_str=date_str,file=file)
			out_file = "{base_folder}/{year}/{date_str}/{file}".format(base_folder=base_folder,year=date.year,date_str=date_str,file=file)

			# Only download files which have not already been downloaded or if forced to.
			if (not os.path.exists(out_file) or OVERWRITE == True):
				if DRYRUN == False:
					try: download_file(tile_url, out_file)
					except Exception as error:
						logging.error(error)
						continue
				else:
					logging.info("Downloading: {tile_url}".format(tile_url=tile_url))
			else:
				logging.info("Skipping already existing tile: {tile_url}".format(tile_url=tile_url))

	
def main():

	# Parse the period of interest.
	startDate = datetime.date.fromisoformat(START)
	endDate = datetime.date.fromisoformat(END)
	logging.info("Start: {start}".format(start=startDate))
	logging.info("End: {end}".format(end=endDate))

	# Generate the list of dates to download.
	dates = get_months(startDate, endDate)
	logging.info("Processing data for the following dates:")
	for date in dates: logging.info(date.strftime("%b %Y"))

	def download_band(band, dates):
			
		# Get the relative paths for each the VRT files for each date.
		vrt_relative_paths = get_vrt_relative_paths(PRODUCT_CODE, band, dates)
		logging.info("Generated {count} VRT path(s) to download for {band}...".format(count=len(vrt_relative_paths),band=band))

		# Download all the tiles referenced in each VRT file.
		download_images(ProductCodes[PRODUCT_CODE], "{path_out}/{product_code}".format(path_out=PATH_OUT,product_code=PRODUCT_CODE), vrt_relative_paths, itemgetter(*TILES)(TileLookup))
	
	for band in BANDS: download_band(band, dates)
	logging.info("Processing complete")


# Run the script
if __name__=="__main__":
	main()
