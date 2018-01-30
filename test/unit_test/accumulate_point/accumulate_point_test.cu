//#ifndef GPU_KENERLS
//#define GPU_KERNELS
//#endif

#include <cassert>
#include <fstream>
#include <iostream>
#include <limits>
#include <map>
#include <math_constants.h>
#include <float.h>
#include <string>
#include <vector>
#include <cuda.h>
#include <cuda_runtime.h>


#include "../../../g2g/common.h"
#include "../../../g2g/init.h"
#include "../../../g2g/cuda/cuda_extra.h"
#include "../../../g2g/matrix.h"
#include "../../../g2g/timer.h"
#include "../../../g2g/partition.h"
#include "../../../g2g/scalar_vector_types.h"
#include "../../../g2g/global_memory_pool.h"

//#include "../../../g2g/pointxc/calc_ggaCS.h"
//#include "../../../g2g/pointxc/calc_ggaOS.h"

//#include "../../../g2g/cuda/kernels/accumulate_point.h"

#include "../../../g2g/libxc/libxcproxy.h"
#include "../../../g2g/libxc/libxc_accumulate_point.h"

//////////////////////////////////////
//// CALC_GGA
#define POT_ALPHA     ((scalar_type)-0.738558766382022447)
#define POT_GL        ((scalar_type)0.620350490899400087)

#define POT_VOSKO_A1  ((scalar_type)0.03109205)
#define POT_VOSKO_B1  ((scalar_type)3.72744)
#define POT_VOSKO_C1  ((scalar_type)12.9352)
#define POT_VOSKO_X0  ((scalar_type)-0.10498)
#define POT_VOSKO_Q   ((scalar_type)6.15199066246304849)
#define POT_VOSKO_A16 ((scalar_type)0.005182008333)
#define POT_VOSKO_Q2  ((scalar_type)4.7309269)

#define POT_ALYP  ((scalar_type)0.04918)
#define POT_BLYP  ((scalar_type)0.132)
#define POT_CLYP  ((scalar_type)0.2533)
#define POT_CLYP3 ((scalar_type)0.0844333333)
#define POT_DLYP  ((scalar_type)0.349)
#define POT_DLYP3 ((scalar_type)0.116333333)
#define POT_CF    ((scalar_type)2.87123400018819)
#define POT_BETA  ((scalar_type)0.0042)

#define POT_ALF ((scalar_type)0.023266)
#define POT_BET ((scalar_type)7.389)
#define POT_GAM ((scalar_type)8.723)
#define POT_DEL ((scalar_type)0.472)


