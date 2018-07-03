;+
;$Id: mask.pro,v 1.6 2009/05/15 17:39:04 nathan Exp $
;
; Project     : STEREO - SECCHI 
;                   
; Name        : MASK
;               
; Purpose     : Widget tool to define a SECCHI Mask or ROI Table.
;               
; Explanation : This tool allows the user to display a SECCHI 
;               image and interactively select the blocks to be 
;		masked (ie. not transmitted).  
;               
; Use         : MASK
;    
; Inputs      : None.
;               
; Opt. Inputs : caller		A structure containing the id of the caller.
;               
; Outputs     : None.
;               
; Opt. Outputs: None.
;               
; Keywords    : None.
;
; Category    : Planning, Scheduling.
;               
; Prev. Hist. : Adapted from SOHO/LASCO. 
;
; Written by  : Ed Esfandiari, NRL, May 2004 - First Version. 
;               
; Modification History:
;              Ed Esfandiari 07/13/04 - Use 4 ROI tables instead of 1.
;              Ed Esfandiari 07/27/04 - Load images and display names.
;              Ed Esfandiari 03/08/05 - Changed grid color.
;              Ed Esfandiari 05/24/05 - Use ccd oriententaion dependant masks.
;              Ed Esfandiari 08/22/06 - Added RETAIN=2 to draw widget.
;              Ed Esfandiari 12/05/06 - Added masktable name_version (from tables_used).
;
; $Log: mask.pro,v $
; Revision 1.6  2009/05/15 17:39:04  nathan
; modifications as of 2009-05-15
;
; Revision 1.4  2005/05/26 20:00:58  esfand
; PT version used to create SEC20050525005 TVAC schedule
;
; Revision 1.3  2005/03/08 20:50:10  esfand
; changed grid color
;
; Revision 1.2  2004/09/01 15:40:44  esfand
; commit new version for Nathan.
;
; Revision 1.1.1.2  2004/07/01 21:19:03  esfand
; first checkin
;
; Revision 1.1.1.1  2004/06/02 19:42:36  esfand
; first checkin
;
;
;-


;__________________________________________________________________________________________________________
;

PRO MASK_EVENT, event

