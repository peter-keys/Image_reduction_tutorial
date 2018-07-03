

;+
; NAME:
;    	TR_GET_DISP.PRO
;
; PURPOSE:
;	Given a datacube of images, measure the rigid displacement
;	between each image and the first in the cube and optionally
;	shift each image to coalign the entire cube.  Uses a centered
;	2^n x 2^n window for coalignment.  Finds the whole-pixel
;	shift of maximum cross-correlation, then interpolates for
;	fractional pixel part either on cross-correlation function or
;	optionally on an array of squared mean absolute deviations (MAD).  
;	Shifts may be accurate to a few tenths of a pixel but don't
;	expect much better than that.
;
; CALLING SEQUENCE:
;	disp = tr_get_disp(data [,/shift][,mad=mad][,/debug])
;
; INPUTS:
;	data -- data cube of images, size (NX,NY,NT); 
;	        data(*,*,0)= reference image to which others are aligned
;
; KEYWORD PARAMETERS:
;	shift -- if set, data(*,*,1:*) are shifted to match the reference
;	mad -- if non-zero, use mad x mad array of MAD residuals to
;	        find final displacement; if 0 < mad < 5, uses 5x5 array
;	        USE ONLY IF IMAGES ARE SAME WAVELENGTHS AND EXPOSURE LEVELS
;	nowindow -- use the full frame in stead of centered window
;	debug  -- prints out parts of cross-correlation & MAD arrays
;
; OUTPUTS:
;	Returns array of displacements disp = fltarr(2,NT)
;	The sense is that data(i,j,0) <==> data(i-disp(0,k),j-disp(1,k),k)
;
;	You can shift the images afterwards using data = shift_img(data, disp)
;
; TO DO:
;	Needs better 2-D interpolation of sub-pixel displacement 
;	Needs better handling when mad x mad doesn't include the minimum
;
; MODIFICATION HISTORY:
;	29-Jan-98 (TDT) - adapted get_disp from H. Lin's flat fielding package ccdcal5.pro
;	 1-Jul-98 (TDT) - added shift keyword, shift_img using poly_2d
;	11-Sep-98 (TDT) - variable MAD search area, fixed bug in subarea size 
;	22-Sep-98 (TDT) - added cross-correlation only feature
;	 1-Oct-98 (TDT) - renamed tr_get_disp and put on-line
;	26-Oct-08 (AdW) - added nowindow option to align on the whole frame
;
;-

;  is_in_range		true where x is inside the interval [lo,hi]
;
function is_in_range, x, lo, hi
   return, (x ge lo) and (x le hi)
   end

;  hanning		alternative (flatter than one in ~idl/lib)
;			Hanning function.
;
;From H. Lin's file ccdcal5.pro, 29-Jan-98
;modified to not be square
function hanning, n, m

x = fltarr (n) + 1.0
y = fltarr (m) + 1.0
tenth =  long (n*.2)
cons = !pi/tenth
for i = 0,tenth do begin
   x(i) = (1.0 - cos (i*cons))/2.0
   x(n-i-1) = x(i)
endfor
tenth =  long (m*.2)
cons = !pi/tenth
for i = 0,tenth do begin
   y(i) = (1.0 - cos (i*cons))/2.0
   y(m-i-1) = y(i)
endfor

return, x # y
end

; shift_img		shift image by given offsets, using IDL 
;			routine poly_2d with cubic interpolation
;			Works on single image or datacube

function shift_img,img,offsets
sz = size(img)
if (sz(0) eq 2) then $
  return, poly_2d(img,[-offsets(0),0.,1.,0.],[-offsets(1),1.,0.,0.],cubic=-0.5)
if (sz(0) eq 3) then for i=0,sz(3)-1 do $
  img(*,*,i) = poly_2d(img(*,*,i),[-offsets(0,i),0.,1.,0.],[-offsets(1,i),1.,0.,0.],cubic=-0.5)
return,img
end
;
;  tr_get_disp	get the image displacements
;
;  Method: Correlation tracks the image sequence using a power-of-2
;  square area centered on the image(s).  First image of sequence
;  is the reference.  Returns array of pixel displacements of images
;  with respect to first image.
; The sense is that data(i,j,0) <==> data(i-disp(0,k),j-disp(1,k),k)
; Changed by TDT to return fractional pixel offsets,
;   added MAD algorithm  29-Jan-98
;   added shift keyword, 1-Jul-98:  if set, shifts all images to match img(*,*,0)
;   variable MAD search area (def = 5x5), fixed bug in subarea size, 11-Sep-98

; Sample calling sequences:
;  disp = tr_get_disp(data)
;  disp = tr_get_disp(data, /shift)
;  disp = tr_get_disp(data, /debug, mad=9)

function tr_get_disp, data, shift=shift, mad=mad, debug=debug, nowindow=nowindow

if not keyword_set(mad) then mad=0
nmad = mad > 5
nmad = 2*(nmad/2)+1
nmad2 = (nmad-1)/2
if not keyword_set(shift) then shift=0
if not keyword_set(debug) then debug=0
errorstring = 'Minimum MAD not in '+string(nmad,format='(I2)')+'^2 area--image #, xmin, ymin:'

