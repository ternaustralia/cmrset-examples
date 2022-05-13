# Setup variables

API_KEY = "<paste api key here>" # e.g. "bmRSFNPXp5KSF5aiI7OjpUM1s6eiANQmgyKF8NJjRpZFJqSGMlPWlRVQlGKndoUzI4JXhkVSYQka0xqNCohcXhVXDRmWQpCNWVJDU2o0SmtE"
PATH_OUT = "<paste output directory path here>"  # e.g."C:/Downloads/AET"
PRODUCT_CODE = "CMRSET_LANDSAT_V2_2"
START = "2016-01-01"
END = "2016-12-01"
OVERWRITE = False
DRYRUN = False
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
	This XML encoded file has all the metadata of the image tiles in that directory.
	"""

	hash = {}
	for date in dates:
	
		date_str = date.strftime("%Y_%m_%d")
		hash[date] = "/{year}/{date}/{product_code}_{date}_{band}.vrt".format(year=date.year,date=date_str,product_code=product_code,band=band)
	
	return hash



def download_file(url, output):
	""" Download a file requiring basic auth from a base64 encoded key. """

	try:
		logging.info("Downloading: {url}".format(url=url))
		headers = {"X-API-Key": API_KEY}

		if isinstance(output, str):
			os.makedirs(os.path.dirname(output), exist_ok=True)
			file = open(output,"wb")
		else:
		   file = output

		response = requests.get(url, headers=headers, stream = True)
		if (response.ok):
			for chunk in response.iter_content(chunk_size=1024):
				file.write(chunk)
		else:
			logging.info("Error downloading file: {status_code} {reason}".format(status_code=response.status_code,reason=response.reason))

	
	except Exception as e:
		logging.info("Error downloading file: {error}".format(error=e))

	finally:
		return file


def download_images(base_url, base_folder, relative_paths, tile_ids):
	""" Downloads the image tiles for the specified paths. """

	logging.info("Processing {count} VRT file(s)...".format(count=len(relative_paths)))
	for relative_path in relative_paths:
	
		date = relative_path
		date_str = date.strftime("%Y_%m_%d")

		# Download VRT file that contains references to the files it mosaics together.
		# We use a system temporary file.
		url = "{base_url}{relative_path}".format(base_url=base_url,relative_path=relative_paths[date])
		tmp = tempfile.TemporaryFile()
		file_vrt = download_file(url, tmp)

		# Load the XML file and select all the source files.
		if file_vrt.tell() == 0: file_vrt.close() # If no data returned in VRT, then abort.
		try:
			file_vrt.seek(0) # Go to beginning of file.
			xd = tmp.read()
			nodes = ET.fromstring(xd).findall(".//VRTRasterBand/ComplexSource/SourceFilename")
			files = sorted(list(map(lambda node: node.text, nodes)))
		except Exception as e:
			logging.info("Error reading file: {error}".format(error=e))
			file_vrt.close()
			continue

		# Filter the tiles to those specified.
		filtered_files = []
		for file in files:
			for tile_id in tile_ids:
				if tile_id in file and file not in filtered_files:
					filtered_files.append(file)

		

		# Loop through all files and download each one.
		logging.info("Downloading {count} tile(s) for {date_str}...".format(count=len(nodes),date_str=date_str))
		for file in filtered_files:

			tile_url = "{base_url}/{year}/{date_str}/{file}".format(base_url=base_url,year=date.year,date_str=date_str,file=file)
			out_file = "{base_folder}/{year}/{date_str}/{file}".format(base_folder=base_folder,year=date.year,date_str=date_str,file=file)

			# Only download files which have not already been downloaded or if forced to.
			if (not os.path.exists(out_file) or OVERWRITE == True) and DRYRUN == False:
				file_cog = download_file(tile_url, out_file)
				file_cog.close()
			else:
				logging.info("Skipping already existing tile: {tile_url}".format(tile_url=tile_url))

		# Delete the temporary VRT file.
		file_vrt.close()

	

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
	
	# Get the relative paths for each the VRT files for each date.
	vrt_relative_paths = get_vrt_relative_paths(PRODUCT_CODE, "ETa", dates)
	logging.info("Generated {count} VRT path(s) to download...".format(count=len(vrt_relative_paths)))

	# Download all the tiles referenced in each VRT file.
	download_images(ProductCodes[PRODUCT_CODE], "{path_out}/{product_code}".format(path_out=PATH_OUT,product_code=PRODUCT_CODE), vrt_relative_paths, itemgetter(*TILES)(TileLookup))
	logging.info("Processing complete")

if __name__=="__main__":
	main()
