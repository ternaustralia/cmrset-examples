docker run --rm ^
	-v C:/Downloads/AETContainer/:/usr/src/app/data ^
	-e PATH_OUT=/usr/src/app/data/ ^
	-e TERN_API_KEY=TXlmY1p1N21DSlNWNUlSeS5PC1IkSzEkSiFbdkI2NEFDUnlVL1ZWPgx1IlYsJ2VRZ0AhC0EKMU5UeFNQSAx2DGhrYydoDTg9WGkgTFR4MGtH ^
	-e BANDS=pixel_qa ^
	-e START=2016-01-01 ^
	-e END=2016-02-01 ^
	-e TILES=10,11 ^
	tern/download_aet:v2 ^

