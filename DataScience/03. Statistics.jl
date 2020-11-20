# ## Statistics
# Having a solid understanding of statistics in data science allows us to understand our data better,
# and allows us to create a quantifiable evaluation of any future conclusions.

using Statistics, StatsBase, RDatasets, Plots, StatsPlots
using KernelDensity, Distributions, LinearAlgebra
using HypothesisTests, PyCall, MLBase

# Distributions.jl defines a large number of types representing different commonly-used
# probability distributions.

d = Normal()

pdf(d, 0), cdf(d, 0), mean(d), var(d), quantile(d, .5), mode(d)

d = Gamma(5, 1)

pdf(d, 4), cdf(d, 4), mean(d), var(d), quantile(d, .5), mode(d)

# Let's examine some eruption data from the old faithful geyser. The data will contain wait
# times between every consecutive times the geyser goes off and the length of the eruptions.

# Let's get the data first...

D = dataset("datasets", "faithful")
names(D)

describe(D)

#-

eruptions = D[!, :Eruptions]
scatter(eruptions, label="eruptions")
waittime = D[!, :Waiting]
scatter!(waittime, label="wait time")

# ### 🔵Statistics plots
# As you can see, this doesn't tell us much about the data... Let's try some statistical plots

histogram(eruptions, label="eruptions")

# You can adjust the number of bins manually or by passing a one of the autobinning functions.

#-

histogram(eruptions, bins=:sqrt, label="eruptions")

# ### 🔵Kernel density estimates
# Next, we will see how we can fit a kernel density estimation function to our data. We will make use
# of the `KernelDensity.jl` package. 

p = kde(eruptions)

# If we want the histogram and the kernel density graph to be aligned we need to remember that the
# "density contribution" of every point added to one of these histograms is `1/(nb of elements)*bin width`.
# Read more about kernel density estimates on its wikipedia page https://en.wikipedia.org/wiki/Kernel_density_estimation

histogram(eruptions, label="eruptions")
plot!(p.x, p.density .* length(eruptions), linewidth=3, color=2, label="kde fit") # nb of elements*bin width

#-

histogram(eruptions, bins=:sqrt, label="eruptions")
plot!(p.x, p.density .* length(eruptions) .*0.2, linewidth=3, color=2, label="kde fit") # nb of elements*bin width

# Next, we will take a look at one probablity distribution, namely the normal distribution and
# verify that it generates a bell curve.

myrandomvector = randn(100_000)
histogram(myrandomvector)
p = kde(myrandomvector)
plot!(p.x, p.density .* length(myrandomvector) .*0.1, linewidth=3, color=2, label="kde fit") # nb of elements*bin width

# ### 🔵Probability distributions
# Another way to generate the same plot is via using the `Distributions` package and choosing the
# probability distribution you want, and then drawing random numbers from it. As an example, we
# will use `d = Normal()` below.

d = Normal()
myrandomvector = rand(d, 100000)
histogram(myrandomvector)
p = kde(myrandomvector)
plot!(p.x, p.density .* length(myrandomvector) .*0.1, linewidth=3, color=2, label="kde fit") # nb of elements*bin width

#-

b = Binomial(40) 
myrandomvector = rand(b,1000000)
histogram(myrandomvector)
p = kde(myrandomvector)
plot!(p.x, p.density .* length(myrandomvector) .*0.5, color=2, label="kde fit") # nb of elements*bin width

# Next, we will try to fit a given set of numbers to a distribution.

x = rand(1000)
d = fit(Normal, x)
myrandomvector = rand(d,1000)
histogram(myrandomvector, nbins=20, fillalpha=0.3, label="fit")
histogram!(x, nbins=20, linecolor = :red, fillalpha=0.3, label="myvector")

#-

x = eruptions
d = fit(Normal, x)
myrandomvector = rand(d, 1000)
histogram(myrandomvector, nbins=20, fillalpha=0.3)
histogram!(x, nbins=20, linecolor = :red, fillalpha=0.3)

# ### 🔵Hypothesis testing
# Next, we will perform hypothesis testing using the `HypothesisTests.jl` package.

myrandomvector = randn(1000)
OneSampleTTest(myrandomvector)

#-

OneSampleTTest(eruptions)

# A note about p-values: Currently using the pvalue of spearman and pearson correlation from Python.
# But you can follow the formula here to implement your own.
# https://stackoverflow.com/questions/53345724/how-to-use-julia-to-compute-the-pearson-correlation-coefficient-with-p-value

scipy_stats = pyimport("scipy.stats")
@show scipy_stats.spearmanr(eruptions,waittime)
@show scipy_stats.pearsonr(eruptions,waittime)

#-

scipy_stats.pearsonr(eruptions,waittime)

#-

corspearman(eruptions,waittime)

#-

cor(eruptions,waittime)

#-

scatter(eruptions,waittime,xlabel="eruption length",
    ylabel="wait time between eruptions",legend=false,grid=false,size=(400,300))

# Interesting! This means that the next time you visit Yellowstone National part to see
# old faithful and you have to wait for too long for it to go off, you will likely get a longer eruption! 

#-

# ### 🔵AUC and Confusion matrix
# Finally, we will cover basic tools you will need such as AUC scores or confusion matrix.
# We use the `MLBase` package for that.

gt = [1, 1, 1, 1, 1, 1, 1, 2]
pred = [1, 1, 2, 2, 1, 1, 1, 1]
C = confusmat(2, gt, pred)   # compute confusion matrix
C ./ sum(C, dims=2)   # normalize per class
sum(diag(C)) / length(gt)  # compute correct rate from confusion matrix
correctrate(gt, pred)
C = confusmat(2, gt, pred)   

#-

gt = [1, 1, 1, 1, 1, 1, 1, 0];
pred = [1, 1, 0, 0, 1, 1, 1, 1]
ROC = MLBase.roc(gt,pred)
recall(ROC)
precision(ROC)
