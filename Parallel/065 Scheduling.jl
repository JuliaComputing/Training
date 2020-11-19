# ## Static vs. Dynamic scheduling
#
# Here we will compare two approaches to parallelizing a loop:
# `@threads` and `@sync - @spawn`.

# Note: use `julia -t 4` to start julia with 4 threads from the command line.
# In VSCode, go to File > Preferences > Settings and search for julia.
# Open settings.json.

Threads.nthreads()

using Images, Statistics
using Base.Threads: @threads, @spawn

# The Mandelbrot set escape time function
function escapetime(z; maxiter=80)
    c = z
    for n = 1:maxiter
        if abs(z) > 2
            return n-1
        end
        z = z^2 + c
    end
    return maxiter
end

# Mandelbrot sets are, of course, one of the most over-done demos
# in computer science. But they are a great example of parallel
# loops with *unbalanced* iterations.

function mandel(; width=80, height=20, maxiter=80)
    out = zeros(Int, height, width)
    real = range(-2.0, 0.5, length=width)
    imag = range(-1.0, 1.0, length=height)
    @threads for x in 1:width
        for y in 1:height
            z = real[x] + imag[y]*im
            out[y,x] = escapetime(z, maxiter=maxiter)
        end
    end
    return out
end

mandel()

@time m = mandel(width=1200,height=900,maxiter=400)
img = Gray.((m.%400)./100)
# save("img.png", clamp.(img, 0, 1))

# With @threads:
# 1 thread: 1.9
# 4 threads: 0.9 ~ 1.5

# With @spawn:
# 4 threads: 0.5 ~ 0.6
# 4 threads, @spawn each element: 1.9

# With @threads:
# 1 Thread : 1.656
# 4 Threads: 0.818

# With @spawn:
# 4 Threads: 0.452
