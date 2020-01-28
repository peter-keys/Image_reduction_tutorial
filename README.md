# A Tutorial for Reconstructing Ground-based Data 

The purpose of this tutorial is to take some sample data and process it so that it is science-ready. We will consider what the reduction process invovles, the steps used and why we need to tak each of these steps. As I was involved in producing a 'user friendly' reduction pipeline for the first SOLARNET project, we will focus on some ROSA data for this short tutorial. 

Typicaly, as a starting point we will consider the reconstruction of broad band images as it is an easier starting point. Hopefully, you are reaidng this as you are taking part in a larger course on image reconstruction techniques, in which case this is a good starting point prior to more advanced image reconstruction (e.g., of images from FPIs etc.)

This will, therefore, be split into different sub-directories. 
1) The ROSA Reduction pipeline - the IDL code for reducing ROSA data
2) KISIP - The KISIP Speckle interferometry package (from KIS) which is used to speckle the images
3) Data - some sample images to work on. The final products are included as a comparison

## ROSA_reduction_pipeline
Pipeline for reducing ROSA data to make ROSA images science-ready.
Developed as part of the SOLARNET project.
Primarily written for SSWIDL. 

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

## KISIP

Note, I am /not/ responsible for KISIP. It can be tricky to set up and I would suggets that you do that in advance (it has been 10years since I set up KISIP myself, so I may not be very useful in troubleshooting installation....)

See the following paper for details on KISIP
http://spie.org/Publications/Proceedings/Paper/10.1117/12.788062

A manula for getting it set up is included in the directory for KISIP.

## Data

Sample data from ROSA of a coupld of different sample targets.

The data matches the intended directory structure of the raw and processed data as they would be acquired from the telescope. A sample of the final products is included as well so you can compare your final output to mine.

Contact: Peter Keys (QUB)
