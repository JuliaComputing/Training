# # Learning to recognize handwritten digits using a neural network


#%%

# We have now reached the point where we can tackle a very interesting task:
# applying the knowledge we have gained with machine learning in general, and
# `Flux.jl` in particular, to create a neural network that can recognize handwritten
# digits! The data are from a data set called MNIST, which has become a classic in
# the machine learning world.

# ## Data munging

#%%

# As we know, the first difficulty with any new data set is locating it, understanding
# what format it is stored in, reading it in and decoding it into a useful data structure in Julia.
#
# The original MNIST data is available [here](http://yann.lecun.com/exdb/mnist); see also the
# [Wikipedia page](https://en.wikipedia.org/wiki/MNIST_database).
# However, the format that the data is stored in is rather obscure.
#
# Fortunately, various packages in Julia provide nicer interfaces to access it.
# We will use the one provided by `Flux.jl`.
#
# The data are images of handwritten digits, and the corresponding labels that were determined
# by hand (i.e. by humans). Our job will be to get the computer to **learn** to recognize digits
# by learning, as usual, the function that relates the input and output data.

# ### Loading and examining the data

## using Pkg; Pkg.add("Flux")
using Flux, Flux.Data.MNIST

# Now we read in the data:

labels = MNIST.labels();
images = MNIST.images();

# Examine the `labels` data. Then examine the first few images.
# *Do not try to view the whole of the `images` object!*
# Try to drill down to discover how the data is laid out.

labels
images[1]

preprocess(img) = vec(Float32.(img))

xs = preprocess.(images[1:5000])
ys = Flux.onehot.(labels[1:5000], [0:9])

# Here is a 3-layer model. It's written like a data structure for convenience,
# but it's actually a composition of functions of vectors!

model = Chain(Dense(length(first(xs)), 20, Flux.leakyrelu),
              Dense(20, 10),
              softmax)

# Dense(num_inputs, num_outputs, nonlinearity): A dense matrix, then a nonlinear function.
# Dense(M, N) is a NxM matrix, since (NxM matrix) * (M vector) => N vector

# `relu` is just max(x, 0)
using Plots
plot(relu, -2, 2)
plot(leakyrelu, -2, 2)

# `softmax` normalizes a vector so it sums to 1.

loss(x, y) = Flux.mse(model(x), y)
accuracy(x, y) = Flux.onecold(model(x), 0:9) == Flux.onecold(y, 0:9)
opt = Descent()
data = zip(xs, ys)
Flux.train!(loss, params(model), data, opt)

# Let's see how it does on a particular example image
model(xs[401])
plot(model(xs[401]))
labels[401]