COMMON MASK_SHARE, maskv
COMMON OS_ALL_SHARE, ccd, ip, ipd, ex, exd, occ_blocks, roi_blocks, fpwl, fpwld
COMMON DIALOG, mdiag,font
COMMON SCHED_SHARE, schedv


    RESTORE, GETENV('PT')+'/IN/OTHER/ccd_size.sav' ;=> xyblks,xyblkpix,xypix,xstart,ystart

    CASE (event.id) OF

	maskv.prnt : BEGIN
           blks= maskv.blocks
           selected = WHERE(blks EQ 1, num)
           chng_arr= INTARR(xyblks*xyblks)
           IF (num GT 0) THEN BEGIN
             ;change= MODIFY_MASK_ORDER(selected) ; change order of selection from idl to mask_table
             spid= ['AB','A','B']
             IF (DATATYPE(schedv) EQ 'UND') THEN $
               sc= 1 $
             ELSE $
               sc=schedv.sc
             IF (sc EQ 0) THEN sc=1  ; use SC-A if AB is used.
             sc= spid(sc)
             camtable= ['EUVI','COR1','COR2','HI1','HI2']
             cam= camtable(maskv.tele) 
             change= MODIFY_MASK_ORDER(sc,cam,selected) ; change order of selection from idl to mask_table
             chng_arr(change)= 1
           ENDIF
           IF (DATATYPE(mdiag) NE 'UND') THEN $
             WIDGET_CONTROL,mdiag,SET_VALUE='Number of blocks selected = '+STRN(num)
           PRINT, 'Mask Array:'
           PRINT, chng_arr, FORMAT='(34Z2)'  ; print the 1156 element mask array as a 34x34 square.
           PRINT, 'Number of blocks selected = ', num
             
           out = FIND_DATA_RUNS(INDGEN(xyblks*xyblks),chng_arr,0,0,1)
           str = 'Blocks = ('
           FOR i=0, (N_ELEMENTS(out)/2)-1 DO BEGIN
              str = str + STRTRIM(STRING(out(i,0)),2) + '-' + STRTRIM(STRING(out(i,1)),2) + ','
           ENDFOR
           str = STRMID(str,0,STRLEN(str)-1) + ')'
           PRINT, str
	END

        maskv.showgrid : BEGIN
           WSET, maskv.draw_win
           CASE (maskv.grid) OF
              0 : BEGIN		;SHOW GRID
                 WIDGET_CONTROL, maskv.showgrid, SET_VALUE=maskv.grid_types(1)        ;** change labels
                 DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_gmap]
                 maskv.grid = 1
              END
              1 : BEGIN		;HIDE GRID
                 WIDGET_CONTROL, maskv.showgrid, SET_VALUE=maskv.grid_types(0)        ;** change labels
                 DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_map]
                 maskv.grid = 0
              END
              ELSE : BEGIN
              END
           ENDCASE
        END
 
        maskv.loadimage : BEGIN
           telstr=''
           CASE maskv.tele OF
             0: telstr='euvi'
             1: telstr='cor1'
             2: telstr='cor2'
             3: telstr='hi1'
             4: telstr='hi2'
           ENDCASE

           newfile = PICKFILE(/READ, FILTER=telstr+'*.fts', PATH= GETENV('PT')+'/IN/FTS/', $
                              /FIX_FILTER, /NOCONFIRM, /MUST_EXIST)
           IF (newfile NE '') THEN BEGIN
             WIDGET_CONTROL, /HOUR
             WSET, maskv.draw_win
             ERASE, COLOR=maskv.gcol
             img = SCCREADFITS(newfile,hdr)
             ;img = READFITS(newfile)
             img = CONGRID(img, maskv.ms, maskv.ms)
             ;std = STDEV(img, mn)
             ;img = BYTSCL(img, 0, mn+4*std, TOP=255-10)		;** leave 10 colors unallocated
             img = BYTSCL(img, min=0, max=MAX(img)/2, TOP=255-10)	;** leave 10 colors unallocated
             img = img + 10
             WSET, maskv.img_map
             TV, img
             WSET, maskv.mask_map
             temp = INTARR(maskv.ms,maskv.ms) + maskv.gcol
             TV, temp
             WSET, maskv.new_map
             TV, img
             WSET, maskv.new_gmap
             TV, img
             FOR i=0,xyblks-1 DO PLOTS, [i*maskv.bs,i*maskv.bs], [0,maskv.ms], /DEVICE, COLOR=0
             FOR i=0,xyblks-1 DO PLOTS, [0,maskv.ms], [i*maskv.bs,i*maskv.bs], /DEVICE, COLOR=0

             selected = WHERE(maskv.blocks EQ 1)
             IF (selected(0) NE -1) THEN BEGIN
               FOR i=0,N_ELEMENTS(selected)-1 DO BEGIN
                 yc = selected(i)/xyblks*maskv.bs
                 xc = (selected(i) - selected(i)/xyblks*xyblks)*maskv.bs
                 WSET, maskv.new_map  & DEVICE, COPY = [xc, yc, maskv.bs, maskv.bs, xc, yc, maskv.mask_map]
                 WSET, maskv.new_gmap & DEVICE, COPY = [xc, yc, maskv.bs, maskv.bs, xc, yc, maskv.mask_map]
               ENDFOR
             ENDIF
             LOADCT, 0, /SILENT
             TVLCT, 142, 229, 238, maskv.gcol
             WSET, maskv.draw_win 
             IF (maskv.grid) THEN $
               DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_gmap] $
             ELSE $
               DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_map]

             toks= STR_SEP(newfile,'/')
             WIDGET_CONTROL, maskv.img_lab, SET_VALUE= toks(N_ELEMENTS(toks)-1) 
           ENDIF
        END

	maskv.draw_w : BEGIN	;** event in draw window
           IF (event.press NE 0) THEN maskv.press = event.press
           IF (event.release NE 0) THEN maskv.press = 0B
           IF (maskv.press NE 0) THEN BEGIN	;** button select
              x = 0 > event.x < (maskv.ms-1)
              y = 0 > event.y < (maskv.ms-1)
              ;bf = 1024./maskv.ms			;** block factor
              bf = FLOAT(xyblks*xyblks)/maskv.ms			;** block factor
              block = FIX(bf*x/xyblks) + FIX(bf*y/xyblks)*xyblks
              yc = block/xyblks*maskv.bs
	      xc = (block - block/xyblks*xyblks)*maskv.bs
              CASE (maskv.press) OF
                ; 1B: BEGIN	;** Left mouse button; select block
                ;    maskv.blocks(block) = 1		
                ;    WSET, maskv.new_map  & DEVICE, COPY = [xc, yc, maskv.bs, maskv.bs, xc, yc, maskv.mask_map]
                ;    WSET, maskv.new_gmap & DEVICE, COPY = [xc, yc, maskv.bs, maskv.bs, xc, yc, maskv.mask_map]
                ;    IF (maskv.type EQ 'OCCULTER') THEN occ_blocks(maskv.tele,*) = maskv.blocks ELSE $
                ;    IF (maskv.type EQ 'ROI') THEN roi_blocks(maskv.tele,*,maskv.table) = maskv.blocks
                ; END
                ; 2B: BEGIN 	;** Middle mouse button; de-select block
                ;    maskv.blocks(block) = 0 
                ;    WSET, maskv.new_map  & DEVICE, COPY = [xc, yc, maskv.bs, maskv.bs, xc, yc, maskv.img_map]
                ;    WSET, maskv.new_gmap & DEVICE, $
                ;          COPY = [xc+1, yc+1, maskv.bs-1, maskv.bs-1, xc+1, yc+1, maskv.img_map]
                ;    IF (maskv.type EQ 'OCCULTER') THEN occ_blocks(maskv.tele,*) = maskv.blocks ELSE $
                ;    IF (maskv.type EQ 'ROI') THEN roi_blocks(maskv.tele,*,maskv.table) = maskv.blocks
                ; END
                 1B: BEGIN	;** Left mouse button; select block
                     END 
                 2B: BEGIN     ;** Middle mouse button; de-select block
                     END
                 4B: BEGIN 	;** Right mouse button; adjust color table
                    nc  = ROUND((FLOAT(y)/maskv.ms)*!D.TABLE_SIZE)
                    cen = ROUND((FLOAT(x)/maskv.ms)*!D.TABLE_SIZE)
                    c0 = (cen - nc/2) > 0 < (!D.TABLE_SIZE-1)
                    c1 = (cen + nc/2) > 0 < (!D.TABLE_SIZE-1)
                    p = INTARR(!D.TABLE_SIZE)
                    IF (cen GT 0) THEN p(0:cen-1) = 0
                    IF (cen LT !D.TABLE_SIZE-1) THEN p(cen:!D.TABLE_SIZE-1) = 255
                    IF (c0 NE c1) THEN p(c0:c1-1) = BYTSCL(INDGEN(c1-c0)*!D.TABLE_SIZE, TOP=255-10)
                    TVLCT, p,p,p, maskv.gcol+1
                 END
              ENDCASE
              WSET, maskv.draw_win
              IF (maskv.grid) THEN $
                DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_gmap] $
              ELSE $
                DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_map]
           ENDIF
	END

	maskv.quit : BEGIN	;** exit program
	   WIDGET_CONTROL, /DESTROY, maskv.base
	END

	maskv.helpb : BEGIN	;** help text
           help_str = STRARR(10)
           help_str(0) = 'Use the right mouse button (press and drag) to adjust the color table.'
           POPUP_HELP, help_str, TITLE="MASK TOOL HELP"
	END

	maskv.telepd : BEGIN	;** select telescope table

           IF (event.index EQ maskv.tele) THEN RETURN

           maskv.tele = event.index

           maskv.blocks(*) = 0

           TVLCT, 180,95,85, 10 ; dark brown is backgrogund
           img = BYTARR(maskv.ms,maskv.ms) & img = img + 10 ; set to background color

           IF (maskv.type EQ 'OCCULTER') THEN maskv.blocks = occ_blocks(maskv.tele,*) ELSE $
           IF (maskv.type EQ 'ROI') THEN maskv.blocks = roi_blocks(maskv.tele,*,maskv.table)

           ;WSET, maskv.new_map  & DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.img_map]
           ;WSET, maskv.new_gmap & DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.img_map]

           ; Since a new telescope is selected, get rid of the currently loaded image, if any, and
           ; only display the background and the grid:

           WSET,maskv.new_map & TV, img
           WSET,maskv.img_map  & DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_map]
           WSET,maskv.new_gmap & TV, img

           FOR i=0,xyblks-1 DO PLOTS, [i*maskv.bs,i*maskv.bs], [0,maskv.ms], /DEVICE, COLOR=0
           FOR i=0,xyblks-1 DO PLOTS, [0,maskv.ms], [i*maskv.bs,i*maskv.bs], /DEVICE, COLOR=0
           selected = WHERE(maskv.blocks EQ 1)
           IF (selected(0) NE -1) THEN BEGIN
             FOR i=0,N_ELEMENTS(selected)-1 DO BEGIN
               yc = selected(i)/xyblks*maskv.bs
               xc = (selected(i) - selected(i)/xyblks*xyblks)*maskv.bs
               WSET, maskv.new_map  & DEVICE, COPY = [xc, yc, maskv.bs, maskv.bs, xc, yc, maskv.mask_map]
               WSET, maskv.new_gmap & DEVICE, COPY = [xc, yc, maskv.bs, maskv.bs, xc, yc, maskv.mask_map]
             ENDFOR
           ENDIF
           WSET, maskv.draw_win
           IF (maskv.grid) THEN $
             DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_gmap] $
           ELSE $
             DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_map]

           WIDGET_CONTROL, maskv.img_lab, SET_VALUE=' ' 
           
	END

        maskv.tabpd : BEGIN 
           IF (maskv.type EQ 'ROI') THEN BEGIN
             ; clear blocks currently displayed:
             maskv.blocks(*) = 0
             WSET, maskv.new_map  & DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.img_map]
             WSET, maskv.new_gmap & DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.img_map]
             FOR i=0,xyblks-1 DO PLOTS, [i*maskv.bs,i*maskv.bs], [0,maskv.ms], /DEVICE, COLOR=0
             FOR i=0,xyblks-1 DO PLOTS, [0,maskv.ms], [i*maskv.bs,i*maskv.bs], /DEVICE, COLOR=0
             WSET, maskv.draw_win
             IF (maskv.grid) THEN $
               DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_gmap] $
             ELSE $
               DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_map]

             maskv.table= event.index
             maskv.blocks = roi_blocks(maskv.tele,*,maskv.table)
             ;WSET, maskv.new_map  & DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.img_map]
             ;WSET, maskv.new_gmap & DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.img_map]
             FOR i=0,xyblks-1 DO PLOTS, [i*maskv.bs,i*maskv.bs], [0,maskv.ms], /DEVICE, COLOR=0
             FOR i=0,xyblks-1 DO PLOTS, [0,maskv.ms], [i*maskv.bs,i*maskv.bs], /DEVICE, COLOR=0
             selected = WHERE(maskv.blocks EQ 1)
             IF (selected(0) NE -1) THEN BEGIN
               FOR i=0,N_ELEMENTS(selected)-1 DO BEGIN
                 yc = selected(i)/xyblks*maskv.bs
                 xc = (selected(i) - selected(i)/xyblks*xyblks)*maskv.bs
                 WSET, maskv.new_map  & DEVICE, COPY = [xc, yc, maskv.bs, maskv.bs, xc, yc, maskv.mask_map]
                 WSET, maskv.new_gmap & DEVICE, COPY = [xc, yc, maskv.bs, maskv.bs, xc, yc, maskv.mask_map]
               ENDFOR
             ENDIF
             WSET, maskv.draw_win
             IF (maskv.grid) THEN $
               DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_gmap] $
             ELSE $
               DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_map]
           ENDIF
        END

        ELSE : BEGIN
        END

   ENDCASE

