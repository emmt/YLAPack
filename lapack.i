/*
 * lapack.i --
 *
 * Interface for BLAS and LAPACK libraries for Yorick.
 *
 *-----------------------------------------------------------------------------
 *
 * Copyright (C) 2011-2017 Éric Thiébaut <eric.thiebaut@univ-lyon1.fr>
 *
 * This file is part of YLAPACK.
 *
 * YLAPACK is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * YLAPACK is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along
 * with YLAPACK.  If not, see <http://www.gnu.org/licenses/>.
 */

if (is_func(plug_in)) plug_in, "ylapack";

// ORDER:
LPK_ROW_MAJOR  = 101;
LPK_COL_MAJOR  = 102;
// TRANSPOSE:
LPK_NO_TRANS   = 111;
LPK_TRANS      = 112;
LPK_CONJ_TRANS = 113;
LPK_ATLAS_CONJ = 114;
// UPLO:
LPK_UPPER      = 121;
LPK_LOWER      = 122;
// DIAG:
LPK_NON_UNIT   = 131;
LPK_UNIT       = 132;
// CBLAS_SIDE:
LPK_LEFT       = 141;
LPK_RIGHT      = 142;

func lpk_trfill(uplo, a)
{
  ntot = numberof(a);
  n = long(0.5 + sqrt(ntot));
  if (n*n != ntot) error, "expecting a square matrix";
  if (! am_subroutine()) {
    insure_temporary, a;
  }
  if (uplo == LPK_UPPER) {
    for (i = 1; i <= n; ++i) {
      for (j = 1; j < i; ++j) {
        a(i,j) = a(j,i);
      }
    }
  } else if (uplo == LPK_LOWER) {
    for (i = 1; i <= n; ++i) {
      for (j = i+1; j <= n; ++j) {
        a(i,j) = a(j,i);
      }
    }
  } else {
    error, "bad value for UPLO";
  }
  return a;
}
func lpk_trzero(uplo, a)
{
  ntot = numberof(a);
  n = long(0.5 + sqrt(ntot));
  if (n*n != ntot) error, "expecting a square matrix";
  if (! am_subroutine()) {
    insure_temporary, a;
  }
  zero = structof(a)(0);
  if (uplo == LPK_UPPER) {
    for (i = 1; i <= n; ++i) {
      for (j = 1; j < i; ++j) {
        a(i,j) = zero;
      }
    }
  } else if (uplo == LPK_LOWER) {
    for (i = 1; i <= n; ++i) {
      for (j = i+1; j <= n; ++j) {
        a(i,j) = zero;
      }
    }
  } else {
    error, "bad value for UPLO";
  }
  return a;
}


local lpk_intro;
/* DOCUMENT LAPACK support for Yorick


   Utilities:
     lpk_model - get the name of the library implementing BLAS/LAPACK.
     lpk_laver - get the version of the LAPACK library.

   BLAS level 1 (vector operations):
     lpk_nrm2 - compute the Euclidean (L2) norm of a vector.
     lpk_asum - compute the sum of absolute values (L1 norm) of a vector.
     lpk_scal - scale a vector.
     lpk_copy - copy a vector into another vector.
     lpk_swap - exchange the elements of two vectors.
     lpk_dot  - dot product of two vectors.
     lpk_axpy - linear combination of two vectors.

   BLAS level 2 (vector-matrix operations):
     lpk_gemv - general matrix-vector multiplication.

   BLAS level 3 (matrix-matrix operations):
     lpk_gemm - general matrix-matrix multiplication.


   Matrix types in the LAPACK naming scheme
     BD - bidiagonal
     DI - diagonal
     GB - general band
     GE - general (i.e., unsymmetric, in some cases rectangular)
     GG - general matrices, generalized problem (i.e., a pair of general
          matrices)
     GT - general tridiagonal
     HB - (complex) Hermitian band
     HE - (complex) Hermitian
     HG - upper Hessenberg matrix, generalized problem (i.e., a Hessenberg
          and a triangular matrix)
     HP - (complex) Hermitian, packed storage
     HS - upper Hessenberg
     OP - (real) orthogonal, packed storage
     OR - (real) orthogonal
     PB - symmetric or Hermitian positive definite band
     PO - symmetric or Hermitian positive definite
     PP - symmetric or Hermitian positive definite, packed storage
     PT - symmetric or Hermitian positive definite tridiagonal
     SB - (real) symmetric band
     SP - symmetric, packed storage
     ST - (real) symmetric tridiagonal
     SY - symmetric
     TB - triangular band
     TG - triangular matrices, generalized problem (i.e., a pair of
          triangular matrices)
     TP - triangular, packed storage
     TR - triangular (or in some cases quasi-triangular)
     TZ - trapezoidal
     UN - (complex) unitary
     UP - (complex) unitary, packed storage

   SEE ALSO:
 */

