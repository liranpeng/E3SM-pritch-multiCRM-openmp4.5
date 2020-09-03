
module buoyancy_mod
  implicit none

contains

  subroutine buoyancy(ncrms)
    use vars
    use params
    implicit none
    integer, intent(in) :: ncrms
    integer i,j,k,kb,icrm
    real(crm_rknd) betu, betd

#if defined(_OPENACC)
    !$acc parallel loop gang vector collapse(4) async(asyncid)
#elif defined(_OPENMP)
    !$omp target teams distribute parallel do collapse(4)
#endif
    do k=2,nzm
      do j=1,ny
        do i=1,nx
          do icrm=1,ncrms
            kb=k-1
            betu=adz(icrm,kb)/(adz(icrm,k)+adz(icrm,kb))
            betd=adz(icrm,k)/(adz(icrm,k)+adz(icrm,kb))
#if defined(_OPENMP)
            !$omp atomic update
#endif
            dwdt(icrm,i,j,k,na)=dwdt(icrm,i,j,k,na) +  &
            bet(icrm,k)*betu* &
            ( tabs0(icrm,k)*(epsv*(qv(icrm,i,j,k)-qv0(icrm,k))-(qcl(icrm,i,j,k)+qci(icrm,i,j,k)-qn0(icrm,k)+qpl(icrm,i,j,k)+qpi(icrm,i,j,k)-qp0(icrm,k))) &
            +(tabs(icrm,i,j,k)-tabs0(icrm,k))*(1.+epsv*qv0(icrm,k)-qn0(icrm,k)-qp0(icrm,k)) ) &
            + bet(icrm,kb)*betd* &
            ( tabs0(icrm,kb)*(epsv*(qv(icrm,i,j,kb)-qv0(icrm,kb))-(qcl(icrm,i,j,kb)+qci(icrm,i,j,kb)-qn0(icrm,kb)+qpl(icrm,i,j,kb)+qpi(icrm,i,j,kb)-qp0(icrm,kb))) &
            +(tabs(icrm,i,j,kb)-tabs0(icrm,kb))*(1.+epsv*qv0(icrm,kb)-qn0(icrm,kb)-qp0(icrm,kb)) )
          end do ! i
        end do ! j
      end do ! k
    end do ! k

!to calculate the buoyancy profile.
  do k=1,nzm
    do j=1,ny
      do i=1,nx
        du(i,j,k,1)=0.
        du(i,j,k,2)=0.
        du(i,j,k,3)=dwdt(i,j,k,na)-du(i,j,k,3)
      end do
    end do
  end do

  call stat_tke(du,tkelebuoy)


  end subroutine buoyancy
end module buoyancy_mod

! TKE budget stuff
! copied in from SAM 6.10.6 code to allow computation of addtional statistics
! mwyant 3/1/2016

! hparish tests this routine and confirms functionality after few modifications. 04/01/2016

subroutine stat_tke(du,tkele)

use vars
implicit none
real du(nx,ny,nz,3)
real tkele(nzm)
real d_u(nz), d_v(nz),d_w(nz),coef
integer i,j,k
coef = 1./float(nx*ny)
do k=1,nz
 d_u(k)=0.
 d_v(k)=0.
 d_w(k)=0.
end do
do k=1,nzm
 do j=1,ny
  do i=1,nx
   d_u(k)=d_u(k)+(u(i,j,k)-u0(k))*du(i,j,k,1)
   d_v(k)=d_v(k)+(v(i,j,k)-v0(k))*du(i,j,k,2)
   d_w(k)=d_w(k)+ w(i,j,k) *      du(i,j,k,3)
  end do
 end do
 d_u(k)=d_u(k)*coef
 d_v(k)=d_v(k)*coef
 d_w(k)=d_w(k)*coef
end do
do k=1,nzm
 tkele(k)=0.5*(d_w(k)+d_w(k+1))+d_u(k)+d_v(k)*YES3D
end do

end