END

;__________________________________________________________________________________________________________
;

PRO MASK, caller

COMMON MASK_SHARE
COMMON OS_ALL_SHARE, ccd, ip, ipd, ex, exd, occ_blocks, roi_blocks, fpwl, fpwld
COMMON TABLES_IN_USE, tables_used

;help,roi_blocks

    RESTORE,GETENV('PT')+'/IN/OTHER/ccd_size.sav' ;=> xyblks,xyblkpix,xypix,xstart,ystart

    IF XRegistered("MASK") THEN BEGIN
       WIDGET_CONTROL, caller.id, GET_UVALUE=type
       maskv.type = type
       title = type+' TABLE'
       IF (DATATYPE(tables_used) NE 'UND') THEN title= title+' ('+tables_used(2)+')' 

       WIDGET_CONTROL, maskv.base, TLB_SET_TITLE=title
       IF (maskv.type EQ 'OCCULTER') THEN maskv.blocks = occ_blocks(maskv.tele,*) ELSE $
       IF (maskv.type EQ 'ROI') THEN maskv.blocks = roi_blocks(maskv.tele,*,maskv.table)
       WSET, maskv.new_map  & DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.img_map]
       WSET, maskv.new_gmap & DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.img_map]
       FOR i=0,xyblks-1 DO PLOTS, [i*maskv.bs,i*maskv.bs], [0,maskv.ms], /DEVICE, COLOR=0
       FOR i=0,xyblks-1 DO PLOTS, [0,maskv.ms], [i*maskv.bs,i*maskv.bs], /DEVICE, COLOR=0
       selected = WHERE(maskv.blocks EQ 1)
       IF (selected(0) NE -1) THEN BEGIN
         FOR i=0,N_ELEMENTS(selected)-1 DO BEGIN
           yc = selected(i)/xyblks*maskv.bs
           xc = (selected(i) - selected(i)/xyblks*xyblks)*maskv.bs
           WSET, maskv.new_map  & DEVICE, COPY = [xc, yc, maskv.bs, maskv.bs, xc, yc, maskv.mask_map]
           WSET, maskv.new_gmap & DEVICE, COPY = [xc, yc, maskv.bs, maskv.bs, xc, yc, maskv.mask_map]
         ENDFOR
       ENDIF
       WSET, maskv.draw_win
       IF (maskv.grid) THEN $
         DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_gmap] $
       ELSE $
         DEVICE, COPY = [0, 0, maskv.ms, maskv.ms, 0, 0, maskv.new_map]
       RETURN
    ENDIF

    ;ms = 640

    IF xyblks EQ 32 THEN ms = 640
    IF xyblks EQ 34 THEN ms = 680

    bs = ms/xyblks ;** block size
    blocks = BYTARR(xyblks*xyblks)
    press = 0B
    title = 'SECCHI MASK TOOL'
    tab_info= ''
    
    IF (DATATYPE(tables_used) NE 'UND') THEN tab_info= ' ('+tables_used(2)+')'
    title= title+tab_info 
    tele_type = [ "  EUVI Table  ", $
                  "  COR1 Table  ", $
                  "  COR2 Table  ", $
                  "  HI1 Table  ", $
                  "  HI2 Table "]

    IF ((SIZE(maskv))(1) EQ 0) THEN BEGIN          ;** not defined yet use default
       tele = 0
       grid = 1
       type = ''			;** occulter, or mask; for scheduling program
       table= 0
    ENDIF ELSE BEGIN
       tele = maskv.tele
       grid = maskv.grid
       type = maskv.type
       table = maskv.table
    ENDELSE


    ;********************************************************************
    ;** SET UP WIDGETS **************************************************

    tables= ["  "]
    msg= "      "
    msg1="      "

    IF (KEYWORD_SET(caller)) THEN BEGIN
       WIDGET_CONTROL, caller.id, GET_UVALUE=type
       IF (type EQ 'OCCULTER') THEN BEGIN
          blocks = occ_blocks(tele,*) 
          title = 'OCCULTER MASK TABLE'
          title= title+tab_info 
          msg1= '                                                                 '
          table=0
          tables= ["OCC Table"]
       ENDIF ELSE IF (type EQ 'ROI') THEN BEGIN
          blocks = roi_blocks(tele,*,table)
          title = 'ROI MASK TABLE'
          title= title+tab_info 
          msg1= ' IP function/step #25, 45, 46, or 47 determines which table to use'
          tables= ["ROI1 Table", $
                   "ROI2 Table", $
                   "ROI3 Table", $
                   "ROI4 Table"]
       ENDIF
       base = WIDGET_BASE(/COLUMN, TITLE=title, /FRAME, GROUP_LEADER=caller.id)
    ENDIF ELSE $
       base = WIDGET_BASE(/COLUMN, TITLE=title, /FRAME)

    row = WIDGET_BASE(base, /ROW)
      telepd = CW_BSELECTOR2(row, tele_type, SET_VALUE=tele)
      tabpd = CW_BSELECTOR2(row, tables, SET_VALUE=table)
      lab = WIDGET_LABEL(row, VALUE = msg1)
      draw_w = WIDGET_DRAW(base, XSIZE=ms, YSIZE=ms, /BUTTON_EVENTS, /MOTION_EVENTS, RETAIN=2)
      ;draw_w = WIDGET_DRAW(base, XSIZE=ms, YSIZE=ms, RETAIN=2) 

    row = WIDGET_BASE(base, /ROW)
      grid_types = ['   Show Grid   ','   Hide Grid   ']
      tmp = WIDGET_LABEL(row, VALUE = msg)

      showgrid = WIDGET_BUTTON(row, VALUE=grid_types(1))
      loadimage  = WIDGET_BUTTON(row, VALUE='  Load Image   ')
      font1='-adobe-times-bold-r-normal--14-140-75-75-p-77-iso8859-1'
      img_lab = WIDGET_LABEL(row, VALUE= '                                                              ',$
                             FONT= font1)
      tmp = WIDGET_LABEL(row, VALUE = msg+msg)
      helpb = WIDGET_BUTTON(row, VALUE='  HELP  ')
    row = WIDGET_BASE(base, /ROW)
      tmp = WIDGET_LABEL(row, VALUE = msg+msg+msg+msg+msg+msg+msg+msg+msg+msg+msg+msg)
      prnt = WIDGET_BUTTON(row, VALUE=' Print Mask ')
    quit = WIDGET_BUTTON(base, VALUE=" Dismiss ")

    ;********************************************************************
    ;** REALIZE THE WIDGETS *********************************************

    WIDGET_CONTROL, base, /REALIZE
    WIDGET_CONTROL, draw_w, GET_VALUE=draw_win
    WIDGET_CONTROL, /HOUR
    WIDGET_CONTROL, helpb, SENSITIVE=1
    WIDGET_CONTROL, showgrid, SENSITIVE=1