template<class scalar_type, int iexch, unsigned int width>  __device__
void calc_ggaCS( scalar_type dens, 
                 const G2G::vec_type<scalar_type,width>& grad,
                 const G2G::vec_type<scalar_type,width>& hess1,
                 const G2G::vec_type<scalar_type,width>& hess2,
                 scalar_type& ex, 
                 scalar_type& ec, 
                 scalar_type& y2a)
{
   // hess1: xx, yy, zz  || hess2: xy, xz, yz
   const scalar_type MINIMUM_DENSITY_VALUE = 1e-13f;
   if (dens < MINIMUM_DENSITY_VALUE) { ex = ec = 0; return; }

   scalar_type y     = cbrt( (scalar_type)dens );  // rho^(1/3)
   scalar_type grad2 = grad.x * grad.x + grad.y * grad.y + grad.z * grad.z;
   if (grad2 == 0) grad2 = (scalar_type)FLT_MIN;
   scalar_type dgrad = sqrt(grad2);

   scalar_type d0 = hess1.x + hess1.y + hess1.z;
   scalar_type u0 = ((grad.x * grad.x) * hess1.x 
                  + 2.0 * grad.x * grad.y * hess2.x 
                  + 2.0 * grad.y * grad.z * hess2.z 
                  + 2.0 * grad.x * grad.z * hess2.y 
                  + (grad.y * grad.y) * hess1.y 
                  + (grad.z * grad.z) * hess1.z) / dgrad;
   y2a = 0;

   // Exchange - Perdew : Phys. Rev B 33 8800 (1986)
   if (iexch == 4 || iexch == 8) {
      scalar_type dens2 = (dens * dens);
      scalar_type ckf   = (scalar_type)3.0936677 * y;
      scalar_type s     = dgrad / ((scalar_type)2.0 * ckf * dens);

      scalar_type fx = (1.0 / 15.0);
      scalar_type s2 = (s * s);
      scalar_type s3 = (s * s * s);
      scalar_type g0 = 1.0 + 1.296 * s2 + 14.0 * pow(s, 4) + 0.2 * pow(s, 6);
      scalar_type F  = pow(g0, fx);
      scalar_type e  = POT_ALPHA * F * y;
      ex = e;

      scalar_type t = d0 / (dens * 4.0 * (ckf * ckf));
      scalar_type u = u0 / (pow( (scalar_type)2.0 * ckf, 3) * dens2);

      scalar_type g2  = 2.592 * s + 56.0 * s3 + 1.2 * pow(s, 5);
      scalar_type g3  = 2.592     + 56.0 * s2 + 1.2 * pow(s, 4);
      scalar_type g4  = 112.0 * s + 4.8  * s3;
      scalar_type dF  = fx * F/g0 * g2;
      scalar_type dsF = fx * F/g0 * (-14.0 * fx * g3 * g2/g0 + g4);

      y2a = POT_ALPHA * y * (1.33333333333 * F - t/s * dF - (u-1.3333333333 * s3) * dsF);
   } else if (iexch >= 5 && iexch <= 7) { // Becke  : Phys. Rev A 38 3098 (1988)
      scalar_type e0 = POT_ALPHA * y;
      scalar_type y2 = dens / 2.0;
      scalar_type r13 = cbrt( y2 );
      scalar_type r43 = cbrt( pow(y2, 4) );
      scalar_type Xs = dgrad / (2.0 * r43);
      scalar_type siper = asinh(Xs);
      scalar_type DN = 1.0 + 6.0 * POT_BETA * Xs * siper;
      scalar_type ect = -2.0 * POT_BETA * r43 * Xs * Xs/(DN * dens);
      scalar_type e = e0 + ect;
      ex = e;

      // Potential
      scalar_type v0 = 1.33333333333333 * e0;
      scalar_type Fb = 1.0 / DN;
      scalar_type XA1 = Xs / sqrt(1.0 + Xs * Xs);
      scalar_type DN1 = 1.0 + Fb * (1.0 - 6.0 * POT_BETA * Xs * XA1);
      scalar_type DN2 = 1.0 / (1.0 + Xs * Xs) + 2.0 * Fb * (2.0 - 6.0 * POT_BETA * Xs * XA1);
      scalar_type DN3 = siper * (1.0 + 2.0 * Fb) + XA1 * DN2;
      scalar_type D02 = d0 / 2.0;
      scalar_type de1 = 1.33333333333333 / (cbrt(pow((scalar_type)dens,7) ) );

      scalar_type DGRADx = (grad.x * hess1.x + grad.y * hess2.x + grad.z * hess2.y) / dgrad;
      scalar_type GRADXx = cbrt( (scalar_type) 2.0 ) * (1.0 / (dens * y) * DGRADx - de1 * grad.x * dgrad);
      scalar_type DGRADy = (grad.x * hess2.x + grad.y * hess1.y + grad.z * hess2.z) / dgrad;
      scalar_type GRADXy = cbrt( (scalar_type) 2.0 ) * (1.0 / (dens * y) * DGRADy - de1 * grad.y * dgrad);
      scalar_type DGRADz = (grad.x * hess2.y + grad.y * hess2.z + grad.z * hess1.z) / dgrad;
      scalar_type GRADXz = cbrt( (scalar_type) 2.0 ) * (1.0 / (dens * y) * DGRADz - de1 * grad.z * dgrad);

      scalar_type T1   = grad.x / 2.0 * GRADXx;
      scalar_type T2   = grad.y / 2.0 * GRADXy;
      scalar_type T3   = grad.z / 2.0 * GRADXz;
      scalar_type DN4  = 6.0 * POT_BETA * Fb * (T1 + T2 + T3);
      scalar_type DN5  = 1.33333333333333 * r43 * r13 * Xs * Xs;
      scalar_type TOT2 = DN5 - D02 * DN1 + DN4 * DN3;

      scalar_type vxc = -POT_BETA * Fb/r43 * TOT2;
      y2a = v0 + vxc;
   } else { // PBE
      scalar_type dgrad1 = grad.x * grad.x * hess1.x;
      scalar_type dgrad2 = grad.y * grad.y * hess1.y;
      scalar_type dgrad3 = grad.z * grad.z * hess1.z;
      scalar_type dgrad4 = grad.x * grad.y * hess2.x;
      scalar_type dgrad5 = grad.x * grad.z * hess2.y;
      scalar_type dgrad6 = grad.y * grad.z * hess2.z;
      scalar_type delgrad = (dgrad1 + dgrad2 + dgrad3 + 2 * (dgrad4 + dgrad5 + dgrad6)) / dgrad;
      scalar_type rlap = hess1.x + hess1.y + hess1.z;

      scalar_type expbe, vxpbe, ecpbe, vcpbe;
      //pbeCS(dens, dgrad, delgrad, rlap, expbe, vxpbe, ecpbe, vcpbe);

      ex  = expbe;
      ec  = ecpbe;
      y2a = vxpbe + vcpbe;
      return;
   }

   // Correlation - Perdew : Phys. Rev B 33 8822 (1986)
   if (iexch >= 4 && iexch <= 6) {
      // TO-DO: hay algun problema con 4 y 5, probablemente este aca
      scalar_type dens2 = (dens * dens);
      scalar_type rs  = POT_GL / y;
      scalar_type x1  = sqrt(rs);
      scalar_type Xx  = rs + POT_VOSKO_B1 * x1 + POT_VOSKO_C1;
      scalar_type Xxo = (POT_VOSKO_X0 * POT_VOSKO_X0) 
                      + POT_VOSKO_B1 * POT_VOSKO_X0 + POT_VOSKO_C1;
  
      scalar_type t1 = 2.0 * x1 + POT_VOSKO_B1;
      scalar_type t2 = log(Xx);
      scalar_type t3 = atan(POT_VOSKO_Q/t1);
      scalar_type t4 = POT_VOSKO_B1 * POT_VOSKO_X0/Xxo;

      ec = POT_VOSKO_A1 * ( 2.0 * log(x1) - t2 
           + 2.0 * POT_VOSKO_B1/POT_VOSKO_Q * t3
           - t4 *(2.0 * log(x1 - POT_VOSKO_X0) - t2 
           + 2.0 * (POT_VOSKO_B1 + 2.0 * POT_VOSKO_X0) / POT_VOSKO_Q * t3));

      scalar_type t5 = (POT_VOSKO_B1 * x1 + 2.0 * POT_VOSKO_C1) / x1;
      scalar_type t6 = POT_VOSKO_X0 / Xxo;
      scalar_type vc = ec - POT_VOSKO_A16 * x1 * 
                   ( t5/Xx - 4.0 * POT_VOSKO_B1 / ((t1 * t1)+(POT_VOSKO_Q * POT_VOSKO_Q2)) 
                   * (1.0 - t6 * (POT_VOSKO_B1 - 2.0 * POT_VOSKO_X0)) 
                   - t4 * (2.0 / (x1 - POT_VOSKO_X0) - t1/Xx));

      if (iexch == 6) {
         y2a = y2a + vc;
      } else {
         scalar_type rs2 = (rs * rs);
         scalar_type Cx1 = 0.002568f + POT_ALF * rs + POT_BET * rs2;
         scalar_type Cx2 = 1.0f + POT_GAM * rs + POT_DEL * rs2 + 1.0e4 * POT_BET * (rs * rs * rs);
         scalar_type C   = 0.001667 + Cx1/Cx2;
         scalar_type Cx3 = POT_ALF + 2.0f * POT_BET * rs;
         scalar_type Cx4 = POT_GAM + 2.0f * POT_DEL * rs + 3.0e4 * POT_BET * rs2;
         scalar_type dC  = Cx3/Cx2 - Cx1/(Cx2 * Cx2) * Cx4;
         dC = -0.333333333333333f * dC * POT_GL / (y * dens);

         scalar_type phi  = 0.0008129082f/C * dgrad/pow((scalar_type)dens, (scalar_type)(7.0f/6.0f));
         scalar_type expo = exp(-phi);
         scalar_type ex0  = expo * C;

         ec = ec + ex0 * grad2 / (y * dens2);

         scalar_type D1   = (2.0f - phi) * d0/dens;
         scalar_type phi2 = (phi * phi);
         scalar_type D2   = 1.33333333333333333f - 3.666666666666666666f * phi + 1.166666666666666f * phi2;
         D2 = D2 * grad2/dens2;
         scalar_type D3 = phi * (phi - 3.0f) * u0/(dens * dgrad);
         scalar_type D4 = expo * grad2 / (y * dens) * (phi2 - phi - 1.0f) * dC;

         vc = vc - 1.0 * (ex0 / y * (D1 - D2 + D3) - D4);
         y2a = y2a + vc;
      }
   } else if (iexch == 7 || iexch == 8) { // Correlation - LYP: PRB 37 785 (1988)
      scalar_type rom13 = 1 / cbrt( dens );
      scalar_type rom53 = cbrt( pow(dens, 5) );
      scalar_type ecro  = expf(-POT_CLYP * rom13);
      scalar_type f1    = 1.0f / (1.0f + POT_DLYP * rom13);
      scalar_type tw    = 1.0f / 8.0f * (grad2/dens - d0);
      scalar_type term  = (tw / 9.0f + d0 / 18.0f) - 2.0f * tw + POT_CF * rom53;
      term = dens + POT_BLYP * (rom13 * rom13) * ecro * term;

      ec = -POT_ALYP * f1 * term/dens;

      scalar_type h1 = ecro/rom53;
      scalar_type g1 = f1 * h1;
      scalar_type tm1 = POT_DLYP3 * (rom13/dens);
      scalar_type fp1 = tm1 * (f1 * f1);
      scalar_type tm2 = -1.666666666f + POT_CLYP3 * rom13;
      scalar_type hp1 = h1 * tm2/dens;
      scalar_type gp1 = fp1 * h1 + hp1 * f1;
      scalar_type fp2 = tm1 * 2.0f * f1 * (fp1 - 0.6666666666f * f1/dens);
      scalar_type tm3 = 1.6666666666f - POT_CLYP3 * 1.3333333333f * rom13;
      scalar_type hp2 = hp1 * tm2/dens + h1 * tm3/(dens * dens);
      scalar_type gp2 = fp2 * h1 + 2.0f * fp1 * hp1 + hp2 * f1;

      scalar_type term3 = -POT_ALYP * (fp1 * dens + f1) 
                          -POT_ALYP * POT_BLYP * POT_CF * (gp1 * dens + 8.0f/3.0f * g1) * rom53;
      scalar_type term4 = (gp2 * dens * grad2 + gp1 * (3.0f * grad2 + 2.0f * dens * d0)
                          + 4.0f * g1 * d0) * POT_ALYP * POT_BLYP/4.0f;
      scalar_type term5 = (3.0f * gp2 * dens * grad2 + gp1 * (5.0f * grad2 + 6.0f * dens * d0)
                          + 4.0f * g1 * d0) * POT_ALYP * POT_BLYP/72.0f;

      y2a = y2a + (term3 - term4 - term5);
   }
}

