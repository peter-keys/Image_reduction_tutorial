;NAME: 
;	ROSA_calibration_file_load.bat
;  
; CATEGORY:
;   File I/O
;  	
;PURPOSE:
;	Loads in the Targets/Grids/Dots/Pinholes for calibrating the data
;	This information is needed for aligning images between cameras
;
;  ** NOTE: YOU NEED TO EDIT SOME OF THIS FILE TO GET THE RIGHT DIRECTORIES/FILTERS **
;
;	(P. Keys Dec 2016)
;-
;
;------------------------------------------------------------------------------------------------

	; File Paths
directory = data_dir

das1_dir = 'DAS1_11Oct2016_Fischer/'
das2_dir = 'DAS2_11Oct2016_Fischer/'
hbeta_dir = 'HARDcam_11Oct2016_Fischer/'
cak_dir = 'DJCcam_11Oct2016_Fischer/'

	; TARGETS
das1_targets = FILE_SEARCH(directory+das1_dir+'das1_rosa_2016-10-11_19.09.39_*.fit')
das2_targets = FILE_SEARCH(directory+das2_dir+'das2_rosa_2016-10-11_19.09.39_*.fit')
halpha_targets = FILE_SEARCH(directory+hbeta_dir+'HARDcam_data_18.09.27._X01_targets.fits')
cak_targets = FILE_SEARCH(directory+cak_dir+'DJCcam_data_18.09.33._X01_targets.fits')

	; GRIDS
das1_grids = FILE_SEARCH(directory+das1_dir+'das1_rosa_2016-10-11_19.20.39_*.fit')
das2_grids = FILE_SEARCH(directory+das2_dir+'das2_rosa_2016-10-11_19.20.39_*.fit')
halpha_grids = FILE_SEARCH(directory+hbeta_dir+'HARDcam_data_18.20.33._X01_grids.fits')
cak_grids = FILE_SEARCH(directory+cak_dir+'DJCcam_data_18.20.36._X01_grids.fits')

	; DOTS
das1_dots = FILE_SEARCH(directory+das1_dir+'das1_rosa_2016-10-11_19.15.32_*.fit')
das2_dots = FILE_SEARCH(directory+das2_dir+'das2_rosa_2016-10-11_19.15.32_*.fit')
halpha_dots = FILE_SEARCH(directory+hbeta_dir+'HARDcam_data_18.15.28._X01_dots.fits')
cak_dots = FILE_SEARCH(directory+cak_dir+'DJCcam_data_18.15.26._X01_dots.fits')

	; PINHOLES (if you have them)
das1_pinholes = FILE_SEARCH(directory+das1_dir+'das1_rosa_2016-10-11_19.25.52_*.fit')
das2_pinholes = FILE_SEARCH(directory+das2_dir+'das2_rosa_2016-10-11_19.25.52_*.fit')
halpha_pinholes = FILE_SEARCH(directory+hbeta_dir+'HARDcam_data_18.25.46._X01_pinholes.fits')
cak_pinholes = FILE_SEARCH(directory+cak_dir+'DJCcam_data_18.25.48._X01_pinholes.fits')

;------------------------------------------------------------------------------------------------
				; MAKE ARRAYS FOR EACH CALIBRATION IMAGE

das1_target = FLTARR(1004,1002)
das2_target = FLTARR(1004,1002)
halpha_target = FLTARR(512,512)
cak_target = FLTARR(512,512)

das1_grid = FLTARR(1004,1002)
das2_grid = FLTARR(1004,1002)
halpha_grid = FLTARR(512,512)
cak_grid = FLTARR(512,512)

das1_dot = FLTARR(1004,1002)
das2_dot = FLTARR(1004,1002)
halpha_dot = FLTARR(512,512)
cak_dot = FLTARR(512,512)

das1_pinhole = FLTARR(1004,1002)
das2_pinhole = FLTARR(1004,1002)
halpha_pinhole = FLTARR(512,512)
cak_pinhole = FLTARR(512,512)

