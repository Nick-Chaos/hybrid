!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%% LIO_INIT.F90  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
! This file contains common initialization routines, including assignation of  !
! default values for options, wether LIO is run alone or in tantem with AMBER  !
! or GROMACS software packages. Routines currently included are:               !
! * lio_defaults     (called from the last two routines and liomd/liosolo)     !
! * init_lio_common  (called from the last two routines and liomd/liosolo)     !
! * init_lio_gromacs (calls the first two routines when running with GROMACS)  !
! * init_lio_amber   (calls the first two routines when running with AMBER)    !
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!


!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%% LIO_DEFAULTS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
! Subroutine lio_defaults gives default values to LIO runtime options.         !
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
subroutine lio_defaults()

    use garcha_mod, only : basis, fmulliken, fcoord, OPEN, NMAX,               &
                           basis_set, fitting_set, int_basis, DIIS, ndiis,     &
                           GOLD, told, Etold, hybrid_converg, good_cut, rmax,  &
                           rmaxs, omit_bas, propagator, NBCH, VCINP, Iexch,    &
                           restart_freq, frestartin, IGRID, frestart, predcoef,&
                           cubegen_only, cube_res, cube_dens, cube_orb,        &
                           cube_sel, cube_orb_file, cube_dens_file, NUNP,      &
                           energy_freq, writeforces, charge,                   &
                           cube_elec, cube_elec_file, cube_sqrt_orb, MEMO,     &
                           NORM, sol, primera,               &
                           watermod, fukui, little_cube_size, sphere_radius,   &
                           max_function_exponent, min_points_per_cube,         &
                           assign_all_functions, remove_zero_weights,          &
                           energy_all_iterations, free_global_memory, dipole,  &
                           lowdin, mulliken, print_coeffs, number_restr, Dbug, &
                           steep, Force_cut, Energy_cut, minimzation_steep,    &
                           n_min_steeps, lineal_search, n_points, timers,      &
                           calc_propM, spinpop, writexyz, IGRID2,              &
                           Rho_LS, P_oscilation_analisis


    use ECP_mod   , only : ecpmode, ecptypes, tipeECP, ZlistECP, cutECP,       &
                           local_nonlocal, ecp_debug, ecp_full_range_int,      &
                           verbose_ECP, Cnorm, FOCK_ECP_read, FOCK_ECP_write,  &
                           Fulltimer_ECP, cut2_0, cut3_0
    implicit none

!   Names of files used for input and output.
    basis          = 'basis'       ; fmulliken      = 'mulliken'    ;
    fcoord         = 'qm.xyz'      ;

!   Theory level options.
    OPEN           = .false.       ; told               = 1.0D-6        ;
    NMAX           = 100           ; Etold              = 1.0d0         ;
    basis_set      = "DZVP"        ; hybrid_converg     = .false.       ;
    int_basis      = .false.       ; good_cut           = 1D-5          ;
    DIIS           = .true.        ; rmax               = 16            ;
    ndiis          = 30            ; rmaxs              = 5             ;
    GOLD           = 10.           ; omit_bas           = .false.       ;
    charge         = 0             ;
    fitting_set    = "DZVP Coulomb Fitting" ;
    Rho_LS         = 0             ; P_oscilation_analisis = .false.

!   Effective Core Potential options.
    ecpmode        = .false.       ; cut2_0             = 15.d0         ;
    ecptypes       = 0             ; cut3_0             = 12.d0         ;
    tipeECP        = 'NOT-DEFINED' ; verbose_ECP        = 0             ;
    ZlistECP       = 0             ; ecp_debug          = .false.       ;
    FOCK_ECP_read  = .false.       ; Fulltimer_ECP      = .false.       ;
    FOCK_ECP_write = .false.       ; local_nonlocal     = 0             ;
    cutECP         = .true.        ; ecp_full_range_int = .false.       ;

!   TD-DFT options.
    propagator     = 1             ; NBCH               = 10            ;

!   Distance restrain options
    number_restr   = 0             ;

!   Geometry Optimizations
    steep= .false.                 ; Force_cut=1D-5                     ;
    Energy_cut= 1D-4               ; minimzation_steep=5D-2             ;
    n_min_steeps = 500             ; lineal_search=.true.               ;
    n_points = 5                   ;

!   Debug
    Dbug = .false.                 ;

