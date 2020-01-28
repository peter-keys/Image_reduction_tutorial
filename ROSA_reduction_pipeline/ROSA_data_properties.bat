;+
;NAME: 
;	ROSA_data_properties.bat
;  
; CATEGORY:
;   File I/O
;  	
;PURPOSE:
;	A batch file with the associated properties of the ROSA data that you 
;	are processing with the ROSA pipeline. This information is supplied 
;	by the data processor for a given data set and should include information 
;	that is lost in the reconstruction process or is just not included in the 
;	original FITS header for whatever reason. (e.g. pointing etc.). The file 
;	has been structured this way to ensure that the header information for data 
;	previously processed with this pipeline can be retrospectively added and to 
;	ensure ease of use for those who are new to this pipeline.	 

;	Below is a list of the FITS keywords that will be included in the 
;	header using this .bat file. Some of these are mandatory for SOLARNET
;	some are not. 
;
;*** NB THERE ARE SOME VALUES YOU NEED TO CHANGE PRIOR TO RUNNING BASED ON THE POINTING AND FILTER YOU ARE PROCESISNG **
;
;	These values come from your notes so you must manually input them.
;	The LINES and KEYWORDS you need to change are:
;	
;		+ LINES 90:133 - You need to comment out the relevant filter/camera values 
;		+ LINE 145 - Put this as the start time of your camera from the raw header
;		+ LINE 185 - Put in the target you were looking at (not a specific target)
;		+ LINE 251 - Put in the PI for the data
;		+ LINE 271 - Put in the exposure for the raw data (may be in orginal raw header)
;		+ LINE 283 - Put in the spatial sampling used (normally 0.069 or 0.138)
;
;	The rest are taken from previous steps in the pipeline (P. Keys Dec 2016)
;-
;
;------------------------------------------------------------------------------------------------
;FITS KEYWORDS:
;DATE-BEG = '2020-12-24T17:00:00.1'		/ Date of start of observation
;DATE-END = '2020-12-24T17:00:02.5'		/ Date of end of observation
;FILENAME = 'ROSA_gband_20201224_170000.1.fits'	
;DATASUM = '2503531142'				/ Data checksum
;CHECKSUM ='hcHjjc9ghcEghc9g'			/ HDU checksum
;DATE = '2020-12-31T23:59:59'			/ Date of FITS file creation
;SOLARNET = 0.5					/ Fully SOLARNET compliant (1), or Partially (0.5)
;ORIGIN = 'Queens University Belfast'		/ Creator of FITS file
;WCSNAME = 'Helioprojective-Cartesian'		/ Required for WCS
;BTYPE = 'Intensity'				/ Description of what the data array represents
;BUNIT = 'DN'					/ Units of data array
;CTYPE1 = 'HPLN-TAN'				/ Type of coordinates along axis 1
;CTYPE2 = 'HPLT-TAN'				/ Type of coordinates along axis 2
;CUNIT1 = 'Angstrom'				/ Units along axis 1
;CUNIT2 = 'arcsec'				/ Units along axis 2
;FILTER1 = 'Gband'				/ Name of filter
;INSTRUME = 'ROSA'				/ Name of instrument
;TEXPOSUR = 					/ [s] Single exposure time
;NSUMEXP = 					/ Number of summed exposures
;HGLN_OBS = 					/ Stonyhurst heliographic lomgitude
;HGLT_OBS = 					/ Stonyhurst heliographic lattitude
;DSUN_OBS = 1498142450				/ [m] Distance from instrument to Sun
;SPECSYSa = 'HELIOCEN'				/ Coordinate reference frame
;CADENCE = 					/ [sec] Planned cadence
;CADAVG = 					/ [sec] Average actual cadence
;ROT_COMP = 1					/ Solar rotation compensation on (1)/off (0)
;DATARMS = 					/ [DN] Root mean square of data
;OBSERVER = 'Peter Keys'			/ Operator who acquired the data
;REQUESTER = 'PI'				/ Name(s) of person(s) requesting observation
;TELECONFG = 'Standard'				/ Telescope configuration
;TELESCOP = 'Dunn Solar Telescope'		/ Name of telescope
;CAMERA = 'Cam 1'				/ Name of camera
;DETECTOR = 'Andor iXon'			/ Name of detector
;WAVELNTH = 					/ [Angstrom] Characteristic wavelength 
;WAVEMIN					/ [Angstrom] Min wavelength covered by filter
;WAVEMAX					/ [Angstrom] Max wavelength covered by filter
;
;ONES I'M ADDING:
;TARGET	= 'QS'					/ General target of observations
;SPATSAMP = 0.069				/ [arcsecs/pix] Spatial sampling employed
;------------------------------------------------------------------------------------------------

test_files = FILE_SEARCH(reduced_dir+filter+'/processed/destretched_*.fits')	; Load in data
image = READFITS(test_files[0],h,/SILENT)

mkhdr,newheader,im=image,2,[imagedim[0],imagedim[1]]			; Make your new header

	; TABLE OF COMMMON FILTERS USED WITH ROSA FOR KEYWORD VALUES
	; (taken from Jess et al. (2010) Sol Phys Vol 261, pp 363-373)

