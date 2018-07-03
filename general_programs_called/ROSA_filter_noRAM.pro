;+
; ROUTINE:    ROSA_filter_noRAM
;
; PURPOSE:    Creates a filtered datacube which has all P-mode oscillations removed
;
; USEAGE:     new_datacube = ROSA_filter(datacube,xsize,ysize,zsize,cadence)
;
; INPUT:      xsize = x dimension of the input datacube
;             ysize = y dimension of the input datacube
;             zsize = z dimension of the input datacube
;             cadence = cadence between images after reconstruction
;
; OUTPUT:     Filtered ROSA datacube
;                 
; AUTHOR:   David B. Jess, November '08
;
;-

FUNCTION ROSA_filter_noRAM,datacube,xsize,ysize,zsize,arcsec_per_pixel,cadence

; THE FOLLOWING PORTION OF CODE IS USED TO FILTER OUT THE 5 MINUTE GLOBAL OSCILLATIONS
; THESE OSCILLATIONS CONTAIN HIGH INTENSITIES OVER A LARGE SPATIAL RANGE AND MUST BE FILTERED OUT
; NOTE... THIS REQUIRES A *LOT* OF MEMORY SO EXITING IDL MAY BE NECESSARY!!!

print,''
print,''
print,'You may want to get a cup of coffee. This could take a while...............'
print,''
print,''


; PIXEL SCALE IN KM
pixel_km = arcsec_per_pixel * 725 ; km

; MAKE A GRANULAR FILTER
granfilt = make_gran_filter(xsize,ysize,zsize,pixel_km,pixel_km,cadence,7)
granfilt = SMOOTH(TEMPORARY(granfilt),[25,25,7],/EDGE)
granfilt = FIX(granfilt)

new_datacube = FLTARR(xsize,ysize,zsize)

; MAKE A SPATIAL APODIZATION WINDOW
apod_window = apod(zsize,11,0.02,0.01,2)
apod_window = apod_window(*,5)

; EVALUATE THE MEDIAN VALUE OF THE ENTIRE DESTRETCHED WHITE LIGHT IMAGE SEQUENCE
temp = FLTARR(xsize,ysize)
FOR i = 0,(zsize-1) DO temp = temp + READFITS(datacube,nslice=i,/silent)
temp = temp / zsize
image_mean = MEDIAN(temp)
image_stats = FLTARR(6,zsize)

FOV_mask = BYTARR(xsize,ysize)
FOV_mask[*] = 1.

FOR i = 0,(zsize-1) DO BEGIN 
    ibis_area_statistics,READFITS(datacube,nslice=i,/silent),FOV_mask,all=allstat
    image_stats(*,i)=allstat
ENDFOR

image_mean = MEAN(image_stats(1,*))

; FOR EACH IMAGE SUBTRACT THE MEDIAN VALUE, MULTIPLY BY THE APODIZATION WINDOW AND THEN MULTIPLY BY THE MASK

;STOP

FOR i = 0,(zsize - 1) DO BEGIN 

    image_fft = COMPLEX(((READFITS(datacube,nslice=i,/silent) - image_mean) * apod_window[i]) * FOV_mask)

    ; TAKE THE FOURIER TRANSFORM OF THE WHITE LIGHT DATA
    image_fft = FFT(TEMPORARY(image_fft),-1)

    ; MULTIPLY THE TRANSFORMED WHITE LIGHT DATA BY THE GRANULAR FILTER CREATED ABOVE
    image_fft = (image_fft * granfilt[*,*,i])

    ; TAKE THE INVERSE FOURIER TRANSFORM
    image_fft = FFT(TEMPORARY(image_fft),1)

    ; FOR EACH IMAGE RE-ADD THE MEDIAN VALUE AND DIVIDE BY THE APODIZATION WINDOW
    ; THIS OBTAINS A DATACUBE WHICH HAS ALL 5 MINUTE GLOBAL OSCILLATIONS REMOVED
    new_datacube[*,*,i] = FLOAT((ABS(image_fft + image_mean) - image_mean)/apod_window[i] + image_mean)

ENDFOR

RETURN,new_datacube
END
