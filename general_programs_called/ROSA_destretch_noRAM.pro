;+
; ROUTINE:    ROSA_destretch_noRAM
;
; PURPOSE:    Creates a destretched datacube based upon a co-aligned input datacube
;
; USEAGE:     new_datacube = ROSA_destrech(datacube,xsize,ysize,zsize,cadence)
;
; INPUT:      xsize = x dimension of the input datacube
;             ysize = y dimension of the input datacube
;             zsize = z dimension of the input datacube
;             cadence = cadence between images after reconstruction
;
; OUTPUT:     Destretched ROSA datacube
;                 
; AUTHOR:   David B. Jess, December '08
;
;-

FUNCTION ROSA_destretch_noRAM,datacube,xsize,ysize,zsize,cadence

loadct,3,/silent

; CREATE A DESTRETCHED ARRAY AND DEFINE A STEP SIZE
; NOTE... THE USE OF "39" IS SIMPLY THE NUMBER OF DESTRETCHING LOCATIONS USED
; NOTE... A STEP SIZE OF 2 MEANS THAT IMAGE 1 WILL BE DESTRETCHED TO IMAGE 3, IMAGE 2 TO IMAGE 4, IMAGE 3 TO IMAGE 5 etc. etc.
; THIS STEP SIZE INSURES A MINIMAL TIME DURATION BETWEEN DESTRETCHED IMAGES
destretched_images  = FLTARR(xsize,ysize,zsize)
grid_size = 39.
step_size  = 2

i=2
ref_image = READFITS(datacube,nslice=(i - step_size),/silent) 
ref_image = ref_image / MEDIAN(ref_image) 
des_image = READFITS(datacube,nslice=i,/silent) 
des_image = des_image / MEDIAN(des_image) 
test_image = reg(des_image,ref_image,BYTARR((FIX(xsize/grid_size)),(FIX(ysize/grid_size))),DISP=disp,RDISP=rdisp) 

disp_all   = FLTARR(2,N_ELEMENTS(disp[0,*,0]),N_ELEMENTS(disp[0,0,*]),zsize)
rdisp_all  = FLTARR(2,N_ELEMENTS(disp[0,*,0]),N_ELEMENTS(disp[0,0,*]),zsize)


; CREATE A SUMMED IMAGE FOR ESTABLISHING BETTER SIGNAL TO NOISE
;datacube_ave = REBIN(datacube,xsize,ysize,1)

; DESTRETCH ALL BEST-CONTRAST IMAGES BASED ON THE STEP SIZE DEFINED ABOVE
window,0,title='Evaluating Long-Term Trend Parameters for ROSA',xsize=xsize,ysize=ysize
FOR i = step_size, (zsize-1), 1 DO BEGIN 
    IF (i MOD 10) EQ 0 THEN PRINT,'Evaluating trend parameters for image: ' + STRTRIM(i,2), ' of ', (zsize-1) 
    ref_image = READFITS(datacube,nslice=(i - step_size),/silent) 
    ref_image = ref_image / MEDIAN(ref_image) 
    des_image = READFITS(datacube,nslice=i,/silent) 
    des_image = des_image / MEDIAN(des_image) 
    test_image = reg(des_image,ref_image,BYTARR((FIX(xsize/grid_size)),(FIX(ysize/grid_size))),DISP=disp,RDISP=rdisp) 
    destretched_images(*,*,i)  = test_image 
    disp_all(*,*,*,i)  = disp 
    rdisp_all(*,*,*,i) = rdisp 
ENDFOR

rdisp_all(*,*,*,0:step_size-1) = rdisp_all(*,*,*,step_size:step_size + (step_size-1))
disp_all(*,*,*,0:step_size-1)  = rdisp_all(*,*,*,step_size:step_size + (step_size-1))

shifts_all       = disp_all - rdisp_all
shifts_all_cor   = shifts_all
shifts_all_sum   = shifts_all * 0.0
shifts_bulk_time = FLTARR(2,zsize)
disp_mask = BYTARR(grid_size,grid_size)
disp_mask[*] = 1.

; APPLY DESTRETCHING SHIFTS TO ALL IMAGES

FOR i = step_size, zsize-1 DO BEGIN 
    ibis_area_statistics,shifts_all_cor(0,*,*,i),disp_mask,median=median_timex 
    ibis_area_statistics,shifts_all_cor(1,*,*,i),disp_mask,median=median_timey 
    shifts_bulk_time(*,i)   = [median_timex, median_timey] 
    shifts_all_cor(0,*,*,i) = shifts_all_cor(0,*,*,i) - shifts_bulk_time(0,i) 
    shifts_all_cor(1,*,*,i) = shifts_all_cor(1,*,*,i) - shifts_bulk_time(1,i) 
    shifts_all_sum(*,*,*,i) = shifts_all_sum(*,*,*,i-step_size) + shifts_all_cor(*,*,*,i) 
ENDFOR

shifts_all_polyfits = FLTARR(2,N_ELEMENTS(disp[0,*,0]),N_ELEMENTS(disp[0,0,*]),6)
shifts_all_yfit     = FLTARR(2,N_ELEMENTS(disp[0,*,0]),N_ELEMENTS(disp[0,0,*]),zsize)
shifts_all_res      = FLTARR(2,N_ELEMENTS(disp[0,*,0]),N_ELEMENTS(disp[0,0,*]),zsize)
shifts_all_yfit_der = FLTARR(2,N_ELEMENTS(disp[0,*,0]),N_ELEMENTS(disp[0,0,*]),zsize)

