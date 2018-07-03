;+
; ROUTINE:    ROSA_filter
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

FUNCTION ROSA_filter,datacube,xsize,ysize,zsize,arcsec_per_pixel,cadence

; THE FOLLOWING PORTION OF CODE IS USED TO FILTER OUT THE 5 MINUTE GLOBAL OSCILLATIONS
; THESE OSCILLATIONS CONTAIN HIGH INTENSITIES OVER A LARGE SPATIAL RANGE AND MUST BE FILTERED OUT
; NOTE... THIS REQUIRES A *LOT* OF MEMORY SO EXITING IDL MAY BE NECESSARY!!!

print,''
print,''
print,'You may want to get a cup of coffee. This may take a while...............'
print,''
print,''


; PIXEL SCALE IN KM
pixel_km = arcsec_per_pixel * 725 ; km

; MAKE A GRANULAR FILTER
granfilt = make_gran_filter(xsize,ysize,zsize,pixel_km,pixel_km,cadence,7)
granfilt = SMOOTH(TEMPORARY(granfilt),[25,25,7],/EDGE)

image_fft = COMPLEXARR(xsize,ysize,zsize,/NOZ)

; MAKE A SPATIAL APODIZATION WINDOW
apod_window = apod(zsize,11,0.02,0.01,2)
apod_window = apod_window(*,5)

; EVALUATE THE MEDIAN VALUE OF THE ENTIRE DESTRETCHED WHITE LIGHT IMAGE SEQUENCE
image_mean = MEDIAN(datacube)
image_stats = FLTARR(6,zsize)

FOV_mask = BYTARR(xsize,ysize)
FOV_mask[*] = 1.

FOR i = 0,(zsize-1) DO BEGIN 
    ibis_area_statistics,datacube(*,*,i),FOV_mask,all=allstat
    image_stats(*,i)=allstat
ENDFOR

image_mean = MEAN(image_stats(1,*))

; FOR EACH IMAGE SUBTRACT THE MEDIAN VALUE, MULTIPLY BY THE APODIZATION WINDOW AND THEN MULTIPLY BY THE MASK

FOR i = 0,(zsize - 1) DO image_fft[*,*,i] = COMPLEX(((datacube[*,*,i] - image_mean) * apod_window[i]) * FOV_mask)

; TAKE THE FOURIER TRANSFORM OF THE WHITE LIGHT DATA
image_fft = FFT(TEMPORARY(image_fft),-1)

; MULTIPLY THE TRANSFORMED WHITE LIGHT DATA BY THE GRANULAR FILTER CREATED ABOVE
FOR i = 0,(zsize-1) DO image_fft[*,*,i] = (image_fft[*,*,i] * granfilt[*,*,i])

; TAKE THE INVERSE FOURIER TRANSFORM
image_fft = FFT(TEMPORARY(image_fft),1)

; FOR EACH IMAGE RE-ADD THE MEDIAN VALUE AND DIVIDE BY THE APODIZATION WINDOW
; THIS OBTAINS A DATACUBE WHICH HAS ALL 5 MINUTE GLOBAL OSCILLATIONS REMOVED
FOR i = 0,(zsize-1) DO datacube[*,*,i] = FLOAT((ABS(image_fft[*,*,i] + image_mean) - image_mean)/apod_window[i] + image_mean)

RETURN,datacube
END
