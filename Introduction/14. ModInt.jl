struct ModInt{n} <: Integer
    k::Int

    ModInt{n}(k::Integer) where {n} = new{n}(mod(k, n))
end

import Base: +, -, *, /

+(a::ModInt{n}, b::ModInt{n}) where {n} = ModInt{n}(a.k + b.k)
-(a::ModInt{n}, b::ModInt{n}) where {n} = ModInt{n}(a.k - b.k)
*(a::ModInt{n}, b::ModInt{n}) where {n} = ModInt{n}(a.k * b.k)
-(a::ModInt{n}) where {n} = ModInt{n}(-a.k)

Base.inv(a::ModInt{n}) where {n} = ModInt{n}(invmod(a.k, n))
/(a::ModInt{n}, b::ModInt{n}) where {n} = a * inv(b)

function Base.show(io::IO, a::ModInt{n}) where {n}
    if get(io, :compact, false)
        print(io, a.k)
    else
        print(io, "$(a.k) mod $n")
    end
end

# Base.promote_rule(M::Type{<:ModInt}, ::Type{<:Integer}) = M
# Base.promote_rule(::Type{M}, ::Type{T}) where {M<:ModInt, T<:Integer} = M
Base.promote_rule(::Type{M}, ::Type{T}) where {M<:ModInt, ModInt<:T<:Integer} = M