das1_target[*] = 0.
das2_target[*] = 0.
halpha_target[*] = 0.
cak_target[*] = 0.

das1_grid[*] = 0.
das2_grid[*] = 0.
halpha_grid[*] = 0.
cak_grid[*] = 0.

das1_dot[*] = 0.
das2_dot[*] = 0.
halpha_dot[*] = 0.
cak_dot[*] = 0.

das1_pinhole[*] = 0.
das2_pinhole[*] = 0.
halpha_pinhole[*] = 0.
cak_pinhole[*] = 0.

calib_image1 = FLTARR(1004,1002)
calib_image2 = FLTARR(1004,1002)
calib_image3 = FLTARR(512,512)
calib_image4 = FLTARR(512,512)

das1_zsize_targets = DBL(((N_ELEMENTS(das1_targets)-1)*256))
das1_zsize_grids = DBL(((N_ELEMENTS(das1_grids)-1)*256))
das1_zsize_dots = DBL(((N_ELEMENTS(das1_dots)-1)*256))
das1_zsize_pinhole = DBL(((N_ELEMENTS(das1_pinholes)-1)*256))

das2_zsize_targets = DBL(((N_ELEMENTS(das2_targets)-1)*256))
das2_zsize_grids = DBL(((N_ELEMENTS(das2_grids)-1)*256))
das2_zsize_dots = DBL(((N_ELEMENTS(das2_dots)-1)*256))
das2_zsize_pinhole = DBL(((N_ELEMENTS(das2_pinholes)-1)*256))

;------------------------------------------------------------------------------------------------

n = READFITS(cak_targets[0],/SILENT)
cak_zsize_targets = N_ELEMENTS(n[0,0,*])

n = READFITS(cak_grids[0],/SILENT)
cak_zsize_grids = N_ELEMENTS(n[0,0,*])

n = READFITS(cak_dots[0],/SILENT)
cak_zsize_dots = N_ELEMENTS(n[0,0,*])

n = READFITS(cak_pinholes[0],/SILENT)
cak_zsize_pinholes = N_ELEMENTS(n[0,0,*])
delvar,n

n = READFITS(halpha_targets[0],/SILENT)
halpha_zsize_targets = N_ELEMENTS(n[0,0,*])

n = READFITS(halpha_grids[0],/SILENT)
halpha_zsize_grids = N_ELEMENTS(n[0,0,*])

n = READFITS(halpha_dots[0],/SILENT)
halpha_zsize_dots = N_ELEMENTS(n[0,0,*])

n = READFITS(halpha_pinholes[0],/SILENT)
halpha_zsize_pinholes = N_ELEMENTS(n[0,0,*])
delvar,n

;------------------------------------------------------------------------------------------------
		; LOAD IN THE AVERAGE DARKS & FLATS FOR EACH FILTER

RESTORE,reduced_dir+'Gband/calib/Average_dark_flat_Gband.sav',/ver
das1_dark = ave_dark
das1_flat = ave_flat
RESTORE,reduced_dir+'Continuum4170/calib/Average_dark_flat_Continuum4170.sav',/ver
das2_dark = ave_dark
das2_flat = ave_flat
RESTORE,reduced_dir+'CaK/calib/Average_dark_flat_CaK.sav',/ver
CaK_dark = ave_dark
CaK_flat = ave_flat
RESTORE,reduced_dir+'Hbeta/calib/Average_dark_flat_Hbeta.sav',/ver
Halpha_dark = ave_dark
Halpha_flat = ave_flat

;------------------------------------------------------------------------------------------------
	; Create the calibration images for the 1k x 1k cameras first

	; --** TARGETS **--
