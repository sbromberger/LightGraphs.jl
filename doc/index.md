# LightGraphs.jl

[![Build Status](https://travis-ci.org/sbromberger/LightGraphs.jl.svg?branch=master)](https://travis-ci.org/sbromberger/LightGraphs.jl)
[![Coverage Status](https://coveralls.io/repos/sbromberger/LightGraphs.jl/badge.svg?branch=master)](https://coveralls.io/r/sbromberger/LightGraphs.jl?branch=master)

An optimized graphs package.

Simple graphs (not multi- or hypergraphs, and no self loops) are represented in a memory- and time-efficient
manner with incidence lists and edge sets. Both directed and undirected graphs are supported via separate types, and conversion is available from directed to undirected.
