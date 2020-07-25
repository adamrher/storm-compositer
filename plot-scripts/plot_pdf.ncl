;**************************************
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/glade/work/aherring/CESM2/arh-git-scripts/ncl/se_func_lib.ncl"
;**************************************
begin
;****************************************
;****************************************

  fname = (/"../composite.ne30pg3.ge.45N.PRECT.JAN.bilin.pdfx.newalg.debug.nc"/)
  nfiles = dimsizes(fname)

  nbins = 500
  xmin = 0.;;
  xmax = 300.;;
  ymin = 2.e-8 ;;;y-axis range
  ymax = 1.

  varnams = "pdfvar"

  xaxis = "PRECT (mm/day)"

  pltNam = "temp_pdf"

  label = (/" ne30pg3"/)

  colors = (/"blue","red","darkorchid4"/)
;******************************************************
; plot options
;******************************************************
;---Start the graphics
  wks = gsn_open_wks("pdf",pltNam)

  res                      = True         ; plot modifications desired
  res@gsnDraw              = False        ; don't draw plot
  res@gsnFrame             = False        ; don't advance frame
  ;res@gsnMaximize = True
  ;res@gsnPaperOrientation = "portrait"
  ;res@vpWidthF = 0.7
  ;res@vpHeightF = 0.35
  res@xyYStyle ="Log"

  ;;res@trXReverse            = True
  res@tmBorderThicknessF = 3 ;axes thickness
  res@tmXBMajorOutwardLengthF = 0.
  res@tmYLMajorOutwardLengthF = 0.
  res@tmXBMinorOutwardLengthF = 0.
  res@tmYLMinorOutwardLengthF = 0.
  res@tmXTMajorOutwardLengthF = 0.
  res@tmYRMajorOutwardLengthF = 0.
  res@tmXTMinorOutwardLengthF = 0.
  res@tmYRMinorOutwardLengthF = 0.

  res@pmLegendDisplayMode    = "NoCreate"                      ; turn on legend
  res@pmLegendSide           = "Bottom"                      ; Change location of
  res@pmLegendParallelPosF   = .7                           ; move units right
  res@pmLegendOrthogonalPosF = -1.15                          ; move units down
  res@pmLegendWidthF         = 0.14                          ; Change width and
  res@pmLegendHeightF        = 0.11                           ; height of legend.
  res@lgPerimOn              = False                         ; turn off box around
  res@lgLabelFontHeightF     = .02                          ; label font height

  res@gsnXYBarChart            = True              ; Create bar plot
  res@gsnXYBarChartOutlineOnly = True
  res@xyMonoLineThickness = True
  res@xyLineThicknessF   = 3

  res@trYMinF                = ymin
  res@trYMaxF                = ymax
  res@trXMinF                = xmin
  res@trXMaxF                = xmax

  ;;add legend
  txres = True
  txres@txFontHeightF = 0.020
  txres@txJust = "CenterLeft"

  plres  = True                  ; polyline mods desired
  plres@gsLineDashPattern  = 0                    ; solid line
  plres@gsLineThicknessF  = 5.                   ; line thicker

  yy = (/ 0.90,0.87,0.84,0.81,0.78,0.75,0.72,0.69,0.66,0.63/)
  xx = (/ 0.70,0.74 /)

do n = 0,nfiles-1

print("Begin case "+n)

   print("Loading pdfvars from " + fname(n))

     ncdf = addfile(fname(n), "r")
     pdfvar = ncdf->$varnams$
     delete(ncdf)

     print("Plotting...")
     res@xyLineColors       = colors(n)
     pvals = ind(pdfvar.gt.0.d0)
     xvals = pdfvar@bin_bounds(0:nbins-1)
     if (n.eq.0) then
       res@tiYAxisString          = "Probability (fraction)"
       res@tiXAxisString          = xaxis
       plot  = gsn_csm_xy(wks,xvals(pvals),pdfvar(pvals)*1.e-2,res)
       delete(res@tiYAxisString)
     else 
       tmp = gsn_csm_xy(wks,xvals(pvals),pdfvar(pvals)*1.e-2,res)
       overlay(plot,tmp)
       delete(tmp)
     end if
     delete([/pvals,xvals,pdfvar/])

     plres@gsLineColor       = colors(n)
     gsn_polyline_ndc(wks,xx,(/yy(n),yy(n)/),plres)   
     gsn_text_ndc(wks,label(n),xx(1),yy(n),txres)

print("done with case " + n)

end do ;nfiles

;;drawNDCGrid(wks)

;*****************************************************
; Panel Plot
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelFigureStringsFontHeightF = 0.02
  resP@gsnPanelFigureStringsPerimOn     = False
  resP@amJust           = "TopRight"
  resP@gsnPanelYWhiteSpacePercent = 5.
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot
  frame(wks)

end

