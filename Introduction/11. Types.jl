# # Types
#
# Topics:
# 1. How types work in Julia
# 2. Defining types
# 3. Type parameters
# 4. Example: `OneHotVector`
# 5. Tuple types
# 6. Summary of kinds of types
# 7. The types of functions

#-

# ## How types work in Julia
#
# Every Julia value has a unique concrete type associated with it:

typeof(3)
typeof('a')

# Types are also first-class values:

typeof(Int)
typeof(DataType)

# The type of a value describes its memory layout as well as describing,
# semantically, "what kind of thing it is".

#-

# There are also *abstract types* that serve to group other types together.

supertype(Int)
supertype(Signed)
supertype(Integer)
supertype(Real)
supertype(Number)

# `isa` queries whether a value belongs to a type.
# `<:` queries whethe one type is a subtype (subset) of another

2 isa Int
2 isa Real
2 isa String
Int <: Integer

isa(2, Int)

# `::` asserts that a value has a certain type, or else throws an error

2::Int
2::String

convert(Int, 2.0)

#-

# ## Defining types

struct Point
    x::Float64
    y::Float64
end

p=Point(1,2)

#-

# Types can be "called" and have methods added like functions.
# When used that way they are sometimes called *constructors*.

Point() = Point(0,0)

Point()

Int(2.0)

Int(2.1)

trunc(Int, 2.1)

x = Point(1,2)

# ### Abstract types

abstract type PointLike
# must have field x
end

struct Point2 <: PointLike
    z::Float64
    y::Float64
end

x_coord(p::PointLike) = p.x

# ### Mutability
#
# Instances of `Point` cannot be modified after construction:

p = Point(1,2)
p.x = 0

# Use `mutable struct` to declare a mutable type:

mutable struct MutablePoint
    x  # note: default field type is `Any`
    y
end

x = MutablePoint(1,1)
x.y = 0
x

fieldnames(Point)

# ### Primitive types
#
# Primitive types are "scalar"-like types whose representation is just a string
# of bits. They have no fields.
# These are not defined often in user code, but are needed in some cases.

primitive type MyInt32 <: Signed 32 end

# ## Type parameters
#
# Some types actually define a family of related types.
# The following is a concrete type, but the *parameters* in curly
# braces indicate that it is one of many possible related types:

Array{Float64,2}

# What is `Array` by itself?

typeof(Array)
dump(Array)

# `Array` is an *iterated union* of dense, in-memory arrays over all
# element types and numbers of dimensions.

Array == (Array{T,N} where N where T){Int}

# The curly braces substitute values for these variables:

Array{Int} == Array{Int,N} where N

Array{Int} <: Array

(Array{T,3} where T) <: Array

Array{<:Number,3}

[1,2] isa Array{Int}

[1,2] isa Array{T,1} where T

[1,2] isa Array{T,2} where T

# `Vector` is an alias for 1-d Arrays:

Vector == Array{T,1} where T

#-

# Types with different parameters are just different, and have no subtype
# relationship. This is called *invariance*.

Array{Int} <: Array{<:Real}

# This is surprising at first, but makes sense if you think about memory
# representations.
# `Array{Real}` can hold any kind of real number so it needs to be an array of
# pointers (or some other structure containing type information for each
# element).
# `Array{Int}` only has `Int`s, so it can use an efficient "flat"
# representation.

# ### Defining types with parameters

struct GenericPoint{T<:Real, S, U, V}
    x::T
    y::T
end
methods(Point)
methods(GenericPoint)

GenericPoint(x, y) = GenericPoint(promote(x,y)...)

GenericPoint(1,2)

@which GenericPoint(1,2.0)

GenericPoint(1.0,2.0)

GenericPoint{Float64}(1,2)

methods(GenericPoint{Float64})

# Constructors can be defined for these too, using syntax that looks like
# how they are called:

function GenericPoint{T}() where T
    return GenericPoint{T}(0,0)
end

GenericPoint{Int}()

GenericPoint()

GenericPoint() = GenericPoint{Float64}()

GenericPoint()

x = GenericPoint

x()

GenericPoint() = 2
GenericPoint()

# ## Example: `OneHotVector`
#
# Often used in machine learning, a "one hot" vector is a vector of all zeros,
# except for a single `1` entry.
# Representing it as a standard vector is memory-inefficient, so it cries out
# for a special implementation.

AbstractVector = AbstractArray{T,1} where T

struct OneHotVector{T<:Number} <: AbstractVector{T}
    idx::Int
    len::Int
end

v = OneHotVector(2, 5)

Base.size(v::OneHotVector) = (v.len,)

function Base.getindex(v::OneHotVector{T}, i::Integer) where {T}
    T(i == v.idx)
end

OneHotVector{Complex{Int}}(3, 10)

A = rand(5,5)

A * OneHotVector(3, 5)

# ### Exercise: make it generic over element type

# ## Tuple types
#
# Tuples are very much like structs, but their types a bit special.
# 1. They have fields, but no names, only indices.
# 2. They are always immutable.
# 3. They can have an arbitrary number of parameters/fields.
# 4. They are *covariant*.

t = ("a", "b")
typeof(t)
typeof((1,2,"",4,5))
# Field access is syntax for calls to `getfield` and `setfield!`

getfield(t, 2)

# For tuples `getindex` == `getfield`:

t[1]

getfield(p, :x)
getfield(p, 2)

Tuple{String} <: Tuple{Any}

# Remember: not true for `Vector{String} <: Vector{Any}`!

# ## Summary of kinds of types
#
# 1. Concrete types: struct, mutable struct, tuple, primitive
# 2. abstract types
# 3. UnionAll types, `Array{T} where T`
# 4. Union types, `Union{Int, Missing}`
# 5. The empty, or "bottom" type `Union{}`

[1,2,missing,3]

Union{}[]

# ## The types of functions
#
# How do functions fit into this scheme?
# Somewhat non-obviously, they are structs!
# In Julia, every "function" has its own struct type.

#-

f(x) = 2x
typeof(f)
f isa typeof(f)
supertype(typeof(f))
# Is equivalent to

struct typeof_g
end

(::typeof_g)(x) = 2x

const g = typeof_g()

g(3)
supertype(typeof(g))

(x::MyType)(y) = 10x + y

n = 3

n(10)

#-

# A simple, top-level function is a struct with 0 fields.

typeof(+)
typeof(cos)

# *Closures*, or inner functions, that capture surrounding
# variables, keep those variables as fields.

adder(x) = y->x+y

a = adder(100)

a(3)

typeof(a)
dump(a)

a.x
