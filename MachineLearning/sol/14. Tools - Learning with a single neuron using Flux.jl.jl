# # Learning with a single neuron using Flux.jl
#
# In this notebook, we'll use `Flux` to create a single neuron and teach it to learn, as we did by hand in notebook 10!


#%%

# ### Read in data and process it
#
# Let's start by reading in our data


## using Pkg; Pkg.add("CSV"); Pkg.add("DataFrames")
using CSV, DataFrames, Flux

apples = DataFrame(CSV.File("data/apples.dat", delim='\t', normalizenames=true))
bananas = DataFrame(CSV.File("data/bananas.dat", delim='\t', normalizenames=true))

# and processing it to extract information about the red and green coloring in our images:


x_apples  = [ [row.red, row.green] for row in eachrow(apples)]
x_bananas = [ [row.red, row.green] for row in eachrow(bananas)]

xs = vcat(x_apples, x_bananas)

ys = vcat(fill(0, size(x_apples)), fill(1, size(x_bananas)))

# The input data is in `xs` and the labels (true classifications as bananas or apples) in `ys`.


#%%

# ### Using `Flux.jl`


#%%

# Now we can load `Flux` to really get going!


## using Pkg; Pkg.add("Flux")
using Flux

# ### Making a single neuron in Flux

model = Dense(2, 1, σ)
loss(x, y) = Flux.mse(model(x), y)
opt = Descent()
Flux.train!(loss, params(model), shuffle!(collect(zip(xs, ys))), opt)

using Plots
scatter(first.(xs), last.(xs), group=ys, xlabel="mean red", ylabel="mean green")
xx = 0.4:.01:.65
yy = .1:0.01:.55
contour!(xx, yy, [model([x, y])[1] for y in yy, x in xx])
#%%

# Let's use `Flux` to build our neuron with 2 inputs and 1 output:
#
#  <img src="data/single-neuron.png" alt="Drawing" style="width: 500px;"/>


#%%

# #### Exercise 1
#
# Recall that Flux exposes the `Dense` function to automatically bundle together
# the weights and biases.  Create a 2-input 1-output `model` that will represent
# our neural network, transformed by a sigmoid to have outputs between 0 and 1.


#%%

# #### Solution


model = Dense(2, 1, σ)

# **Tests**


x = rand(2)

@assert isapprox(model(x), σ.(model.W*x + model.b))

#


#%%

# We previously put the two weights in a vector, $\mathbf{w}$. Flux instead puts weights in a $1 \times 2$ matrix (i.e. a matrix with 1 *row* and 2 *columns*).
#
# Previously, to compute the dot product of $\mathbf{w}$ and $\mathbf{x}$ we had to use either the `dot` function, or we had to transpose the vector $\mathbf{w}$:
#
# ```julia
# # transpose w
# b = w' * x
# # or use dot!
# b = dot(w, x)
# ```
# If the weights are instead stored in a $1 \times 2$ matrix, `W`, then we can simply multiply `W` and `x` together instead!
#
# We start off with random values for our parameters and data:


W = rand(1, 2)

#%%

x = rand(2)

# Note that the product of `W` and `x` will now be an array (vector) with a single element, rather than a single number:


W * x

# This means that our bias `b` is treated as an array when we're using `Flux`:


b = rand(1)

#


#%%

# #### Exercise 2
#
# Define a loss function called `loss`.
#
# `loss` should take two inputs: a vector storing data, `x`, and a vector storing the correct "labels" for that data. `loss` should return the sum of the squares of differences between the predictions and the correct labels.


#%%

# #### Solution


loss(x, y) = Flux.mse(model(x), y)

# **Tests**


x, y = rand(2), rand(1)
@assert isapprox( loss(x, y), sum((model(x) .- y).^2) )

#


#%%

# ## Calculating gradients using Flux


#%%

# For learning, we know that what we need is a way to calculate derivatives of the `loss` function with respect to the parameters `W` and `b`. So far, we have been doing that using finite differences.
#
# `Flux.jl` instead implements an _automatic_ method called **differentiable programming** that calculates gradients (essentially) exactly, in an automatic way, by indirectly applying the rules of calculus.
# You can ask for the gradient of every and any Julia function. We could ask for the gradient of a model:


gradient(x->model(x)[1], xs[1])

# But what is that computing?  **What is the gradient that we need to train our model?**
#
# #### Exercise 3
#
# Find the relevant gradient needed to train your `model` based upon the first
# datapoint in our dataset (`xs[1]`). Note that `Flux` provides a function `params` to ask models for their tuneable parameters.


#%%

# #### Solution


gradient(()->loss(xs[1], ys[1]), params(model))

#


#%%

# ### Stochastic gradient descent


#%%

# We can now use these features to reimplement stochastic gradient descent, following the method we used in the previous notebook, but now using backpropagation!


#%%

# #### Exercise 4
#
# Modify the code from the previous notebook for stochastic gradient descent to use Flux instead.


#%%

# #### Solution


function stochastic_gradient_descent!(loss, model, xs, ys; η = 0.01, N=1000)
    for step in 1:N

        i = rand(1:length(xs))  # choose a data point at random
        x = xs[i]
        y = ys[i]

        grads = gradient(params(model)) do
            loss(x, y)
        end
        model.b .-= η * grads[model.b]
        model.W .-= η * grads[model.W]
    end
    return model
end

# ### Investigating stochastic gradient descent


#%%

# Let's look at the values stored in `b` before we run stochastic gradient descent:


b

# After running `stochastic_gradient_descent`, we find the following:


W_final, b_final = stochastic_gradient_descent(loss, W, b, xs, ys, 1000)

# we can look at the values of `W_final` and `b_final`, which our machine learned to generate our desired classification.


W_final

#%%

b_final

# #### Exercise 5
#
# Plot the data and the learned function.


#%%

# #### Solution


## using Pkg; Pkg.add("Plots")
using Plots

# Let's draw the function that the network has learned, together with the data:


heatmap(0:0.01:1, 0:0.01:1, (x,y)->model([x, y])[1])

scatter!(first.(x_apples), last.(x_apples), color=:red, label="apples")
scatter!(first.(x_bananas), last.(x_bananas), color=:yellow, label="bananas")
xlabel!("average red content")
ylabel!("average green content")

# #### Exercise 6
#
# Do this plot every so often as the learning process is proceeding in order to have an animation of the process.


#%%

# #### Exercise 7
#
# Use Flux functions instead of developing your own SGD algorithm. The docs
# for `Descent`, `Flux.train!`, and `zip` may be helpful:


?Descent

#%%

?Flux.train!

# #### Solution


## model = Dense(2, 1, σ)
# loss(x, y) = Flux.mse(model(x), y)
data = zip(xs, ys)
opt = Descent()
Flux.train!(loss, params(model), data, opt)

# ## Adding more features


#%%

# #### Exercise 13
#
# So far we have just used two features, red and green.
#
# (i) What might make for a good third feature?  Add it and plot the data.
#
# (ii) Train a neuron with 3 inputs and 1 output on the data.
#
# (iii) Can you find a good way to visualize the result?