sz = size(data)
nx = sz(1) & ny = sz(2) & nz = sz(3)
disp = fltarr (2,nz)

; ADW  20081025  option to use full frame
if keyword_set(nowindow) then begin
	nnx = nx
	nny = ny
endif else begin
	; TDT  11-Sep-98  added + 1.e-5 to make this work right!
	nnx = 2^long (alog10 (min ([nx, ny]))/.30103 + 1.e-5)
	nny = nnx
endelse

; TDT 29-Jan-98  added float to this next statement
nnsqd = float(nnx)*float(nny)
appodize = hanning (nnx, nny)

ref = data ((nx-nnx)/2:(nx+nnx)/2-1, (ny-nny)/2:(ny+nny)/2-1, 0)

tref = conj (fft ((ref-total(ref)/nnsqd)*appodize, -1))

for i = 1, nz-1 do begin
   scene = data ((nx-nnx)/2:(nx+nnx)/2-1,(ny-nny)/2:(ny+nny)/2-1, i)
   tscene = fft ((scene-total(scene)/nnsqd)*appodize, -1)
   cc = shift (abs (fft (tref*tscene, 1)), nnx/2, nny/2)
   printerror = 1

   mx = max (cc, loc)		; locate peak of Cross Correlation
   xmax0 = loc mod nnx
   ymax0 = loc/nnx
   xmax = ( (xmax0 > nmad2) < (nnx-nmad2-1) )
   ymax = ( (ymax0 > nmad2) < (nny-nmad2-1) )
   if debug then begin 
   	print,'Fourier Cross-correlation Peak: ',xmax0,ymax0
	print,cc(xmax-2:xmax+2,ymax-2:ymax+2), format='(5F8.1)'
   endif
   cc = -cc(xmax-nmad2:xmax+nmad2,ymax-nmad2:ymax+nmad2)
   
;   if (is_in_range (xmax,5,nnx-6) and is_in_range(ymax,5,nny-6) and (mad ne 0)) then begin
   if (mad) then begin

; Mean Absolute Difference algorithm centered on xmax & ymax

	cc = fltarr(nmad,nmad)
	dx = nnx/2-xmax
	dy = nny/2-ymax
	nnx2 = (nnx/2-abs(dx)-nmad2-1)/2
	nxl = nnx/2-nnx2
	nxh = nnx/2+nnx2
	nny2 = (nny/2-abs(dy)-nmad2-1)/2
	nyl = nny/2-nny2
	nyh = nny/2+nny2
	area = float(nxh-nxl+1)*float(nyh-nyl+1)

	for idx=-nmad2,nmad2 do begin
	for idy=-nmad2,nmad2 do begin
	cc(idx+nmad2,idy+nmad2)=total(appodize(nxl:nxh,nyl:nyh)*abs(ref(nxl:nxh,nyl:nyh) - $
	  scene(nxl-dx+idx:nxh-dx+idx,nyl-dy+idy:nyh-dy+idy)))/area
	endfor
	endfor
	cc = cc^2
	if debug then begin
	  print,'Squared MAD array:'
	  print,cc, format='('+string(nmad,format='(i2)')+'F8.1)'
	endif

     endif
; Locate minimum of MAD^2 or -Cross-correlation function
;   hope nmad x nmad is big enough to include minimum
	mx = min (cc, loc)		
	xmax7 = loc mod nmad
	ymax7 = loc/nmad
; 3 point parabolic fit, following Niblack, W.: Digital Image Processing,
; Prentice/Hall, 1986, p 139. 
; Need better 2-D peak interpolation routine here!
	if (xmax7 gt 0 and xmax7 lt (nmad-1) ) then begin
	  denom = mx*2 - cc(loc-1) - cc(loc+1)
	  xfra = (mx-cc(loc-1))/denom
	endif else begin 
	  xfra = 0
	  if (printerror) then print,errorstring,i,xmax7-nmad2,ymax7-nmad2
	  printerror=0
	endelse
	if (ymax7 gt 0 and ymax7 lt (nmad-1) ) then begin
	  denom = mx*2 - cc(loc-nmad) - cc(loc+nmad)
	  yfra = (mx-cc(loc-nmad))/denom
	endif else begin 
	  yfra = 0
	  if (printerror) then print,errorstring,i,xmax7-nmad2,ymax7-nmad2
	  printerror=0
	endelse

	xfra = xfra + xmax7 - nmad2-0.5
	yfra = yfra + ymax7 - nmad2-0.5
	if debug then print,xfra,yfra,format='("Fractional dx, dy: ",2F10.3)'
	xmax = xfra + xmax 
	ymax = yfra + ymax 

;      endif

   disp(0,i) = (nnx/2-xmax)
   disp(1,i) = (nny/2-ymax)
   
   if debug then print, i, disp(0,i), disp(1,i), $
     format='("Image ",I4, "    Final offsets ",2F10.2,/)'
   if (shift) then data(*,*,i) = shift_img(data(*,*,i),disp(*,i))
   endfor
   
return, disp
end

