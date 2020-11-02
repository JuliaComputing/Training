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

# #### Exercise 2
#
# Define a loss function called `loss`.
#
# `loss` should take two inputs: a vector storing data, `x`, and a vector storing the correct "labels" for that data. `loss` should return the sum of the squares of differences between the predictions and the correct labels.


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

# ### Stochastic gradient descent


#%%

# We can now use these features to reimplement stochastic gradient descent, following the method we used in the previous notebook, but now using backpropagation!


#%%

# #### Exercise 4
#
# Modify the code from the previous notebook for stochastic gradient descent to use Flux instead.


#%%

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