template<class scalar_type, unsigned int width> __device__
void calc_ggaCS_in( scalar_type dens, 
                    const G2G::vec_type<scalar_type,width>& grad,
                    const G2G::vec_type<scalar_type,width>& hess1,
                    const G2G::vec_type<scalar_type,width>& hess2,
                    scalar_type& ex, 
                    scalar_type& ec, 
                    scalar_type& y2a,
                    const int iexch)
{
   switch(iexch) {
      case 0: return calc_ggaCS<scalar_type, 0, width>(dens, grad, hess1, hess2, ex, ec, y2a);
      case 1: return calc_ggaCS<scalar_type, 1, width>(dens, grad, hess1, hess2, ex, ec, y2a);
      case 2: return calc_ggaCS<scalar_type, 2, width>(dens, grad, hess1, hess2, ex, ec, y2a);
      case 3: return calc_ggaCS<scalar_type, 3, width>(dens, grad, hess1, hess2, ex, ec, y2a);
      case 4: return calc_ggaCS<scalar_type, 4, width>(dens, grad, hess1, hess2, ex, ec, y2a);
      case 5: return calc_ggaCS<scalar_type, 5, width>(dens, grad, hess1, hess2, ex, ec, y2a);
      case 6: return calc_ggaCS<scalar_type, 6, width>(dens, grad, hess1, hess2, ex, ec, y2a);
      case 7: return calc_ggaCS<scalar_type, 7, width>(dens, grad, hess1, hess2, ex, ec, y2a);
      case 8: return calc_ggaCS<scalar_type, 8, width>(dens, grad, hess1, hess2, ex, ec, y2a);
      case 9: return calc_ggaCS<scalar_type, 9, width>(dens, grad, hess1, hess2, ex, ec, y2a);
      default: assert(false);
   }
}



