;+
; ROUTINE:    ROSA_destretch_Bfield
;
; PURPOSE:    Creates a destretched datacube based upon a co-aligned input datacube
;
; USEAGE:     new_datacube = ROSA_destrech(datacube,xsize,ysize,zsize,cadence)
;
; INPUT:      xsize = x dimension of the input datacube
;             ysize = y dimension of the input datacube
;             zsize = z dimension of the input datacube
;             cadence = cadence between images after reconstruction
;
; OUTPUT:     Destretched ROSA datacube
;                 
; AUTHOR:   David B. Jess, November '08
;
;-

FUNCTION ROSA_destretch_Bfield,datacube,xsize,ysize

loadct,0,/silent
mult,1,1

kernels = [51, 31, 13]

destretched_images  = datacube
im_ref = datacube[*,*,0] 
im_cor = datacube[*,*,1] 
test_reg = reg_loop(im_cor, im_ref, kernels, disp=disp, rdisp=rdisp)
destretched_image = DOREG(im_cor,rdisp[*,*,*],disp[*,*,*])
destretched_images[*,*,0] = im_ref
destretched_images[*,*,1] = destretched_image

RETURN,destretched_images











END
