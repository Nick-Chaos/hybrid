C==============================================================================
C PBE and PW91 functional incorporated from Burke's code. Modifications
C to run under this DFT program by D. Bikiel.
C==============================================================================
C##############################################################################
C==============================================================================

c-----------------------------------------------------------------
c PBE alpha2.1:
c Perdew-Burke-Ernzerhof generalized gradient approximation to the
c density functional for exchange-correlation energy of a many-electron
c system.
c  --------------------------------------------------------------------
c |WARNING!  PBE is a simplification of PW91, which yields almost      |
c |identical numerical results with simpler formulas from a simpler    |
c |derivation.  If you should find significant DIFFERENCES between     |
c |PBE and PW91 results, please consult kieron@merlin.phy.tulane.edu   |
c |or perdew@mailhost.tcs.tulane.edu.  Thank you.                      |
c  --------------------------------------------------------------------
c Note: Neglects small grad (zeta) contributions to the correlation
c energy.
c
c Programs implement functional in PBE paper, July 1996 version.
c 
c----------------------------------------------------------------------
c Kieron Burke, July 2, 1996.
C Atomic units are used, so all energies are in hartrees and all 
c distances in bohrs.  
c 1 hartree=27.2116eV=627.5kcal/mol; 1bohr=0.529E-10m.

c----------------------------------------------------------------------
C BEGIN THE RADIAL LOOP
c dup=up density
c agrup=|grad up|
c delgrup=(grad up).(grad |grad up|) 
c uplap=grad^2 up=Laplacian of up
c dn,agrdn,delgrdn,dnlap=corresponding down quantities
c d=up+dn
c agrad=|grad rho|
c delgrad=(grad rho).(grad |grad rho|) 


460      IF(densa.EQ.0.D0.OR.densb.EQ.0.D0) THEN
         ec = 0.0D0
         ex = 0.0D0
         v = 0.0D0
         RETURN
         ENDIF


C Up / Down density

          grup2 = adx*adx + ady*ady + adz*adz
          agrup = DSQRT(grup2)
          agrdn = agrup

         dgrada1 = adx*adx*adxx / agrup
         dgrada2 = ady*ady*adyy / agrup
         dgrada3 = adz*adz*adzz / agrup
         dgrada4 = 2.0D0*adx*ady*adxy / agrup
         dgrada5 = 2.0D0*adx*adz*adxz / agrup
         dgrada6 = 2.0D0*ady*adz*adyz / agrup

         delgrup = dgrada1+dgrada2+dgrada3+dgrada4+dgrada5+dgrada6
         delgrdn = delgrup 
 

          uplap = adxx + adyy + adzz
          dnlap = uplap

C Up + Down Density

         grad2 = dx*dx + dy*dy + dz*dz
         agrad = DSQRT(grad2)

         dgrad1 = dx*dx*dxx / agrad
         dgrad2 = dy*dy*dyy / agrad
         dgrad3 = dz*dz*dzz / agrad
         dgrad4 = 2.0D0*dx*dy*dxy / agrad
         dgrad5 = 2.0D0*dx*dz*dxz / agrad
         dgrad6 = 2.0D0*dy*dz*dyz / agrad
          
         delgrad = dgrad1+dgrad2+dgrad3+dgrad4+dgrad5+dgrad6

            dup=densa
            ddn=densb
     

            call easypbeC(dup,agrup,delgrup,uplap,ddn,agrdn,delgrdn,
     1           dnlap,agrad,delgrad,1,1,
     1           exlsd,vxuplsd,vxdnlsd,eclsd,vcuplsd,vcdnlsd,
     1           expw91,vxuppw91,vxdnpw91,ecpw91,vcuppw91,vcdnpw91,
     1           expbe,vxuppbe,vxdnpbe,ecpbe,vcuppbe,vcdnpbe)


C-------DEBUG CORRELATION: ONLY EXCHANGE--------------------------

c           call easypbe(dup,agrup,delgrup,uplap,ddn,agrdn,delgrdn,
c    1           dnlap,agrad,delgrad,0,1,
c    1           exlsd,vxuplsd,vxdnlsd,eclsd,vcuplsd,vcdnlsd,
c    1           expw91,vxuppw91,vxdnpw91,ecpw91,vcuppw91,vcdnpw91,
c    1           expbe,vxuppbe,vxdnpbe,ecpbe,vcuppbe,vcdnpbe)

C------------------------------------------------------------------

C rename the variables to engage the DFT ones
 
            ex = expbe
            ec = ecpbe 
            va = vxuppbe + vcuppbe
            vb = vxdnpbe + vcdnpbe
             v = va + vb  


c           ex = expw91
c           ec = ecpw91
c           va = vxuppw91 + vcuppw91
c           vb = vxdnpw91 + vcdnpw91

c DEBUG POTENTIAL=====================================
         
c           ex = 0.D0
c           ec = 0.D0
c           vxuppbe = 0.D0
c           vcuppbe = 0.D0
c           vxdnpbe = 0.D0
c           vcdnpbe = 0.D0
c           va = vxuppbe + vcuppbe
c           vb = vxdnpbe + vcdnpbe
c           va = 0.D0
c           vb = 0.D0
c=====================================================
c           write(*,*) 'ex',ex,'ec',ec,'va',va,'vb',vb

            end