//////////////////////////////////////
//// KERNEL FOR ACCUMULATE_POINT
template<class scalar_type, bool compute_energy, bool compute_factor, bool lda>
__global__ void gpu_accumulate_point (scalar_type* const energy, scalar_type* const factor, 
		    const scalar_type* const point_weights,
            	    uint points, int block_height, scalar_type* partial_density, 
		    G2G::vec_type<scalar_type,4>* dxyz,
                    G2G::vec_type<scalar_type,4>* dd1, 
		    G2G::vec_type<scalar_type,4>* dd2) {

  uint point = blockIdx.x * DENSITY_ACCUM_BLOCK_SIZE + threadIdx.x;
  //uint point = blockIdx.x * 128 + threadIdx.x;

  scalar_type point_weight = 0.0f;
  scalar_type y2a, exc_corr, exc_c, exc_x;

  scalar_type _partial_density(0.0f);
  G2G::vec_type<scalar_type,4> _dxyz, _dd1, _dd2;

  _dxyz = _dd1 = _dd2 = G2G::vec_type<scalar_type,4>(0.0f,0.0f,0.0f,0.0f);

  bool valid_thread = (point < points);
  if (valid_thread)
    point_weight = point_weights[point];

  if (valid_thread) {
    for(int j =0 ; j<block_height; j++) {
      const int this_row = j*points+point;

      _partial_density += partial_density[this_row];
      _dxyz += dxyz[this_row];
      _dd1 += dd1[this_row];
      _dd2 += dd2[this_row];
     }
  }

  calc_ggaCS_in<scalar_type, 4>(_partial_density, _dxyz, _dd1, _dd2, exc_x, exc_c, y2a, 9);
  exc_corr = exc_x + exc_c;

  if (compute_energy && valid_thread){
    energy[point] = (_partial_density * point_weight) * exc_corr;
  }

  if (compute_factor && valid_thread){
    factor[point] = point_weight * y2a;
  }

}


