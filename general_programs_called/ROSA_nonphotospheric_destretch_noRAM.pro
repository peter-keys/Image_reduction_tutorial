;+
; ROUTINE:    ROSA_nonphotospheric_destretch_noRAM
;
; PURPOSE:    Creates a destretched datacube based upon a co-aligned input datacube
;
; USEAGE:     new_datacube = ROSA_destrech(datacube,xsize,ysize,zsize,cadence)
;
; INPUT:      xsize2 = x dimension of the input datacube
;             ysize2 = y dimension of the input datacube
;             zsize2 = z dimension of the input datacube
;             param_file = file containing all destretching parameters based on photospheric data
;   	      gentle = keyword which, if selected, causes a smoothing of destretching parameters (useful if cadences are different)
;
; OUTPUT:     Destretched ROSA datacube
;                 
; AUTHOR:   David B. Jess, November '08
;
;-

FUNCTION ROSA_nonphotospheric_destretch_noRAM,datacube,xsize2,ysize2,zsize2,param_file,gentle=gentle

RESTORE,param_file

loadct,3,/silent

destretched_images  = FLTARR(xsize2,ysize2,zsize2)
FOR i = 0,(zsize2-1) DO destretched_images[*,*,i] = 0.

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

;rdisp_all = CONGRID(rdisp_all,2,(N_ELEMENTS(rdisp_all[0,*,0,0])),(N_ELEMENTS(rdisp_all[0,0,*,0])),zsize2)
;disp_all_polycor = CONGRID(disp_all_polycor,2,(N_ELEMENTS(disp_all_polycor[0,*,0,0])),(N_ELEMENTS(disp_all_polycor[0,0,*,0])),zsize2)

FOV_mask = BYTARR(xsize2,ysize2)
FOV_mask[*] = 1.

window,0,title='Destretched ROSA Images',xsize=xsize2,ysize=ysize2
FOR i=0,(zsize2-1),1 DO BEGIN 
    ref_image = READFITS(datacube,nslice=i,/silent)
    test_image = doreg(ref_image, new_rdisp_all[*,*,*,i], new_disp_all_polycor[*,*,*,i]) 
    destretched_images[*,*,i] = test_image 
    ibis_tvmask,destretched_images[*,*,i],FOV_mask 
ENDFOR

RETURN,destretched_images

END