;------------------------------------------------------------------------------------------------
; Uncomment the filter being processed (could be improved so you don't need to comment with IF statements)	<---- You need to change

;CaK				; Cam 3
Wavelength = 3933.7		; [Angstrom]
Waveminimum = 3933.2		; [Angstrom]
Wavemaximum = 3934.2		; [Angstrom]
Camera_num = 'Cam 3'
Camera_name = 'Andor iXon Ultra DU-897U'

;Continuum4170			; Cam 2
;Wavelength = 4170.0		; [Angstrom]
;Waveminimum = 4144.0 		; [Angstrom]
;Wavemaximum = 4196.0		; [Angstrom]
;Camera_num = 'Cam 2'
;Camera_name = 'Andor iXon DU-885K'

;Continuum3500			; Cam 3
;Wavelength = 3500.0		; [Angstrom]
;Waveminimum = 3449.0 		; [Angstrom]
;Wavemaximum = 3551.0		; [Angstrom]
;Camera_num = 'Cam 3'
;Camera_name = 'Andor iXon Ultra DU-897U'

;Gband				; Cam 1
;Wavelength = 4305.5 		; [Angstrom]
;Waveminimum = 4300.9		; [Angstrom]
;Wavemaximum = 4310.1		; [Angstrom]
;Camera_num = 'Cam 1'
;Camera_name = 'Andor iXon DU-885K'

;Halpha (Zeiss)			; Cam 4
;Wavelength = 6562.8		; [Angstrom]
;Waveminimum = 6562.675		; [Angstrom]
;Wavemaximum = 6562.925		; [Angstrom]
;Camera_num = 'Cam 4'
;Camera_name = 'Andor iXon X3 DU-887-BV'

;Hbeta (UBF)			; Cam 4
;Wavelength = 4861.0		; [Angstrom]
;Waveminimum = 4860.895		; [Angstrom]
;Wavemaximum = 4861.105		; [Angstrom]
;Camera_num = 'Cam 4'
;Camera_name = 'Andor iXon X3 DU-887-BV'

;------------------------------------------------------------------------------------------------
; Add in the standard keywords that won't change between frames
; The other ones will be added by a loop system when generating the new filenames 
;
;	** You need to edit these values to suit your data **
;------------------------------------------------------------------------------------------------

	; Use 'print,start_header[10]' to get the DATE-BEG value (add this to the ISO_stime [i.e start time])

;NB it is possible that this is off by 1hr due to the way the clocks work if so change it based on your notes

ISO_stime = '2016-10-10T18:07:46.000Z'	;Need to add a Z in at the end here (start time)	<---- You need to change

;'2016-10-10T17:13:14.000Z''2016-10-10T18:07:46.000Z'  '2016-10-10T17:15:39.000Z'Cak...1st
; ** DATE-BEG **	
SXADDPAR,newheader,'DATE-BEG',ISO_stime,'Date of start of observation'  
;------------------------------------------------------------------------------------------------

	; Need to work out the end of the observations (Probably a simpler way of doing this...)

TIMESTAMPTOVALUES,ISO_stime,year=yr,month=mnth,day=dy,hour=hrs,minute=mins,second=secs,offset=offset

length = N_ELEMENTS(test_files) * cadence	; [sec] Length of data in seconds

nhour = FIX(length/(60*60.))						; Number of hours observing
nmins = FIX(((length/(60.)-(nhour * 60.))))  				; Number of mins observing 
nsecs = ((((length/(60.)-(nhour * 60.))))-nmins)*60.			; Number of secs observing

e_hour = hrs+nhour							; End Hour
e_mins = mins+nmins							; End Mins
e_secs = secs+nsecs							; End Secs

IF (e_secs GE 60) THEN e_mins = e_mins + 1 
IF (e_secs GE 60) THEN e_secs = e_secs - 60	; In case you have more than 60s
IF (e_mins GE 60) THEN e_hour = e_hour + 1 
IF (e_mins GE 60) THEN e_mins = e_mins - 60	; In case you have more than 60mins

IF (e_secs GE 10) THEN secstr = STRING(e_secs,FORMAT='(F6.3)')		; Change to string and take 3 d.p.
IF (e_secs LT 10) THEN secstr = '0'+STRING(e_secs,FORMAT='(F5.3)') 	; If <10 add in a '0' to pad
minstr = arr2str(e_mins,/TRIM)						; Change to string 
IF (e_mins LT 10) THEN minstr = '0'+minstr				; If <10 add in a '0' to pad
hrstr = arr2str(e_hour,/TRIM)						; Change to string
IF (e_hour LT 10) THEN hrstr = '0'+hrstr				; If <10 add in a '0' to pad

ISO_etime = arr2str(yr,/TRIM)+'-'+arr2str(mnth,/TRIM)+'-'+arr2str(dy,/TRIM)+'T'+hrstr+':'+minstr+':'+secstr+'Z'

; ** DATE-END **	
SXADDPAR,newheader,'DATE-END',ISO_etime,'Date of end of observation'  
;------------------------------------------------------------------------------------------------

; ** DATA LEVEL **	
SXADDPAR,newheader,'LEVEL', 1,'Data level of FITS file'  
;------------------------------------------------------------------------------------------------

; ** TARGET **  QS, AR, LIMB, or FLARE								<--- You need to change
SXADDPAR,newheader,'TARGET','AR12599','General target of observations'  
;------------------------------------------------------------------------------------------------

; ** WAVELENGTH **
SXADDPAR,newheader,'WAVELNTH',Wavelength,'[Angstrom] Characteristic wavelength'  

; ** WAVEMIN **
SXADDPAR,newheader,'WAVEMIN',Waveminimum,'[Angstrom] Min wavelength covered by filter'  

; ** WAVEMAX **
SXADDPAR,newheader,'WAVEMAX',Wavemaximum,'[Angstrom] Max wavelength covered by filter'  
;------------------------------------------------------------------------------------------------

; ** WCSNAME **
SXADDPAR,newheader,'WCSNAME','Heliocentric-Cartesian','Required for WCS'  
;------------------------------------------------------------------------------------------------

; ** BTYPE **
SXADDPAR,newheader,'BTYPE','Intensity','Description of what the data array represents'  
;------------------------------------------------------------------------------------------------

; ** BUNIT **
SXADDPAR,newheader,'BUNIT','DN','Units of data array'  
;------------------------------------------------------------------------------------------------

; ** CTYPE1 **
SXADDPAR,newheader,'CTYPE1','HPLN-TAN','Type of coordinates along axis 1'  
;------------------------------------------------------------------------------------------------

; ** CTYPE2 **
SXADDPAR,newheader,'CTYPE2','HPLT-TAN','Type of coordinates along axis 2'  
;------------------------------------------------------------------------------------------------

; ** CUNIT1 **
SXADDPAR,newheader,'CUNIT1','Pixels','Units along axis 1'  
;------------------------------------------------------------------------------------------------

; ** CUNIT2 **
SXADDPAR,newheader,'CUNIT2','Pixels','Units along axis 2'  
;------------------------------------------------------------------------------------------------

; ** SOLARNET **
SXADDPAR,newheader,'SOLARNET',0.5,'Fully SOLARNET compliant (1), or Partially (0.5)'  
;------------------------------------------------------------------------------------------------

; ** DSUN-OBS **
SXADDPAR,newheader,'DSUN-OBS',149597780,'[km] Distance from instrument to Sun'  
;------------------------------------------------------------------------------------------------

; ** TELESCOP **
SXADDPAR,newheader,'TELESCOP','Dunn Solar Telescope (USA)','Name of telescope'  
;------------------------------------------------------------------------------------------------

; ** INSTRUME **
SXADDPAR,newheader,'INSTRUME','ROSA','Name of instrument'  
;------------------------------------------------------------------------------------------------

; ** ORIGIN **
SXADDPAR,newheader,'ORIGIN','Queens University Belfast','Creator of FITS file'  
;------------------------------------------------------------------------------------------------

; ** OBSERVER **
SXADDPAR,newheader,'OBSERVER','Peter Keys','Operator who acquired the data'  
;------------------------------------------------------------------------------------------------

; ** REQUESTER **	(Data PI)								<--- You need to change
SXADDPAR,newheader,'REQUESTER','D. Long','PI for the data'  
;------------------------------------------------------------------------------------------------

; ** CAMERA **
SXADDPAR,newheader,'CAMERA',Camera_num,'Name of camera'  
;------------------------------------------------------------------------------------------------

; ** DETECTOR **
SXADDPAR,newheader,'DETECTOR',Camera_name,'Name of detector'  
;------------------------------------------------------------------------------------------------

; ** FILTER **
SXADDPAR,newheader,'FILTER1',filter,'Name of filter'  
;------------------------------------------------------------------------------------------------

; ** ROT-COMP **
SXADDPAR,newheader,'ROT-COMP',1,'Solar rotation compensation on (1)/off (0)'  
;------------------------------------------------------------------------------------------------

; ** TEXPOSUR **	(The exposure time of the raw data)					<--- You need to change
SXADDPAR,newheader,'TEXPOSUR',40,'[ms] Single exposure time'  
;------------------------------------------------------------------------------------------------

; ** NSUMEXP **
SXADDPAR,newheader,'NSUMEXP',burst_number,'Number of summed exposures'  
;------------------------------------------------------------------------------------------------

; ** CADAVG **
SXADDPAR,newheader,'CADAVG',cadence,'[sec] Average actual cadence'  
;------------------------------------------------------------------------------------------------

; ** SPATSAMP **  (The spatial sampling - default is 0.069/0.138 depending on 1k/512 cams)	<--- You need to change
SXADDPAR,newheader,'SPATSAMP',0.138,'[arcsecs/pix] Spatial sampling employed'  
;------------------------------------------------------------------------------------------------

;	********** REST ARE INPUT THROUGH A FOR-LOOP AS THEY NEED TO BE CALCUATED IN EACH FRAME **********