//////////////////////////////////////
//// TESTS

void gpu_accumulate_point_test0001()
{
    printf("** gpu_accumulate_point_test0001 **\n");

    cudaError_t err = cudaSuccess;
    uint n = 5;
    uint m = 5;
    uint number_of_points = n+m;

    G2G::CudaMatrix< G2G::vec_type<double,4> > dxyz_gpu;
    G2G::CudaMatrix< G2G::vec_type<double,4> > dd1_gpu;
    G2G::CudaMatrix< G2G::vec_type<double,4> > dd2_gpu;

    dxyz_gpu.resize(COALESCED_DIMENSION(number_of_points),m);
    dd1_gpu.resize(COALESCED_DIMENSION(number_of_points),m);
    dd2_gpu.resize(COALESCED_DIMENSION(number_of_points),m);

    // Now the arrays for energy, factors, point_weight and partial_density
    double *energy_gpu = NULL;
    double *factor_gpu = NULL;
    double *point_weights_gpu = NULL;
    double *partial_density_gpu = NULL;

    // Create the arrays in CUDA memory.
    uint size = number_of_points * sizeof(double);
    err = cudaMalloc((void**)&energy_gpu, size);
    if (err != cudaSuccess)
    {
	printf("Failed to allocate vector energy_gpu!\n");
    }

    err = cudaMalloc((void**)&factor_gpu, size);
    if (err != cudaSuccess)
    {
	printf("Failed to allocate vector factor_gpu!\n");
    }

    err = cudaMalloc((void**)&point_weights_gpu, size);
    if (err != cudaSuccess)
    {
	printf("Failed to allocate vector point_weights_gpu!\n");
    }

    err = cudaMalloc((void**)&partial_density_gpu, size);
    if (err != cudaSuccess)
    {
	printf("Failed to allocate vector partial_density_gpu!\n");
    }

    // Set the cuda array values to a default value.
    cudaMemset(energy_gpu, -1, size);
    cudaMemset(factor_gpu, -2, size);
    cudaMemset(point_weights_gpu, -3, size);
    cudaMemset(partial_density_gpu, -4, size);

    // Launch the CUDA Kernel
    int numElements = n+m;
    int threadsPerBlock = 32;
    int blocksPerGrid = (numElements + threadsPerBlock - 1) / threadsPerBlock;
    printf("CUDA kernel launch with %d blocks of %d threads\n", blocksPerGrid, threadsPerBlock);
    // Call the CUDA KERNEL
    gpu_accumulate_point<double,true, true, false><<<blocksPerGrid, threadsPerBlock>>> 
		    (energy_gpu, factor_gpu, 
		    point_weights_gpu,
            	    numElements, 1, partial_density_gpu, 
		    dxyz_gpu.data,
                    dd1_gpu.data, 
		    dd2_gpu.data);


    // TODO: copy and print the results.

    cudaFree(energy_gpu);
    cudaFree(factor_gpu);
    cudaFree(point_weights_gpu);
    cudaFree(partial_density_gpu);

}

