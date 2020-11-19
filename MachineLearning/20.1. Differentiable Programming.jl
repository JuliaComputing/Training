using Zygote, LinearAlgebra

# This example will showcase how we do a simple linear fit with Zygote, making
# use of complex datastructures, a home-grown stochastic gradient descent
# optimizer, and some good old-fashioned math.  We start with the problem
# statement:  We wish to learn the mapping `f(X) -> Y`, where `X` is a matrix
# of vector observations, `f()` is a linear mapping function and `Y` is a
# vector of scalar observations.

# Because we like complex objects, we will define our linear regression as the
# following object:
mutable struct LinearRegression
    # These values will be implicitly learned
    weights::Matrix
    bias::Float64
end
LinearRegression(nparams) = LinearRegression(randn(1, nparams), 0.0)

# Our linear prediction looks very familiar; w*X + b
function predict(model::LinearRegression, X)
    return model.weights * X .+ model.bias
end

# Our "loss" that must be minimized is the L2 norm between our current
# prediction and our ground-truth Y
function loss(model::LinearRegression, X, Y)
    return norm(predict(model, X) .- Y, 2)
end


# Our "ground truth" values (that we will learn, to prove that this works)
weights_gt = [1.0, 2.7, 0.3, 1.2]'
bias_gt = 0.4

# Generate a dataset of many observations
X = randn(length(weights_gt), 10000)
Y = weights_gt * X .+ bias_gt

# Add a little bit of noise to `X` so that we do not have an exact solution,
# but must instead do a least-squares fit:
X .+= 0.001.*randn(size(X))


# Now we begin our "training loop", where we take examples from `X`,
# calculate loss with respect to the corresponding entry in `Y`, find the
# gradient of our model, update the model, and continue.
model = LinearRegression(size(X, 1))

# Calculate gradient upon `model` for the first example in our training set
grads = Zygote.gradient(model) do m
    return loss(m, X[:,1], Y[1])
end

# The `grads` object is a Tuple containing one element per argument to
# `gradient()`, so we take the first one to get the gradient w.r.t. `model`:
grads = grads[1]

# Because our LinearRegression object is mutable, the gradient holds a
# reference to it, which we peel via `grads[]`:
grads = grads[]

# Zygote uses a NamedTuple to represent the gradient of a struct, since
# it doesn't necessarily know how to construct an instance of your
# custom type.
# That can actually be customized, but we try to make everything "just work"
# by default.

# Let's define an update rule that will allow us to modify the weights
# of our model a tad bit according to the gradients
function sgd_update!(model::LinearRegression, grads, η = 0.001)
    model.weights .-= η .* grads.weights
    model.bias -= η * grads.bias
end

# Now let's do that for each example in our training set:
@info("Running train loop for $(size(X,2)) iterations")
for idx in 1:size(X, 2)
    grads = Zygote.gradient(m -> loss(m, X[:, idx], Y[idx]), model)[1][]
    sgd_update!(model, grads)
end

# Let's see how close we got to the "correct" values!
model

# ## This is differentiable programming! Key points:
#
# * Reverse-mode autodiff tells us how to update a potentially-large number of
#   parameters given only a scalar "loss".
# * Many parameters == sophisticated models
# * Any program can be used as the model.
#
# * A "machine learning framework" is just a kit of reusable parts for this process:
#   * Some popular kinds of models (functions) designed to be composed into "layers"
#   * Autodiff
#   * Some optimization algorithms
#   * Some loss functions
#   * A training loop
#   * Some pre-trained networks
#   * Tools for visualization etc.