extern lpk_model;
/* DOCUMENT lpk_model()
     Get the name of the library which implements BLAS and LAPACK.
   SEE ALSO lpk_laver
*/

extern lpk_laver;
/* DOCUMENT ver = lpk_laver()
     Get the version of LAPACK, the result is an array of 3 integers:
     [MAJOR,MINOR,PATCH].
   SEE ALSO lpk_model
*/

extern lpk_nrm2;
/* DOCUMENT lpk_nrm2(x);
         or lpk_nrm2(x, xrng);
     The function LPK_NRM2 computes the Euclidean norm of vector X.
     The result is:
         lpk_nrm2(x) --------------> sqrt(sum(abs(x)^2))
         lpk_nrm2(x, xrng) --------> sqrt(sum(abs(x(*)(xrng))^2))

  FIXME: check for complex
 */

extern lpk_scal;
/* DOCUMENT lpk_scal, alpha, x;
         or lpk_scal, alpha, x, xrng;
     The subroutine LPK_SCAL scales the elements of vector X by the scalar
     ALPHA.  If the range XRNG = START:STOP:STEP is indicated, only the
     elements corresponding to this range are scaled.  The range is
     interpreted using Yorick's rules as if X is a flat (1-D) vector.  The
     operation is done in-place and X must be a variable (not an expression).
     When called as a function, X is returned (the full X not the part indexed
     by XRNG).
 */

extern lpk_copy;
/* DOCUMENT lpk_copy, x,       y;
         or lpk_copy, x, xrng, y;
         or lpk_copy, x,       y, yrng;
         or lpk_copy, x, xrng, y, yrng;

     The subroutine LPK_COPY copies the elements of vector X into
     vector Y.  If the range XRNG = XSTART:XSTOP:XSTEP and/or YRNG =
     YSTART:YSTOP:YSTEP are indicated, only the elements corresponding to
     this/these range(s) are copied.  The ranges are interpreted using
     Yorick's rules as if X and Y are flat (1-D) vectors.  The operation is
     done in-place, and Y must be a variable (not an expression).

  SEE ALSO: lpk_swap.
*/

extern lpk_swap;
/* DOCUMENT lpk_swap, x,       y;
         or lpk_swap, x, xrng, y;
         or lpk_swap, x,       y, yrng;
         or lpk_swap, x, xrng, y, yrng;

     The subroutine LPK_SWAP exchanges the elements of vector X by those of
     vector Y.  If the range XRNG = XSTART:XSTOP:XSTEP and/or YRNG =
     YSTART:YSTOP:YSTEP are indicated, only the elements corresponding to
     this/these range(s) are exchanged.  The ranges are interpreted using
     Yorick's rules as if X and Y are flat (1-D) vectors.  The operation is
     done in-place, X and Y must be variables (not expressions).

  SEE ALSO: lpk_copy.
*/

extern lpk_dot;
/* DOCUMENT lpk_dot(x, xrng, y, yrng)

     This function computes the dot product of "vectors" X and Y.  XRNG and
     YRNG are optional ranges to specify which parts of X and Y to consider.
     If they are provided, XRNG and YRNG are interpreted as if X and Y are
     flat (mono-dimensional) arrays.  Hence the returned value is formally
     equivalent to:

         lpk_dot(x, y)  ---------------->  sum(conj(x(*))*y(*))
         lpk_dot(x, xrng, y, yrng)  ---->  sum(conj(x(*)(xrng))*y(*)(yrng))
         lpk_dot(x, y, yrng)  ---------->  sum(conj(x(*))*y(*)(yrng))
         lpk_dot(x, xrng, y)  ---------->  sum(conj(x(*)(xrng))*y(*))

     For instance, assuming X and Y are real vectors:

         lpk_dot(x, 11:30:2, y, 1:30:3)

     gives the same result as:

         sum(x(11:30:2)*y(1:30:3))


  SEE ALSO: lpk_axpy.
 */

