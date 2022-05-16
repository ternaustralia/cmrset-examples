# Script Parameters

API_KEY = "your-api-key" # e.g. "bmRSFNPXp5KSF5aiI7OjpUM1s6eiANQmgyKF8NJjRpZFJqSGMlPWlRVQlGKndoUzI4JXhkVSYQka0xqNCohcXhVXDRmWQpCNWVJDU2o0SmtE"
PATH_OUT = "your-output-path"  # e.g."C:/Downloads/AET"
UPDATE_METHOD = "UPDATE_MISSING"
PRODUCT_CODE = "CMRSET_LANDSAT_V2_2"
START = "2020-01-01"
END = "2020-12-01"
BANDS = ["ETa", "pixel_qa"]
TILES = list(range(0, 12)) # All tiles
#TILES = [10,11] # Some tiles
DRYRUN = False

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
from enum import Enum, auto
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

# A session which contains common settings which will be used for all web requests made.
Session = requests.Session()
Session.headers.update({"X-API-Key": API_KEY})


class UpdateMethod(Enum):
	""" An enum for the various processing methods. """
	UPDATE_MISSING = auto()
	UPDATE_NEW = auto()
	UPDATE_ALL = auto()


def get_months(start, end):
	""" Get a monthly array of dates between start and end. """

	# Ensure dates are 1st of the month.
	start = start.replace(day=1)
	end = end.replace(day=1)

	date = start
	array = []
	while(date <= end):
	
		array.append(date)
		date = date + relativedelta(months=1)
	
	return array


def get_vrt_relative_paths(product_code, dates, bands):
	""" Get the relative paths for the VRT files based upon product, band, and the date range. """

	date_hash = {}
	for date in dates:

		date_hash[date] = {}
		for band in bands:
	
			date_str = date.strftime("%Y_%m_%d")
			date_hash[date][band] = "/{year}/{date}/{product_code}_{date}_{band}.vrt".format(year=date.year,date=date_str,product_code=product_code,band=band)
	
	return date_hash


def get_vrt_sources(file):
	"""	Get all the sources referenced within a VRT file. """

	file.seek(0) # Go to beginning of file.
	xml_doc = file.read()
	nodes = ET.fromstring(xml_doc).findall(".//VRTRasterBand/*/SourceFilename") # Use wildcard for different source types.
	files = sorted(list(map(lambda node: node.text, nodes)))                    # Sort the node values after searching the nodes.

	return files


def download_file(url, out_file, dryrun=False):
	""" Download a file requiring X-API-Key auth from a base64 encoded key. """

	logging.info("Downloading: {url}".format(url=url))
	if dryrun == False:
		response = Session.get(url, stream = True)	# Session accessed from global scope.
		response.raise_for_status()					# Trigger exception for unacceptable status codes.

		is_str = isinstance(out_file, str)
		if is_str:
			os.makedirs(os.path.dirname(out_file), exist_ok=True)
			out_file = open(out_file,"wb")

		# Read large files in chunks.
		for chunk in response.iter_content(chunk_size=1024 * 1024 * 10): # 10 MB chunks.
			out_file.write(chunk)

		if is_str: out_file.close()

		return response


def confirm_download(url, out_file, update_method):
	def update_missing():
		result = not os.path.exists(out_file)
		if not result: logging.info("Skipping already existing tile: {tile_url}".format(tile_url=url))
		return result
	def undate_new():
		pass
	def update_all():
		return True

	options = {
		UpdateMethod.UPDATE_MISSING : update_missing(),
		UpdateMethod.UPDATE_NEW : undate_new(),
		UpdateMethod.UPDATE_ALL : update_all(),
	}

	return options[update_method]


def download_images(base_url, base_folder, relative_paths, tile_ids=list(range(0, 12)), update_method=UpdateMethod.UPDATE_MISSING, dryrun=False):
	""" Downloads the image tiles for the specified paths. """

	for date in relative_paths:
		logging.info("Processing {count} band(s) for {date}...".format(count=len(relative_paths[date]),date=date))
		for band in relative_paths[date]:
			logging.info("Processing {band} for {date}...".format(band=band,date=date))
	
			# Download VRT file that contains references to the files it mosaics.
			try:
				vrt_url = "{base_url}{relative_path}".format(base_url=base_url,relative_path=relative_paths[date][band])
				vrt_file = tempfile.TemporaryFile() # Create temporary file for VRT.
				download_file(vrt_url, vrt_file)    # Download VRT contents to the temporary file.
				files = get_vrt_sources(vrt_file)   # Read the source files referenced within the VRT.
			except Exception as error:
				logging.error(error)
				continue
			finally:
				vrt_file.close()                    # Delete the temporary file.

			# Filter the tiles to those specified.
			filtered_files = list(filter(lambda file: any(tile_id in file for tile_id in tile_ids), files))

			# Download all the tiles for the filtered space/time/variable parameters.
			logging.info("Pocessing {count} tile(s) for {band} on {date}...".format(count=len(filtered_files),band=band,date=date.strftime("%Y-%m-%d")))
			for file in filtered_files:

				date_str = date.strftime("%Y_%m_%d")
				tile_url = "{base_url}/{year}/{date_str}/{file}".format(base_url=base_url,year=date.year,date_str=date_str,file=file)
				out_file = "{base_folder}/{year}/{date_str}/{file}".format(base_folder=base_folder,year=date.year,date_str=date_str,file=file)

				# Only download files which have not already been downloaded or if forced to.
				if confirm_download(tile_url, out_file, update_method):
					try: download_file(tile_url, out_file, dryrun=dryrun)
					except Exception as error:
						logging.error(error)
						continue


def main():

	# Parse the period of interest.
	start = datetime.date.fromisoformat(START)
	end = datetime.date.fromisoformat(END)
	logging.info("Start: {start}".format(start=start))
	logging.info("End: {end}".format(end=end))

	# Generate the list of dates to download.
	dates = get_months(start, end)
	logging.info("Processing data for the following dates:")
	for date in dates: logging.info(date.strftime("%b %Y"))

	# Get the relative paths for each the VRT files for each date.
	vrt_relative_paths = get_vrt_relative_paths(PRODUCT_CODE, dates, BANDS)

	# Download all the tiles referenced in each VRT file.
	download_images(ProductCodes[PRODUCT_CODE], "{path_out}/{product_code}".format(path_out=PATH_OUT,product_code=PRODUCT_CODE), vrt_relative_paths, itemgetter(*TILES)(TileLookup), update_method=UpdateMethod[UPDATE_METHOD], dryrun=DRYRUN)

	logging.info("Processing complete")


# Run the script
if __name__=="__main__":
	main()
