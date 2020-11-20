# An introduction to sparse arrays in Julia
#
# Agenda
# 1 Basics
# 2 Examples
# 3 Gotchas!
# 4 Linear algebra
#  - Direct solvers
#  - Iterative solvers
#  - Eigen- and singular values

# Basics
# Sparse arrays allow for working with very very large matrices provded that
# they are sparse, i.e. contain mostly zeros. Internally, only the non-zeros
# and their indices are stored. This is in contrast to dense array strucutues
# where the indices are implicit.
#
# Pro: More memory efficient and lower algorithmic complexity
# Cons: More expensive index calculations and storage requirement for indices
#
# There exists several sparse array types. Julia's default sparse array type
# is using the compressed sparse column (CSC) format.

# Sparse arrays are shipped with Julia as a standard library
using SparseArrays

# Our first sparse array
A1 = sparse([1 0; 0 1])

# However, this way of constructing the array defeats the purpose since it first
# constructs dense array and then converts.

# Instead, use i, j, v constructor
A2 = sparse([1, 2], [1, 2], [1, 1])

# A SparseMatrixCSC is an AbstractMatrix
A2 isa AbstractMatrix

# so any method defined for AbstractMatrix works on a SparseMatrixCSC. E.g.
A2[1]
A2[1,2]
sum(A2)
size(A2)

# this can be dangerous, though. More on that later.

# What's inside?
dump(A2)

# Other constructors for sparse matrices
# Random pattern with Gaussian non-zeros
sprandn(10000, 10000, 0.001)

# Matrix with a few diagonals
spdiagm(-1 => fill(-1.0, 9), 0 => fill(2.0, 10), 1 => fill(1.0, 9))

# Block sparse matrices
blockdiag(sprandn(1000, 1000, 0.01), sprandn(1000, 1000, 0.01))

# Convenience functions when working with sparse matrices
# The reverse of the i,j constructor  is called findnz
findnz(A2)

# and can be very handy
# It's often useful to query the number of non-zeros to estimate the memory size
# of a sparse matrix and how expensize operations on it might be
nnz(A2)

# ...the faction of non-zeros can interest
nnz(A2)/length(A2)


############
# Examples #
############
# There are many different types of sparse matrices but many of them fall into
# two main groups: one where the matrix represents
# a discretization of differential equations and one where the matrix represents
# a data graph. The distribution of the non-zeros are very different in the two groups

# The best collection of sparse matrices can be found at
# https://sparse.tamu.edu/
# and a convenient way of fetching them is via the MatrixDepot package
using MatrixDepot

# Bug in current release of MatrixDepot. So we can't load cached matrices. Sorry!
let p = joinpath(dirname(pathof(MatrixDepot)), "..", "data", "uf")
    isdir(p) && rm(p, recursive=true)
end

# This is a matrix representing a graph
# Pajek network: connectivity of internet routers
A_internet = matrixdepot("Pajek/internet")

# How much storage does it require
Base.summarysize(A_internet)/1000^2 # in MB

# If stored as a dense matrix that would have required
prod(size(A_internet))*8/1000^3 # GB

# and spy plots are convenient for visualizing the sparsity pattern. We'll use
# the UnicodePlots package. The show method for sparse matrices in Julia 1.6
# will look like this.
using UnicodePlots
spy(A_internet)

A_pre2 = matrixdepot("ATandT/pre2")
spy(A_pre2)

# Completely different patterns
# Roy Tromble. finite-state machine for natural language processing
A_language = matrixdepot("Tromble/language")
spy(A_language)

###########
# Gotchas #
###########
# Densifying operations might consume all your memory
A0 = spzeros(10000, 10000)

A0 .* 1 # ok!
A0 .+ 1 # not ok!
GC.gc() # To free up the memory again

# ...we disallow one of the most common densifying operations
using LinearAlgebra
inv(A0 + I)