extern lpk_axpy;
/* DOCUMENT lpk_axpy(alpha, x, xrng, y, yrng)
         or lpk_axpy, alpha, x, xrng, y, yrng;

     This function computes: Y += ALPHA*X where X and Y are "vectors" and
     ALPHA is a scalar.

     FIXME: The operation is done in-place: the result is stored into variable
     Y.  When called as a function, Y is returned.

     See lpk_dot for the meaning of optional arguments, XRNG and YRNG.

  SEE ALSO: lpk_dot.
*/

extern lpk_gemv;
/* DOCUMENT lpk_gemv, trans, alpha, a, x,       beta, y;
         or lpk_gemv, trans, alpha, a, x, xrng, beta, y;
         or lpk_gemv, trans, alpha, a, x,       beta, y, yrng;
         or lpk_gemv, trans, alpha, a, x, xrng, beta, y, yrng;

     The function LPK_GEMV performs the following vector-matrix operation:

         y := alpha*op(A)*x + beta*y

     with:

         op(A) = A,        if TRANS = LPK_NO_TRANS,
         op(A) = A^T,      if TRANS = LPK_TRANS,
         op(A) = A^H,      if TRANS = LPK_CONJ_TRANS,

     where ALPHA and BETA are scalars, X and Y are "vectors" of dimension
     lists XDIMS and YDIMS respectively and A is a "matrix" of dimensions
     YDIMS-by-XDIMS, if TRANS = LPK_NO_TRANS, or XDIMS-by-YDIMS if TRANS =
     LPK_TRANS or LPK_CONJ_TRANS.

     XRNG and YRNG are optional ranges to specify which elements of X and Y to
     consider.  If they are specified, then X and Y are considered as flat
     arrays and XDIMS is the dimension list of X(*)(XRNG) and likewise for
     YDIMS.

     The operation is done in-place, argument Y must be a variable reference.


   SEE ALSO: lpk_gemm.
*/

extern lpk_gemm;
/* DOCUMENT lpk_gemm, transa, transb, alpha, a, b, beta, c;
         or res = lpk_gemm(transa, transb, alpha, a, b, beta, c);

     The function LPK_GEMM performs one of the matrix-matrix operations:

         C := alpha*op(A)*op(B) + beta*C

     where:

         op(A) = A   if TRANSA = LPK_NO_TRANS
                 A^T if TRANSA = LPK_TRANS
                 A^H if TRANSA = LPK_CONJ_TRANS

     and similarly for op(B) according to TRANSB.

     Arguments must be such that op(A) is M-by-K, op(B) is K-by-N
     and C is M-by-N where M, N and K are arbitrary dimension lists.

     Using a loosy notation len() for the number of dimensions of its
     arguments, then:

       len(A) = len(M) + len(K)
       len(B) = len(K) + len(N)
       len(C) = len(M) + len(N)

     hence there is no ambiguity as:

       len(K) = (len(A) + len(B) - len(C))/2
       len(M) = len(A) - len(K)
       len(N) = len(B) - len(K)

   SEE ALSO: lpk_gemv.
*/

