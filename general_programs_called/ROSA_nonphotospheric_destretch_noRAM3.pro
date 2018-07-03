;+
; ROUTINE:    ROSA_nonphotospheric_destretch_noRAM
;
; PURPOSE:    Creates a destretched datacube based upon a co-aligned input datacube
;
; USEAGE:     ROSA_nonphotospheric_destrech_noRAM3,datacube,xsize,ysize,zsize,cadence)
;
; INPUT:      xsize2 = x dimension of the input datacube
;             ysize2 = y dimension of the input datacube
;             zsize2 = z dimension of the input datacube
;             param_file = file containing all destretching parameters based on photospheric data
;             gentle = keyword which, if selected, causes a smoothing of destretching parameters (useful if cadences are different)
;
; OUTPUT:     Destretched ROSA datacube
;                 
; AUTHOR:   David B. Jess, Nov 2011
;
;-

PRO ROSA_nonphotospheric_destretch_noRAM3,datacube,xratio,yratio,zratio,param_file,wavelength_positions

RESTORE,param_file
spkim_wl_disp_use = vectors.disp
spkim_wl_rdisp = vectors.rdisp
shifts_cor_sum = vectors.dsip_sum
kernels = vectors.kernels
shifts_bulk = vectors.shifts_bulk

numims = FIX(N_ELEMENTS(spkim_wl_disp_use[0,0,0,*])*zratio)

spkim_wl_disp_use2 = FLTARR(2, FIX(N_ELEMENTS(spkim_wl_disp_use[0,*,0,0])*xratio), FIX(N_ELEMENTS(spkim_wl_disp_use[0,0,*,0])*yratio), $
                     FIX(N_ELEMENTS(spkim_wl_disp_use[0,0,0,*])*zratio))
spkim_wl_disp_use2[0,*,*,*] = CONGRID(REFORM(spkim_wl_disp_use[0,*,*,*]), N_ELEMENTS(spkim_wl_disp_use2[0,*,0,0]), $
                    N_ELEMENTS(spkim_wl_disp_use2[0,0,*,0]), N_ELEMENTS(spkim_wl_disp_use2[0,0,0,*]),/interp)
spkim_wl_disp_use2[1,*,*,*] = CONGRID(REFORM(spkim_wl_disp_use[1,*,*,*]), N_ELEMENTS(spkim_wl_disp_use2[1,*,0,0]), $
                    N_ELEMENTS(spkim_wl_disp_use2[1,0,*,0]), N_ELEMENTS(spkim_wl_disp_use2[1,0,0,*]),/interp)

spkim_wl_rdisp2 = FLTARR(2, FIX(N_ELEMENTS(spkim_wl_rdisp[0,*,0,0])*xratio), FIX(N_ELEMENTS(spkim_wl_rdisp[0,0,*,0])*yratio), $
                     FIX(N_ELEMENTS(spkim_wl_rdisp[0,0,0,*])*zratio))
spkim_wl_rdisp2[0,*,*,*] = CONGRID(REFORM(spkim_wl_rdisp[0,*,*,*]), N_ELEMENTS(spkim_wl_rdisp2[0,*,0,0]), $
                    N_ELEMENTS(spkim_wl_rdisp2[0,0,*,0]), N_ELEMENTS(spkim_wl_rdisp2[0,0,0,*]), /interp)
spkim_wl_rdisp2[1,*,*,*] = CONGRID(REFORM(spkim_wl_rdisp[1,*,*,*]), N_ELEMENTS(spkim_wl_rdisp2[1,*,0,0]), $
                    N_ELEMENTS(spkim_wl_rdisp2[1,0,*,0]), N_ELEMENTS(spkim_wl_rdisp2[1,0,0,*]), /interp)


t0 = SYSTIME(1) 
t1 = t0
wv=0
scan=0
FOR i=0,(numims-1) DO BEGIN
    IF (i MOD 100) EQ 0 THEN PRINT,''
    IF (i MOD 100) EQ 0 THEN PRINT,'Destretching image '+STRTRIM(i,2)+' of '+STRTRIM(numims,2)+' - so basically '+ $
       STRTRIM((RND((DBL(i)/DBL(numims))*100.)),2)+'% complete'
    IF (i MOD 100) EQ 0 THEN loops_to_go = FIX((numims-i) / 100.)   
    IF (i MOD 100) EQ 0 THEN systm = SYSTIME(1)  
    IF (i MOD 100) EQ 0 THEN loop_time = (systm - t1)   
    IF (i MOD 100) EQ 0 THEN t1 = systm
    IF (i MOD 100) EQ 0 THEN hours = FIX((loop_time*loops_to_go)/3600.)
    IF (i MOD 100) EQ 0 THEN minutes = FIX(((loop_time*loops_to_go)-(hours*3600.))/60.)
    IF (i MOD 100) EQ 0 THEN PRINT,'Estimated time to completion = '+STRTRIM(hours,2)+' hrs  '+STRTRIM(minutes,2)+' min'
    IF (i MOD 100) EQ 0 THEN PRINT,''
    image = READFITS(datacube[i],/silent)
    new_image = DOREG(image,spkim_wl_rdisp2[*,*,*,i],spkim_wl_disp_use2[*,*,*,i])
    IF (scan le 9) THEN filename = '0000' + arr2str(scan,/trim) + '.fits'
    IF (scan gt 9) AND (scan le 99) THEN filename = '000' + arr2str(scan,/trim) + '.fits'
    IF (scan gt 99) AND (scan le 999) THEN filename = '00' + arr2str(scan,/trim) + '.fits'
    IF (scan gt 999) AND (scan le 9999) THEN filename = '0' + arr2str(scan,/trim) + '.fits'
    IF (scan gt 9999) AND (scan le 99999) THEN filename = '' + arr2str(scan,/trim) + '.fits'
    IF wv le 9 THEN pos = 'pos0'+arr2str(wv,/trim) 
    IF wv gt 9 THEN pos = 'pos'+arr2str(wv,/trim) 
    WRITEFITS,'IBIS_destretched_'+pos+'_'+filename,new_image
    wv=wv+1
    IF wv eq wavelength_positions THEN scan = scan + 1
    IF wv eq wavelength_positions THEN wv = 0
ENDFOR


END
