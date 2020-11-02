# # C interoperability

# Calling C is built in to Julia's compiler --- the C ABI is the lingua
# franca among all programming languages!

# To call libc, or anything else in the current process' global namespace,
# you just need the name of the function:
ccall(:puts, Cint, (Cstring,), "Hello")

# We have a family of types beginning with `C`: Cint, Cchar, Cdouble, Cvoid, ...
# Cvoid is `Nothing`

@time ccall(:sleep, Cuint, (Cuint,), 3)

# To call functions in other libraries:

run(`gcc -shared -fPIC -o libhello.so hello.c`)

ccall((:hello, "./libhello.so"), Cvoid, (Cstring,), "NASA")

ccall((:sqr, "./libhello.so"), Cdouble, (Cdouble,), sqrt(2))

# ## Callbacks from C to Julia

# Naturally, we will call qsort, the only higher-order function in C :)

T = Float64

# C-friendly callback function
function callback(p_a::Ptr{T}, p_b::Ptr{T})::Cint
    a = unsafe_load(p_a)
    b = unsafe_load(p_b)
    a < b ? -1 : b < a ? 1 : 0
end

p = [1.2, 3.4]

p_a = pointer(p, 1)
p_b = pointer(p, 2)
callback(p_b, p_a)

# get C-callable function pointer
p_callback = @cfunction(callback, Cint, (Ptr{T}, Ptr{T}))

A = randn(10)

# call C's qsort function
ccall(:qsort, Cvoid,
      (Ptr{T}, Csize_t, Csize_t, Ptr{Cvoid}),
      A, length(A), sizeof(T), p_callback)

A

# Here's how we could make a proper wrapper for this:

function qsort!((<)::Function, A::Vector{T}) where T

    # C-friendly callback function
    function callback(p_a::Ptr{T}, p_b::Ptr{T})::Cint
        a = unsafe_load(p_a)
        b = unsafe_load(p_b)
        a < b ? -1 : b < a ? 1 : 0
    end

    # get C-callable function pointer
    p_callback = @cfunction($callback, Cint, (Ptr{T}, Ptr{T}))

    # call C's qsort function
    ccall(:qsort, Cvoid,
          (Ptr{T}, Csize_t, Csize_t, Ptr{Cvoid}),
          A, length(A), sizeof(T), p_callback)

    return A
end

# default comparison by `isless` function
qsort!(A::Vector) = qsort!(isless, A)

A = randn(10)

qsort!((x,y)->abs(y) < abs(x), A)

A

# Works on other types too!
B = rand(-10:10, 20)
qsort!((x,y)->abs(y) < abs(x), B)

B

# Can C sort with units??

using Unitful

t = rand(10)*u"s"

qsort!(t)

# Of course it can!
t

# ## Embedding julia in C/Fortran
# https://docs.julialang.org/en/latest/manual/embedding/

# ## C++ interop
# https://github.com/JuliaInterop/Cxx.jl
