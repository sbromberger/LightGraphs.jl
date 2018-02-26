# Inspiration for this code came from EvolvingGraphs:
# https://github.com/weijianzhang/EvolvingGraphs.jl
#
# The EvolvingGraphs.jl package is licensed under the MIT "Expat" License:
# Copyright (c) 2015: Weijian Zhang.
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.#
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

"""
    katz_centrality(g, α=0.3)
Calculate the [Katz centrality](https://en.wikipedia.org/wiki/Katz_centrality)
of the graph `g` optionally parameterized by `α`. Return a vector representing
the centrality calculated for each node in `g`.
"""
function katz_centrality(g::AbstractGraph, α::Real=0.3)
    nvg = nv(g)
    v = ones(Float64, nvg)
    spI = sparse(one(Float64) * I, nvg, nvg)
    A = adjacency_matrix(g, Bool; dir=:in)
    v = (spI - α * A) \ v
    v /=  norm(v)
    return v
end