extern lpk_syrk;
/* DOCUMENT lpk_syrk, uplo, trans, alpha, a, beta, c;
         or res = lpk_syrk(uplo, trans, alpha, a, beta, c);

     LPK_SYRK performs one of the symmetric rank K operations

         C := alpha*A.A^T + beta*C,    if trans = LPK_NO_TRANS
         C := alpha*A^T.A + beta*C,    if trans = LPK_TRANS or LPK_CONJ_TRANS

     where alpha and beta are scalars, C is an N-by-N symmetric matrix and A
     is an N-by-K matrix in the first case and a K-by-N matrix in the second
     case.  As far as they correctly match with the dimension lists of
     arguments A and C, N and K can be several consecutive dimensions.

     When called as a subroutine, the operation is done "in-place" and the
     result is saved in variable C (in this case, argument C must be a
     variable, not an expression).  When called as a function the result of
     the operation is returned by LPK_SYRK and, if argument C is a variable,
     its contents is left unchanged.

     For instance:

         c = array(double, 2,3, 2,3);
         a = random(2,3, 4,5,6);
         lpk_syrk, LPK_UPPER, LPK_NO_TRANS, 1.0, a, 0.0, c;

     will work by assuming that N is 2-by-3 and K is 4-by-5-by-6 and produce
     the same result as:

         c = a(,,*)(,,+) * a(,,*)(,,+);

     except that only the upper triangular part of C will be computed by
     LPK_SYRK.


  SEE ALSO:
 */

extern lpk_potrf;
/* DOCUMENT lpk_potrf, uplo, a;
         or res = lpk_potrf(uplo, a);

     The function LPK_POTRF computes the Cholesky factorization of a real
     symmetric positive definite matrix A.  The factorization has the form

         A = U^T.U,  if UPLO = LPK_UPPER, or
         A = L.L^T,  if UPLO = LPK_LOWER,

     where U is an upper triangular matrix and L is lower triangular.

     The argument A must be a positive definite N-by-N matrix where N
     represents one or several consecutive dimensions.  If UPLO = LPK_UPPER,
     the leading N-by-N upper triangular part of A contains the upper
     triangular part of the matrix A, and the strictly lower triangular part
     of A is not referenced.  If UPLO = LPK_LOWER, the leading N-by-N lower
     triangular part of A contains the lower triangular part of the matrix A,
     and the strictly upper triangular part of A is not referenced.

     When called as a subroutine, the operation is done "in-place" and the
     result is saved in variable A (in this case, argument A must be a
     variable, not an expression).  When called as a function the result of the
     operation is returned by LPK_POTRF and, if argument A is
     a variable, its contents is left unchanged.

  SEE ALSO: lpk_potri, lpk_potrs, lpk_posv.
*/
//extern lpk_potf2;
/*  LPK_POTF2 computes the Cholesky factorization of a real symmetric
 *  positive definite matrix A.
 *
 *  The factorization has the form
 *     A = U**T * U ,  if UPLO = 'U', or
 *     A = L  * L**T,  if UPLO = 'L',
 *  where U is an upper triangular matrix and L is lower triangular.
 *
 *  This is the unblocked version of the algorithm, calling Level 2 BLAS.
 */

extern lpk_potrs;
/* DOCUMENT x = lpk_potrs(uplo, a, b);

     The function LPK_POTRS solves a system of linear equations A.X = B
     with a real symmetric positive definite matrix A using the Cholesky
     factorization computed by LPK_POTRF, that is one of:

        A = U^T.U,  if UPLO = LPK_UPPER, or
        A = L.L^T,  if UPLO = LPK_LOWER.

     The left-hand side matrix A is a N-by-N array, and the left-hand side
     vector B is a N-by-NRHS real array (here N and NRHS stand for any number
     of consecutive dimensions; see the documentation of LPK_GESV for more
     explanations of this feature). The result X has the same dimension list
     as B.


  SEE ALSO: lpk_potrf, lpk_potri, lpk_posv, lpk_gesv.
 */

extern lpk_potri;
/* DOCUMENT lpk_potri, uplo, a;
         or res = lpk_potri(uplo, a);

     The function LPK_POTRI the inverse of a real symmetric positive definite
     matrix A using the Cholesky factorization computed by LPK_POTRF, that is
     one of:

         A = U^T.U,  if UPLO = LPK_UPPER, or
         A = L.L^T,  if UPLO = LPK_LOWER.

     When called as a subroutine, the operation is done "in-place" and the
     result is saved in variable A (in this case, argument A must be a
     variable, not an expression).  When called as a function the result of
     the operation is returned by LPK_POTRI and, if argument A is a variable,
     its contents is left unchanged.

     Only the upper (if UPLO = LPK_UPPER), or only the lower (if UPLO =
     LPK_LOWER) part of A and RES are used/computed.

  SEE ALSO: lpk_potrf, lpk_potrs, lpk_posv.
*/

