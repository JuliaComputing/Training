# ## Data
# Being able to easily load and process data is a crucial task that can make any data science more pleasant.
# In this notebook, we will cover most common types often encountered in data science tasks, and we will be
# using this data throughout the rest of this tutorial.

using BenchmarkTools
using DataFrames
using DelimitedFiles
using CSV
using XLSX

# # 🗃️ Get some data
# In Julia, it's pretty easy to dowload a file from the web using the `download` function.
# But also, you can use your favorite command line tool to download files by easily switching
# from Julia via the `;` key. Let's try both.
#
# Note: `download` depends on external tools such as curl, wget or fetch. So you must have one of these.

?download

#-

P = download("https://raw.githubusercontent.com/nassarhuda/easy_data/master/programming_languages.csv",
    "programminglanguages.csv")

# Another way would be to use a shell command to get the same file.

;wget "https://raw.githubusercontent.com/nassarhuda/easy_data/master/programming_languages.csv"

;head programminglanguages.csv

# # 📂 Read your data from text files.
# The key question here is to load data from files such as `csv` files, `xlsx` files, or just raw
# text files. We will go over some Julia packages that will allow us to read such files very easily.
#
# The standard library includes `DelimitedFiles`, which can be used for simple e.g. tab-separated
# data files. However it is not a fully-functional CSV reader.

# A more powerful package to use here is the `CSV` package. By default, the CSV package imports the
# data to a DataFrame, which can have several advantages as we will see below.
#
# In general,[`CSV.jl`](https://juliadata.github.io/CSV.jl/stable/) is the recommended way to load CSVs
# in Julia.

C = CSV.read("programminglanguages.csv");

#-

typeof(C)
C[1:10,:]

names(C)
C.year
C.language

describe(C)

#-

## To write to a *.csv file using the CSV package
CSV.write("programminglanguages_CSV.csv", C)

# Another type of files that we may often need to read is `XLSX` files. Let's try to read a new file.

T = XLSX.readdata("data/zillow_data_download_april2020.xlsx", #file name
    "Sale_counts_city", #sheet name
    "A1:F9" #cell range
    )

# If you don't want to specify cell ranges... though this will take a little longer...

G = XLSX.readtable("data/zillow_data_download_april2020.xlsx","Sale_counts_city");

# Here, `G` is a tuple of two items. The first is a vector of vectors where each vector corresponds to
# a column in the excel file. And the second is the header with the column names.

G[1]

#-

G[1][1][1:10]

#-

G[2][1:10]

# And we can easily store this data in a DataFrame. `DataFrame(G...)` uses the "splat" operator to
# _unwrap_ these arrays and pass them to the DataFrame constructor.

D = DataFrame(G...) # equivalent to DataFrame(G[1],G[2])

#-

food = ["apple", "cucumber", "tomato", "banana"]
calories = [105,47,22,105]
price = [0.85,1.6,0.8,0.6,]
dataframe_calories = DataFrame(item=food, calories=calories)
dataframe_prices = DataFrame(item=food, price=price)

# Shortcut:

dataframe_foods = DataFrame(; food, calories, price)

#-

DF = innerjoin(dataframe_calories, dataframe_prices, on=:item)

#-

## we can also use the DataFrame constructor on a Matrix
DataFrame(T)

# You can also easily write data to an XLSX file

## if you already have a dataframe: 
## XLSX.writetable("filename.xlsx", collect(DataFrames.eachcol(df)), DataFrames.names(df))
XLSX.writetable("writefile_using_XLSX.xlsx", G[1], G[2])

# ## ⬇️ Importing your data
#
# Often, the data you want to import is not stored in plain text, and you might want to import
# different kinds of types. Here we will go over importing `jld`, `npz`, `rda`, and `mat` files.
# Hopefully, these four will capture the types from four common programming languages used in
# Data Science (Julia, Python, R, Matlab).
#
# We will use a toy example here of a very small matrix. But the same syntax will hold for bigger files.
#
# ```
# 4×5 Array{Int64,2}:
#  2  1446  1705  1795  1890
#  3  2926  3121  3220  3405
#  4  2910  3022  2937  3224
#  5  1479  1529  1582  1761
#  ```

# In general, check out the JuliaIO github org for lots of file format support.

# Any julia value can be written using the Serialization stdlib.
using Serialization
serialize("mat.jls", rand(5,5))
deserialize("mat.jls")

