# Unit tracking with Unitful

using Unitful

# Units are written with a special *string macro*

u"m"
# This is just a shorthand for:
@u_str "m"

typeof(u"m")

# Multiplying some number by this unit forms a quantity:

5u"m"

typeof(5u"m")

const m = u"m"

5m
# If you want, you can import specific unit names as identifiers.
# Note that these are not exported by default, since that would pollute
# your namespace with lots of short variable names.

using Unitful: m

5m

# Why use string macros? Two big advantages:
#
# * There are _lots_ of supported units
# * Allows for parsing complex combinations
# * Allows for SI (and other) prefixes

2.6u"kg*m/s^2"
260u"cN"

2.6u"kg*m/s^2" == 260.0u"cN"

# You can ask for the "preferred" (SI) representation:

upreferred(260.0u"cN")

# There are lots of types...
upreferred(22000.0u"ft^2")
upreferred(0.5u"ac")

# We can also convert between units easily with uconvert

uconvert(u"inch", 1.0u"c" * 1u"ns")


# So now you can actually do arithmetic on mixed types:

5u"lbf*s" + 3u"N*s"
sqrt(3u"N*s")


promote(5u"lbf*s", 3u"N*s")

3u"N*s" /u"N*s"

Unitful.ustrip(3u"N*s")
# Units combine easily e.g. with matrix operations

using Unitful: s

# Velocity matrix
V = rand(3,3)*m./s

using DataFrames
df = DataFrame(v = rand(10).*m./s, t = rand(10)u"°F")
using CSV
CSV.write("test.csv", df)
CSV.read("test.csv")

# Time vector
t = [1s, 2s, 3s]
# Distance vector
V*t

# No overhead (where possible)
@code_native 1m + 2m


# Uncertainty tracking with measurements
using Measurements

x = 5 ± 0.2

x + x

x - x

y = 5 ± 0.2

x + y

x - y

# What's really cool is that this just works through
# all of Julia's standard library:

sin(x)
cos(y)

sin(x)/cos(y)

# And even through other functions in other packages:
using DifferentialEquations
# Constants
g = 9.79 ± 0.02
L = 1.00 ± 0.01

# Initial state (speed & angle)
u₀ = [0 ± 0, π/60 ± 0.01]
tspan = (0, 6.5)

# The differential equation
function pendulum(du, u, p, t)
    θ = u[1]
    dθ = u[2]
    du[1] = dθ
    du[2] = -(g/L) * θ
end

prob = ODEProblem(pendulum, u₀, tspan)
sol = solve(prob, Tsit5())

sol.t
sol.u

using Plots
plot(sol.t, first.(sol.u))

# Or just use the "plot recipe" for DifferentialEquations
plot(sol)

# Or try the analytical solution:
t = 0:.1:6.5
plot(t, u₀[2] .* cos.(sqrt(g/L) .* t))


typeof(1u"m" ± 10u"cm")

x = (1 ± .1)*u"m"
x/5u"s"

@which 1u"m" ± 10u"cm"