//extern lpk_pocon;
/*  LPK_POCON estimates the reciprocal of the condition number (in the 1-norm)
 *  of a real symmetric positive definite matrix using the Cholesky
 *  factorization A = U**T*U or A = L*L**T computed by LPK_POTRF.
 *
 *  An estimate is obtained for norm(inv(A)), and the reciprocal of the
 *  condition number is computed as RCOND = 1 / (ANORM * norm(inv(A))).
 */

//extern lpk_porfs;
/* LPK_PORFS improves the computed solution to a system of linear
 *  equations when the coefficient matrix is symmetric positive definite,
 *  and provides error bounds and backward error estimates for the
 *  solution.
 */

/*---------------------------------------------------------------------------*/
/* DRIVER (HIGH LEVEL) ROUTINES */

extern lpk_gesv;
/* DOCUMENT x = lpk_gesv(a, b);

    Like LUsolve (which see), function LPK_GESV computes the solution to a
    system of linear equations:

        A.X = B,

    where A is an N-by-N matrix and X and B are N-by-any matrices using LU
    factorization (Gauss pivoting).  In this notation, N represents one or
    more consecutive dimensions (see below) and the result X has the same
    dimension list as B.

    Like LUsolve, LPK_GESV can be used to solve several similar problems at
    the same time; however, a notable difference with LUsolve is that N stands
    for one or more consecutive dimensions.  The constraint is that the first
    half of the dimensions (noted N) of A must be the same as the second half
    of its dimensions and identical to the leading dimensions of B.  Without
    adding ambiguities, this generalizes the notion of a square matrix.

    An example of using the multi-dimensional matrix feature is given below:

        a = random(3,4,5,3,4,5)  - 0.5;
        x = random(3,4,5,6,7) - 0.5;
        b = (a(,,,*))(..,+)*(x(*,,))(+,..);
        xp = lpk_gesv(a, b);

    where, unless A is singular, XP should have the same values as X up to
    rounding errors.  In standard linear algebra notation, A is a 60 rows by
    60 columns square matrix (60 = 3*4*5).

    Another advantage of LPK_GESV over LUsolve is that it may be much faster
    if the BLAS and LAPACK are optimized for your achitecture.

    If you do not care of overwriting A and/or B, you can unref them, for
    instance:

        x = lpk_gesv(unref(a), b);

    will use A (if it has the suitable type) as a workspace for the
    decomposition and thus avoid making a temporary copy.


   SEE ALSO: LUsolve, unref.
 */

extern lpk_posv;
/* DOCUMENT x = lpk_posv(uplo, a, b);

     LPK_POSV uses Cholesky decomposition to solve a system of linear
     equations

         A.X = B,

     where A is an N-by-N symmetric or Hermitian (for a linear system with
     complex coefficients) positive definite matrix and X and B are N-by-NRHS
     matrices.  Note that N and NRHS stand for any number of consecutive
     dimensions (see LPK_GESV for more explanations of this feature).

     The Cholesky decomposition is used to factor A as (using U^H to denote
     the conjugate transpose of matrix U):

       A = U^H.U,  if UPLO = LPK_UPPER, or
       A = L.L^H,  if UPLO = LPK_LOWER,

     where U is an upper triangular matrix and L is a lower triangular matrix.
     The factored form of A is then used to solve the system of equations.

     If UPLO = LPK_UPPER, only the upper triangular part of A is used; while
     if UPLO = LOWER, only the lower triangular part of A is used.  Like
     LPK_GESV, you may unref A and/or B if they are no longer needed and to
     avoid making unnecessary copies.

     If A is symmetric (or Hermitian) but not positive definite, use LPK_SYSV
     or LPK_HESV to solve the system.


   SEE ALSO: LUsolve, unref, lpk_gesv, lpk_sysv, lpk_potrf.
 */

