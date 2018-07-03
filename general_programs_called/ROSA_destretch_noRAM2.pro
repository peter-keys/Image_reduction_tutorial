;+
; ROUTINE:    ROSA_destretch_noRAM2
;
; PURPOSE:    Creates a destretched datacube based upon a co-aligned input datacube
;
; USEAGE:     ROSA_destrech_noRAM2,datacube,xsize,ysize,zsize,cadence
;
; INPUT:      xsize = x dimension of the input datacube
;             ysize = y dimension of the input datacube
;             zsize = z dimension of the input datacube
;             cadence = cadence between images after reconstruction
;
; OUTPUT:     Destretched FITS files
;                 
; AUTHOR:   David B. Jess, May '09
; MODIFIED: David B. Jess, December '10 (allowing variable x & y sizes)
;
;-

PRO ROSA_destretch_noRAM2,datacube,xsize,ysize,zsize,cadence

loadct,3,/silent

; CREATE A DESTRETCHED ARRAY AND DEFINE A STEP SIZE
; NOTE... THE USE OF "39" IS SIMPLY THE NUMBER OF DESTRETCHING LOCATIONS USED
; NOTE... A STEP SIZE OF 2 MEANS THAT IMAGE 1 WILL BE DESTRETCHED TO IMAGE 3, IMAGE 2 TO IMAGE 4, IMAGE 3 TO IMAGE 5 etc. etc.
; THIS STEP SIZE INSURES A MINIMAL TIME DURATION BETWEEN DESTRETCHED IMAGES
;destretched_images  = FLTARR(xsize,ysize,zsize)
destretched_images  = FLTARR(xsize,ysize)
grid_size_x = 11.
grid_size_y = 11.
step_size  = 5

i=step_size
ref_image = READFITS(datacube[(i - step_size)],/silent) 
ref_image = ref_image / MEDIAN(ref_image) 
ref_image = CONGRID(ref_image,xsize,ysize)
des_image = READFITS(datacube[i],/silent) 
des_image = des_image / MEDIAN(des_image) 
des_image = CONGRID(des_image,xsize,ysize)
test_image = reg(des_image,ref_image,BYTARR((FIX(xsize/grid_size_x)),(FIX(ysize/grid_size_y))),DISP=disp,RDISP=rdisp) 

disp_all   = FLTARR(2,N_ELEMENTS(disp[0,*,0]),N_ELEMENTS(disp[0,0,*]),zsize)
rdisp_all  = FLTARR(2,N_ELEMENTS(disp[0,*,0]),N_ELEMENTS(disp[0,0,*]),zsize)


; CREATE A SUMMED IMAGE FOR ESTABLISHING BETTER SIGNAL TO NOISE
;datacube_ave = REBIN(datacube,xsize,ysize,1)

; DESTRETCH ALL BEST-CONTRAST IMAGES BASED ON THE STEP SIZE DEFINED ABOVE
window,0,title='Evaluating Long-Term Trend Parameters for ROSA',xsize=xsize,ysize=ysize
FOR i = step_size, (zsize-1), 1 DO BEGIN 
    IF (i MOD 10) EQ 0 THEN PRINT,'Evaluating trend parameters for image: ' + STRTRIM(i,2), ' of ', (zsize-1) 
    ref_image = CONGRID(READFITS(datacube[(i - step_size)],/silent),xsize,ysize) 
    ref_image = ref_image / MEDIAN(ref_image) 
    des_image = CONGRID(READFITS(datacube[i],/silent),xsize,ysize) 
    des_image = des_image / MEDIAN(des_image) 
    test_image = reg(des_image,ref_image,BYTARR((FIX(xsize/grid_size_x)),(FIX(ysize/grid_size_y))),DISP=disp,RDISP=rdisp) 
    disp_all(*,*,*,i)  = disp 
    rdisp_all(*,*,*,i) = rdisp 
ENDFOR

rdisp_all(*,*,*,0:step_size-1) = rdisp_all(*,*,*,step_size:step_size + (step_size-1))
;disp_all(*,*,*,0:step_size-1)  = rdisp_all(*,*,*,step_size:step_size + (step_size-1))

;CHECK THIS OUT!!!!!!!!!!!!!!!!
disp_all(*,*,*,0:step_size-1)  = disp_all(*,*,*,step_size:step_size + (step_size-1))

shifts_all       = disp_all - rdisp_all
shifts_all_cor   = shifts_all
shifts_all_sum   = shifts_all * 0.0
shifts_bulk_time = FLTARR(2,zsize)
disp_mask = BYTARR(grid_size_x,grid_size_y)
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
    ref_image = CONGRID(READFITS(datacube[(i - step_size)],/silent),xsize,ysize) 
    ref_image = ref_image / MEDIAN(ref_image) 
    des_image = CONGRID(READFITS(datacube[i],/silent),xsize,ysize) 
    des_image = des_image / MEDIAN(des_image)
    test_image = reg(des_image,ref_image,BYTARR((FIX(xsize/grid_size_x)),(FIX(ysize/grid_size_y))),DISP=disp,RDISP=rdisp) 
    disp_all(*,*,*,i)  = disp 
    rdisp_all(*,*,*,i) = rdisp 
ENDFOR

rdisp_all(*,*,*,0:step_size-1) = rdisp_all(*,*,*,step_size:step_size + (step_size-1))
disp_all(*,*,*,0:step_size-1)  = disp_all(*,*,*,step_size:step_size + (step_size-1))


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
    ref_image = CONGRID(READFITS(datacube[i],/silent),xsize,ysize)
    test_image = doreg(ref_image, rdisp_all(*,*,*,i), disp_all_polycor(*,*,*,i)) 
    destretched_images(*,*)  = test_image 
    IF (i le 9) THEN filename = '0000' + arr2str(i,/trim) + '.fits'
    IF (i gt 9) AND (i le 99) THEN filename = '000' + arr2str(i,/trim) + '.fits'
    IF (i gt 99) AND (i le 999) THEN filename = '00' + arr2str(i,/trim) + '.fits'
    IF (i gt 999) AND (i le 9999) THEN filename = '0' + arr2str(i,/trim) + '.fits'
    IF (i gt 9999) AND (i le 99999) THEN filename = '' + arr2str(i,/trim) + '.fits'
    WRITEFITS,'destretched_'+filename,destretched_images
    ;WRITEFITS,'IBIS_Na_destretched_pos00_'+filename,destretched_images
    ibis_tvmask,destretched_images(*,*),FOV_mask 
ENDFOR

; WRITE A SAVE FILE CONTAINING ALL THE RIGID AND DESTRETCHING PARAMETERS TO APPLY TO OTHER ROSA DATA (of the same batch!)
systm = SYSTIME(0)
; HAS THE FORM: Thu Nov 27 13:08:03 2008
; NEED TO CONVERT TO PROPER LINUX FORM
day = STRMID(systm,8,2)
month = STRMID(systm,4,3)
year = STRMID(systm,20,4)

SAVE,FILENAME='/data/rosa3/oldrosa1/Speckle/Data/Reconstructed/29Oct2010/destretch_params/destretch_params_written_'+day+month+year+'.sav',rdisp_all,disp_all_polycor,xsize,ysize,cadence

loadct,0,/silent

END
