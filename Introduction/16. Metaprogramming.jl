# # Macros and metaprogramming

# Metaprogramming is writing programs that manipulate programs.
# To facilitate this, Julia has data types specialized for representing code.

# Identifiers are represented as Symbols

:a  # "the symbol a"

typeof(:a)

# Call `eval` to execute a code object

eval(:a)

a = 3

eval(:a)

# Symbols can be combined into expressions (type `Expr`)
# Note the prefix colon is a "quoting" operator

ex = :(a + b)

typeof(ex)

b = 7

eval(ex)

dump(ex)

dump(:(x = 3))

# More complicated expressions are represented as "abstract syntax trees" (ASTs),
# consisting of expressions nested inside expressions:

ex = :( sin(3a + 2b^2) )

dump(ex)

# `quote ... end` can be used to quote longer blocks of code

blk = quote
    println("Hello")
end

eval(blk)

push!(blk.args, :(println("AFTER")))
pushfirst!(blk.args, :(println("BEFORE")))
eval(blk)

# ## Macros

# The name *macro* is given to a kind of "super-function" that takes a piece of code as an argument,
# and returns an altered piece of code. A macro is thus a very different kind of object than a
# standard function (although it can be thought of as a function in the mathematical sense of the word).

# @mac a b c ===>  code to execute

# Metaprogramming is useful in a variety of settings. The following are a few example use cases:
# - to eliminate boilerplate (repetitive) code
# - to automatically generate complex code that would be painful by hand
# - to unroll loops for efficiency
# - to inline code for efficiency

# Macros are invoked using the `@` sign, e.g.

@time sin(10)

# A trivial example of defining a macro is the following, which runs whatever code it is
# passed two times.
# The `$` sign is used to interpolate the value of the expression (similar to its usage for
# string interpolation):

macro twice(ex)
    quote
        $(esc(ex))
        $(esc(ex))
    end
end

x = 0
@twice println(x += 1)

ex = :(@twice println(x += 1))

eval(ex)

# We can see what effect the macro actually has using `Meta.@macroexpand`:

Meta.@macroexpand @twice println(x += 1)

Meta.@macroexpand @time sin(10)

macro mytime(ex)
    quote
        t0 = time()
        val = $ex
        t1 = time()
        println("$(t1-t0) seconds elapsed")
        val
    end
end

@mytime (sleep(1); "done")

Meta.@macroexpand @mytime (sleep(1); "done")

# # Macro Hygiene (and lack thereof)

t1 = "the first terminator movie"
@mytime t1 *= " is the best"

macro mytime(ex)
    quote
        t0 = time()
        val = $(esc(ex))
        t1 = time()
        println("$(t1-t0) seconds elapsed")
        val
    end
end

t1 = "the first terminator movie"
@mytime t1 *= " is the best"

Meta.@macroexpand @mytime t1 *= " is the best"

macro set_a(val)
    :($(esc(:a)) = $(esc(val)))
end

Meta.@macroexpand @set_a 1.5

@set_a 1.5

a

# **Exercise**: Define a macro `@until` that does an `until` loop.

macro until(#= your code =#)
    # your code
end

let i = 0
    @until i==10 begin
        println(i)
        i += 1
    end
end

# ## Macros for numerical performance: Horner's method

# There are many interesting examples of macros in `Base`. One that is accessible is Horner's method
# for evaluating a polynomial:
#
#     $$p(x) = a_n x^n + a_{n-1} x^{n-1} + \cdots + a_1 x^1 + a_0$$
#
# may be evaluated efficiently as
#
#     $$p(x) = a_0 + x(a_1 + \cdots x(a_{n-2} + \cdots + x(a_{n-1} + x a_n) \cdots ) ) $$
#
# with only $n$ multiplications.
#
# The obvious way to do this is with a `for` loop. But if we know the polynomial *at compile time*,
# this loop may be unrolled using metaprogramming. This is implemented in the `Math` module in
# `math.jl` in `Base`, so the name of the macro which is not exported is `@Base.Math.horner`, so in
# the current namespace, `horner` should be undefined:

# copied from base/math.jl
macro horner(x, p...)
    ex = esc(p[end])
    for i = length(p)-1:-1:1
        ex = :( $(esc(p[i])) + t * $ex )
    end
    Expr(:block, :(t = $(esc(x))), ex)
end

# This is called as follows: to evaluate the polynomial $p(x) = 2 + 3x + 4x^2$ at $x=3$, we do

x = 3
@horner(x, 2, 3, 4, 5)

# To see what the macro does to this call, we again use `macroexpand`:

Meta.@macroexpand @horner(x, 2, 3, 4, 5, 6, 7, 8, 9, 10)

f(x) = @horner(x, 1.2, 2.3, 3.4, 4.5)

@code_native f(0.1)

f_base(x) = Base.Math.@horner(x, 1.2, 2.3, 3.4, 4.5)

@code_native f_base(0.1)

@edit Base.Math.@horner(x, 1.2)

# From looking at the Base code we learn two things:
# - Base.Math uses the combined `muladd` for performance
# - The Julia compiler improved such that this no longer strictly needs to be a macro
