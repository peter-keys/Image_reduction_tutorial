;+
; ROUTINE:    ROSA_nonphotospheric_destretch_noRAM
;
; PURPOSE:    Creates a destretched datacube based upon a co-aligned input datacube
;
; USEAGE:     ROSA_nonphotospheric_destrech_noRAM2,datacube,xsize,ysize,zsize,cadence)
;
; INPUT:      xsize2 = x dimension of the input datacube
;             ysize2 = y dimension of the input datacube
;             zsize2 = z dimension of the input datacube
;             param_file = file containing all destretching parameters based on photospheric data
;             gentle = keyword which, if selected, causes a smoothing of destretching parameters (useful if cadences are different)
;
; OUTPUT:     Destretched ROSA datacube
;                 
; AUTHOR:   David B. Jess, May '09
;
;-

PRO ROSA_nonphotospheric_destretch_noRAM2,datacube,xsize2,ysize2,zsize2,param_file,gentle=gentle

RESTORE,param_file

loadct,3,/silent

destretched_images  = FLTARR(xsize2,ysize2)
destretched_images[*] = 0.

value = N_ELEMENTS(rdisp_all[*,0,0,0])
new_rdisp_all = FLTARR(value,(N_ELEMENTS(rdisp_all[0,*,0,0])),(N_ELEMENTS(rdisp_all[0,0,*,0])),zsize2)
FOR i = 0,(value-1) DO BEGIN
    temp = REFORM(rdisp_all[i,*,*,*])
    temp = CONGRID(temp,(N_ELEMENTS(rdisp_all[0,*,0,0])),(N_ELEMENTS(rdisp_all[0,0,*,0])),zsize2)
    new_rdisp_all[i,*,*,*] = temp
ENDFOR

value = N_ELEMENTS(disp_all_polycor[*,0,0,0])
new_disp_all_polycor = FLTARR(value,(N_ELEMENTS(disp_all_polycor[0,*,0,0])),(N_ELEMENTS(disp_all_polycor[0,0,*,0])),zsize2)
FOR i = 0,(value-1) DO BEGIN
    temp = REFORM(disp_all_polycor[i,*,*,*])
    temp = CONGRID(temp,(N_ELEMENTS(disp_all_polycor[0,*,0,0])),(N_ELEMENTS(disp_all_polycor[0,0,*,0])),zsize2)
    IF KEYWORD_SET(gentle) THEN temp = SMOOTH(temp,2) 
    new_disp_all_polycor[i,*,*,*] = temp
ENDFOR

FOV_mask = BYTARR(xsize2,ysize2)
FOV_mask[*] = 1.

window,0,title='Destretched ROSA Images',xsize=xsize2,ysize=ysize2
FOR i=0,(zsize2-1),1 DO BEGIN 
    ref_image = READFITS(datacube[i],/silent)
    destretched_images = doreg(ref_image, new_rdisp_all[*,*,*,i], new_disp_all_polycor[*,*,*,i]) 
    IF (i le 9) THEN filename = 'destretched_000' + arr2str(i,/trim) + '.fits'
    IF (i gt 9) AND (i le 99) THEN filename = 'destretched_00' + arr2str(i,/trim) + '.fits'
    IF (i gt 99) AND (i le 999) THEN filename = 'destretched_0' + arr2str(i,/trim) + '.fits'
    IF (i gt 999) AND (i le 9999) THEN filename = 'destretched_' + arr2str(i,/trim) + '.fits'
    WRITEFITS,filename,destretched_images
    ibis_tvmask,destretched_images[*,*],FOV_mask 
ENDFOR

END