# Advantages:
# * 100% language coverage, even functions!
# * Binary format, so reasonably efficient for e.g. numeric data
# * Very simple

serialize("f.jls", x->2x+1)
deserialize("f.jls")(10)

# Disadvantages:
# * Not compatible with any other formats (though you could use e.g. pyjulia for reading)
# * No partial reads/writes; need to use multiple files instead
# * Probably slower than special-purpose formats when the data is constrained
# * Julia version 1.x is guaranteed to read files written by 1.(x-1), but not the other way around.

#-

# JLD uses libhdf5 to write almost any julia data to HDF5 files.
# It cleverly tries to maintain as much julia-specific metadata as possible,
# while still being fully HDF5-compatible.
# It has been around for a long time.

using JLD
jld_data = JLD.load("data/mytempdata.jld")
save("mywrite.jld", jld_data)

# A newer alternative is JLD2. It has no binary dependencies, and re-implements a subset
# of HDF5 in pure julia. It is often faster but is less comprehensive. Other HDF5 tools
# will be able to read its files, but it cannot read all HDF5 files.

#-

# NPZ reads numpy-saved data

using NPZ
npz_data = npzread("data/mytempdata.npz")
npzwrite("mywrite.npz", npz_data)

#-

using RData
R_data = RData.load("data/mytempdata.rda")
## We'll need RCall to save here. https://github.com/JuliaData/RData.jl/issues/56
using RCall
@rput R_data
R"save(R_data, file=\"mywrite.rda\")"

#-

using MAT
Matlab_data = matread("data/mytempdata.mat")
matwrite("mywrite.mat",Matlab_data)

# # 🔢 Time to process the data from Julia
# We will mainly cover `Matrix` (or `Vector`), `DataFrame`s, and `dict`s (or dictionaries).
# Let's bring back our programming languages dataset and start playing it the matrix it's stored in.

P_df = C

# Here are some quick questions we might want to ask about this simple data.
# - Which year was was a given language invented?
# - How many languages were created in a given year?

## Q1: Which year was was a given language invented?
function year_created(P_df, language::String)
    loc = findfirst(==(language), P_df.language)
    return P_df.year[loc]
end
year_created(P_df, "Julia")

#-

year_created(P_df, "W")

#-

function year_created_handle_error(P_df, language::String)
    loc = findfirst(==(language), P_df.language)
    !isnothing(loc) && return P_df.year[loc]
    error("Error: Language not found.")
end
year_created_handle_error(P_df, "W")

#-

## Q2: How many languages were created in a given year?
count(==(2011), P_df.year)

# Next, we'll use dictionaries. A quick way to create a dictionary is with the `Dict()` function.
# But this creates a dictionary without types. Here, we will specify the types of this dictionary.

## A quick example to show how to build a dictionary
Dict([("A", 1), ("B", 2), (1,[1,2])])

#-

# Now, let's populate the dictionary with years as keys and vectors that hold all the programming
# languages created in each year as their values.

P_dictionary = Dict{Integer, Vector{String}}()

for (year, language) in eachrow(P_df)
    langs = get!(Vector{String}, P_dictionary, year)
    push!(langs, language)
end

P_dictionary

#-

length(keys(P_dictionary))

#-

## Q1: Which year was was a given language invented?
## now instead of looking in one long vector, we will look in many small vectors
year_created(dict, language::String) = findfirst(vec->in(language, vec), dict)
year_created(P_dictionary, "Julia")

#-

## Q2: How many languages were created in a given year?
how_many_per_year(P_dictionary, year::Int64) = length(P_dictionary[year])
how_many_per_year(P_dictionary, 2011)

# ## Missing data

# The singleton value `missing` in julia represents an existing, but *unknown* value.
# It uses 3-valued logic.

1 == missing     # missing
missing & false  # false
missing | true   # true

# Conditions in julia require a definite answer however.

if 1 == missing
    # oops
end

# There are many possible designs for missing data. The "standard" `missing` uses a
# single dedicated type for all missing data:

d = [1, missing, 2, missing]  # Vector{Union{Missing, Int64}}

# Some alternate designs are:
# DataValues.jl - A missing value has a type, and the missingness is indicated by a
#                 per-value flag instead of its own type.
# SentinelMissings.jl - For handling data (e.g. legacy data) where missingness is
#                       represented by a special value like -9999.

# To skip missing values
collect(skipmissing(d))

ddf = DataFrame(year = [1991, 1992], price = [1.0, missing])

# To skip rows with missing values:

dropmissing(ddf)