extern lpk_sysv;
extern lpk_hesv;
/* DOCUMENT x = lpk_sysv(uplo, a, b);
         or x = lpk_hesv(uplo, a, b);

     LPK_SYSV and LPK_HESV uses Bunch-Kaufman factorization to solve a real or
     complex system of linear equations

         A.X = B,

     where A is an N-by-N symmetric (for LPK_SYSV) or Hermitian (for LPK_HESV)
     matrix and X and B are N-by-NRHS matrices.  Note that N and NRHS stand
     for any number of consecutive dimensions (see LPK_GESV for more
     explanations of this feature).

     The Bunch-Kaufman diagonal pivoting method is used to factor A, in
     LPK_SYSV the factorization writes (using U^T to denote the transpose of
     matrix U):

         A = U.D.U^T,  if UPLO = LPK_UPPER, or
         A = L.D.L^T,  if UPLO = LPK_LOWER,

     while in LPK_HESV the factorization writes (using U^H to denote the
     conjugate transpose of matrix U):

         A = U.D.U^H,  if UPLO = LPK_UPPER, or
         A = L.D.L^H,  if UPLO = LPK_LOWER,

     where U (or L) is a product of permutation and unit upper (lower)
     triangular matrices, and D is symmetric (for LPK_SYSV) or Hermitian (for
     LPK_HESV) and block diagonal with 1-by-1 and 2-by-2 diagonal blocks.  The
     factored form of A is then used to solve the system of equations A.X = B.

     If UPLO = LPK_UPPER, only the upper triangular part of A is used; while
     if UPLO = LOWER, only the lower triangular part of A is used.  Like
     LPK_GESV, you may unref A and/or B if they are no longer needed and to
     avoid making unnecessary copies.


   SEE ALSO: LUsolve, unref, lpk_gesv, lpk_posv.
 */

extern lpk_eigen;
/* DOCUMENT w = lpk_eigen(a);
         or w = lpk_eigen(a, z);

     LPK_EIGEN computes the eigenvalues W of the N-by-N symmetric (or
     Hermitian) matrix A, optionally computing the eigenvectors.  The
     eigenvectors are stored in variable Z if it is specified; otherwise,
     they are not computed.  If they are required, the eigenvectors are
     stored in the columns of Z.

     The spectral factorization of A writes:

        A = Z . diag(W) . transpose(Z)

     in Yorick notation:

        A = (Z*W(-,))(,+)*Z(,+) = Z(,+)*(W(-,)*Z)(,+)

     Keyword LOWER can be set true to indicate that the lower triangular part
     of the matrix A has been initialized (the upper part is not used).  The
     default is to assume that the upper triangular part has been initialized
     and not use the lower part.

     Keyword SLOW can be set true to not use the faster divide-and-conquer
     algorithm to compute the eigenvectors.

     LPK_EIGEN uses LAPACK routines (S/D)SYEV, (S/D)SYEVD, ZHEEV and ZHEEVD.


   SEE ALSO: SVdec, lpk_gesvd, lpk_ggsvd.
 */

extern lpk_gesvd;
extern lpk_gesdd;
/* DOCUMENT t = lpk_gesvd(a,s,u,vt);
         or     lpk_gesvd,a,s,u,vt;
         or t = lpk_gesdd(a,s,u,vt);
         or     lpk_gesdd,a,s,u,vt;

     LPK_GESVD and LPK_GESDD compute the singular value decomposition (SVD) of
     a M-by-N matrix A, optionally computing the left and/or right singular
     vectors. The SVD is written:

       A = U . SIGMA . conj(transpose(V))

     where SIGMA is an M-by-N matrix which is zero except for its min(M,N)
     diagonal elements, U is an M-by-M orthogonal matrix, and V is an N-by-N
     orthogonal matrix.  The diagonal elements of SIGMA are the singular
     values of A; they are real and non-negative, and are returned in
     descending order.  The first min(M,N) columns of U and V are the left and
     right singular vectors of A.

     Arguments S, U and VT are (optional) output variables to store the
     results: the singular values (the diagonal of SIGMA) are stored in S, the
     left singular vectors are stored in the columns of U, and the right
     singular vectors are stored in the rows of VT.  Note that these routines
     return transpose(V) -- or conj(transpose(V)) for a complex matrix A --
     not V.

     LPK_GESDD uses a divide-and-conquer algorithm to compute the singular
     vectors (if they are required) and is much faster than LPK_GESVD for
     large matrices, but uses more workspace.  If none of U and VT are
     specified, the singular vectors are not computed by LPK_GESDD.

     LPK_GESVD is slower than LPK_GESDD for large matrices but uses less
     workspace and is able to compute only the left or only the right singular
     vectors (depending whether U and VT are specified as variables or not).

     Keyword FULL can be set true to compute all singular vectors.  Otherwise,
     only the first min(M,N) singular vectors are computed.

     When called as a subroutine, an error is raised in case of failure;
     otherwise, when called as function, an integer status T is returned:

       T = 0: successful exit.
       T < 0: the (-T)-th argument had an illegal value.
       T > 0: algorithm did not converge.

   SEE ALSO: SVdec, lpk_eigen, lpk_ggsvd.
 */

