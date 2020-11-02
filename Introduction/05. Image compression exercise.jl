# # Exercise: compressing an image using the SVD

using Pkg
Pkg.add("Images")
Pkg.add("ImageMagick")

using Images, LinearAlgebra

banana = load("Courses/Introduction to Julia/images/banana.jpg")

# Images work just like arrays, but display specially

size(banana)

banana[60,50]

gb = Gray.(banana)

channelview(gb)

channelview(banana)

# The SVD factorizes a matrix A such that
#     A == U * S * transpose(V)
# where U and V are unitary, and S is diagonal.
#
# You can think of this as a sum of outer products (column of U times row
# of V), where each one is scaled by a value in diag(S).
# Each outer product is a full matrix (image).
# So, the ones scaled by larger singular values are more important,
# and we can throw away ones scaled by smaller values.

# Here's what it looks like keeping 30, 10, 5, and 3 values:

function compress_channel(channel, k)
    U, S, Vt = svd(channel)
    return U[:, 1:k] * Diagonal(S[1:k]) * Vt[:, 1:k]'
end

function compress_image(img, k)
    return RGB.(compress_channel(red.(img), k),
                compress_channel(green.(img), k),
                compress_channel(blue.(img), k))
end



# ## Problem statement
#
# Write a function `compress_image`. Its arguments should be an image and the
# factor by which you want to compress the image. A compressed grayscale image
# should display when compress_image is called.
# For example,
#     `compress_image("images/104_100.jpg", 33)`
# will return a compressed image of a grayscale banana built using 3 singular
# values. (This image has 100 singular values, so use fld(100, 33) to determine
# how many singular values to keep. fld performs "floor" division.)
#
# Hints:
# - Perform the SVD on the `channelview` of the image.
# - Read the documentation for `svd`.

Gray(-0.5)

function svd_compress(A, nv)
    F = svd(A)
    return F.U[:,1:nv] * Diagonal(F.S[1:nv]) * F.Vt[1:nv,:]
end

ss = load(imgpath)

function compress_image(imgfile, factor)
    img = load(imgfile)
    gs = Gray.(img)
    cv = channelview(gs)
    F = svd(cv)
    m, n = size(cv)
    #m == n || error("image must be square")
    nv = fld(n, factor)
    compressed = F.U[:,1:nv] * Diagonal(F.S[1:nv]) * F.Vt[1:nv,:]
    return Gray.(compressed)
end

compress_image("Courses/Introduction to Julia/images/banana.jpg",2)

compress_image(imgpath, 5)

# Remember: you can index arrays with `:` and ranges `a:b`:

A = [ i+j for i = 1:10, j = 1:10 ]

A[2:4, :]
A[1:2, 1:2]
A[:, 4:5]

svd
