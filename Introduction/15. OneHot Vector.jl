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

Base.getindex(v::OneHotVector, i::Integer) = Int(i == v.idx)

end
#-

OneHotVector(3, 10)

#-

A = rand(5,5)

#-

A * OneHotVector(3, 5)

#-

Vector(OneHotVector(3,5))

# ## Exercise
#
# Generalize it to any element type.



