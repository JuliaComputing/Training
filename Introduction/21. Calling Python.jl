using PyCall
using Conda

# Using basic Python:

py"sum"([1,2,3])

py"""
def add_one(x):
    return x + 1
"""

py"add_one"(2)

# Recursively calling back and forth between Python and Julia:
julia_fib(x) = x < 2 ? 1 : py"fib"(x-1) + py"fib"(x-2)
py"""
def fib(x):
    if x < 2:
        return 1
    else:
        return $julia_fib(x-1) + $julia_fib(x-2)
""" # """ # This is just a comment to fix syntax highlighting

julia_fib.(1:10)

[@timed(julia_fib(x))[2][1] for x in 1:25]

using Profile
@profile julia_fib(25)


fib(x) = x < 2 ? 1 : fib(x-1) + fib(x-2)
@time fib(25)

py"""
def pyfib(x):
    if x < 2:
        return 1
    else:
        return pyfib(x-1) + pyfib(x-2)
"""

@time py"pyfib"(25)
# Accessing Python packages

Conda.add("numpy")

np = pyimport("numpy")

np.sin(2)

np.arange(5)

# A slightly more complicated example: Let's use SciPy's optimizers:

Conda.add("scipy")

np = pyimport("numpy")
opt = pyimport("scipy.optimize")

py"""
def rosen(x):
    "The Rosenbrock function"
    return sum(100.0*(x[1:]-x[:-1]**2.0)**2.0 + (1-x[:-1])**2.0)
""" # """

x0 = np.array([1.3, 0.7, 0.8, 1.9, 1.2])
@time res = opt.minimize(py"rosen", x0, method="nelder-mead")

# But of course you could do this with Julia instead...
using Optim
@time res = optimize(py"rosen", x0, NelderMead())

# Or with a true Julia function:
function rosen(x)
    return sum(100.0*(x[2:end].-x[1:end-1].^2).^2 .+ (1.0.-x[1:end-1]).^2.0)
end

rosen(x0) == py"rosen"(x0)

@time res = optimize(rosen, x0, NelderMead())

@time opt.minimize(rosen, x0, method="nelder-mead")
