function bilin,u,x,y
;bilinear interpolator for partial pixel shifts
;IZ, LPARL 1/92

ix=fix(x) & iy=fix(y)
if (abs(ix)+abs(iy)) gt 0 then v=shift(u,ix,iy) else v=u
p=x-ix & q=y-iy
p1=1-p & q1=1-q
return,v*p1*q1+shift(v,1,0)*p*q1+shift(v,0,1)*p1*q+shift(v,1,1)*p*q
end