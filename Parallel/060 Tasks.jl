# # A brief introduction to Tasks
#
# A task in Julia is an independent call stack:
#
# - you can have multiple tasks that are all at different points of execution,
#   all independent of each other
#
# - you can transfer control from one task ("stack") to another and keep
#   executing
#
# - you can transfer control back to the same task and keep going from where it
#   was before with the same call stack
#
# Concurrency:
#
# - a given CPU core can only be executing one of these at a time
#
# - but different CPU cores can be executing different tasts at the same time
#
# Blocking:
#
# - all blocking operations like `sleep`, I/O, waiting on things appear to be
#   blocking from the programmer's perspective
#
# - but none of these actually block under the hood
#
# - instead, they transfer control back to a scheduler task which keeps track of
#   which work tasks are blocked or ready to run
#
# - if all tasks are blocked, the scheduler just waits until some event happens
#   that allows some tasks to start working
#
# - when some tasks are ready to do work (i.e. CPU, not waiting), the scheduler
#   starts one of them back up on each CPU core

# The simplest possible concurrent example:

@time @sync begin
    @async sleep(1)
    @async sleep(1)
end

# "Concurrency" vs "parallelism"
#
# concurrency: I don't care about the ordering of these they could run in any
# order at the same time and you can do parts of one while the other is waiting
#
# parallelism: these actually run at the same on different CPU cores, getting
# real work done, not just waiting
#
# When you use `@async` you're only expressing concurrency tasks will always run
# on the same kernel thread
#
# Later, we'll see `Threads.@spawn` which starts a new task that can actually
# run on a separate kernel thread
#
# Use `@async` when you have blocking tasks like I/O or waiting on some other
# event and you want to do many of these at the same time.
#
# Use `Threads.@spawn` when you have actually CPU-bound work to do at the same
# time on different kernel threads.

# The next simplest concurrent example...

using JSON
using Downloads: download

function delay_request(id::Int)
    url = "https://httpbingo.org/delay/2"
    file = download("$url?id=$id")
    data = JSON.parsefile(file)
    parse(Int, data["args"]["id"][1])
end

@time @sync for id = 1:10
    @async begin
        println("REQ $id")
        id′ = delay_request(id)
        println("GOT $id′ [$id]")
    end
end

# Note on `@sync`
#
# It's usually a good idea to wrap a set of async tasks in a `@sync` which will
# wait for all of them to be done.
#
# However, sometimes you just want to spin off a "background" task that never
# finishes or you don't care when it does. For this you can use `@async` without
# `@sync`:

stop = false
t = @async while !stop
    println("💗")
    sleep(1)
end

# Here we use the global `stop` to stop the task. This is fine here because
# we're using tasks but not threads; if you're acessing anything global from
# multiple threads, you have to be more careful and there are good tools for
# this — atomics, locks, etc. — which we'll cover in the next sections

# WARNING: if a task fails and no one waits for it, you may never get any
# notification of there being any kind of problem

t = @async (sleep(1); 1 + "hi")

wait(ans)

# Therefore, it's generally best practice in any production code to wrap all
# `@async` calls in a `@sync` call or otherwise make sure all tasks are waited
# on by some "parent" task

## Fetching values from tasks

t = @async (sleep(3); rand())
wait(t)

t = @async (sleep(3); rand())
fetch(t)

# There's a lot more low level detail about tasks but this is all you need 99%
# of the time:
#
# - write what looks like blocking code in each task
#
# - start multiple concurrent tasks with `@async`


# ## Quiz:
#
# How long will this take?

@time for i in 1:4
    sleep(1)
end

# What about this?

@time @sync for i in 1:4
    @async sleep(1)
end

# And finally, this?

@time for i in 1:10
    @async sleep(1)
end

# Now what if I had something that actually did work?

function work(N)
    series = 1.0
    for i in 1:N
        series += (isodd(i) ? -1 : 1) / (i*2+1)
    end
    return 4*series
end
work(1)
@time work(100_000_000)

#%%

@time @sync for i in 1:10
    @async work(100_000_000)
end
