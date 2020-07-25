!******************************************************************************
!
! Subroutines for rotation
!
!******************************************************************************
  SUBROUTINE regrot(pxreg,pyreg,pxrot,pyrot,pxcen,pycen,kdim)
    IMPLICIT NONE
!
!----------------------------------------------------------------------
!
!*    conversion between regular and rotated spherical coordinates.
!*
!*    pxreg     longitudes of the regular coordinates
!*    pyreg     latitudes of the regular coordinates
!*    pxrot     longitudes of the rotated coordinates
!*    pyrot     latitudes of the rotated coordinates
!*              all coordinates given in degrees n (negative for s)
!*              and degrees e (negative values for w)
!*    pxcen     regular longitude of the south pole of the rotated grid
!*    pycen     regular latitude of the south pole of the rotated grid
!*
!*    kcall=-1: find regular as functions of rotated coordinates.
!*    kcall= 1: find rotated as functions of regular coordinates.
!
!-----------------------------------------------------------------------
!
      integer kdim
      real(8) :: pxreg(kdim),pyreg(kdim),&
                 pxrot(kdim),pyrot(kdim)
      real(8) :: pxcen,pycen
!
!-----------------------------------------------------------------------
!
      real(8) ::  zsycen,zcycen,zpih
      real(8) ::  zxmxc(kdim),zsxmxc(kdim),zcxmxc(kdim),zsyreg(kdim),zcyreg(kdim), &
                  zsyrot(kdim),zcyrot(kdim),zcxrot(kdim),zsxrot(kdim)

      real(8),parameter :: pi = 3.14159265358979 

      zpih = pi*0.5d0
!
!----------------------------------------------------------------------
!
      zsycen = SIN((pycen+zpih))
      zcycen = COS((pycen+zpih))

      zxmxc  = pxreg - pxcen
      zsxmxc = SIN(zxmxc)
      zcxmxc = COS(zxmxc)
      zsyreg = SIN(pyreg)
      zcyreg = COS(pyreg)
      zsyrot = zcycen*zsyreg - zsycen*zcyreg*zcxmxc
      WHERE(zsyrot.lt.-1.0) zsyrot = -1.0
      WHERE(zsyrot.gt. 1.0) zsyrot =  1.0
      !
      pyrot = ASIN(zsyrot)
      !
      zcyrot = COS(pyrot)
      zcxrot = (zcycen*zcyreg*zcxmxc +zsycen*zsyreg)/zcyrot
      WHERE(zsxrot.lt.-1.0) zsxrot = -1.0
      WHERE(zsxrot.gt. 1.0) zsxrot =  1.0
      zsxrot = zcyreg*zsxmxc/zcyrot
      !
      pxrot = ACOS(zcxrot)
      !
      WHERE(zsxrot.lt.0) pxrot = -pxrot
               !
    END SUBROUTINE regrot
