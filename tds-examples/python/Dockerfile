FROM python:3.7-alpine3.14
#FROM python:3.7-slim

WORKDIR /usr/src/app

# Install least changing requirements first
COPY requirements.txt .
RUN pip3 install -r requirements.txt --no-cache-dir # Use --no-cache-dir to get smaller images

ENV UPDATE_METHOD=UPDATE_MISSING
ENV PRODUCT_CODE=CMRSET_LANDSAT_V2_2
ENV START=
ENV END=
ENV BANDS=ETa,pixel_qa
ENV TILES=0,1,2,3,4,5,6,7,8,9,10,11
ENV DRYRUN=False


# Need to mount these files
COPY download-aet.py .

ENTRYPOINT ["python3", "./download-aet.py"]



