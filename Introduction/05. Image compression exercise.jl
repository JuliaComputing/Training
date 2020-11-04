# # Exercise: compressing an image using the SVD

using Images, LinearAlgebra

banana = load("images/banana.jpg")

# Images work just like arrays, but display specially

size(banana)

banana[60,50]

gb = Gray.(banana)

grayvals = channelview(gb)

channelview(banana)

# we can take apart and reassemble the red, green, and blue channels
RGB.(red.(banana), green.(banana), blue.(banana))

# The SVD factorizes a matrix A such that
#     A == U * S * transpose(V)
# where U and V are unitary, and S is diagonal.

U, S, V = svd(grayvals)

norm(U * Diagonal(S) * V' - grayvals)

# You can think of this as a sum of outer products (column of U times row
# of V), where each one is scaled by a value in diag(S).
# Each outer product is a full matrix (image).
# So, the ones scaled by larger singular values are more important,
# and we can throw away ones scaled by smaller values.

# Here's what it looks like keeping 30, 10, 5, and 3 values:

[load("images/banana_30svals.png")
 load("images/banana_10svals.png")
 load("images/banana_5svals.png")
 load("images/banana_3svals.png")]


# ## Problem statement
#
# Write a function `compress_image`. Its arguments should be an image and the
# factor by which you want to compress the image. A compressed grayscale image
# should display when compress_image is called.
# For example,
#     `compress_image(banana, 33)`
# will return a compressed image of a grayscale banana built using 3 singular
# values. (This image has 100 singular values, so use fld(100, 33) to determine
# how many singular values to keep. fld performs "floor" division.)
#
# Hints:
# - Perform the SVD on the `channelview` of the image.
# - Read the documentation for `svd`.

function compress_image(img, factor)
    # your code here
end

compress_image("images/banana.jpg",2)

# Remember: you can index arrays with `:` and ranges `a:b`:

A = [ i+j for i = 1:10, j = 1:10 ]

A[2:4, :]
A[1:2, 1:2]
A[:, 4:5]

# Extra credit: Make it work on RGB images by compressing each
# channel separately, and reassembling them.
