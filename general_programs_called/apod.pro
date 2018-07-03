;-------------------------------------------------------------
;+
; NAME:
;      APOD
; PURPOSE:
;      This function computes an apodization window for a 2-d
;      fourier transform. 
; CATEGORY:
;      FOURIER ANALYSIS
; CALLING SEQUENCE:
;      ff = apod(nx,ny,px,py,iwin)
; INPUTS:
;      nx = The x-dimension of the 2-d array.
;        type: scalar,integer
;      ny = The y-dimension of the 2-d array.
;        type: scalar,integer
;      px = The percentage from the x-border that you want
;        the apodzation window to slope down to zero until.
;        type: scalar,floating point.
;      py = The percentage from the y-border that you want
;        the apodzation window to slope down to zero until.
;        type: scalar,floating point.
;      iwin = The type of apodization window that you want to
;        use. The apodization windows offered are as follows : 
;        ----------------------------------
;        iwin --------- Apodization window
;        ----------------------------------
;        0 ------------ Hanning window 
;        1 ------------ Hamming window 
;        2 ------------ Blackman window 
;        3 ------------ Exact blackman window 
;        4 ------------ Minimum 3-term window
;        5 ------------ Smooth 3-term window 
;        6 ------------ First Derivative window 
;        7 ------------ Minimum Noise window 
;        8 ------------ Fifth Derivative window 
;        type: scalar,integer.
; KEYWORD PARAMETERS:
; OUTPUTS:
;      ff = The 2-d fourier filter.
;        type: array,floating point,fltarr(nx,ny)
; COMMON BLOCKS:
; NOTES:
;      Thanks to Larry November for telling me about this algorithm.
; MODIFICATION HISTORY:
;      H. Cohl,  23 Apr, 1991 --- Initial implementation.
;-
;-------------------------------------------------------------

function apod,nx,ny,px,py,iwin,help=help

  ;Display idl header if help is required.
  if keyword_set(help) or n_params() lt 5 then begin
    get_idlhdr,'apod.pro'
    xb=-1
    goto,finishup
  endif

  ;Set constants for specific windows.
  pw0=[.5,.5,0.]
  pw1=[.53836,.46164,0.]
  pw2=[.42,.5,.08,0.]
  pw3=[.4265907,.4965606,.0768487,0.]
  pw4=[.42323,.49755,.07922,0.]
  pw5=[.44959,.49364,.05677,0.]
  pw6=[.355768,.487396,.144232,.012604,0.] 
  pw7=[.338946,.481973,.161054,.01827,0.]
  pw8=[.3125,.46875,.1875,.03125,0.]
  ex=execute('ta=pw'+strcompress(string(iwin),/rem))

  N=n_elements(ta)

  wdx=px*nx
  wdy=py*ny

  ix=findgen(nx)
  iy=findgen(ny)

  xrx=abs(ix-.5*(nx-1))-.5*(nx-1)+wdx
  xry=abs(iy-.5*(ny-1))-.5*(ny-1)+wdy

  wx=where(xrx le 0.)
  wy=where(xry le 0.)

  if wx(0) ne -1 then xrx(wx)=0.
  if wy(0) ne -1 then xry(wy)=0.

  xrx=!pi*xrx/(wdx+1.)
  xry=!pi*xry/(wdy+1.)

  xbx=0. & xby=0.

  for i=0,N-1 do begin
    xbx=xbx+ta(i)*cos(i*xrx)
    xby=xby+ta(i)*cos(i*xry)
  endfor

  xb=xbx#transpose(xby)

  finishup:

return,xb

end
