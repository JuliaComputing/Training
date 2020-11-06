# # Basics: Arithmetic, Assignment, and Strings
#
# Topics:
# 1. Infix arithmetic operators
# 2. Numeric literals
# 3. Comparisons
# 4. Assignments
# 5. Strings

#-

# ## Arithmetic should largely be familiar

3 + 7 # addition

#-

10 - 3 # subtraction

#-

20 * 5 # multiplication

#-

100 / 10 # division
100 / 7

#-

10 ^ 2 # exponentiation

#-

101 % 3 # remainder (modulus)
mod(101, 3)
101 % -3
mod(101, -3)

#-

sqrt(2) # square root

#-

√2 # Unicode to the rescue: \sqrt + TAB
√42
√5

# Note that dividing two integers yields a floating point number. There are two additional operators that may be helpful here:

10 / 6

#-

10 ÷ 6 # \div TAB or the `div` function
div(10, 6)

#-

div(10, 6)

#-

10 // 6

# ### Numbers: Many different ways to write the number forty-two

fortytwos = (42, 42.0, 4.20e1, 4.20f1, 84//2, 0x2a)

#-

for x in fortytwos
    show(x)
    println("\tisa $(typeof(x))")
end

# ### Bitwise arithmetic

0x2a & 0x70 # AND

#-

0x2a | 0x70 # OR

#-

42 & 112

#-

0b0010 << 2 # == 0b1000

# ### Logical operators

false && true # AND

#-

false || true # OR

# Note that they "short-circuit!"

x = -42
x > 0 || error("x must be positive")
x < 0 && error("x is negative")

# ### Comparisons

1 == 1.0 == 1//1 # Equality
1 <= 2 < 3
2 < 1

#-

1 === 1.0 # Programmatically identical

#-

3 < π
π
#-

1 <= 1

#-

.1 + .2

#-

.1 + .2 ≈ .3 # \approx + TAB
isapprox(.1 + .2, .3)

# Comparisons "chain"
#
# Try inserting parentheses around one of these comparisons

2 == 2.0 == 0x02

#-

x = 42
0 < x < 100 || error("x must be between 0 and 100")

# ### Higher precision

2^63

big(2)^1000

big(pi)

big"0.1"

big(0.1)

# # Assignment
#
# Assignment in Julia is done with the single `=`. All it does
# is associates a name (on the left) to a value (on the right).

x = 1 # Use the name `x` for the value `1`
y = x

x = 2
y

x = [1]
x[1] = 2
#-

y = x # Use the name `y` for the value that `x` refers to

#-

x = "hello!" # Decide you have a better use for the name `x`

#-

y # Is still the value 1

#-

# "Simultaneous" multiple assignment

x, y = y, x  # swap x and y
x, y = y, x  # swap back


x, y = f()
#-

ϵ = eps(1.0) # You can make your own unicode names

x₀ = 1
χ² = 2
χ²
χ²

#-

5ϵ # Juxtaposition is multiplication

#-

# We make use of juxtaposition for complex numbers

2*im
(1 + 2im)^2

# ## Updating operators
#
# All the infix arithmetic operators above can be used as "updating" operators in conjunction with an assignment:

y = 0
y += 1
y = y + 1

# This is exactly the same!
# Note that it's just re-purposing the _same name_ for a new value. This means that the type might even change:

y += 1.5
y /= 2

# # Strings

s1 = "I am a string."

#-

s2 = """I am also" a string. """

#-

"""Here, we get an "error" because it's ambiguous where this string ends"""

#-

"""Look, Mom, no "errors"!!! """

#-

                println("""The other nice thing about triple-quoted
                           string literals is that they ignore leading
                           indentation, which is nice for long strings
                           in real code. Try changing these quotes!""")

# Strings are not written with single `'`s — that's used for a single character:

'this is my string'

#-

'⊂'
s1[1]

#-

'If you try writing a string in single-quotes, you will get an error'

'\u2200'

# ## String interpolation

#-

# You can use the dollar sign inside a string to evaluate a Julia expression inside a string — either a single variable or a more complicated expression:

name = "Jane"
num_fingers = 10
num_toes = 10
println("Hello, my name is $name.")
println("I have $num_fingers fingers and $num_toes toes.")

#-

println("That is $(num_fingers + num_toes) digits in all!!")
println("That is $(num_fingers / num_toes) fingers per toe")

"Here is a literal \$"
println("Here is a literal \$")
raw"Here is a literal $"
path = raw"C:\Program Files\Somewhere"
