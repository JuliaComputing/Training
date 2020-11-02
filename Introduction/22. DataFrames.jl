using DataFrames, RDatasets, Statistics, Plots

iris = dataset("datasets", "iris")
groups = groupby(iris, "Species")
combine(groups, max_sepal = "SepalLength"=>maximum,
                mean_sepal = "SepalLength"=>mean)

# 
# StatsPlots.@df iris plot(:SepalLength, :SepalWidth, colour = :Species)