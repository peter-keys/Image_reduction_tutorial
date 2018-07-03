; Possible problem if ny,nx,nt are not all even

function make_gran_filter,nx,ny,nt,dx,dy,dt,cs,reverse=reverse,cutoff=cutoff,tcutoff=tcutoff
  tt=float(nt)*float(dt)
  xx=float(nx)*float(dx)
  ct=cs*tt
  x2 =xx*xx/(ct*ct)
  yy=float(ny)*float(dy)
  y2=yy*yy/(ct*ct)
  ;flt = bytarr(nx,ny,nt)
  flt = fltarr(nx,ny,nt)
  if keyword_set(reverse) then begin
          flt(*,*,*) = 1
          val=0
  endif else begin
          flt(*,*,*) = 0
          val=1
  endelse

; I'll probably need to eliminate all these ifs.
; Might also try to access in memory order

   for i=0,nt/2 do begin
    for k=0,ny/2 do begin
        for j=0,nx/2 do begin
; this next line has been compressed to eliminate common sub-expressions
; the original form is
;       icrit=1.0+cs*tt*sqrt((float(j)^2/(xx*xx))+(float(k)^2/(yy*yy)))
          icrit=1.0+sqrt((float(j)^2/(x2))+(float(k)^2/(y2)))
; can probably do better without the if statement using where or some such
          if i le icrit then flt(j,k,i)=val
       endfor
     endfor
   endfor

  for k=0,nt/2 do begin
    for j=0,ny/2 do begin
      for i=nx-1,(nx/2)+1,-1 do begin
        if flt(nx-i,j,k) eq val then flt(i,j,k) = val
      endfor
    endfor
  endfor

  for k=0,nt/2 do begin
    for j=ny-1,(ny/2)+1,-1 do begin
      for i=0,nx-1 do begin
        if flt(i,ny-j,k) eq val then flt(i,j,k) = val
      endfor
    endfor
  endfor

  ; fill other quadrants of the filter cube keeping in mind the ordering
  ; of fourier transform data


  ; set up top of data cube
  for i=nt-1,(nt/2)+1,-1 do begin
    for j=0,nx-1 do begin
      for k=0,ny-1 do begin
          if flt(j,k,nt-i) eq val then flt(j,k,i) = val
       endfor
    endfor
  endfor

  if keyword_set(cutoff) then begin
        smask=mydist(nx,ny)
        smask=shift(smask,nx/2,ny/2)
        ind=where(smask gt cutoff)
        smask(*)=1
        smask(ind)=0
        smask=shift(smask,nx/2,ny/2)
        for i=0,nt-1 do flt(*,*,i)=flt(*,*,i)*smask
  endif
  if keyword_set(tcutoff) then begin
        nc=rnd(tcutoff*1e-3*dt*nt)
        for i=nc,nt-nc-1 do flt(*,*,i)=0
  endif
return, flt

end