c----------------------------------------------------------------------
c######################################################################
c----------------------------------------------------------------------
      subroutine easypbeC(up,agrup,delgrup,uplap,dn,agrdn,delgrdn,dnlap,
     1           agr,delgr,lcor,lpot,
     1           exlsd,vxuplsd,vxdnlsd,eclsd,vcuplsd,vcdnlsd,
     1           expw91,vxuppw91,vxdnpw91,ecpw91,vcuppw91,vcdnpw91,
     1           expbe,vxuppbe,vxdnpbe,ecpbe,vcuppbe,vcdnpbe)

c     subroutine easypbe2(up,agrup,delgrup,uplap,dn,agrdn,delgrdn,dnlap,
c    1           agr,delgr,lcor,lpot,adx,bdx,ady,bdy,adz,bdz
c    1           exlsd,vxuplsd,vxdnlsd,eclsd,vcuplsd,vcdnlsd,
c    1           expw91,vxuppw91,vxdnpw91,ecpw91,vcuppw91,vcdnpw91,
c    1           expbe,vxuppbe,vxdnpbe,ecpbe,vcuppbe,vcdnpbe)

c----------------------------------------------------------------------
c----------------------------------------------------------------------
c EASYPBE is a driver for the PBE subroutines, using simple inputs
c K. Burke, May 14, 1996.
c inputs: up=up density
c	: agrup=|grad up|
c	: delgrup=(grad up).(grad |grad up|) 
c	: uplap=grad^2 up=Laplacian of up
c	: dn,agrdn,delgrdn,dnlap=corresponding down quantities
c	: agr=|grad rho|
c	: delgr=(grad rho).(grad |grad rho|) 
c	: lcor=flag to do correlation(=0=>don't)
c	: lpot=flag to do potential(=0=>don't)
c outputs: exlsd=LSD exchange energy density, so that
c		ExLSD=int d^3r rho(r) exlsd(r)
c	 : vxuplsd=up LSD exchange potential
c	 : vxdnlsd=down LSD exchange potential
c        : exclsd=LSD exchange-correlation energy density
c	 : vxcuplsd=up LSD exchange-correlation potential
c	 : vxcdnlsd=down LSD exchange-correlation potential
c        : expw91,vxuppw91,vxdnpw91,ecpw91,etc.=PW91 quantities
c        : expbe,vxuppbe,vxdnpbe,ecpbe,etc.=PBE quantities
c----------------------------------------------------------------------
c----------------------------------------------------------------------
c needed constants:
c pi32=3 pi**2
c alpha=(9pi/4)**thrd
      implicit real*8(a-h,o-z)
      parameter(thrd=1.d0/3.d0,thrd2=2.d0*thrd)
      parameter(pi32=29.608813203268075856503472999628d0)
      parameter(pi=3.1415926535897932384626433832795d0)
      parameter(alpha=1.91915829267751300662482032624669d0)
c----------------------------------------------------------------------
c----------------------------------------------------------------------
c PBE exchange
c use  Ex[up,dn]=0.5*(Ex[2*up]+Ex[2*dn]) (i.e., exact spin-scaling)
c do up exchange
c fk=local Fermi wavevector for 2*up=(3 pi^2 (2up))^(1/3) 
c s=dimensionless density gradient=|grad rho|/ (2*fk*rho)_(rho=2*up)
c u=delgrad/(rho^2*(2*fk)**3)_(rho=2*up)
c v=Laplacian/(rho*(2*fk)**2)_(rho=2*up)
c     write(*,*) 'Estoy en PBE'
 
      rho2=2.d0*up
      
c     write(*,*)'2rho up',rho2
       
      if(rho2.gt.1d-18)then
        fk=(pi32*rho2)**thrd
        s=2.d0*agrup/(2.d0*fk*rho2)
        u=4.d0*delgrup/(rho2*rho2*(2.d0*fk)**3)
        v=2.d0*uplap/(rho2*(2.d0*fk)**2)
        
c       write(*,*)'s,u,v=',s,u,v

        call exchpbeC(rho2,s,u,v,0,lpot,exuplsd,vxuplsd)
c       call exchpw91C(rho2,s,u,v,exuppw91,vxuppw91)
        call exchpbeC(rho2,s,u,v,1,lpot,exuppbe,vxuppbe)
      else
	exuplsd=0.d0
	vxuplsd=0.d0
c	exuppw91=0.d0
c 	vxuppw91=0.d0
	exuppbe=0.d0
	vxuppbe=0.d0
      endif
c repeat for down
      rho2=2.d0*dn
      
c     write(*,*)'2rho dn',rho2

      if(rho2.gt.1d-18)then
        fk=(pi32*rho2)**thrd
        s=2.d0*agrdn/(2.d0*fk*rho2)
        u=4.d0*delgrdn/(rho2*rho2*(2.d0*fk)**3)
        v=2.d0*dnlap/(rho2*(2.d0*fk)**2)

c       write(*,*)'s,u,v=',s,u,v

        call exchpbeC(rho2,s,u,v,0,lpot,exdnlsd,vxdnlsd)
c       call exchpw91C(rho2,s,u,v,exdnpw91,vxdnpw91)
        call exchpbeC(rho2,s,u,v,1,lpot,exdnpbe,vxdnpbe)
      else
	exdnlsd=0.d0
	vxdnlsd=0.d0
c	exdnpw91=0.d0
c	vxdnpw91=0.d0
	exdnpbe=0.d0
	vxdnpbe=0.d0
      endif
10    continue 
c construct total density and contribution to ex
      rho=up+dn
      exlsd=(exuplsd*up+exdnlsd*dn)/rho
c     expw91=(exuppw91*up+exdnpw91*dn)/rho
      expbe=(exuppbe*up+exdnpbe*dn)/rho
      if(lcor.eq.0)return
c----------------------------------------------------------------------
c----------------------------------------------------------------------
c Now do correlation
c zet=(up-dn)/rho
c g=phi(zeta)
c rs=(3/(4pi*rho))^(1/3)=local Seitz radius=alpha/fk
c sk=Ks=Thomas-Fermi screening wavevector=sqrt(4fk/pi)
c twoksg=2*Ks*phi
c t=correlation dimensionless gradient=|grad rho|/(2*Ks*phi*rho)
c uu=delgrad/(rho^2*twoksg^3)
c rholap=Laplacian
c vv=Laplacian/(rho*twoksg^2)
c ww=(|grad up|^2-|grad dn|^2-zet*|grad rho|^2)/(rho*twoksg)^2
c ec=lsd correlation energy
c vcup=lsd up correlation potential
c vcdn=lsd down correlation potential
c h=gradient correction to correlation energy
c dvcup=gradient correction to up correlation potential
c dvcdn=gradient correction to down correlation potential
      if(rho.lt.1.d-18)return
      zet=(up-dn)/rho
      g=((1.d0+zet)**thrd2+(1.d0-zet)**thrd2)/2.d0
      fk=(pi32*rho)**thrd
      rs=alpha/fk
      sk=dsqrt(4.d0*fk/pi)
      twoksg=2.d0*sk*g
      t=agr/(twoksg*rho)
      uu=delgr/(rho*rho*twoksg**3)
      rholap=uplap+dnlap
      vv=rholap/(rho*twoksg**2)

C---PRINTING THINGS FOR DEBUGGING--------------
    
c     write(*,*)'uu,delgr,rho',uu,delgr,rho
c     write(*,*)'rho,zet',rho,zet
c     write(*,*)'fk,rs,sk',fk,rs,sk
c     write(*,*)'t,uu,rholap,vv',t,uu,rholap,vv

C-----------------------------------------------

C----reconstruction of ww-----------------------
c    
C Grad(zet)
c    
c     dxzet = 2.0D0*(adx*dn - bdx*up)/(up+dn)**2
c     dyzet = 2.0D0*(ady*dn - bdy*up)/(up+dn)**2
c     dzzet = 2.0D0*(adz*dn - bdz*up)/(up+dn)**2
c
C Grad(rho)*Grad(zet)
c
c     grgrx = adx*dxzet
c     grgry = ady*dyzet
c     grgrz = adz*dzzet
c
C Sum of coordinates product
c      
c     grgr = grgrx + grgry + grgrz
c
c     ww = grgr/(rho*rho*twoksg**2)
C--------------------------------------------------------

      ww=(agrup**2-agrdn**2-zet*agr**2)/(rho*rho*twoksg**2)

      call CORPBEC(RS,ZET,T,UU,VV,WW,1,lpot,ec,vcup,vcdn,
     1                  H,DVCUP,DVCDN,rho)

C Debug Correlation: Only energies ----------

c     call CORPBC(RS,ZET,T,UU,VV,WW,1,0,ec,vcup,vcdn,
c    1                  H,DVCUP,DVCDN)

C---------------------------------------------------- 
      eclsd=ec
      ecpbe=ec+h
      vcuplsd=vcup
      vcdnlsd=vcdn
      vcuppbe=vcup+dvcup
      vcdnpbe=vcdn+dvcdn

C---- DEBUG COR. POTENTIAL: PRINT BULLSHITS--------
c     write(*,*) 'vcup,vcupppbe',vcup,vcuppbe
c     write(*,*) 'vcdn,vcdnpbe',vcdn,vcdnpbe
c--------------------------------------------------

      call CORLSDC(RS,ZET,EC,VCUP,VCDN,ECRS,ECZET,ALFC)
c     call CORPW91C(RS,ZET,G,EC,ECRS,ECZET,T,UU,VV,WW,H,DVCUP,DVCDN)
c     ecpw91=ec+h
c     vcuppw91=vcup+dvcup
c     vcdnpw91=vcdn+dvcdn
      return
      end
c----------------------------------------------------------------------
c######################################################################
c----------------------------------------------------------------------
      SUBROUTINE EXCHPBEC(rho,S,U,V,lgga,lpot,EX,VX)
c----------------------------------------------------------------------
C  PBE EXCHANGE FOR A SPIN-UNPOLARIZED ELECTRONIC SYSTEM
c  K Burke's modification of PW91 codes, May 14, 1996
c  Modified again by K. Burke, June 29, 1996, with simpler Fx(s)
c----------------------------------------------------------------------
c----------------------------------------------------------------------
C  INPUT rho : DENSITY
C  INPUT S:  ABS(GRAD rho)/(2*KF*rho), where kf=(3 pi^2 rho)^(1/3)
C  INPUT U:  (GRAD rho)*GRAD(ABS(GRAD rho))/(rho**2 * (2*KF)**3)
C  INPUT V: (LAPLACIAN rho)/(rho*(2*KF)**2)
c   (for U,V, see PW86(24))
c  input lgga:  (=0=>don't put in gradient corrections, just LDA)
c  input lpot:  (=0=>don't get potential and don't need U and V)
C  OUTPUT:  EXCHANGE ENERGY PER ELECTRON (EX) AND POTENTIAL (VX)
c----------------------------------------------------------------------
c----------------------------------------------------------------------
c References:
c [a]J.P.~Perdew, K.~Burke, and M.~Ernzerhof, submiited to PRL, May96
c [b]J.P. Perdew and Y. Wang, Phys. Rev.  B {\bf 33},  8800  (1986);
c     {\bf 40},  3399  (1989) (E).
c----------------------------------------------------------------------
c----------------------------------------------------------------------
c Formulas:
c   	e_x[unif]=ax*rho^(4/3)  [LDA]
c ax = -0.75*(3/pi)^(1/3)
c	e_x[PBE]=e_x[unif]*FxPBE(s)
c	FxPBE(s)=1+uk-uk/(1+ul*s*s)                 [a](13)
c uk, ul defined after [a](13) 
c----------------------------------------------------------------------
c----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      parameter(thrd=1.d0/3.d0,thrd4=4.d0/3.d0)
      parameter(pi=3.14159265358979323846264338327950d0)
      parameter(ax=-0.738558766382022405884230032680836d0)
      parameter(um=0.2195149727645171d0,uk=0.8040d0,ul=um/uk)
c----------------------------------------------------------------------
c----------------------------------------------------------------------
c construct LDA exchange energy density
      exunif = AX*rho**THRD
      if(lgga.eq.0)then
	ex=exunif
        vx=ex*thrd4
	return
      endif
c----------------------------------------------------------------------
c----------------------------------------------------------------------
c construct PBE enhancement factor
      S2 = S*S
      P0=1.d0+ul*S2
      FxPBE = 1d0+uk-uk/P0
      EX = exunif*FxPBE
      if(lpot.eq.0)return
c----------------------------------------------------------------------
c----------------------------------------------------------------------
C  ENERGY DONE. NOW THE POTENTIAL:
c  find first and second derivatives of Fx w.r.t s.
c  Fs=(1/s)*d FxPBE/ ds
c  Fss=d Fs/ds
      Fs=2.d0*uk*ul/(P0*P0)
      Fss=-4.d0*ul*S*Fs/P0
c----------------------------------------------------------------------
c----------------------------------------------------------------------
c calculate potential from [b](24) 
      VX = exunif*(THRD4*FxPBE-(U-THRD4*S2*s)*FSS-V*FS)
      RETURN
      END
c----------------------------------------------------------------------
c######################################################################
c----------------------------------------------------------------------
      SUBROUTINE CORPBEC(RS,ZET,T,UU,VV,WW,lgga,lpot,ec,vcup,vcdn,
     1                  H,DVCUP,DVCDN,rho)
c----------------------------------------------------------------------
c  Official PBE correlation code. K. Burke, May 14, 1996.
C  INPUT: RS=SEITZ RADIUS=(3/4pi rho)^(1/3)
C       : ZET=RELATIVE SPIN POLARIZATION = (rhoup-rhodn)/rho
C       : t=ABS(GRAD rho)/(rho*2.*KS*G)  -- only needed for PBE
C       : UU=(GRAD rho)*GRAD(ABS(GRAD rho))/(rho**2 * (2*KS*G)**3)
C       : VV=(LAPLACIAN rho)/(rho * (2*KS*G)**2)
C       : WW=(GRAD rho)*(GRAD ZET)/(rho * (2*KS*G)**2
c       :  UU,VV,WW, only needed for PBE potential
c       : lgga=flag to do gga (0=>LSD only)
c       : lpot=flag to do potential (0=>energy only)
c  output: ec=lsd correlation energy from [a]
c        : vcup=lsd up correlation potential
c        : vcdn=lsd dn correlation potential
c        : h=NONLOCAL PART OF CORRELATION ENERGY PER ELECTRON
c        : dvcup=nonlocal correction to vcup
c        : dvcdn=nonlocal correction to vcdn
c----------------------------------------------------------------------
c----------------------------------------------------------------------
c References:
c [a] J.P.~Perdew, K.~Burke, and M.~Ernzerhof, 
c     {\sl Generalized gradient approximation made simple}, sub.
c     to Phys. Rev.Lett. May 1996.
c [b] J. P. Perdew, K. Burke, and Y. Wang, {\sl Real-space cutoff
c     construction of a generalized gradient approximation:  The PW91
c     density functional}, submitted to Phys. Rev. B, Feb. 1996.
c [c] J. P. Perdew and Y. Wang, Phys. Rev. B {\bf 45}, 13244 (1992).
c----------------------------------------------------------------------
c----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
c thrd*=various multiples of 1/3
c numbers for use in LSD energy spin-interpolation formula, [c](9).
c      GAM= 2^(4/3)-2
c      FZZ=f''(0)= 8/(9*GAM)
c numbers for construction of PBE
c      gama=(1-log(2))/pi^2
c      bet=coefficient in gradient expansion for correlation, [a](4).
c      eta=small number to stop d phi/ dzeta from blowing up at 
c          |zeta|=1.
      parameter(thrd=1.d0/3.d0,thrdm=-thrd,thrd2=2.d0*thrd)
      parameter(sixthm=thrdm/2.d0)
      parameter(thrd4=4.d0*thrd)
      parameter(GAM=0.5198420997897463295344212145565d0)
      parameter(fzz=8.d0/(9.d0*GAM))
      parameter(gama=0.03109069086965489503494086371273d0)
      parameter(bet=0.06672455060314922d0,delt=bet/gama)
      parameter(eta=1.d-12)

c----------------------------------------------------------------------
c----------------------------------------------------------------------
c find LSD energy contributions, using [c](10) and Table I[c].
c EU=unpolarized LSD correlation energy
c EURS=dEU/drs
c EP=fully polarized LSD correlation energy
c EPRS=dEP/drs
c ALFM=-spin stiffness, [c](3).
c ALFRSM=-dalpha/drs
c F=spin-scaling factor from [c](9).
c construct ec, using [c](8)
      rtrs=dsqrt(rs)
      CALL gcor2C(0.0310907D0,0.21370D0,7.5957D0,3.5876D0,1.6382D0,
     1    0.49294D0,rtrs,EU,EURS)
      CALL gcor2C(0.01554535D0,0.20548D0,14.1189D0,6.1977D0,3.3662D0,
     1    0.62517D0,rtRS,EP,EPRS)
      CALL gcor2C(0.0168869D0,0.11125D0,10.357D0,3.6231D0,0.88026D0,
     1    0.49671D0,rtRS,ALFM,ALFRSM)
      ALFC = -ALFM
      Z4 = ZET**4
      F=((1.D0+ZET)**THRD4+(1.D0-ZET)**THRD4-2.D0)/GAM
      EC = EU*(1.D0-F*Z4)+EP*F*Z4-ALFM*F*(1.D0-Z4)/FZZ
c----------------------------------------------------------------------
c----------------------------------------------------------------------
c LSD potential from [c](A1)
c ECRS = dEc/drs [c](A2)
c ECZET=dEc/dzeta [c](A3)
c FZ = dF/dzeta [c](A4)
      ECRS = EURS*(1.D0-F*Z4)+EPRS*F*Z4-ALFRSM*F*(1.D0-Z4)/FZZ
      FZ = THRD4*((1.D0+ZET)**THRD-(1.D0-ZET)**THRD)/GAM
      ECZET = 4.D0*(ZET**3)*F*(EP-EU+ALFM/FZZ)+FZ*(Z4*EP-Z4*EU
     1        -(1.D0-Z4)*ALFM/FZZ)
      COMM = EC -RS*ECRS/3.D0-ZET*ECZET
      VCUP = COMM + ECZET
      VCDN = COMM - ECZET
      if(lgga.eq.0)return
c----------------------------------------------------------------------
c----------------------------------------------------------------------
c PBE correlation energy
c G=phi(zeta), given after [a](3)
c DELT=bet/gamma
c B=A of [a](8)
      G=((1.d0+ZET)**thrd2+(1.d0-ZET)**thrd2)/2.d0
      G3 = G**3
      PON=-EC/(G3*gama)
      B = DELT/(DEXP(PON)-1.D0)
      B2 = B*B
      T2 = T*T
      T4 = T2*T2
      RS2 = RS*RS
      RS3 = RS2*RS
      Q4 = 1.D0+B*T2
      Q5 = 1.D0+B*T2+B2*T4
      H = G3*(BET/DELT)*DLOG(1.D0+DELT*Q4*T2/Q5)
      if(lpot.eq.0)return
c----------------------------------------------------------------------
c----------------------------------------------------------------------
C ENERGY DONE. NOW THE POTENTIAL, using appendix E of [b].
      G4 = G3*G
      T6 = T4*T2
      RSTHRD = RS/3.D0
      GZ=(((1.d0+zet)**2+eta)**sixthm-
     1((1.d0-zet)**2+eta)**sixthm)/3.d0
      FAC = DELT/B+1.D0
      BG = -3.D0*B2*EC*FAC/(BET*G4)
      BEC = B2*FAC/(BET*G3)
      Q8 = Q5*Q5+DELT*Q4*Q5*T2
      Q9 = 1.D0+2.D0*B*T2
      hB = -BET*G3*B*T6*(2.D0+B*T2)/Q8
      hRS = -RSTHRD*hB*BEC*ECRS
      FACT0 = 2.D0*DELT-6.D0*B
      FACT1 = Q5*Q9+Q4*Q9*Q9
      hBT = 2.D0*BET*G3*T4*((Q4*Q5*FACT0-DELT*FACT1)/Q8)/Q8
      hRST = RSTHRD*T2*hBT*BEC*ECRS
      hZ = 3.D0*GZ*h/G + hB*(BG*GZ+BEC*ECZET)
      hT = 2.d0*BET*G3*Q9/Q8
      hZT = 3.D0*GZ*hT/G+hBT*(BG*GZ+BEC*ECZET)
      FACT2 = Q4*Q5+B*T2*(Q4*Q9+Q5)
      FACT3 = 2.D0*B*Q5*Q9+DELT*FACT2
      hTT = 4.D0*BET*G3*T*(2.D0*B/Q8-(Q9*FACT3/Q8)/Q8)
      COMM = H+HRS+HRST+T2*HT/6.D0+7.D0*T2*T*HTT/6.D0
      PREF = HZ-GZ*T2*HT/G
      FACT5 = GZ*(2.D0*HT+T*HTT)/G
      COMM = COMM-PREF*ZET-UU*HTT-VV*HT-WW*(HZT-FACT5)

c---- DEBUG COR. POTENTIAL: PRINT BULLSHITS--------
c     write(*,*) 'comm',comm
c     write(*,*) 'zet,UU,HTT',zet,UU,HTT
c     write(*,*) 'VV,HT,WW,(HZT-FACT5)',VV,HT,WW,(HZT-FACT5)
c--------------------------------------------------

C-----IF CONDITION ON RHO
c     IF(rho.GE.0.735D0) THEN
c     COMM= 0.0D0     
c     ENDIF

      DVCUP = COMM + PREF
      DVCDN = COMM - PREF
      
      
C---- DEBUG COR. POTENTIAL: PRINT BULLSHITS--------
c     write(*,*) 'comm',comm
c     write(*,*) 'h,hrs,hrst',h,hrs,hrst
c     write(*,*) 't2*ht,t2*t*htt',t2*ht,t2*t*htt
c--------------------------------------------------

C---- DEBUG COR. POTENTIAL: PRINT BULLSHITS--------
c     write(*,*) 'vcup,vcdn',vcup,vcdn
c     write(*,*) 'dvcup,dvcdn',dvcup,dvcdn
c--------------------------------------------------

      RETURN
      END
c----------------------------------------------------------------------
c######################################################################
c----------------------------------------------------------------------
      SUBROUTINE GCOR2C(A,A1,B1,B2,B3,B4,rtrs,GG,GGRS)
c slimmed down version of GCOR used in PW91 routines, to interpolate
c LSD correlation energy, as given by (10) of
c J. P. Perdew and Y. Wang, Phys. Rev. B {\bf 45}, 13244 (1992).
c K. Burke, May 11, 1996.
      IMPLICIT REAL*8 (A-H,O-Z)
      Q0 = -2.D0*A*(1.D0+A1*rtrs*rtrs)
      Q1 = 2.D0*A*rtrs*(B1+rtrs*(B2+rtrs*(B3+B4*rtrs)))
      Q2 = DLOG(1.D0+1.D0/Q1)
      GG = Q0*Q2
      Q3 = A*(B1/rtrs+2.D0*B2+rtrs*(3.D0*B3+4.D0*B4*rtrs))
      GGRS = -2.D0*A*A1*Q2-Q0*Q3/(Q1*(1.d0+Q1))
      RETURN
      END
c----------------------------------------------------------------------
c######################################################################
c----------------------------------------------------------------------
      SUBROUTINE EXCHPW91C(D,S,U,V,EX,VX)
C  GGA91 EXCHANGE FOR A SPIN-UNPOLARIZED ELECTRONIC SYSTEM
C  INPUT D : DENSITY
C  INPUT S:  ABS(GRAD D)/(2*KF*D)
C  INPUT U:  (GRAD D)*GRAD(ABS(GRAD D))/(D**2 * (2*KF)**3)
C  INPUT V: (LAPLACIAN D)/(D*(2*KF)**2)
C  OUTPUT:  EXCHANGE ENERGY PER ELECTRON (EX) AND POTENTIAL (VX)
      IMPLICIT REAL*8 (A-H,O-Z)
      parameter(a1=0.19645D0,a2=0.27430D0,a3=0.15084D0,a4=100.d0)
      parameter(ax=-0.7385588D0,a=7.7956D0,b1=0.004d0)
      parameter(thrd=0.333333333333D0,thrd4=1.33333333333D0)
c for Becke exchange, set a3=b1=0
      FAC = AX*D**THRD
      S2 = S*S
      S3 = S2*S
      S4 = S2*S2
      P0 = 1.D0/DSQRT(1.D0+A*A*S2)
      P1 = DLOG(A*S+1.D0/P0)
      P2 = DEXP(-A4*S2)
      P3 = 1.D0/(1.D0+A1*S*P1+B1*S4)
      P4 = 1.D0+A1*S*P1+(A2-A3*P2)*S2
      F = P3*P4
      EX = FAC*F
C  LOCAL EXCHANGE OPTION
C     EX = FAC
C  ENERGY DONE. NOW THE POTENTIAL:
      P5 = B1*S2-(A2-A3*P2)
      P6 = A1*S*(P1+A*S*P0)
      P7 = 2.D0*(A2-A3*P2)+2.D0*A3*A4*S2*P2-4.D0*B1*S2*F
      FS = P3*(P3*P5*P6+P7)
      P8 = 2.D0*S*(B1-A3*A4*P2)
      P9 = A1*P1+A*A1*S*P0*(3.D0-A*A*S2*P0*P0)
      P10 = 4.D0*A3*A4*S*P2*(2.D0-A4*S2)-8.D0*B1*S*F-4.D0*B1*S3*FS
      P11 = -P3*P3*(A1*P1+A*A1*S*P0+4.D0*B1*S3)
      FSS = P3*P3*(P5*P9+P6*P8)+2.D0*P3*P5*P6*P11+P3*P10+P7*P11
      VX = FAC*(THRD4*F-(U-THRD4*S3)*FSS-V*FS)
C  LOCAL EXCHANGE OPTION:
C     VX = FAC*THRD4
      RETURN
      END
c----------------------------------------------------------------------
c######################################################################
c----------------------------------------------------------------------
      SUBROUTINE CORLSDC(RS,ZET,EC,VCUP,VCDN,ECRS,ECZET,ALFC)
C  UNIFORM-GAS CORRELATION OF PERDEW AND WANG 1991
C  INPUT: SEITZ RADIUS (RS), RELATIVE SPIN POLARIZATION (ZET)
C  OUTPUT: CORRELATION ENERGY PER ELECTRON (EC), UP- AND DOWN-SPIN
C     POTENTIALS (VCUP,VCDN), DERIVATIVES OF EC WRT RS (ECRS) & ZET (ECZET)
C  OUTPUT: CORRELATION CONTRIBUTION (ALFC) TO THE SPIN STIFFNESS
      IMPLICIT REAL*8 (A-H,O-Z)
      parameter(gam=0.5198421D0,fzz=1.709921D0)
      parameter(thrd=0.333333333333D0,thrd4=1.333333333333D0)
      F = ((1.D0+ZET)**THRD4+(1.D0-ZET)**THRD4-2.D0)/GAM
      CALL GCORC(0.0310907D0,0.21370D0,7.5957D0,3.5876D0,1.6382D0,
     1    0.49294D0,1.00D0,RS,EU,EURS)
      CALL GCORC(0.01554535D0,0.20548D0,14.1189D0,6.1977D0,3.3662D0,
     1    0.62517D0,1.00D0,RS,EP,EPRS)
      CALL GCORC(0.0168869D0,0.11125D0,10.357D0,3.6231D0,0.88026D0,
     1    0.49671D0,1.00D0,RS,ALFM,ALFRSM)
C  ALFM IS MINUS THE SPIN STIFFNESS ALFC
      ALFC = -ALFM
      Z4 = ZET**4
      EC = EU*(1.D0-F*Z4)+EP*F*Z4-ALFM*F*(1.D0-Z4)/FZZ
C  ENERGY DONE. NOW THE POTENTIAL:
      ECRS = EURS*(1.D0-F*Z4)+EPRS*F*Z4-ALFRSM*F*(1.D0-Z4)/FZZ
      FZ = THRD4*((1.D0+ZET)**THRD-(1.D0-ZET)**THRD)/GAM
      ECZET = 4.D0*(ZET**3)*F*(EP-EU+ALFM/FZZ)+FZ*(Z4*EP-Z4*EU
     1        -(1.D0-Z4)*ALFM/FZZ)
      COMM = EC -RS*ECRS/3.D0-ZET*ECZET
      VCUP = COMM + ECZET
      VCDN = COMM - ECZET
      RETURN
      END
c----------------------------------------------------------------------
c######################################################################
c----------------------------------------------------------------------
      SUBROUTINE GCORC(A,A1,B1,B2,B3,B4,P,RS,GG,GGRS)
C  CALLED BY SUBROUTINE CORLSD
      IMPLICIT REAL*8 (A-H,O-Z)
      P1 = P + 1.D0
      Q0 = -2.D0*A*(1.D0+A1*RS)
      RS12 = DSQRT(RS)
      RS32 = RS12**3
      RSP = RS**P
      Q1 = 2.D0*A*(B1*RS12+B2*RS+B3*RS32+B4*RS*RSP)
      Q2 = DLOG(1.D0+1.D0/Q1)
      GG = Q0*Q2
      Q3 = A*(B1/RS12+2.D0*B2+3.D0*B3*RS12+2.D0*B4*P1*RSP)
      GGRS = -2.D0*A*A1*Q2-Q0*Q3/(Q1**2+Q1)
      RETURN
      END
c----------------------------------------------------------------------
c######################################################################
c----------------------------------------------------------------------
      SUBROUTINE CORpw91C(RS,ZET,G,EC,ECRS,ECZET,T,UU,VV,WW,H,
     1                   DVCUP,DVCDN)
C  pw91 CORRELATION, modified by K. Burke to put all arguments 
c  as variables in calling statement, rather than in common block
c  May, 1996.
C  INPUT RS: SEITZ RADIUS
C  INPUT ZET: RELATIVE SPIN POLARIZATION
C  INPUT T: ABS(GRAD D)/(D*2.*KS*G)
C  INPUT UU: (GRAD D)*GRAD(ABS(GRAD D))/(D**2 * (2*KS*G)**3)
C  INPUT VV: (LAPLACIAN D)/(D * (2*KS*G)**2)
C  INPUT WW:  (GRAD D)*(GRAD ZET)/(D * (2*KS*G)**2
C  OUTPUT H: NONLOCAL PART OF CORRELATION ENERGY PER ELECTRON
C  OUTPUT DVCUP,DVCDN:  NONLOCAL PARTS OF CORRELATION POTENTIALS
      IMPLICIT REAL*8 (A-H,O-Z)
      parameter(xnu=15.75592D0,cc0=0.004235D0,cx=-0.001667212D0)
      parameter(alf=0.09D0)
      parameter(c1=0.002568D0,c2=0.023266D0,c3=7.389D-6,c4=8.723D0)
      parameter(c5=0.472D0,c6=7.389D-2,a4=100.D0)
      parameter(thrdm=-0.333333333333D0,thrd2=0.666666666667D0)
      BET = XNU*CC0
      DELT = 2.D0*ALF/BET
      G3 = G**3
      G4 = G3*G
      PON = -DELT*EC/(G3*BET)
      B = DELT/(DEXP(PON)-1.D0)
      B2 = B*B
      T2 = T*T
      T4 = T2*T2
      T6 = T4*T2
      RS2 = RS*RS
      RS3 = RS2*RS
      Q4 = 1.D0+B*T2
      Q5 = 1.D0+B*T2+B2*T4
      Q6 = C1+C2*RS+C3*RS2
      Q7 = 1.D0+C4*RS+C5*RS2+C6*RS3
      CC = -CX + Q6/Q7
      R0 = 0.663436444d0*rs
      R1 = A4*R0*G4
      COEFF = CC-CC0-3.D0*CX/7.D0
      R2 = XNU*COEFF*G3
      R3 = DEXP(-R1*T2)
      H0 = G3*(BET/DELT)*DLOG(1.D0+DELT*Q4*T2/Q5)
      H1 = R3*R2*T2
      H = H0+H1
C  LOCAL CORRELATION OPTION:
C     H = 0.0D0
C  ENERGY DONE. NOW THE POTENTIAL:
      CCRS = (C2+2.*C3*RS)/Q7 - Q6*(C4+2.*C5*RS+3.*C6*RS2)/Q7**2
      RSTHRD = RS/3.D0
      R4 = RSTHRD*CCRS/COEFF
      GZ = ((1.D0+ZET)**THRDM - (1.D0-ZET)**THRDM)/3.D0
      FAC = DELT/B+1.D0
      BG = -3.D0*B2*EC*FAC/(BET*G4)
      BEC = B2*FAC/(BET*G3)
      Q8 = Q5*Q5+DELT*Q4*Q5*T2
      Q9 = 1.D0+2.D0*B*T2
      H0B = -BET*G3*B*T6*(2.D0+B*T2)/Q8
      H0RS = -RSTHRD*H0B*BEC*ECRS
      FACT0 = 2.D0*DELT-6.D0*B
      FACT1 = Q5*Q9+Q4*Q9*Q9
      H0BT = 2.D0*BET*G3*T4*((Q4*Q5*FACT0-DELT*FACT1)/Q8)/Q8
      H0RST = RSTHRD*T2*H0BT*BEC*ECRS
      H0Z = 3.D0*GZ*H0/G + H0B*(BG*GZ+BEC*ECZET)
      H0T = 2.*BET*G3*Q9/Q8
      H0ZT = 3.D0*GZ*H0T/G+H0BT*(BG*GZ+BEC*ECZET)
      FACT2 = Q4*Q5+B*T2*(Q4*Q9+Q5)
      FACT3 = 2.D0*B*Q5*Q9+DELT*FACT2
      H0TT = 4.D0*BET*G3*T*(2.D0*B/Q8-(Q9*FACT3/Q8)/Q8)
      H1RS = R3*R2*T2*(-R4+R1*T2/3.D0)
      FACT4 = 2.D0-R1*T2
      H1RST = R3*R2*T2*(2.D0*R4*(1.D0-R1*T2)-THRD2*R1*T2*FACT4)
      H1Z = GZ*R3*R2*T2*(3.D0-4.D0*R1*T2)/G
      H1T = 2.D0*R3*R2*(1.D0-R1*T2)
      H1ZT = 2.D0*GZ*R3*R2*(3.D0-11.D0*R1*T2+4.D0*R1*R1*T4)/G
      H1TT = 4.D0*R3*R2*R1*T*(-2.D0+R1*T2)
      HRS = H0RS+H1RS
      HRST = H0RST+H1RST
      HT = H0T+H1T
      HTT = H0TT+H1TT
      HZ = H0Z+H1Z
      HZT = H0ZT+H1ZT
      COMM = H+HRS+HRST+T2*HT/6.D0+7.D0*T2*T*HTT/6.D0
      PREF = HZ-GZ*T2*HT/G
      FACT5 = GZ*(2.D0*HT+T*HTT)/G
      COMM = COMM-PREF*ZET-UU*HTT-VV*HT-WW*(HZT-FACT5)
      DVCUP = COMM + PREF
      DVCDN = COMM - PREF
C  LOCAL CORRELATION OPTION:
C     DVCUP = 0.0D0
C     DVCDN = 0.0D0
      RETURN
      END
C--------------------------------------------------