FOR d = 0,(N_ELEMENTS(das1_targets)-2) DO BEGIN &$
    FOR i = 0,255 DO BEGIN &$
    		; ** DAS 1 **
        calib_image1 = READFITS(das1_targets[d],exten=(i+1),/silent) &$
	calib_image1 = (calib_image1 - das1_dark) / das1_flat &$
	das1_target = das1_target + (calib_image1 / das1_zsize_targets) &$
		; ** DAS 2 **
	calib_image2 = READFITS(das2_targets[d],exten=(i+1),/silent) &$
	calib_image2 = (calib_image2 - das2_dark) / das2_flat &$
	das2_target = das2_target + (calib_image2 / das2_zsize_targets) &$
    ENDFOR &$
ENDFOR

	; --** GRIDS **--
FOR d = 0,(N_ELEMENTS(das1_grids)-2) DO BEGIN &$
    FOR i = 0,255 DO BEGIN &$
    		; ** DAS 1 **
        calib_image1 = READFITS(das1_grids[d],exten=(i+1),/silent) &$
	calib_image1 = (calib_image1 - das1_dark) / das1_flat &$
	das1_grid = das1_grid + (calib_image1 / das1_zsize_grids) &$
    		; ** DAS 2 **
        calib_image2 = READFITS(das2_grids[d],exten=(i+1),/silent) &$
	calib_image2 = (calib_image2 - das2_dark) / das2_flat &$
	das2_grid = das2_grid + (calib_image2 / das2_zsize_grids) &$
    ENDFOR &$
ENDFOR

	; --** DOTS **--
FOR d = 0,(N_ELEMENTS(das1_dots)-2) DO BEGIN &$
    FOR i = 0,255 DO BEGIN &$
    		; ** DAS 1 **
        calib_image1 = READFITS(das1_dots[d],exten=(i+1),/silent) &$
	calib_image1 = (calib_image1 - das1_dark) / das1_flat &$
	das1_dot = das1_dot + (calib_image1 / das1_zsize_dots) &$
		; ** DAS 2 **
        calib_image2 = READFITS(das2_dots[d],exten=(i+1),/silent) &$
	calib_image2 = (calib_image2 - das2_dark) / das2_flat &$
	das2_dot = das2_dot + (calib_image2 / das2_zsize_dots) &$
    ENDFOR &$
ENDFOR

	; --** PINHOLES **--
FOR d = 0,(N_ELEMENTS(das1_pinholes)-2) DO BEGIN &$
    FOR i = 0,255 DO BEGIN &$
    		; ** DAS 1 **
        calib_image1 = READFITS(das1_pinholes[d],exten=(i+1),/silent) &$
	calib_image1 = (calib_image1 - das1_dark) / das1_flat &$
	das1_pinhole = das1_pinhole + (calib_image1 / das1_zsize_pinhole) &$
    		; ** DAS 2 **
        calib_image2 = READFITS(das2_pinholes[d],exten=(i+1),/silent) &$
	calib_image2 = (calib_image2 - das2_dark) / das2_flat &$
	das2_pinhole = das2_pinhole + (calib_image2 / das2_zsize_pinhole) &$
    ENDFOR &$
ENDFOR

;------------------------------------------------------------------------------------------------
	; Create the calibration images for the 512 x 512 cameras

	; --** TARGETS **--
FOR i = 0,(cak_zsize_targets - 1) DO BEGIN &$
    		; ** CA K **
        calib_image3 = READFITS(cak_targets[0],nslice=i,/silent) &$
	calib_image3 = (calib_image3 - cak_dark) / cak_flat &$
	cak_target = cak_target + (calib_image3 / cak_zsize_targets) &$
ENDFOR
FOR i = 0,(halpha_zsize_targets - 1) DO BEGIN &$
    		; ** HBETA **
        calib_image4 = READFITS(halpha_targets[0],nslice=i,/silent) &$
	calib_image4 = (calib_image4 - halpha_dark) / halpha_flat &$
	halpha_target = halpha_target + (calib_image4 / halpha_zsize_targets) &$
ENDFOR

	; --** GRIDS **--