!   Write options and Restart options.
    writexyz       = .true.        ;
    print_coeffs   = .false.       ; frestart           ='restart.out'  ;
    VCINP          = .false.       ; frestartin         = 'restart.in'  ;
    restart_freq   = 0             ; writeforces        = .false.       ;
    fukui          = .false.       ; lowdin             = .false.       ;
    mulliken       = .false.       ; dipole             = .false.       ;
    print_coeffs   = .false.       ; calc_propM         = .false.       ;
    spinpop        = .false.       ;


!   Old GPU_options
    max_function_exponent = 10     ; little_cube_size     = 8.0         ;
    min_points_per_cube   = 1      ; assign_all_functions = .false.     ;
    sphere_radius         = 0.6    ; remove_zero_weights  = .true.      ;
    energy_all_iterations = .false.; free_global_memory   = 0.0         ;

!   Cube, grid and other options.
    predcoef       = .false.       ; cubegen_only       = .false.       ;
    cube_res       = 40            ;
    cube_dens      = .false.       ; cube_orb           = .false.       ;
    Iexch          = 9             ; cube_sel           = 0             ;
    cube_orb_file  = "orb.cube"    ; cube_dens_file     = 'dens.cube'   ;
    IGRID          = 2             ; cube_elec          = .false.       ;
    IGRID2         = 2             ; cube_elec_file     = 'field.cube'  ;
    timers         = 0             ; NORM               = .true.        ;
    NUNP           = 0             ; energy_freq        = 1             ;
    cube_sqrt_orb  = .false.       ; MEMO               = .true.        ;
    sol            = .false.       ;
    primera        = .true.        ; watermod           = 0             ;

    return
end subroutine lio_defaults
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%% INIT_LIO_COMMON %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
! Performs LIO variable initialization.                                        !
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
subroutine init_lio_common(natomin, Izin, nclatom, callfrom)

    use garcha_mod, only : nunp, RMM, d, c, a, Nuc, ncont, cx,                 &
                           ax, Nucx, ncontx, cd, ad, Nucd, ncontd, indexii,    &
                           indexiid, r, v, rqm, Em, Rm, pc, nnat, af, B, Iz,   &
                           natom, ng0, ngd0, ngrid, nl, norbit, ntatom,        &
                           free_global_memory, little_cube_size,&
                           assign_all_functions, energy_all_iterations,        &
                           remove_zero_weights, min_points_per_cube,           &
                           max_function_exponent, sphere_radius, M,Fock_Hcore, &
                           Fock_Overlap, P_density, OPEN, timers, MO_coef_at,  &
                           MO_coef_at_b, charge, Rho_LS
    use ECP_mod,    only : Cnorm, ecpmode
    use field_data, only : chrg_sq
    use fileio    , only : lio_logo
    use fileio_data, only: style, verbose

    implicit none
    integer , intent(in) :: nclatom, natomin, Izin(natomin), callfrom
    integer              :: ng2, ngdDyn, ngDyn, ierr, ios, MM

    if (verbose .gt. 2) then
      write(*,*)
      write(*,'(A)') "LIO initialisation."
    endif
    call g2g_timer_start('lio_init')
    call g2g_set_options(free_global_memory, little_cube_size, sphere_radius, &
                         assign_all_functions, energy_all_iterations,         &
                         remove_zero_weights, min_points_per_cube,            &
                         max_function_exponent, timers, verbose)

    chrg_sq = charge**2
    if (callfrom.eq.1) then
        natom  = natomin
        if (.not.(allocated(Iz))) allocate(Iz(natom))
        Iz = Izin
        ntatom = natom + nclatom
        allocate(r(ntatom,3), rqm(natom,3), pc(ntatom))
    endif

    ! ngDyn : n° of atoms times the n° of basis functions.                   !
    ! norbit: n° of molecular orbitals involved.                               !
    ! ngdDyn: n° of atoms times the n° of auxiliary functions.               !
    ! Ngrid : n° of grid points (LS-SCF part).                                 !
    ! NOTES: Ngrid may be set to 0  in the case of Numerical Integration. For  !
    ! large systems, ng2 may result in <0 due to overflow.                     !

    ! Sets the dimensions for important arrays.
    call DIMdrive(ngDyn,ngdDyn)

    ng2 = 5*ngDyn*(ngDyn+1)/2 + 3*ngdDyn*(ngdDyn+1)/2 + &
          ngDyn  + ngDyn*norbit + Ngrid

    if (ng2 .le. 0) then
      write(*,*) "Error in ng2"
      write(*,*) "dimension for RMM is greater than max integer representaion"
      write(*,*) "should break RMM into smaller arrays"
      stop 
    end if

    allocate(RMM(ng2)    , d(natom, natom), c(ngDyn,nl)   , a(ngDyn,nl)     ,&
             Nuc(ngDyn)  , ncont(ngDyn)   , cd(ngdDyn,nl) , ad(ngdDyn,nl)   ,&
             Nucd(ngdDyn), ncontd(ngdDyn) , indexii(ngDyn), indexiid(ngdDyn),&
             v(ntatom,3) , Em(ntatom)     , Rm(ntatom)    , af(ngdDyn)      ,&
             nnat(200)   , B(ngdDyn,3))

    if (ngdDyn .gt. ngDyn) Then
       allocate(cx(ngdDyn,nl), ax(ngdDyn,nl), Nucx(ngdDyn), ncontx(ngdDyn))
    else
       allocate(cx(ngDyn,nl), ax(ngDyn,nl), Nucx(ngDyn), ncontx(ngDyn))
    endif

    ! Cnorm contains normalized coefficients of basis functions.
    ! Differentiate C for x^2,y^2,z^2 and  xy,xz,yx (3^0.5 factor)
    if (ecpmode) allocate (Cnorm(ngDyn,nl))

    call g2g_init()
    allocate(MO_coef_at(ngDyn*ngDyn))
    if (OPEN) allocate(MO_coef_at_b(ngDyn*ngDyn))


    ! Prints chosen options to output.
    call drive(ng2, ngDyn, ngdDyn)

    ! reemplazos de RMM
    MM=M*(M+1)/2
    allocate(Fock_Hcore(MM), Fock_Overlap(MM), P_density(MM))
    if ( (Rho_LS.gt.0)) call P_linearsearch_init()
    call g2g_timer_stop('lio_init')

    return
