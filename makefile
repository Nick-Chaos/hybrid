OBJ =      int.o init.o drive.o SCF.o  func.o  \
           int2.o  int3.o int3G.o exch.o    \
           exch2.o pot.o int2G.o int1G.o \
           geom.o intSG.o MD2.o write.o \
           dns.o dns2.o dnsg.o potg.o dip.o dipG.o  \
           int3N.o exchnum.o exchnum2.o grid.o\
           densg.o  exchfock.o\
           nwrite.o dfp2.o lsearch.o SCFop.o\
           densgop.o dns2op.o dnsop.o exchnum2op.o\
           exchnumop.o potop.o lalg.o alg.o\
           dnsgop.o potgop.o elec.o charge.o dip2.o vol.o\
           mmsol.o mmsolG.o intsolG.o intsol.o resp.o\
           efield.o  popu.o int3mem.o int3lu.o
LIBS= -L/opt/intel/mkl72/lib/32/ -lmkl_lapack -lmkl_ia32 -lguide 
COMPFLG  = -mp1 -ip -O3 -c
COMPFLG3 = -O -c
#more or less general
CPP     = /lib/cpp
CPPFLAGS =  -P -traditional-cpp
DEFINE   = -Dpack
/home/dbikiel/prog/DFT/big90 :  $(OBJ)
	ifort -o /home/dbikiel/prog/DFT/big90 $(OBJ)  $(LINKFLG)  $(LIBS)        
init.o    : init.f
	ifort $(COMPFLG) init.f 
int.o    : int.f param
	ifort $(COMPFLG) int.f 
int1G.o    : int1G.f param
	ifort $(COMPFLG) int1G.f 
drive.o : drive.f param 
	ifort $(COMPFLG) drive.f 
func.o : func.f
	ifort $(COMPFLG) func.f 
int2.o    : int2.f param
	$(CPP) $(CPPFLAGS) $(DEFINE) int2.f int2_cpp.f 
	ifort $(COMPFLG) int2_cpp.f 
	mv int2_cpp.o int2.o
	rm -f int2_cpp.f
int2G.o    : int2G.f param
	ifort $(COMPFLG) int2G.f 
int3G.o    : int3G.f param
	ifort $(COMPFLG) int3G.f 
int3.o    : int3.f param
	$(CPP) $(CPPFLAGS) $(DEFINE) int3.f int3_cpp.f
	ifort $(COMPFLG) int3_cpp.f
	mv int3_cpp.o int3.o
	rm -f int3_cpp.f
int3N.o    : int3N.f param
	$(CPP) $(CPPFLAGS) $(DEFINE) int3N.f int3N_cpp.f
	ifort $(COMPFLG) int3N_cpp.f
	mv int3N_cpp.o int3N.o
	rm -f int3N_cpp.f
int3lu.o    : int3lu.f param
	$(CPP) $(CPPFLAGS) $(DEFINE) int3lu.f int3lu_cpp.f
	ifort $(COMPFLG) int3lu_cpp.f
	mv int3lu_cpp.o int3lu.o
	rm -f int3lu_cpp.f
int3mem.o    : int3mem.f param
	ifort $(COMPFLG) int3mem.f
exch.o    : exch.f param
	$(CPP) $(CPPFLAGS) $(DEFINE) exch.f exch_cpp.f
	ifort $(COMPFLG) exch_cpp.f
	mv exch_cpp.o exch.o
	rm -f exch_cpp.f
exch2.o    : exch2.f param
	$(CPP) $(CPPFLAGS) $(DEFINE) exch2.f exch2_cpp.f
	ifort $(COMPFLG) exch2_cpp.f
	mv exch2_cpp.o exch2.o
	rm -f exch2_cpp.f
pot.o    : pot.f 
	ifort $(COMPFLG) pot.f 
SCF.o    : SCF.f param
	$(CPP) $(CPPFLAGS) $(DEFINE) SCF.f SCF_cpp.f
	ifort $(COMPFLG) SCF_cpp.f 
	mv SCF_cpp.o SCF.o
	rm -f SCF_cpp.f
MD2.o     : MD2.f param
	ifort $(COMPFLG) MD2.f 
geom.o     : geom.f param
	$(CPP) $(CPPFLAGS) $(DEFINE) geom.f geom_cpp.f
	ifort $(COMPFLG) geom_cpp.f
	mv geom_cpp.o geom.o
	rm -f geom_cpp.f