;    gcol = 9	;** color index for grid
    gcol = 11 ;** color index for grid ; AEE
    ;img = READFITS('/home/argus/scott/images/occulter/c2.fits')
    IF ((SIZE(img))(0) NE 2) THEN img = BYTARR(ms,ms) $
    ELSE BEGIN
       img = CONGRID(img, ms, ms)
       std = STDEV(img, mn)
       img = BYTSCL(img, 0, mn+4*std, TOP=255-10)		;** leave 10 colors unallocated
    ENDELSE
    img = img + 10
    TVLCT, 180,95,85, 10   ;** load dull dark brown into entry 10
    img_map = 29
    WINDOW, img_map, XSIZE=ms, YSIZE=ms, /PIXMAP
    TV, img
    mask_map = 30
    WINDOW, mask_map, XSIZE=ms, YSIZE=ms, /PIXMAP
    temp = INTARR(ms,ms) + gcol
    TVLCT, 142,229,238, gcol  ;** load light blue into entry 11 - used by mask.pro
    TV, temp
    new_map = 31
    WINDOW, new_map, XSIZE=ms, YSIZE=ms, /PIXMAP
    TVLCT, 180,95,85, 10   ;** load dull dark brown into entry 10
    TV, img
    new_gmap = 28
    WINDOW, new_gmap, XSIZE=ms, YSIZE=ms, /PIXMAP
    TV, img
    FOR i=0,xyblks-1 DO PLOTS, [i*bs,i*bs], [0,ms], /DEVICE, COLOR=0
    FOR i=0,xyblks-1 DO PLOTS, [0,ms], [i*bs,i*bs], /DEVICE, COLOR=0

    ;** if blocks were set at some previous time reset them
    selected = WHERE(blocks EQ 1)
    IF (selected(0) NE -1) THEN BEGIN
      FOR i=0,N_ELEMENTS(selected)-1 DO BEGIN
        yc = selected(i)/xyblks*bs
        xc = (selected(i) - selected(i)/xyblks*xyblks)*bs
        WSET, new_map  & DEVICE, COPY = [xc, yc, bs, bs, xc, yc, mask_map]
        WSET, new_gmap & DEVICE, COPY = [xc, yc, bs, bs, xc, yc, mask_map]
      ENDFOR
    ENDIF

    LOADCT, 0, /SILENT