# Array wrappers can hide the sparse structure and cause dispatch to slow fallbacks
@time sum(A0)
@time sum(A0')

# Corners of floating point arithmetic behaves differently
[1 0; 0 0]*[NaN, NaN]
sparse([1 0; 0 0])*[NaN, NaN]

# ...but still
[1 0; 0 0]*NaN 

# It's possible to store zeros as a non-zero
AI = sparse(1.0I, 3, 3)
dump(AI)

AI[1, 1] = 0; AI

nnz(AI)
count(!iszero, AI)

# ... you can explicitly ask that they stored zeros are dropped
dropzeros!(AI)
nnz(AI)

##################
# Linear algebra #
##################
# One of the major applications of sparse matrices is solving large linear systems (\)-like
# Two approches: direct or iterative

# The direct solver: SuiteSparse which is included as a standard library
# These methods are used by default when calling \ on a sparse matrix

# example: a very sparse matrix (0.1% non-zeros)
Asparse = sprandn(4000, 4000, 0.001) + I;
Adense  = Matrix(Asparse);
b = Asparse*ones(size(Asparse, 1));

@time Asparse\b;
@time Adense\b;
Asparse\b ≈ Adense\b

# example: a less sparse matrix (1% non-zeros)
Asparse = sprandn(4000, 4000, 0.01) + I;
Adense  = Matrix(Asparse);
b = Asparse*ones(size(Asparse, 1))

@time Asparse\b;
@time Adense\b;
Asparse\b ≈ Adense\b

# ...so sparse solvers are not necessarily faster but allows for solving larger problems

# Factorizations
# cholesky for positive definite sparse matrices

Adense = [  1  1/3    0
          1/3    1  1/2
            0  1/2    1]
Asparse = sparse(Adense)

Fdense  = cholesky(Adense)
Fsparse = cholesky(Asparse)

# works like a dense factorization
b = [1; 2; 3]
Fdense\b ≈ Fsparse\b

# ...almost...
Fdense.L\b ≈ Fsparse.L\b

# ...the sparse factorization uses pivoting to reduce fill-in during the factorization
Fsparse.p

# so when working with the factor directly, the `PtL` version is often preferred
Fsparse.PtL\b ≈ Fsparse.L\b[Fsparse.p]

# ... so the factorization is actually P*A*P' = L*L'

# For cholesky (and ldlt) the pivoting (P) only depends on the non-zero pattern

# ldlt for symmetric sparse matrices in general
A = sparse(
    [ -1 1/2 1/4
     1/2   1 1/2
     1/4 1/2   1])

F = cholesky(A) # fails

# ...it's possible to use the cholesky to test for (numerical positive definiteness)
F = cholesky(A, check=false)
issuccess(F)

# ... for indefinite matrices, we can use ldlt
Fldlt = ldlt(A)

# ... but not it might still fail if it hits a zero pivot
A[1, 1] = 0
ldlt(A)

# lu for general sparse matrices
# the error message suggested that we try the LU
Flu = lu(A)

# ...what happened? The LU uses pivoting both during the symbolic and numerical factorizations
# The pivoting vectors are named `p` and `q`. In addition, the sparse LU also
# scales the rows of the input matrix. These values are stored in `Rs`
Flu.p
Flu.q
Flu.Rs
Flu.L*Flu.U ≈ (Flu.Rs .* A)[Flu.p, Flu.q]

# qr for sparse QR.
# The sparse QR is used useful for solving large least squares problems
A = sprandn(100000, 10, 0.001);
b = A*ones(size(A, 2)) + randn(size(A, 1));
F = qr(A);
F\b

# ...this is what A\b does automatically
A\b == F\b

# Iterative solvers. Large and complicated area. Several Julia packages available
# IterativeSolvers.jl
# Krylov.jl
# KrylovKit.jl
# KrylovMethods.jl
# ... and probably many more
using IterativeSolvers

# Plate-fin heat exchanger (medium case) (DAE) David.Averous@ensigct.fr

A_epb2 = matrixdepot("Averous/epb2")

b = ones(size(A_epb2, 1))

# direct
@time x_lu = lu(A_epb2)\b;

# iterative
@time x_iter = bicgstabl(A_epb2, b);

# Iterative solvers can handle much larger problems but often requires good preconditioners
# for reasonable performance. We won't go into details here.

# Eigen- and singular values
# Computing all eigen- or singular values of a sparse matrix is generall too expensive.
# However, in many applications it is sufficient to know something about the largest or
# smallest values. Again, many implementations are available. From the traditional Arpack
# to new Julia implementations in e.g. TSVD and KrylovKit
using TSVD, KrylovKit
Fsvd = tsvd(A_epb2, 5)
Fsvd[2]

Feig = eigsolve(A_epb2, 5)
Feig[1]