; FIT A POLYNOMIAL TO THE DESTRETCHING SHIFTS TO SMOOTH OVER TIME SINCE BEST-CONTRAST IMAGES DO NOT NECESSARILY HAVE A CONSTANT CADENCE

imtimes_sec = FINDGEN(zsize)*cadence

FOR xx = 0,(N_ELEMENTS(disp[0,*,0])-1) DO BEGIN 
    FOR yy=0,(N_ELEMENTS(disp[0,0,*])-1) DO BEGIN 
        FOR dir=0,1 DO BEGIN 
	    scurve = REFORM(shifts_all_sum(dir,xx,yy,*)) 
	    shifts_all_polyfits(dir,xx,yy,*)   = POLY_FIT(imtimes_sec,scurve,5,yfit=yfit_scurve) 
	    shifts_all_yfit(dir,xx,yy,*)       = yfit_scurve 
	    shifts_all_res(dir,xx,yy,*)        = scurve - yfit_scurve 
	    shifts_all_yfit_der(dir,xx,yy,1:*) = first_der(REFORM(shifts_all_yfit(dir,xx,yy,*))) 
        ENDFOR 
    ENDFOR 
ENDFOR

FOV_mask = BYTARR(xsize,ysize)
FOV_mask[*] = 1.

; REDUCE STEP SIZE TO 1 SO ALL WHITE LIGHT IMAGES CAN BE DESTRETCHED TO THE SUCESSIVE IMAGE
step_size  = 1
window,0,title='Evaluating Destretching Parameters for ROSA',xsize=xsize,ysize=ysize
FOR i = step_size, (zsize-1), 1 DO BEGIN 
    IF (i MOD 10) EQ 0 THEN PRINT,'Evaluating destretching parameters for image: ' + STRTRIM(i,2), ' of ', (zsize-1) 
    ref_image = READFITS(datacube,nslice=(i - step_size),/silent) 
    des_image = READFITS(datacube,nslice=i,/silent) 
    test_image = reg(des_image,ref_image,BYTARR((FIX(xsize/grid_size)),(FIX(ysize/grid_size))),DISP=disp,RDISP=rdisp) 
    destretched_images(*,*,i)  = test_image 
    disp_all(*,*,*,i)  = disp 
    rdisp_all(*,*,*,i) = rdisp 
ENDFOR

rdisp_all(*,*,*,0:step_size-1) = rdisp_all(*,*,*,step_size:step_size + (step_size-1))
disp_all(*,*,*,0:step_size-1)  = rdisp_all(*,*,*,step_size:step_size + (step_size-1))


; NOW WE CORRECT THE MEASURED IMAGE SHIFTS WITH THE LONG TERM TRENDS MEASURED PREVIOUSLY
shifts_all_step1       = disp_all - rdisp_all
shifts_all_step1_cor   = shifts_all_step1
shifts_all_step1_sum   = shifts_all_step1

FOR i = 0, zsize-1 DO BEGIN 
    shifts_all_step1_cor(*,*,*,i) = shifts_all_step1(*,*,*,i) - shifts_all_yfit_der(*,*,*,i) 
    shifts_all_step1_sum(*,*,*,i) = REBIN(shifts_all_step1_cor(*,*,*,0:i),2,N_ELEMENTS(shifts_all_step1_sum[0,*,0,0]),N_ELEMENTS(shifts_all_step1_sum[0,0,*,0]),1) * (i+1) 
ENDFOR

shifts_all_step1_sum = shifts_all_step1_sum - REBIN(shifts_all_step1_sum(*,*,*,FIX(zsize/2)),2,N_ELEMENTS(shifts_all_step1_sum[0,*,0,0]),N_ELEMENTS(shifts_all_step1_sum[0,0,*,0]),zsize)
disp_all_polycor     = shifts_all_step1_sum + rdisp_all

; APPLY ALL DESTRETCHING SHIFTS AND DISPLAY RESULTING FIT
window,0,title='Destretched ROSA Images',xsize=xsize,ysize=ysize
FOR i=0,(zsize-1),1 DO BEGIN 
    ref_image = READFITS(datacube,nslice=i,/silent)
    test_image = doreg(ref_image, rdisp_all(*,*,*,i), disp_all_polycor(*,*,*,i)) 
    destretched_images(*,*,i) = test_image 
    ibis_tvmask,destretched_images(*,*,i),FOV_mask 
ENDFOR

; WRITE A SAVE FILE CONTAINING ALL THE RIGID AND DESTRETCHING PARAMETERS TO APPLY TO OTHER ROSA DATA (of the same batch!)
systm = SYSTIME(0)
; HAS THE FORM: Thu Nov 27 13:08:03 2008
; NEED TO CONVERT TO PROPER LINUX FORM
day = STRMID(systm,8,2)
month = STRMID(systm,4,3)
year = STRMID(systm,20,4)

SAVE,FILENAME='/data/rosa1/Speckle/Data/Param_files/destretch_params_written_'+day+month+year+'.sav',rdisp_all,disp_all_polycor,xsize,ysize,cadence

loadct,0,/silent

RETURN,destretched_images
END
