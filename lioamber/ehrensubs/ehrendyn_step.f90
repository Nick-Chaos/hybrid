!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
subroutine ehrendyn_step( step_back, propagator_id, time_value, time_step,     &
                        & nbasis, natoms, nucpos, nucvel, nucfor_ds,           &
                        & Sinv, Uinv, Linv, dens_oldi, dens_midi, dens_newo,   &
                        & fock_mid, dipmom, energy )
!------------------------------------------------------------------------------!
!
! All matrices must be in OM
!
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
   implicit none
   logical, intent(inout)    :: step_back
   integer, intent(in)       :: propagator_id
   real*8 , intent(in)       :: time_value
   real*8 , intent(in)       :: time_step
   integer, intent(in)       :: nbasis
   integer, intent(in)       :: natoms

   real*8, intent(in)        :: nucpos(3, natoms)
   real*8, intent(in)        :: nucvel(3, natoms)
   real*8, intent(inout)     :: nucfor_ds(3, natoms)

   real*8, intent(in)        :: Sinv(nbasis, nbasis)
   real*8, intent(in)        :: Uinv(nbasis, nbasis)
   real*8, intent(in)        :: Linv(nbasis, nbasis)

   complex*16, intent(in)    :: dens_oldi(nbasis, nbasis)
   complex*16, intent(in)    :: dens_midi(nbasis, nbasis)
   complex*16, intent(out)   :: dens_newo(nbasis, nbasis)

   real*8    , intent(inout) :: fock_mid(nbasis, nbasis)
   real*8    , intent(inout) :: dipmom(3)
   real*8    , intent(inout) :: energy

   complex*16, allocatable   :: dens_old(:,:)
   complex*16, allocatable   :: dens_mid(:,:)
   real*8    , allocatable   :: fock0(:,:)
   real*8                    :: dipmom0(3)
   real*8                    :: energy0

   integer                   :: substep, substeps
   real*8                    :: dt
   real*8                    :: elec_field(3)
   real*8    , allocatable   :: Bmat(:,:)
   real*8    , allocatable   :: Dmat(:,:)
   complex*16, allocatable   :: Tmat(:,:)
   complex*16, allocatable   :: dens_mao(:,:)

   integer, parameter :: propagator_id_verlet = 1
   integer, parameter :: propagator_id_magnus = 2

   allocate( Bmat(nbasis,nbasis), Dmat(nbasis,nbasis), Tmat(nbasis,nbasis) )
   allocate( dens_old(nbasis,nbasis), dens_mid(nbasis,nbasis) )
   allocate( dens_mao(nbasis,nbasis) )
   allocate( fock0(nbasis,nbasis) )

   dens_old   = dens_oldi
   dens_mid   = dens_midi
   fock0      = fock_mid
   dipmom0(:) = 0.0d0
   energy0    = energy

   if (step_back) then
      substeps = 20
      dt = (-time_step) / ( (2.0d0)*(substeps) )
      dens_old = dens_mid
   else
      substeps = 0
      dt = time_step
   endif


   do substep = 0, substeps
      fock_mid = Fock0
      dipmom   = dipmom0
      energy   = energy0

!     Fock and Force calculation (needs density and fock in AO)
!     (this should leave the right Rho in RMM for get_forces)
      dens_mao = dens_mid
      dens_mao = matmul(dens_mao, Linv)
      dens_mao = matmul(Uinv, dens_mao)
      call ehrenaux_setfld( time_value, elec_field )
      call RMMcalc3_FockMao( dens_mao, elec_field, fock_mid, dipmom, energy)
      call calc_forceDS( natoms, nbasis, nucpos, nucvel, dens_mao, fock_mid, Sinv,&
                       & Bmat, nucfor_ds )


!     Set ups propagation cuasi-fock matrix (needs fock in ON)
      fock_mid = matmul(fock_mid, Uinv)
      fock_mid = matmul(Linv, fock_mid)
      Dmat = calc_Dmat( nbasis, Linv, Uinv, Bmat )
      Tmat = DCMPLX(fock_mid) + DCMPLX(0.0d0,1.0d0) * DCMPLX(Dmat)


!     Density Propagation (works in ON)
      if (propagator_id==propagator_id_verlet) then
         print*,'This is verlet!'
         call ehrenaux_verlet( nbasis, dt, Tmat, dens_old, dens_mid, dens_newo )

      else if (propagator_id==propagator_id_magnus) then
         print*,'This is magnus!'
         call ehrenaux_magnus( nbasis, 20, dt, Tmat, dens_mid, dens_old, dens_newo )

      else
         print*,'Unidentified substep!'; stop

      endif

      if (step_back) then
         step_back = .false.
         dt = (-2.0d0) * dt
         dens_old = dens_newo
      else
         dens_old = dens_mid
         dens_mid = dens_newo
      endif

   enddo

 
   deallocate( Bmat, Dmat, Tmat )
   deallocate( dens_old, dens_mid )
   deallocate( dens_mao )
   deallocate( fock0 )

end subroutine ehrendyn_step
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