extern lpk_ggsvd;
/* DOCUMENT inf = lpk_ggsvd(m, n, p, k, l, a, b, alpha, beta, u, v, q, i);

     Arguments M, N and P give the dimension of the problem.  M and P are the
     number of elements for the leading dimension(s) of A and B respectively;
     N is the number of elements of the trailing dimension(s) of A and B.  In
     other words, arrays A and B are treated as M-by-N and P-by-N matrices.

     Arguments K and L are variables used to store the dimension of the
     sub-blocks described below.  K + L = effective numerical rank of
     (A',B')', where A' denotes the transpose (or conjugate transpose for a
     complex matrix) of A.

     On input, arguments A and B contain the M-by-N matrix A and P-by-N matrix
     B.  On output, if A and B are variable names, they will contain the
     triangular matrix R or parts of it.

     Arguments ALPHA and BETA are variables to store the generalized singular
     value pairs of A and B.

     If arguments U, V, and Q are given, they must be variables to store the
     unitary matrices U, V, or Q respectively.  These arguments can be nil to
     not compute these matrices (or only some of them).

     Arguments K and L are variables used to store the dimension of the
     sub-blocks described below.  K + L = effective numerical rank of
     (A',B')', where A' denotes the transpose (or conjugate transpose for a
     complex matrix) of A.

     Argument I is a variable to store the sorting information.  More
     precisely, the following loop will sort ALPHA:

         for (j = k+1; j <= min(m,k+l); ++j) {
           temp = alpha(j);
           alpha(j) = alpha(i(j));
           alpha(i(j)) = temp;
         }

     or:
         j = k+1 : min(m,k+l);
         temp = alpha(j);
         alpha(j) = alpha(i(j));
         alpha(i(j)) = temp;

   SEE ALSO: SVdec, lpk_gesvd.
 */

/*---------------------------------------------------------------------------*/
/* FIT-DICT */

extern lpk_fit_dict;
/* DOCUMENT: unbias_coef = lpk_fit_dict(data, dict, coef, row, col, threshold);

   This routine fits the DATA samples (as a ATOM_SIZE-by-DATA_SIZE array) on
   a dictionary DICT (as an ATOM_SIZE-by-DICT_SIZE array) given a
   list COEF of significant coefficients (as a DICT_SIZE-by-DATA_SIZE sparse
   matrix).

   COEF = the SPARSE_SIZE values of the sparse matrix coefficients
   ROW  = the SPARSE_SIZE row indexes --> atom index
   COL  = the SPARSE_SIZE column indexes of the coefficients --> data index

    COEFS(l) = A(ROWS(l),COLS(l))

   ATOM_SIZE = number of values in an atom (a patch)
   DICT_SIZE = number of atoms in the dictionary
   DATA_SIZE = number of atoms to fit
   SPARSE_SIZE = number of sparse coefficients

   The result is a list of unbiased coefficients.


 */

/*---------------------------------------------------------------------------*/
/* INITIALIZATION */

extern lpk_init;
/* DOCUMENT lpk_init;
     This subroutine initializes internals of Yorick interface to LAPACK
     and verify assumptions made in the code.
 */
lpk_init;
