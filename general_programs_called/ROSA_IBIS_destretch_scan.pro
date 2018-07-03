;+
; ROUTINE:    ROSA_IBIS_destretch_scan
;
; PURPOSE:    Creates a destretched datacube based upon a co-aligned input datacube
;
; USEAGE:     ROSA_IBIS_destrech_scan,datacube,xsize,ysize,zsize,cadence)
;
; INPUT:      xsize2 = x dimension of the input datacube
;             ysize2 = y dimension of the input datacube
;             zsize2 = z dimension of the input datacube (ie number of scans)
;             param_file = file containing all destretching parameters based on photospheric data
;             gentle = keyword which, if selected, causes a smoothing of destretching parameters (useful if cadences are different)
;
; OUTPUT:     Destretched ROSA datacube
;                 
; AUTHOR:   David B. Jess, May '09
; MODIFIED: David B. Jess, December '10 (allowing more than 10 wavelength positions)
;
;-

PRO ROSA_IBIS_destretch_scan,datacube,xsize2,ysize2,zsize2,wavelength_steps,param_file,gentle=gentle

RESTORE,param_file

IF (xsize2 MOD 2) ne 0 THEN xsize3 = (xsize2+1) ELSE xsize3=xsize2
IF (ysize2 MOD 2) ne 0 THEN ysize3 = (ysize2+1) ELSE ysize3=ysize2

datacube_compare = FLTARR(xsize3,ysize3,2)

temp = READFITS(datacube[0],/silent)
my_x = N_ELEMENTS(temp[*,0]) &$
my_y = N_ELEMENTS(temp[0,*]) &$
offset_x = FIX(DBL(my_x - xsize)/2.) &$
offset_y = FIX(DBL(my_y - ysize)/2.) &$

datacube_compare[*,*,0] = CONGRID(temp[offset_x:(offset_x+xsize2-1),offset_y:(offset_y+ysize2-1)],xsize3,ysize3)

all_images = FLTARR(xsize3,ysize3,zsize2)

FOR zzz = 1,(wavelength_steps-1) DO BEGIN 

    temp = READFITS(datacube[zzz*zsize2],/silent)
    my_x = N_ELEMENTS(temp[*,0]) &$
    my_y = N_ELEMENTS(temp[0,*]) &$
    offset_x = FIX(DBL(my_x - xsize)/2.) &$
    offset_y = FIX(DBL(my_y - ysize)/2.) &$
    picture2 = CONGRID(temp[offset_x:(offset_x+xsize2-1),offset_y:(offset_y+ysize2-1)],xsize3,ysize3)
    datacube_compare[*,*,1] = picture2
    FOR i = 0,4 DO ccshifts = TR_GET_DISP(datacube_compare,/shift)
    picture2 = datacube_compare[*,*,1]
    loadct,3,/silent
   
    test = FLTARR(xsize3,ysize3,2)
    test[*,*,0] = picture2

    all_images[*,*,0] = picture2

    FOR i = 1,(zsize2-1) DO BEGIN 
        temp = READFITS(datacube[(zzz*zsize2)+i],/silent) 
	my_x = N_ELEMENTS(temp[*,0]) &$
        my_y = N_ELEMENTS(temp[0,*]) &$
        offset_x = FIX(DBL(my_x - xsize)/2.) &$
        offset_y = FIX(DBL(my_y - ysize)/2.) &$
        test[*,*,1] = CONGRID(temp[offset_x:(offset_x+xsize2-1),offset_y:(offset_y+ysize2-1)],xsize3,ysize3)
	FOR j = 0,4 DO ccshifts = TR_GET_DISP(test,/shift) 
        all_images[*,*,i] = test[*,*,1] 
        test[*,*,0] = test[*,*,1]
    ENDFOR


    destretched_images  = FLTARR(xsize3,ysize3)
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

    window,0,title='Destretched IBIS Images',xsize=xsize2,ysize=ysize2
    FOR i=0,(zsize2-1),1 DO BEGIN 
        ref_image = all_images[*,*,i]
        destretched_images = doreg(ref_image, new_rdisp_all[*,*,*,i], new_disp_all_polycor[*,*,*,i]) 
        IF (i le 9) THEN filename = '0000' + arr2str(i,/trim) + '.fits'
        IF (i gt 9) AND (i le 99) THEN filename = '000' + arr2str(i,/trim) + '.fits'
        IF (i gt 99) AND (i le 999) THEN filename = '00' + arr2str(i,/trim) + '.fits'
        IF (i gt 999) AND (i le 9999) THEN filename = '0' + arr2str(i,/trim) + '.fits'
        IF (i gt 9999) AND (i le 99999) THEN filename = '' + arr2str(i,/trim) + '.fits'
        IF zzz le 9 THEN WRITEFITS,'IBIS_Na_destretched_pos0'+arr2str(zzz,/trim)+'_'+filename,destretched_images
	IF zzz gt 9 THEN WRITEFITS,'IBIS_Na_destretched_pos'+arr2str(zzz,/trim)+'_'+filename,destretched_images
        ibis_tvmask,destretched_images[*,*],FOV_mask 
    ENDFOR

print,'Processing wavelength position ',(zzz+1),' of ',wavelength_steps

ENDFOR

END
