;**************************************
;var_cam.ncl
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/gpfs/fs1/work/aherring/CESM2/arh-git-scripts/ncl/se_func_lib.ncl"
;**************************************
begin
;****************************************
  p0 = 1000.d2
  secpday = 60.*60.*24;
  pi = 3.14159265358979
  g = 9.80616
  Re = 6371.22
  cp = 1004.
  Rd = 287.
;****************************************

  title = "JAN"

  fname = (/"../composite.f09.ge.45N.PRECT.JAN.bilin.pdfx.debug.nc", \
	    "../composite.ne30pg3.ge.45N.PRECT.JAN.bilin.pdfx.debug.nc"/)

  runnams = (/"f09","ne30pg3"/)

  nfiles = dimsizes(fname)

  VAR = "bar"
  lbtitle = "PRECT (mm/day)"

  ;;set contour levels
  maxcn  = 12.;;1020.
  mincn  =  0.;;880.
  cnlevs = 20.
  cnspc  = (maxcn-mincn)/cnlevs

  cellfill = True

  pltNam = "temp_contours"

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation
  ;;gsn_define_colormap(wks,"MPL_jet")
  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
  ;;gsn_define_colormap(wks,"BlWhRe")
  plot = new( (/nfiles/), "graphic")

   res             = True
   res@gsnMaximize = False
   res@gsnDraw     = False      ; Will draw later, after overlaying
   res@gsnFrame    = False      ; all plots

   res@cnFillOn          = True               ; turn on color fill
   res@cnLinesOn         = False
   res@gsnSpreadColors   = True               ; use full range of color map
   res@cnLineLabelsOn       = False
   res@cnInfoLabelOn        = False
   res@lbLabelBarOn         = False
   res@tiMainFontHeightF = 0.006

   res@vpWidthF  = 0.3
   res@vpHeightF = 0.8

   res@mpGridAndLimbOn   = False           ; turn on lat/lon lines
   res@mpGridLatSpacingF = 10.
   res@mpGridLonSpacingF = 30.
   ;res@mpGridLineColor      = -1
   res@mpPerimOn         = False               ; turn off perimeter
   res@mpFillOn         = False
   res@mpOutlineBoundarySets     = "NoBoundaries"

   ;;res@mpProjection = "Orthographic"
   ;;res@mpCenterLonF = 0.
   ;;res@mpCenterLatF = 0

;******************************************************
; begin loop
;******************************************************

 do n = 0,nfiles-1

   f  = addfile (fname(n),"r")
   var = f->$VAR$
   lon2d = f->lon2d
   lat2d = f->lat2d
   nall = f->nall
   delete(f)

   runnams(n) = runnams(n) + " (" + nall + ")"

   var@lat2d = lat2d
   var@lon2d = lon2d

   print("max: " + max(var))
   print("min: " + min(var))

   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF  = mincn
   res@cnMaxLevelValF  = maxcn
   res@cnLevelSpacingF = cnspc

   if (cellfill) then
     res@cnFillMode = "CellFill"
     vf = addfile("../curvilin-scrip.nc","r")
     res@sfXCellBounds = vf->grid_corner_lon
     res@sfYCellBounds = vf->grid_corner_lat
     delete(vf)
   else
     res@cnFillMode = "AreaFill"
   end if

   res@mpMinLatF =-20.
   res@mpMaxLatF = 20.
   res@mpMinLonF =-20.
   res@mpMaxLonF = 20.

   res@gsnAddCyclic      = False
   plot(n) = gsn_csm_contour_map(wks,var,res)
   delete([/var,lat2d,lon2d/])

   if (cellfill) then
     delete([/res@sfXCellBounds,res@sfYCellBounds/])
   end if

 end do;;n


;;;drawNDCGrid(wks)
;*****************************************************
; Plot panel
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  ;resP@gsnPaperOrientation = "portrait"

  resP@gsnPanelFigureStrings = runnams
  resP@gsnPanelFigureStringsFontHeightF = 0.015
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "TopRight"

  resP@gsnPanelMainString = title

  resP@gsnPanelLabelBar = True
  ;;resP@lbBoxSeparatorLinesOn= False
  resP@gsnPanelBottom   = 0.1
  resP@lbTitleString              = lbtitle
  resP@lbTitlePosition            = "Bottom"
  resP@lbTitleFontHeightF         = 0.015
  resP@lbLabelFontHeightF         = 0.01
  resP@pmLabelBarOrthogonalPosF   = -0.02

  ;resP@txString = pltTitle
  gsn_panel(wks,plot,(/1,nfiles/),resP)               ; now draw as one plot

frame(wks)

end

