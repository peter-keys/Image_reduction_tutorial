

function rnd,fl
	sg=1
	for i=0L,n_elements(fl)-1 do begin
		if(fl(i) ne 0.) then sg = fl(i)/abs(fl(i))
		fl(i)=(fl(i)+sg*.5)
	endfor
return,fix(fl)
end
