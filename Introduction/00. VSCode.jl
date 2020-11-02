# ## Getting started with VS Code and Julia
#
# VS Code is a convenient way to view, edit, and display interactive code.
#
# # Installation:
#
# 1. Install Julia 1.5.2 for your platform: https://julialang.org/downloads/
# 2. Install VS Code for your platform: https://code.visualstudio.com/download
# 3. Launch VS Code!
#   3.1 Inside VS Code, go to the extensions view either by:
#       - executing the View: Show Extensions command (click View->Command Palette...)
#       - or by clicking on the gear icon on the bottom left and selecting Extensions
#   3.2 In the extensions view, simply search for "Julia" and install!
#
# # Getting these materials:
#
# These materials are hosted on GitHub at https://github.com/JuliaComputing/IntroductionTraining
#
# To download these materials, you can either:
#
#   - Download the zipped directory: https://github.com/JuliaComputing/IntroductionTraining/archive/master.zip
#   - Use git to _clone_ the repository
#       (I only recommend this if you are already familiar with git)

# ----------------------------
#
# # Executing code
# To execute a line of Julia code, place your cursor on that line and
# and hit `Control` and `Enter`

1 + 1
2 + 2

# Note that the input and output appears in the REPL below. 
# If the line ends in a semicolon the output is hidden
# (but the code is still executed)

2 + 2;
[1,2,3,4]

# Helpful shortcuts
#
# # Documentation
#
# You can get documentation help just by hovering over a symbol:

println("Hello world")

# ## Using the interactive REPL
#
# You can also execute code from within the REPL directly.
# Note that a number of special modes are available at the REPL

# ? - docs
# ; - shell
# ] - package management

# Finally, try using the up arrow at the REPL