PRO B_field_maker, files_LH, files_RH, twist, expansion, xsize=xsize, ysize=ysize, smoothit=smoothit


elements = N_ELEMENTS(files_LH)
IF N_ELEMENTS(files_RH) lt elements THEN elements = N_ELEMENTS(files_RH)

IF NOT KEYWORD_SET(smooth) THEN smoothit = 1

IF NOT KEYWORD_SET(xsize) THEN BEGIN 
   xsize = 2500.
   ysize = 2500.
   FOR i = 0,(elements-1) DO BEGIN
       temp = READFITS(files_LH[i],/silent)
       temp2 = READFITS(files_RH[i],/silent)
       IF N_ELEMENTS(temp[*,0]) lt xsize THEN xsize = N_ELEMENTS(temp[*,0])
       IF N_ELEMENTS(temp[0,*]) lt ysize THEN ysize = N_ELEMENTS(temp[0,*])
       IF N_ELEMENTS(temp2[*,0]) lt xsize THEN xsize = N_ELEMENTS(temp2[*,0])
       IF N_ELEMENTS(temp2[0,*]) lt ysize THEN ysize = N_ELEMENTS(temp2[0,*])
   ENDFOR
ENDIF

print,''
print,'The dimensions of the reconstructed B-field image will be '+ARR2STR(xsize,/trim)+' by '+$
      ARR2STR(ysize,/trim)+' with '+ARR2STR(elements,/trim)+' elements'
print,''

datacube = FLTARR(xsize,ysize,2)
datacube[*] = 0.

midx = FIX(xsize/2.)
midy = FIX(ysize/2.)

FOR i = 0,(elements-1) DO BEGIN 
    LH = READFITS(files_LH[i],/silent)
    RH = READFITS(files_RH[i],/silent)
    LH = LH>0.
    RH = RH>0.
    RH = ROT(RH,twist,expansion)
    datacube[*,*,0] = LH[0:(xsize-1),0:(ysize-1)]
    datacube[*,*,1] = RH[0:(xsize-1),0:(ysize-1)]
    FOR j = 0,4 DO ccshifts = TR_GET_DISP(datacube,/shift)
    datacube = SMOOTH(datacube,smoothit)
    destretched = ROSA_destretch_Bfield(datacube,xsize,ysize)
    LH = REFORM(destretched[*,*,0])
    ;LH = SMOOTH(destretched[*,*,0],2)
    RH = REFORM(destretched[*,*,1])
    ;RH = SMOOTH(destretched[*,*,1],2)
    B_field = ((LH - RH) / (LH + RH))
    IF (i le 9) THEN name = '0000' + arr2str(i,/trim)
    IF (i gt 9) AND (i le 99) THEN name = '000' + arr2str(i,/trim)
    IF (i gt 99) AND (i le 999) THEN name = '00' + arr2str(i,/trim)
    IF (i gt 999) AND (i le 9999) THEN name = '0' + arr2str(i,/trim)
    IF (i gt 9999) AND (i le 99999) THEN name = '' + arr2str(i,/trim)
    WRITEFITS,'B_field_'+name+'.fits',B_field
    PRINT,'Processed image number ',(i+1),' of ',(elements)
ENDFOR

END
