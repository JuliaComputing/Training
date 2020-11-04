# # Index iterators

A = rand(3,5)

#-

eachindex(A)

#-

keys(A)

#-

Av = view(A, [1,3], [1,2,5])

#-

A[[1,3],[1,2,5]]

#-

eachindex(Av)

# ### Example: $3\times 3\times \dots \times3$ boxcar filter (from a blog post by Tim Holy)

function boxcar3(A::AbstractArray)
    out = similar(A)
    R = CartesianIndices(size(A))
    I1, Iend = first(R), last(R)
    for I in R
        n, s = 0, zero(eltype(out))
        for J in CartesianIndices(map(:, max(I1, I-I1).I, min(Iend, I+I1).I))
            s += A[J]
            n += 1
        end
        out[I] = s/n
    end
    out
end

#-

using Images

#-

A = rand(256,256);

#-

Gray.(A)

#-

Gray.(boxcar3(A))

#-

function sumalongdims!(B, A)
    # It's assumed that B has size 1 along any dimension that we're summing
    fill!(B, 0)
    Bmax = CartesianIndex(size(B))
    for I in CartesianIndices(size(A))
        B[min(Bmax,I)] += A[I]
    end
    B
end

#-

B = zeros(1, 256)

#-

sumalongdims!(B, A)

#-

reduce(+,A,dims=(1,))

# `CartesianIndices` and other "N-d" iterators have a shape that propagates through generators.

[1 for i in CartesianIndices((2,3))]

#-

B = rand(5,5)

#-

view(B,CartesianIndices((2,3)))

# ## Exercise: CartesianIndex life!
#
# - Write a function `neighborhood(A::Array, I::CartesianIndex)` that returns a view of the 3x3 neighborhood around a location
# - Write a function `liferule(A, I)` that implements the evolution rule of Conway's life cellular automaton:
#   - 2 live neighbors $\rightarrow$ stay the same
#   - 3 live neighbors $\rightarrow$ 1
#   - otherwise $\rightarrow$ 0
# - Write a function `life(A)` that maps A to the next life step using these

#-

# Some famous initial conditions:

A = fill(0, 128,128);

#-

A[61:63,61:63] = [1 1 0
                  0 1 1
                  0 1 0]

#-

A = life(A)
## `repeat` can be used to get chunky pixels to make the output easier to see
Gray.(repeat(A,inner=(4,4)))

#-