end subroutine init_lio_common
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%% INIT_LIO_GROMACS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
! Subroutine init_lio_gromacs performs Lio initialization when called from     !
! GROMACS software package, in order to conduct a hybrid QM/MM calculation.    !
! In order to avoid compatibility problems due to a FORTRAN/C++ interface, LIO !
! options are read from a file named "lio.in" in the current workspace.        !
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
subroutine init_lio_gromacs(natomin, Izin, nclatom, chargein)
    use garcha_mod, only: charge

    implicit none
    integer,  intent(in) :: chargein, nclatom, natomin, Izin(natomin)
    integer              :: dummy
    character(len=20)    :: inputFile

    ! Gives default values to runtime variables.
    call lio_defaults()
    charge = chargein

    ! Checks if input file exists and writes data to namelist variables.
    inputFile = 'lio.in'
    call read_options(inputFile)

    ! Initializes LIO. The last argument indicates LIO is not being used alone.
    call init_lio_common(natomin, Izin, nclatom, 1)

    return
end subroutine init_lio_gromacs
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!


!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%% INIT_LIO_AMBER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
! Subroutine init_lio_amber performs Lio initialization when called from AMBER !
! software package, in order to conduct a hybrid QM/MM calculation.            !
! AMBER directly passes options to LIO, but since the interface has not been   !
! officialy updated on the AMBER side, only some variables are received.       !
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
subroutine init_lio_amber(natomin, Izin, nclatom, charge_i, basis_i            &
           , output_i, fcoord_i, fmulliken_i, frestart_i, frestartin_i         &
           , verbose_i, OPEN_i, NMAX_i, NUNP_i, VCINP_i, GOLD_i, told_i        &
           , rmax_i, rmaxs_i, predcoef_i, idip_i, writexyz_i                   &
           , intsoldouble_i, DIIS_i, ndiis_i, dgtrig_i, Iexch_i, integ_i       &
           , DENS_i , IGRID_i, IGRID2_i , timedep_i , tdstep_i                 &
           , ntdstep_i, field_i, exter_i, a0_i, epsilon_i, Fx_i, Fy_i          &
           , Fz_i, NBCH_i, propagator_i, writedens_i, tdrestart_i              &
           )

    use garcha_mod, only : basis, fmulliken, fcoord, OPEN, NMAX,             &
                           basis_set, fitting_set, int_basis, DIIS, ndiis,   &
                           GOLD, told, Etold, hybrid_converg, good_cut,      &
                           rmax, rmaxs, omit_bas, propagator, NBCH,          &
                           VCINP, restart_freq, writexyz, frestartin,        &
                           frestart, predcoef, Iexch,                        &
                           cubegen_only, cube_res, cube_dens, cube_orb,      &
                           cube_sel, cube_orb_file, cube_dens_file, NUNP,    &
                           energy_freq, cube_elec_file,       &
                           cube_elec, cube_sqrt_orb, IGRID, IGRID2, charge
    use td_data   , only : tdrestart, tdstep, ntdstep, timedep, writedens
    use field_data, only : field, a0, epsilon, Fx, Fy, Fz
    use fileio_data, only: verbose
    use ECP_mod   , only : ecpmode, ecptypes, tipeECP, ZlistECP, cutECP,     &
                           local_nonlocal, ecp_debug, ecp_full_range_int,    &
                           verbose_ECP, Cnorm, FOCK_ECP_read, FOCK_ECP_write,&
                           Fulltimer_ECP, cut2_0, cut3_0

    implicit none
    integer , intent(in) :: charge_i, nclatom, natomin, Izin(natomin)
    character(len=20) :: basis_i, fcoord_i, fmulliken_i, frestart_i, &
                         frestartin_i, inputFile
    logical           :: verbose_i, OPEN_i, VCINP_i, predcoef_i, writexyz_i,   &
                         DIIS_i, field_i, exter_i, writedens_i, tdrestart_i
    integer           :: NMAX_i, NUNP_i, ndiis_i, Iexch_i, IGRID_i, IGRID2_i,  &
                         timedep_i, ntdstep_i, NBCH_i, propagator_i, dummy
    real*8            :: GOLD_i, told_i, rmax_i, rmaxs_i, tdstep_i,  &
                         a0_i, epsilon_i, Fx_i, Fy_i, Fz_i
    ! Deprecated or removed variables
    character(len=20) :: output_i
    integer           :: idip_i
    logical           :: intsoldouble_i, dens_i, integ_i
    double precision  :: dgtrig_i

    ! Gives default values to variables.
    call lio_defaults()

    ! Checks if input file exists and writes data to namelist variables.
    inputFile = 'lio.in'
    call read_options(inputFile)

    basis          = basis_i        ;
    fcoord         = fcoord_i       ; fmulliken     = fmulliken_i    ;
    frestart       = frestart_i     ; frestartin    = frestartin_i   ;
    OPEN           = OPEN_i         ;
    NMAX           = NMAX_i         ; NUNP          = NUNP_i         ;
    VCINP          = VCINP_i        ; GOLD          = GOLD_i         ;
    told           = told_i         ; rmax          = rmax_i         ;
    rmaxs          = rmaxs_i        ; predcoef      = predcoef_i     ;
    writexyz       = writexyz_i     ;
    DIIS           = DIIS_i         ; ndiis         = ndiis_i        ;
    Iexch          = Iexch_i        ;
    IGRID          = IGRID_i        ;
    IGRID2         = IGRID2_i       ; timedep       = timedep_i      ;
    field          = field_i        ; tdrestart     = tdrestart_i    ;
    tdstep         = tdstep_i       ; ntdstep       = ntdstep_i      ;
    a0             = a0_i           ; epsilon       = epsilon_i      ;
    Fx             = Fx_i           ; Fy            = Fy_i           ;
    Fz             = Fz_i           ; NBCH          = NBCH_i         ;
    propagator     = propagator_i   ; writedens     = writedens_i    ;
    charge         = charge_i       ;

    if (verbose_i) verbose = 1
    ! Initializes LIO. The last argument indicates LIO is not being used alone.
    call init_lio_common(natomin, Izin, nclatom, 1)

    return
