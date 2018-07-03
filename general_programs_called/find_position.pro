FUNCTION find_position, INPOS, time_0, time_1,in_arcsec=in_arcsec,out_arcsec=out_arcsec

;+
; NAME:
;        FIND_POSITION
; PURPOSE:
;        little piece of code to calculate position, for coordination with IRIS
;        and others, who use mainly [x,y] in arcsec, while DST works best with heliographic
;        coordinates
; METHOD:
;        uses mainly conv_h2a (helio to arcsec) and conv_a2h (arcsec to helio) from the SSW
;        code. Sign convention: Positive x = W; positive y = N
;        Uses standard law for differential rotation: 
;        Delta phi = A + B*(sin(lat))^2 + C*(sin(lat))^4
;        with Delta phi = degrees/day; A=14.7; B=-2.4; C=-1.8
; CALLING SEQUENCE:
;        pos_out=find_position(INPOS,time_0,time_1)
;        pos_out=find_position(INPOS,time_0,time_1,/in_arcsec)
;        pos_out=find_position(INPOS,time_0,time_1,/out_arcsec)
; INPUT:
;        INPOS   - position angle from sun center in default units of
;                degrees.  [x,y], with
;                    x = angle in E/W direction with W positive
;                    y = angle in N/S direction with N positive
;        time_0  -  date and time of input position - string, format: 'dd-Mon-yyyy hh:mm:ss.dd' 
;        time_1  -  date and time of output position - string, format: 'dd-Mon-yyyy hh:mm:ss.dd'
; OUTPUT:
;       pos_out  - position angle of INPOS projected from time_0 to time_1  
;                  same sign convention as INPOS;  default units of degrees
;                  Output is FLOAT (or DOUBLE if input is DOUBLE)
; OPTIONAL KEYWORD INPUT:
;       in_arcsec - if set, input coordinates are in arcsec on projected disk
; OPTIONAL KEYWORD OUTPUT:
;       out_arcsec - if set, input coordinates are in arcsec on projected disk
; CALLS:        ANYTIM2INTS, CONV_A2H, CONV_H2A                                            
; HISTORY:
;       Written by G. Cauzzi Oct-16
;-


; just a reminder: time_now = !stime
; time_1 is usually AFTER time_0


t0=anytim2ints(time_0) ; structure; day + ms from beginning of day
t1=anytim2ints(time_1)

delta_t=(t1.day-t0.day)+(t1.time-t0.time)/1000./86400. ; in days

if keyword_set(in_arcsec) then helio=conv_a2h(INPOS,time_0) else helio=INPOS
helio_r=abs(helio*!pi/180.)

rotrate=14.7-2.4*(sin(helio_r(1))^2)-1.8*(sin(helio_r(1))^4)
delta_phi=rotrate*delta_t

helio(0)=helio(0)+delta_phi

if keyword_set(out_arcsec) then pos_out=conv_h2a(helio,time_1) else pos_out=helio

return,pos_out

end