; TVLCT, 255,0,0, 1      ;** load red into entry 1
; TVLCT, 0,255,0, 2      ;** load green into entry 2
; TVLCT, 142,229,238, 3  ;** load blue into entry 3
; TVLCT, 255,255,0,4     ;** load yellow into entry 4
; TVLCT, 200,0,0, 5      ;** load dull red into entry 5
; TVLCT, 0,200,0, 6      ;** load dull green into entry 6
; TVLCT, 0,206,237, 7    ;** load dull blue into entry 7
; TVLCT, 200,200,0,8     ;** load dull yellow into entry 8
; TVLCT, 142,229,238, 9  ;** load light blue into entry 9 - used by mask.pro

; AEE changed here and in schedule.pro and mask_old.pro

 TVLCT, 255,0,0, 1      ;** load red into entry 1
 TVLCT, 0,255,0, 2      ;** load green into entry 2
 TVLCT, 142,229,238, 3  ;** load blue into entry 3
 TVLCT, 255,255,0,4     ;** load yellow into entry 4
 TVLCT, 204,117,89, 5   ;** load brown  into entry 5
 TVLCT, 200,0,0, 6      ;** load dull red into entry 6
 TVLCT, 0,200,0, 7      ;** load dull green into entry 7
 TVLCT, 0,206,237, 8    ;** load dull blue into entry 8
 TVLCT, 200,200,0, 9    ;** load dull yellow into entry 9
 TVLCT, 180,95,85, 10   ;** load dull dark brown into entry 10
 TVLCT, 142,229,238, 11  ;** load light blue into entry 11 - used by mask.pro

    WSET, draw_win 
    IF (grid) THEN $
      DEVICE, COPY = [0, 0, ms, ms, 0, 0, new_gmap] $
    ELSE $
      DEVICE, COPY = [0, 0, ms, ms, 0, 0, new_map]

    maskv = CREATE_STRUCT( 'base', base,	 	$
                           'quit', quit, 		$
                           'telepd', telepd, 		$
                           'tabpd', tabpd,              $
                           'table', table,              $
                           'helpb', helpb, 		$
                           'draw_win', draw_win, 	$
                           'draw_w', draw_w, 		$
                           'bs', bs, 			$
                           'ms', ms, 			$
                           'blocks', blocks,		$
                           'img_lab', img_lab,          $
                           'img_map', img_map, 		$
                           'mask_map', mask_map, 	$
                           'new_map', new_map, 		$
                           'new_gmap', new_gmap, 	$
                           'grid', grid, 		$
                           'gcol', gcol, 		$
                           'press', press, 		$
                           'showgrid', showgrid, 	$
                           'grid_types', grid_types, 	$
                           'prnt', prnt, 		$
                           'type', type, 		$
                           'tele', tele, 		$
                           'loadimage', loadimage)

   XMANAGER, 'MASK', base

   SETUP_PT_COLOR_TBL

END
