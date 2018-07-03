;	first_der.pro
;
;	program to find the first derivative of a one-dimensional array
;

function first_der,arr

sz = size(arr)
if sz(0) ne 1 then goto, finishup

firder = arr(1:sz(1)-1)-arr(0:sz(1)-2)

return,firder

finishup:

end
