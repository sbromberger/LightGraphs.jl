# LightGraphs

## Important Note
Until [an issue with one of our dependencies](https://github.com/JuliaLinearAlgebra/Arpack.jl/issues/5) is resolved, LightGraphs will not work with any Julia 0.7 version that has been built from source on OSX or other systems with a compiler more modern than GCC7. If you must use LightGraphs with Julia 0.7, please [download a Julia binary](https://julialang.org/downloads/).

[![Build Status](https://travis-ci.org/JuliaGraphs/LightGraphs.jl.svg?branch=master)](https://travis-ci.org/JuliaGraphs/LightGraphs.jl)
[![codecov.io](http://codecov.io/github/JuliaGraphs/LightGraphs.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaGraphs/LightGraphs.jl?branch=master)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://juliagraphs.github.io/LightGraphs.jl/latest)
[![Join the chat at https://gitter.im/JuliaGraphs/LightGraphs.jl](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/JuliaGraphs/LightGraphs.jl)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.889971.svg)](https://doi.org/10.5281/zenodo.889971)

[![LightGraphs](http://pkg.julialang.org/badges/LightGraphs_0.3.svg)](http://pkg.julialang.org/?pkg=LightGraphs)
[![LightGraphs](http://pkg.julialang.org/badges/LightGraphs_0.4.svg)](http://pkg.julialang.org/?pkg=LightGraphs&ver=0.4)
[![LightGraphs](http://pkg.julialang.org/badges/LightGraphs_0.5.svg)](http://pkg.julialang.org/?pkg=LightGraphs)
[![LightGraphs](http://pkg.julialang.org/badges/LightGraphs_0.6.svg)](http://pkg.julialang.org/?pkg=LightGraphs)
[![LightGraphs](http://pkg.julialang.org/badges/LightGraphs_0.7.svg)](http://pkg.julialang.org/detail/LightGraphs)

LightGraphs offers both (a) a set of simple, concrete graph implementations -- `Graph`
(for undirected graphs) and `DiGraph` (for directed graphs), and (b) an API for
the development of more sophisticated graph implementations under the `AbstractGraph`
type.

The project goal is to mirror the functionality of robust network and graph
analysis libraries such as [NetworkX](http://networkx.github.io) while being
simpler to use and more efficient than existing Julian graph libraries such as
[Graphs.jl](https://github.com/JuliaLang/Graphs.jl). It is an explicit design
decision that any data not required for graph manipulation (attributes and
other information, for example) is expected to be stored outside of the graph
structure itself. Such data lends itself to storage in more traditional and
better-optimized mechanisms.

Additional functionality may be found in a number of companion packages, including:
  * [LightGraphsExtras.jl](https://github.com/JuliaGraphs/LightGraphsExtras.jl):
  extra functions for graph analysis.
  * [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl): graphs with
  associated meta-data.
  * [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl):
  weighted graphs.
  * [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl): tools for importing
  and exporting graph objects using common file types like edgelists, GraphML,
  Pajek NET, and more.  

## Documentation
Full documentation is available at [GitHub Pages](https://juliagraphs.github.io/LightGraphs.jl/latest).
Documentation for methods is also available via the Julia REPL help system.
Additional tutorials can be found at [JuliaGraphsTutorials](https://github.com/JuliaGraphs/JuliaGraphsTutorials).

## Installation
Installation is straightforward:
```julia-repl
julia> Pkg.add("LightGraphs")
```

## Supported Versions
* LightGraphs master is generally designed to work with the latest stable version of Julia (except during Julia version increments as we transition to the new version).
* Julia 0.3: LightGraphs v0.3.7 is the last version guaranteed to work with Julia 0.3.
* Julia 0.4: LightGraphs versions in the 0.6 series are designed to work with Julia 0.4.
* Julia 0.5: LightGraphs versions in the 0.7 series are designed to work with Julia 0.5.
* Julia 0.6: LightGraphs versions in the 0.8 through 0.12 series are designed to work with Julia 0.6.
* Julia 0.7: LightGraphs versions in the 0.14 series are designed to work with Julia 0.7.
* Later versions: Some functionality might not work with prerelease / unstable / nightly versions of Julia. If you run into a problem, please file an issue.

# Contributing and Reporting Bugs
We welcome contributions and bug reports! Please see [CONTRIBUTING.md](https://github.com/JuliaGraphs/LightGraphs.jl/blob/master/CONTRIBUTING.md)
for guidance on development and bug reporting.
