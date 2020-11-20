# Banded and block-banded matrices

# What is a banded matrix? A matrix `B` is banded with lower band `kl` and
# upper band `ku` when i > j + ku or j > i + ku => b[i,j] == 0.

# An example of a banded matrix
A1 = diagm(-1 => -ones(5), 0 => 2*ones(6), 1 => -ones(5))

# however, this one is stores all the zeros which is wasteful.

# The banded property holds true for many but not all of the sparse matrices
# discussed in last lecture so a banded matrix is sparse (unless the bands are very large)
# but many sparse matrices are not banded.
#
# Then why not just always use sparse matrices? They ignore much of the structure which
# can be exploited for efficiency both in terms of memory usage, algorithmic options, and
# efficient memory access.
#
# Like linear algebra routines for standard matrices, routines for banded matrices are
# available in LAPACK but these routines are not available as a standard library in Julia.
# Instead, they are made available in Sheehan Olver's BandedMatrices package
using BandedMatrices, LinearAlgebra

# We can construct the equivalent of `A` but stored as a BandedMatrix and compare the size
B1 = BandedMatrix(-1 => -ones(5), 0 => 2*ones(6), 1 => -ones(5))
Base.summarysize(A1)
Base.summarysize(B1)

# What is inside?
dump(B1)
B1.data

# Let us consider a larger case
n = 5000
B2 = BandedMatrix(-2 => randn(n-2), -1 => randn(n-1), 0 => randn(n), 1 => randn(n-1))
A2 = Matrix(B2)
C2 = sparse(B2)

Base.summarysize(A2)/1000^3 # in GB
Base.summarysize(B2)/1000^2 # in MB

b = A2*ones(size(A2, 1))

@time A2\b; # Dense
@time B2\b; # Banded
@time C2\b; # Sparse

# Because of the predictability of the non-zeros, the solution is computed much faster than the
# sparse solution

# Banded matrices naturally occur when discretizing partial differential equations. For a 1D problem
# the band size depends on the order of the derivative approximation used in the discretiztion.
#
# Problems in higher dimension also have a banded structure. Here is an example from the SuiteSparse
# collection of sparse matrix

# Temporal freq domain seismic modeling; J. Washbourne, Chevron
A_chevron = matrixdepot("Chevron/Chevron2")

# use abs in the spy plot since the values are complex
spy(abs.(A_chevron))

# Visual inspection of the matrix reveals that is built up of 201x201 matrices. Here is one
# of the off-diagonal blocks
spy(abs.(A_chevron[202:402,1:201]))

# The number of main diagonal blocks is
size(A_chevron, 1)/201

# There are one upper and one lower block diagonal and each of them has three diagonals so it
# is a 2D 9 point stencil calculation. The expected number of nonzeros is roughly
size(A_chevron, 1) |> n -> 3*n + 2*3*(n - 201)
# ...compare
nnz(A_chevron)
# ...so it looks about right

# An alternative representation of a problem like this is a block-banded matrix structure.
# In a block matrix, each element is itself a matrix. A block-banded matrix is a banded
# matrix where each element is a matrix. The block elements can generally have any structure.
# In our example, they will again be banded. The BandedBlockMatrices package (also written by
# Sheehan Olver) has support for this structure.
using BlockBandedMatrices

# The BlockBandedMatrix structure allows for arbitrary matrices as the elements whereas
# BlockBandedBlockMatrix is optimized for a case like the Chevron matrix

# Let us first build a small version to see how it looks like
BandedBlockBandedMatrix{Complex{Float64}}(I, [2, 2, 2], [2, 2, 2], (1, 1), (1, 1))

# Now, we build a BandedBlockBandedMatrix version of the Chevron matrix
# first we create the structure (notice that based on reading the doct, it looks like the constructor are under development)
BBB_chevron = BandedBlockBandedMatrix{Complex{Float64}}(I, fill(201, 449), fill(201, 449), (1, 1), (1, 1))

# ...and then we populate it
for j in 1:449
    for _i in -1:1
        i = j + _i
        if i ∉ 1:449
            continue
        end
        BBB_chevron[Block(i, j)] = A_chevron[(1:201) .+ 201*(i - 1), (1:201) .+ 201*(j - 1)]
    end
end

# let us print it
BBB_chevron

# check that it matches A_chevron
sparse(BBB_chevron) == A_chevron

# how large are they?
Base.summarysize(A_chevron)/1000^2 # MB
Base.summarysize(BBB_chevron)/1000^2 # MB

# How does it perform
b = ones(eltype(A_chevron), size(BBB_chevron, 1))
@time A_chevron\b;
@time BBB_chevron\b;

@time A_chevron*b;
@time BBB_chevron*b;

# Much work has gone into optimizing sparse matrix operations. While the BBB
# structure is more efficient, in theory, the implementations have received
# fewer man hours.