FOR i = 0,(cak_zsize_grids - 1) DO BEGIN &$
    		; ** CA K **
        calib_image3 = READFITS(cak_grids[0],nslice=i,/silent) &$
	calib_image3 = (calib_image3 - cak_dark) / cak_flat &$
	cak_grid = cak_grid + (calib_image3 / cak_zsize_grids) &$
ENDFOR
FOR i = 0,(halpha_zsize_grids - 1) DO BEGIN &$
    		; ** HBETA **
        calib_image4 = READFITS(halpha_grids[0],nslice=i,/silent) &$
	calib_image4 = (calib_image4 - halpha_dark) / halpha_flat &$
	halpha_grid = halpha_grid + (calib_image4 / halpha_zsize_grids) &$
ENDFOR

	; --** DOTS **--
FOR i = 0,(cak_zsize_dots - 1) DO BEGIN &$
    		; ** CA K **
        calib_image3 = READFITS(cak_dots[0],nslice=i,/silent) &$
	calib_image3 = (calib_image3 - cak_dark) / cak_flat &$
	cak_dot = cak_dot + (calib_image3 / cak_zsize_dots) &$
ENDFOR
FOR i = 0,(halpha_zsize_dots - 1) DO BEGIN &$
    		; ** HBETA **
        calib_image4 = READFITS(halpha_dots[0],nslice=i,/silent) &$
	calib_image4 = (calib_image4 - halpha_dark) / halpha_flat &$
	halpha_dot = halpha_dot + (calib_image4 / halpha_zsize_dots) &$
ENDFOR

	; --** PINHOLES **--
FOR i = 0,(cak_zsize_pinholes - 1) DO BEGIN &$
    		; ** CA K **
        calib_image3 = READFITS(cak_pinholes[0],nslice=i,/silent) &$
	calib_image3 = (calib_image3 - cak_dark) / cak_flat &$
	cak_pinhole = cak_pinhole + (calib_image3 / cak_zsize_pinholes) &$
ENDFOR
FOR i = 0,(halpha_zsize_pinholes - 1) DO BEGIN &$
    		; ** HBETA **
        calib_image4 = READFITS(halpha_pinholes[0],nslice=i,/silent) &$
	calib_image4 = (calib_image4 - halpha_dark) / halpha_flat &$
	halpha_pinhole = halpha_pinhole + (calib_image4 / halpha_zsize_pinholes) &$
ENDFOR

;------------------------------------------------------------------------------------------------
				; OUTPUT THE CALIBRATION FILES TO A SAVE FILE FOR FUTURE USE

	; Save the targets/grids/dots/pinholes in individual arrays for each filter
	; You may want to change the names of these based on the filters used (to avoid confusion later)
	; I have named them _calib to stop these overwriting variables in the main pipeline
					
Gband_calib = FLTARR(1004,1002,4)
Gband_calib[*,*,0] = das1_target
Gband_calib[*,*,1] = das1_grid
Gband_calib[*,*,2] = das1_dot
Gband_calib[*,*,3] = das1_pinhole

Cont4170_calib = FLTARR(1004,1002,4)
Cont4170_calib[*,*,0] = das2_target
Cont4170_calib[*,*,1] = das2_grid
Cont4170_calib[*,*,2] = das2_dot
Cont4170_calib[*,*,3] = das2_pinhole

CaK_calib = FLTARR(512,512,4)
CaK_calib[*,*,0] = cak_target
CaK_calib[*,*,1] = cak_grid
CaK_calib[*,*,2] = cak_dot
CaK_calib[*,*,3] = cak_pinhole

Hbeta_calib = FLTARR(512,512,4)
Hbeta_calib[*,*,0] = halpha_target
Hbeta_calib[*,*,1] = halpha_grid
Hbeta_calib[*,*,2] = halpha_dot
Hbeta_calib[*,*,3] = halpha_pinhole
	
	; Save these arrays out to the reduced dircetory for future use
SAVE,FILENAME=reduced_dir+'Alignment_calibration_images.sav',gband_calib,cont4170_calib,CaK_calib,Hbeta_calib
;------------------------------------------------------------------------------------------------
					; END