end subroutine init_lio_amber
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!




!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%% INIT_LIOAMBER_EHREN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
! Performs LIO variable initialization.                                        !
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
subroutine init_lioamber_ehren(natomin, Izin, nclatom, charge_i, basis_i       &
           , output_i, fcoord_i, fmulliken_i, frestart_i, frestartin_i         &
           , verbose_i, OPEN_i, NMAX_i, NUNP_i, VCINP_i, GOLD_i, told_i        &
           , rmax_i, rmaxs_i, predcoef_i, idip_i, writexyz_i                   &
           , intsoldouble_i, DIIS_i, ndiis_i, dgtrig_i, Iexch_i, integ_i       &
           , DENS_i , IGRID_i, IGRID2_i , timedep_i , tdstep_i                 &
           , ntdstep_i, field_i, exter_i, a0_i, epsilon_i, Fx_i, Fy_i          &
           , Fz_i, NBCH_i, propagator_i, writedens_i, tdrestart_i, dt_i        &
           )

   use garcha_mod, only: M, first_step, doing_ehrenfest                        &
                      &, nshell, nuc, ncont, a, c, charge
   use td_data, only: timedep, tdstep

   use basis_subs, only: basis_data_set, basis_data_norm

   use lionml_data, only: ndyn_steps, edyn_steps

   use liosubs,    only: catch_error


   implicit none
   integer, intent(in) :: charge_i, nclatom, natomin, Izin(natomin)

   character(len=20) :: basis_i, output_i, fcoord_i, fmulliken_i, frestart_i   &
                     &, frestartin_i, inputFile

   logical :: verbose_i, OPEN_i, VCINP_i, predcoef_i, writexyz_i, DIIS_i       &
           &, intsoldouble_i, integ_i, DENS_i, field_i, exter_i, writedens_i   &
           &, tdrestart_i

   integer :: NMAX_i, NUNP_i, idip_i, ndiis_i, Iexch_i, IGRID_i, IGRID2_i      &
           &, timedep_i, ntdstep_i, NBCH_i, propagator_i, dummy

   real*8  :: GOLD_i, told_i, rmax_i, rmaxs_i, dgtrig_i, tdstep_i, a0_i        &
           &, epsilon_i, Fx_i, Fy_i, Fz_i, dt_i


   call init_lio_amber(natomin, Izin, nclatom, charge_i, basis_i               &
           , output_i, fcoord_i, fmulliken_i, frestart_i, frestartin_i         &
           , verbose_i, OPEN_i, NMAX_i, NUNP_i, VCINP_i, GOLD_i, told_i        &
           , rmax_i, rmaxs_i, predcoef_i, idip_i, writexyz_i                   &
           , intsoldouble_i, DIIS_i, ndiis_i, dgtrig_i, Iexch_i, integ_i       &
           , DENS_i , IGRID_i, IGRID2_i , timedep_i , tdstep_i                 &
           , ntdstep_i, field_i, exter_i, a0_i, epsilon_i, Fx_i, Fy_i          &
           , Fz_i, NBCH_i, propagator_i, writedens_i, tdrestart_i              &
           )


   first_step=.true.

   if ( (ndyn_steps>0) .and. (edyn_steps>0) ) doing_ehrenfest=.true.

   call basis_data_set(nshell(0),nshell(1),nshell(2),nuc,ncont,a,c)