void cpu_accumulate_point_test0001()
{
    printf("** cpu_accumulate_point_test0001 **\n");
    cudaError_t err = cudaSuccess;
    uint n = 5;
    uint m = 5;
    uint number_of_points = n+m;

    G2G::CudaMatrix< G2G::vec_type<double,4> > dxyz_gpu;
    G2G::CudaMatrix< G2G::vec_type<double,4> > dd1_gpu;
    G2G::CudaMatrix< G2G::vec_type<double,4> > dd2_gpu;

    dxyz_gpu.resize(COALESCED_DIMENSION(number_of_points),m);
    dd1_gpu.resize(COALESCED_DIMENSION(number_of_points),m);
    dd2_gpu.resize(COALESCED_DIMENSION(number_of_points),m);

    G2G::vec_type<double,4>* dxyz_cpu;
    G2G::vec_type<double,4>* dd1_cpu;
    G2G::vec_type<double,4>* dd2_cpu;

    // Alloc memory in the host for the gpu data
    uint size = (n+m) * sizeof(G2G::vec_type<double,4>);
    dxyz_cpu = (G2G::vec_type<double,4> *)malloc(size);
    dd1_cpu = (G2G::vec_type<double,4> *)malloc(size);
    dd2_cpu = (G2G::vec_type<double,4> *)malloc(size);

    // Copy data from device to host.
    err = cudaMemcpy(dxyz_cpu, dxyz_gpu.data, size, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess)
    {
        printf("Failed to copy vector dxyz_gpu from device to host!\n");
        exit(EXIT_FAILURE);
    }

    err = cudaMemcpy(dd1_cpu, dd1_gpu.data, size, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess)
    {
        printf("Failed to copy vector dd1_gpu from device to host!\n");
        exit(EXIT_FAILURE);
    }

    err = cudaMemcpy(dd2_cpu, dd2_gpu.data, size, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess)
    {
        printf("Failed to copy vector dd2_gpu from device to host!\n");
        exit(EXIT_FAILURE);
    }

    // Allocate the host input vectors
    double *energy_cpu = (double *)malloc(size);
    double *factor_cpu = (double *)malloc(size);
    double *point_weights_cpu = (double *)malloc(size);
    double *partial_density_cpu = (double *)malloc(size);

    const int nspin = 1;
    const int functionalExchange = 101;
    const int functionalCorrelation = 130;
    LibxcProxy<double,4> libxcProxy(functionalExchange, functionalCorrelation, nspin);

    // CALL CPU ACCUMULATE POINT
    libxc_cpu_accumulate_point<double, true, true, false>(&libxcProxy, energy_cpu, 
	factor_cpu, point_weights_cpu,
        number_of_points, 1, partial_density_cpu, 
	dxyz_cpu, dd1_cpu, dd2_cpu);

    // Free jack :)
    free(energy_cpu);
    free(factor_cpu);
    free(point_weights_cpu);
    free(partial_density_cpu);

    free(dd1_cpu);
    free(dd2_cpu);
    free(dxyz_cpu);

}





/////////////////////////////////////
//// MAIN

int main(int argc, char **argv)
{
    printf("****************************\n");
    printf("** Accumulate Point test  **\n");
    printf("****************************\n");

    gpu_accumulate_point_test0001();
    cpu_accumulate_point_test0001();

    printf("*************************\n");
    printf("**      Test End       **\n");
    printf("*************************\n");

    return 0;
}