# Often used in machine learning, a "one hot" vector is a vector of all zeros, except for a single `1` entry.
# Representing it as a standard vector is memory-inefficient, so it cries out for a special implementation.
module OneHotVectors
struct OneHotVector <: AbstractVector{Int}
    idx::Int # <- Which index is "hot" -- 1
    len::Int # <- The total length (all other values 0)
end

#-

Base.size(v::OneHotVector) = (v.len,)

#-

function Base.getindex(v::OneHotVector, i::Integer)
    return Int(i == v.idx)
end

# A more efficient implementation of matrix multiply is possible for this type
#function Base.:*(M::AbstractMatrix, v::OneHotVector)
#end

end # module

# Notice it already prints like a normal array

OneHotVector(3, 10)

# Matrix multiply works as if by magic

A = rand(5,5)

A * OneHotVector(3, 5)

# Let's see if we can speed up matrix-vector multiply

A = rand(2000, 2000)

@time A * OneHotVector{Float32}(3, 2000);

v = Vector(OneHotVector{Float32}(3, 2000))

@time A * v;

# ## Exercise
#
# Generalize it to any element type.
