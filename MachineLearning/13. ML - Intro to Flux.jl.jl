# # Intro to Flux.jl


#%%

# We have learned how machine learning allows us to classify data as apples or bananas with a single neuron. However, some of those details are pretty fiddly! Fortunately, Julia has a powerful package that does much of the heavy lifting for us, called [`Flux.jl`](https://fluxml.github.io/).
#
# *Using `Flux` will make classifying data and images much easier!*


#%%

# ## Using `Flux.jl`
#
# In the next notebook, we are going to see how Flux allows us to redo the calculations from the previous notebook in a simpler way. We can get started with `Flux.jl` via:


## using Pkg; Pkg.add("Flux")
using Flux

# #### Helpful built-in functions
#
# When working we'll `Flux`, we'll make use of built-in functionality that we've had to create for ourselves in previous notebooks.
#
# For example, the sigmoid function, σ, that we have been using already lives within `Flux`:


?σ

# Importantly, `Flux` allows us to *automatically create neurons* with the **`Dense`** function. For example, in the last notebook, we were looking at a neuron with 2 inputs and 1 output:
#
#  <img src="data/single-neuron.png" alt="Drawing" style="width: 500px;"/>
#
#  We could create a neuron with two inputs and one output via


model = Dense(2, 1, σ)

# This `model` object comes with places to store weights and biases:


model.W

#%%

model.b

#%%

typeof(model.W)

# Perhaps most nicely, we can _evaluate_ this model for a given input just by using it like a function:


model([1,2])

# Can you reproduce its output?


#%%

# Perhaps the most powerful functionality is the ability to automatically compute the gradient of an arbitrary Julia function.


f(x) = 3x^2 + 2x + 1;
gradient(f, 4)

# Or with two arguments simultaneously:


f(x, y) = 3x^2 + 2x*y - 4y^2
gradient(f, 5, 6)

#


#%%

# Other helpful built-in functionality include other common (even if simple) utilities
# used in machine learning tasks, like other activation and cost functions. This
# includes the cost function that we've used in previous notebooks -
#
# $$L(w, b) = \sum_i \left[y_i - f(x_i, w, b) \right]^2$$
#
# This is the "mean square error" function, which in `Flux` is named **`Flux.mse`**.


methods(Flux.mse)