intSG.o     : intSG.f param
	ifort $(COMPFLG) intSG.f 
dfp2.o     : dfp2.f param
	ifort $(COMPFLG) dfp2.f 
lsearch.o     : lsearch.f param
	ifort $(COMPFLG) lsearch.f 
write.o     : write.f param
	$(CPP) $(CPPFLAGS) $(DEFINE) write.f write_cpp.f
	ifort $(COMPFLG) write_cpp.f
	mv write_cpp.o write.o
	rm -f write_cpp.f
nwrite.o     : nwrite.f param
	$(CPP) $(CPPFLAGS) $(DEFINE) nwrite.f nwrite_cpp.f
	ifort $(COMPFLG) nwrite_cpp.f
	mv nwrite_cpp.o nwrite.o
	rm -f nwrite_cpp.f
dns.o     : dns.f param
	ifort $(COMPFLG) dns.f 
dns2.o     : dns2.f param
	ifort $(COMPFLG) dns2.f 
dnsg.o     : dnsg.f param
	ifort $(COMPFLG) dnsg.f 
densg.o     : densg.f param
	ifort $(COMPFLG) densg.f 
potg.o     : potg.f 
	ifort $(COMPFLG) potg.f 
dip.o     : dip.f param
	ifort $(COMPFLG) dip.f 
dipG.o     : dipG.f param
	ifort $(COMPFLG) dipG.f 
dip2.o     : dip2.f param
	ifort $(COMPFLG) dip2.f 
vol.o     : vol.f param
	ifort $(COMPFLG) vol.f 
exchnum.o     : exchnum.f param
	ifort $(COMPFLG) exchnum.f 
grid.o     : grid.f
	ifort $(COMPFLG) grid.f 
exchnum2.o     : exchnum2.f param
	ifort $(COMPFLG) exchnum2.f 
exchfock.o     : exchfock.f param
	ifort $(COMPFLG) exchfock.f 
SCFop.o    : SCFop.f param
	$(CPP) $(CPPFLAGS) $(DEFINE) SCFop.f SCFop_cpp.f
	ifort $(COMPFLG) SCFop_cpp.f
	mv SCFop_cpp.o SCFop.o
	rm -f SCFop_cpp.f
densgop.o     : densgop.f param
	ifort $(COMPFLG) densgop.f
dns2op.o     : dns2op.f param
	ifort $(COMPFLG) dns2op.f
dnsop.o     : dnsop.f param
	ifort $(COMPFLG) dnsop.f
exchnum2op.o     : exchnum2op.f param
	ifort $(COMPFLG) exchnum2op.f
exchnumop.o     : exchnumop.f param
	ifort $(COMPFLG) exchnumop.f
potop.o     : potop.f param
	ifort $(COMPFLG) potop.f
potgop.o     : potgop.f 
	ifort $(COMPFLG) potgop.f
dnsgop.o     : dnsgop.f param
	ifort $(COMPFLG) dnsgop.f
alg.o     : alg.f 
	ifort $(COMPFLG) alg.f
#eig.o     : eig.f
#	ifort $(COMPFLG3) eig.f
#svd.o     : svd.f
#	ifort $(COMPFLG3) svd.f
elec.o     : elec.f param
	ifort $(COMPFLG) elec.f 
charge.o   : charge.f param
	$(CPP) $(CPPFLAGS) $(DEFINE) charge.f charge_cpp.f
	ifort $(COMPFLG) charge_cpp.f
	mv charge_cpp.o charge.o
	rm -f charge_cpp.f
intsol.o    : intsol.f param
	ifort $(COMPFLG) intsol.f 
mmsol.o    : mmsol.f param
	ifort $(COMPFLG) mmsol.f 
intsolG.o    : intsolG.f param
	ifort $(COMPFLG) intsolG.f 
mmsolG.o    : mmsolG.f param
	ifort $(COMPFLG) mmsolG.f 
resp.o    : resp.f param
	ifort $(COMPFLG) resp.f 
efield.o    : efield.f param
	ifort $(COMPFLG) efield.f 
lalg.o    : lalg.f param
	ifort $(COMPFLG) lalg.f 
popu.o    : popu.f param
	ifort $(COMPFLG) popu.f 




