# # Building a single neural network layer using `Flux.jl`
#
# In this notebook, we'll move beyond binary classification. We'll try to distinguish between three fruits now, instead of two. We'll do this using **multiple** neurons arranged in a **single layer**.


#%%

# ## Read in and process data


#%%

# We can start by loading the necessary packages and getting our data into working order with similar code we used at the beginning of the previous notebooks, except that now we will combine three different apple data sets, and will add in some grapes to the fruit salad!


using CSV, DataFrames, Flux, Plots

#%%

## Load apple data in CSV.read for each file
apples1 = DataFrame(CSV.File("data/Apple_Golden_1.dat", delim='\t', normalizenames=true))
apples2 = DataFrame(CSV.File("data/Apple_Golden_2.dat", delim='\t', normalizenames=true))
apples3 = DataFrame(CSV.File("data/Apple_Golden_3.dat", delim='\t', normalizenames=true))
# And then concatenate them all together
apples = vcat(apples1, apples2, apples3)

# And now let's build an array called `x_apples` that stores data from the `red` and `blue` columns of `apples`. From `applecolnames1`, we can see that these are the 3rd and 5th columns of `apples`:


size(apples)

#%%

apples[1:1, :]

#%%

x_apples  = [ [apples[i, :red], apples[i, :blue]] for i in 1:size(apples, 1) ]

# Similarly, let's create arrays called `x_bananas` and `x_grapes`:


## Load data from *.dat files
bananas = DataFrame(CSV.File("data/Banana.dat", delim='\t', normalizenames=true))
grapes1 = DataFrame(CSV.File("data/Grape_White.dat", delim='\t', normalizenames=true))
grapes2 = DataFrame(CSV.File("data/Grape_White_2.dat", delim='\t', normalizenames=true))

# Concatenate data from two grape files together
grapes = vcat(grapes1, grapes2)

# Build x_bananas and x_grapes from bananas and grapes
x_bananas  = [ [bananas[i, :red], bananas[i, :blue]] for i in 1:size(bananas, 1) ]
x_grapes = [ [grapes[i, :red], grapes[i, :blue]] for i in 1:size(grapes, 1) ]

#%%

xs = vcat(x_apples, x_bananas, x_grapes)

# ## One-hot vectors


#%%

# Now we wish to classify *three* different types of fruit. It is not clear how to encode these three types using a single output variable; indeed, in general this is not possible.
#
# Instead, we have the idea of encoding $n$ output types from the classification into *vectors of length $n$*, called "one-hot vectors":
#
# $$
# \textrm{apple} = \begin{pmatrix} 1 \\ 0 \\ 0 \end{pmatrix};
# \quad
# \textrm{banana} = \begin{pmatrix} 0 \\ 1 \\ 0 \end{pmatrix};
# \quad
# \textrm{grape} = \begin{pmatrix} 0 \\ 0 \\ 1 \end{pmatrix}.
# $$
#
# The term "one-hot" refers to the fact that each vector has a single $1$, and is $0$ otherwise.
#
# Effectively, the first neuron will learn whether or not (1 or 0) the data corresponds to an apple, the second whether or not (1 or 0) it corresponds to a banana, etc.


#%%

# `Flux.jl` provides an efficient representation for one-hot vectors, using advanced features of Julia so that it does not actually store these vectors, which would be a waste of memory; instead `Flux` just records in which position the non-zero element is. To us, however, it looks like all the information is being stored:


## using Pkg; Pkg.add("Flux")
using Flux: onehot

onehot(1, 1:3)

# #### Exercise 1
#
# Make an array `labels` that gives the labels (1, 2 or 3) of each data point. Then use `onehot` to encode the information about the labels as a vector of `OneHotVector`s.


#%%

# ## Single layer in Flux


#%%

# Let's suppose that there are two pieces of input data, as in the previous single neuron notebook. Then the network has 2 inputs and 3 outputs:




#%%

include("draw_neural_net.jl")
draw_network([2, 3])

# `Flux` allows us to express this again in a simple way:


using Flux

#%%

model = Dense(2, 3, σ)

# #### Exercise 2
#
# Now what do the weights inside `model` look like? How does this compare to the diagram of the network layer above?


#%%

# ## Training the model


#%%

# Despite the fact that the model is now more complicated than the single neuron from the previous notebook, the beauty of `Flux.jl` is that the rest of the training process **looks exactly the same**!


#%%

# #### Exercise 3
#
# Implement training for this model.


#%%

# #### Exercise 4
#
# Visualize the result of the learning for each neuron. Since each neuron is sigmoidal, we can get a good idea of the function by just plotting a single contour level where the function takes the value 0.5, using the `contour` function with keyword argument `levels=[0.5, 0.501]`.


using Plots
plot(colorbar=false, xlabel="average red amount", ylabel="average blue amount")

contour!(0:0.01:1, 0:0.01:1, (x,y)->model([x,y])[1], levels=[0.5], color = cgrad([:red, :red]))
contour!(0:0.01:1, 0:0.01:1, (x,y)->model([x,y])[2], levels=[0.5], color = cgrad([:yellow, :yellow]))
contour!(0:0.01:1, 0:0.01:1, (x,y)->model([x,y])[3], levels=[0.5], color = cgrad([:green, :green]))

scatter!(first.(x_apples), last.(x_apples), color=:red, label="apples")
scatter!(first.(x_bananas), last.(x_bananas), color=:yellow, label="bananas")
scatter!(first.(x_grapes), last.(x_grapes), color=:green, label="grapes")

# #### Exercise 5
#
# Interpret the results by checking which fruit each neuron was supposed to learn and what it managed to achieve.