!   call basis_data_norm( M, size(c,2), c )

   tdstep = (dt_i) * (41341.3733366d0)
!  tdstep = (dt_i) / ( (20.455d0) * (2.418884326505E-5) )
!
!  Amber should have time units in 1/20.455 ps, but apparently it has time
!  in ps. Just have to transform to atomic units
!  ( AU = 2.418884326505 x 10e-17 s )

end subroutine init_lioamber_ehren
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!


!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
!%% INIT_LIO_HYBRID  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
! Subroutine init_lio_hybrid performs Lio initialization when called from      !
! Hybrid software package, in order to conduct a hybrid QM/MM calculation.     !
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
subroutine init_lio_hybrid(hyb_natom, mm_natom, chargein, iza, spin)
    use garcha_mod, only: OPEN, Nunp, charge
    implicit none
    integer, intent(in) :: hyb_natom !number of total atoms
    integer, intent(in) :: mm_natom  !number of MM atoms
    integer             :: dummy
    character(len=20)   :: inputFile
    integer, intent(in) :: chargein   !total charge of QM system
    integer, dimension(hyb_natom), intent(in) :: iza  !array of charges of all QM/MM atoms
    double precision, intent(in) :: spin !number of unpaired electrons
    integer :: Nunp_aux !auxiliar
   
    ! Gives default values to runtime variables.
    call lio_defaults()
    charge = chargein

    !select spin case
    Nunp_aux=int(spin)
    Nunp=Nunp_aux

    ! Checks if input file exists and writes data to namelist variables.
    inputFile = 'lio.in'
    call read_options(inputFile)
    !select spin case
    Nunp_aux=int(spin)
    if (Nunp_aux .ne. Nunp) STOP "lio.in have a different spin than *.fdf"
    if (Nunp .ne. 0) OPEN=.true.
    if (OPEN) write(*,*) "Runing hybrid open shell, with ", Nunp, "unpaired electrons"

    ! Initializes LIO. The last argument indicates LIO is not being used alone.
    call init_lio_common(hyb_natom, Iza, mm_natom, 1)

    return
end subroutine init_lio_hybrid
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!
