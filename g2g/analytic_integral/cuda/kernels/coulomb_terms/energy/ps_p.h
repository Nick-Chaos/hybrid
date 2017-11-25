{
  scalar_type F_mT[3];
  {
    scalar_type PmQ[3];
    PmQ[0] = P[0] - nuc_pos_dens_sh[j].x;
    PmQ[1] = P[1] - nuc_pos_dens_sh[j].y;
    PmQ[2] = P[2] - nuc_pos_dens_sh[j].z;
    scalar_type T = (PmQ[0] * PmQ[0] + PmQ[1] * PmQ[1] + PmQ[2] * PmQ[2]) * rho;
    lio_gamma<scalar_type, 2>(F_mT, T);
  }
  {
    // START INDEX i1=0, CENTER 1
    {
      scalar_type p1ss_1 = PmA[0] * F_mT[1] + WmP[0] * F_mT[2];
      // START INDEX i2=0, CENTER 3
      {
        scalar_type p1sp2_0 = WmQ[0] * p1ss_1;
        p1sp2_0 += inv_two_zeta_eta * F_mT[1];
#ifdef FOCK_CALC
        my_fock[0] += (double)(fit_dens_sh[j + 0] * prefactor_dens * p1sp2_0);
#else
        rc_sh[0][tid] += (double)(dens[0] * prefactor_dens * p1sp2_0);
#endif
      }
      // START INDEX i2=1, CENTER 3
      {
        scalar_type p1sp2_0 = WmQ[1] * p1ss_1;
#ifdef FOCK_CALC
        my_fock[0] += (double)(fit_dens_sh[j + 1] * prefactor_dens * p1sp2_0);
#else
        rc_sh[1][tid] += (double)(dens[0] * prefactor_dens * p1sp2_0);
#endif
      }
      // START INDEX i2=2, CENTER 3
      {
        scalar_type p1sp2_0 = WmQ[2] * p1ss_1;
#ifdef FOCK_CALC
        my_fock[0] += (double)(fit_dens_sh[j + 2] * prefactor_dens * p1sp2_0);
#else
        rc_sh[2][tid] += (double)(dens[0] * prefactor_dens * p1sp2_0);
#endif
      }
    }
    // START INDEX i1=1, CENTER 1
    {
      scalar_type p1ss_1 = PmA[1] * F_mT[1] + WmP[1] * F_mT[2];
      // START INDEX i2=0, CENTER 3
      {
        scalar_type p1sp2_0 = WmQ[0] * p1ss_1;
#ifdef FOCK_CALC
        my_fock[1] += (double)(fit_dens_sh[j + 0] * prefactor_dens * p1sp2_0);
#else
        rc_sh[0][tid] += (double)(dens[1] * prefactor_dens * p1sp2_0);
#endif
      }
      // START INDEX i2=1, CENTER 3
      {
        scalar_type p1sp2_0 = WmQ[1] * p1ss_1;
        p1sp2_0 += inv_two_zeta_eta * F_mT[1];
#ifdef FOCK_CALC
        my_fock[1] += (double)(fit_dens_sh[j + 1] * prefactor_dens * p1sp2_0);
#else
        rc_sh[1][tid] += (double)(dens[1] * prefactor_dens * p1sp2_0);
#endif
      }
      // START INDEX i2=2, CENTER 3
      {
        scalar_type p1sp2_0 = WmQ[2] * p1ss_1;
#ifdef FOCK_CALC
        my_fock[1] += (double)(fit_dens_sh[j + 2] * prefactor_dens * p1sp2_0);
#else
        rc_sh[2][tid] += (double)(dens[1] * prefactor_dens * p1sp2_0);
#endif
      }
    }
    // START INDEX i1=2, CENTER 1
    {
      scalar_type p1ss_1 = PmA[2] * F_mT[1] + WmP[2] * F_mT[2];
      // START INDEX i2=0, CENTER 3
      {
        scalar_type p1sp2_0 = WmQ[0] * p1ss_1;
#ifdef FOCK_CALC
        my_fock[2] += (double)(fit_dens_sh[j + 0] * prefactor_dens * p1sp2_0);
#else
        rc_sh[0][tid] += (double)(dens[2] * prefactor_dens * p1sp2_0);
#endif
      }
      // START INDEX i2=1, CENTER 3
      {
        scalar_type p1sp2_0 = WmQ[1] * p1ss_1;
#ifdef FOCK_CALC
        my_fock[2] += (double)(fit_dens_sh[j + 1] * prefactor_dens * p1sp2_0);
#else
        rc_sh[1][tid] += (double)(dens[2] * prefactor_dens * p1sp2_0);
#endif
      }
      // START INDEX i2=2, CENTER 3
      {
        scalar_type p1sp2_0 = WmQ[2] * p1ss_1;
        p1sp2_0 += inv_two_zeta_eta * F_mT[1];
#ifdef FOCK_CALC
        my_fock[2] += (double)(fit_dens_sh[j + 2] * prefactor_dens * p1sp2_0);
#else
        rc_sh[2][tid] += (double)(dens[2] * prefactor_dens * p1sp2_0);
#endif
      }
    }
  }
}
