# LightGraphs

[![Build Status](https://travis-ci.org/JuliaGraphs/LightGraphs.jl.svg?branch=master)](https://travis-ci.org/JuliaGraphs/LightGraphs.jl)
[![codecov.io](http://codecov.io/github/JuliaGraphs/LightGraphs.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaGraphs/LightGraphs.jl?branch=master)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://juliagraphs.github.io/LightGraphs.jl/latest)
[![Join the chat at https://gitter.im/JuliaGraphs/LightGraphs.jl](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/JuliaGraphs/LightGraphs.jl)
[![DOI](https://zenodo.org/badge/29314835.svg)](https://zenodo.org/badge/latestdoi/29314835)

[![LightGraphs](http://pkg.julialang.org/badges/LightGraphs_0.3.svg)](http://pkg.julialang.org/?pkg=LightGraphs)
[![LightGraphs](http://pkg.julialang.org/badges/LightGraphs_0.4.svg)](http://pkg.julialang.org/?pkg=LightGraphs&ver=0.4)
[![LightGraphs](http://pkg.julialang.org/badges/LightGraphs_0.5.svg)](http://pkg.julialang.org/?pkg=LightGraphs)
[![LightGraphs](http://pkg.julialang.org/badges/LightGraphs_0.6.svg)](http://pkg.julialang.org/?pkg=LightGraphs)

An optimized graphs package.

Simple graphs (not multi- or hypergraphs) are represented in a memory- and
time-efficient manner with adjacency lists and edge iterators. Both directed and
undirected graphs are supported via separate types, and conversion is available
from directed to undirected.

The project goal is to mirror the functionality of robust network and graph
analysis libraries such as [NetworkX](http://networkx.github.io) while being
simpler to use and more efficient than existing Julian graph libraries such as
[Graphs.jl](https://github.com/JuliaLang/Graphs.jl). It is an explicit design
decision that any data not required for graph manipulation (attributes and
other information, for example) is expected to be stored outside of the graph
structure itself. Such data lends itself to storage in more traditional and
better-optimized mechanisms.

Additional functionality may be found in the companion package [LightGraphsExtras.jl](https://github.com/JuliaGraphs/LightGraphsExtras.jl).

## Documentation
Full documentation is available at [GitHub Pages](https://juliagraphs.github.io/LightGraphs.jl/latest).
Documentation for methods is also available via the Julia REPL help system.
Additional tutorials can be found at [JuliaGraphsTutorials](https://github.com/JuliaGraphs/JuliaGraphsTutorials).

## Core Concepts
A graph *G* is described by a set of vertices *V* and edges *E*:
*G = {V, E}*. *V* is an integer range `1:n`; *E* is represented as forward
(and, for directed graphs, backward) adjacency lists indexed by vertices. Edges
may also be accessed via an iterator that yields `Edge` types containing
`(src<:Integer, dst<:Integer)` values. Both vertices and edges may be integers
of any type, and the smallest type that fits the data is recommended in order
to save memory.

*LightGraphs.jl* provides two graph types: `Graph` is an undirected graph, and
`DiGraph` is its directed counterpart.

Graphs are created using `Graph()` or `DiGraph()`; there are several options
(see the tutorials for examples).

Multiple edges between two given vertices are not allowed: an attempt to
add an edge that already exists in a graph will result in a silent failure.


## Installation
Installation is straightforward:
```julia-repl
julia> Pkg.add("LightGraphs")
```

## Current functionality
- **core functions:** vertices and edges addition and removal, degree (in/out/histogram), neighbors (in/out/all/common)

- **distance within graphs:** eccentricity, diameter, periphery, radius, center

- **distance between graphs:** spectral_distance, edit_distance

- **connectivity:** strongly- and weakly-connected components, bipartite checks, condensation, attracting components, neighborhood

- **operators:** complement, reverse, reverse!, union, join, intersect, difference,
symmetric difference, blkdiag, induced subgraphs, products (cartesian/scalar)

- **shortest paths:** Dijkstra, Dijkstra with predecessors, Bellman-Ford, Floyd-Warshall, A*

- **small graph generators:** see [smallgraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl/blob/master/src/generators/smallgraphs.jl) for list

- **random graph generators:** Erdős–Rényi, Watts-Strogatz, random regular, arbitrary degree sequence, stochastic block model

- **centrality:** betweenness, closeness, degree, pagerank, Katz

- **traversal operations:** cycle detection, BFS and DFS DAGs, BFS and DFS traversals with visitors, DFS topological sort, maximum adjacency / minimum cut, multiple random walks, diffusion

- **flow operations:** maximum flow

- **matching:** Matching functions have been moved to [LightGraphsExtras.jl](https://github.com/JuliaGraphs/LightGraphsExtras.jl).

- **clique enumeration:** maximal cliques

- **linear algebra / spectral graph theory:** adjacency matrix (works as input to [GraphLayout](https://github.com/IainNZ/GraphLayout.jl) and [Metis](https://github.com/JuliaSparse/Metis.jl)), Laplacian matrix, non-backtracking matrix

- **community:** modularity, community detection, core-periphery, clustering coefficients

- **persistence formats:** LightGraphs natively supports a proprietary compressed format. For other formats, please see the [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl) package.

- **visualization:** integration with
[GraphPlot](https://github.com/JuliaGraphs/GraphPlot.jl),
[Plots](https://github.com/JuliaPlots/Plots.jl) via [PlotRecipes](https://github.com/JuliaPlots/PlotRecipes.jl), [GraphLayout](https://github.com/IainNZ/GraphLayout.jl), [TikzGraphs](https://github.com/sisl/TikzGraphs.jl),  [NetworkViz](https://github.com/abhijithanilkumar/NetworkViz.jl/)


## Core API
These functions are defined as the public contract of the `LightGraphs.AbstractGraph` interface.

### Constructing and modifying the graph
- `Graph`
- `DiGraph`
- `add_edge!`
- `rem_edge!`
- `add_vertex!`, `add_vertices!`
- `rem_vertex!`
- `zero`

### Edge/Arc interface
- `src`
- `dst`
- `reverse`
- `==`
- Pair / Tuple conversion

### Accessing state
- `nv`
- `ne`
- `vertices` (Iterable)
- `edges` (Iterable)
- `neighbors`, `in_neighbors`, `out_neighbors`
- `has_vertex`
- `has_edge`
- `has_self_loops` (though this might be a trait or an abstract graph type)
- `is_directed` (implemented via traits)
- `eltype` (for edges and graphs)


### Non-Core APIs
These functions can be constructed from the Core API functions but can be given specialized implementations in order to improve performance.

- `adjacency_matrix`
- `degree`

This can be computed from neighbors by default `degree(g,v) = length(neighbors(g,v))` so you don't need to implement this unless your type can compute degree faster than this method.


## Supported Versions
* LightGraphs master is designed to work with the latest stable version of Julia.
* Julia 0.3: LightGraphs v0.3.7 is the last version guaranteed to work with Julia 0.3.
* Julia 0.4: LightGraphs versions in the 0.6 series are designed to work with Julia 0.4.
* Julia 0.5: LightGraphs versions in the 0.7 series are designed to work with Julia 0.5.
* Julia 0.6: LightGraphs versions in the 0.8, 0.9, and 0.10 series are designed to work with Julia 0.6.
* Later versions: Some functionality might not work with prerelease / unstable / nightly versions of Julia. If you run into a problem, please file an issue.

# Contributing and Reporting Bugs
We welcome contributions and bug reports! Please see [CONTRIBUTING.md](https://github.com/JuliaGraphs/LightGraphs.jl/blob/master/CONTRIBUTING.md)
for guidance on development and bug reporting.
