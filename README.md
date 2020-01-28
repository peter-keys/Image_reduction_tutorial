# A Tutorial for Reconstructing Ground-based Data 

## ROSA_reduction_pipeline
Pipeline for reducing ROSA data to make ROSA images science-ready.
Developed as part of the SOLARNET project.
Primarily written for SSWIDL. 

See accopanying manual for details on using the code.
Dependencies not included here: KISIP Speckle interferometry package (http://spie.org/Publications/Proceedings/Paper/10.1117/12.788062)

Basic tenets of the code:
  - Creates suggested directory structures for processing data
  - Dark/flat corrects raw data
  - Produces a specklgram based on user specifications (and darks/flat corrected data)
  - User now needs to speckle the data with KISIP (not included)
  - Data converted back to fits and rigidly aligned after speckle
  - Data is destretched (to remove effects induced by speckle)
  - Data is rigidly aligned again
  - Data is converted into SOLARNET standard (file naming is set to usual data standards and FITS header is updated)
  - Data is coaligned to other cameras using claibration files
  - Quick look images of the data are created

Contact: Peter Keys (QUB)
