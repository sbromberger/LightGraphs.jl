# LightGraphs

[![Build Status](https://travis-ci.org/JuliaGraphs/LightGraphs.jl.svg?branch=master)](https://travis-ci.org/JuliaGraphs/LightGraphs.jl)
[![codecov.io](http://codecov.io/github/JuliaGraphs/LightGraphs.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaGraphs/LightGraphs.jl?branch=master)
[![LightGraphs](http://pkg.julialang.org/badges/LightGraphs_0.4.svg)](http://pkg.julialang.org/?pkg=LightGraphs&ver=0.4)
[![Documentation Status](https://readthedocs.org/projects/lightgraphsjl/badge/?version=latest)](http://lightgraphsjl.readthedocs.org/en/latest/)
[![Join the chat at https://gitter.im/JuliaGraphs/LightGraphs.jl](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/JuliaGraphs/LightGraphs.jl)

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

## Core Concepts
A graph *G* is described by a set of vertices *V* and edges *E*:
*G = {V, E}*. *V* is an integer range `1:n`; *E* is represented as forward
(and, for directed graphs, backward) adjacency lists indexed by vertices. Edges
may also be accessed via an iterator that yields `Edge` types containing
`(src::Int, dst::Int)` values.

*LightGraphs.jl* provides two graph types: `Graph` is an undirected graph, and
`DiGraph` is its directed counterpart.

Graphs are created using `Graph()` or `DiGraph()`; there are several options
(see below for examples).

Edges are added to a graph using `add_edge!(g, e)`. Instead of an edge type
integers may be passed denoting the source and destination vertices (e.g.,
`add_edge!(g, 1, 2)`).

Multiple edges between two given vertices are not allowed: an attempt to
add an edge that already exists in a graph will result in a silent failure.

Edges may be removed using `rem_edge!(g, e)`. Alternately, integers may be passed
denoting the source and destination vertices (e.g., `rem_edge!(g, 1, 2)`). Note
that, particularly for very large graphs, edge removal is a (relatively)
expensive operation. An attempt to remove an edge that does not exist in the graph will result in an
error.

Use `nv(g)` and `ne(g)` to compute the number of vertices and edges respectively.

`rem_vertex!(g, v)` alters the vertex identifiers. In particular, calling `n=nv(g)`, it swaps `v` and `n` and then removes `n`.

`edges(g)` returns an iterator to the edge set. Use `collect(edge(set))` to fill
an array with all edges in the graph.

## Installation
Installation is straightforward:
```julia
julia> Pkg.add("LightGraphs")
```

## Usage Examples
(all examples apply equally to `DiGraph` unless otherwise noted):

```julia
# create an empty undirected graph
g = Graph()

# create a 10-node undirected graph with no edges
g = Graph(10)
@assert nv(g) == 10

# create a 10-node undirected graph with 30 randomly-selected edges
g = Graph(10,30)

# add an edge between vertices 4 and 5
add_edge!(g, 4, 5)

# remove an edge between vertices 9 and 10
rem_edge!(g, 9, 10)

# create vertex 11
add_vertex!(g)

# remove vertex 2
# attention: this changes the id of vertex nv(g) to 2
rem_vertex!(g, 2)

# get the neighbors of vertex 4
neighbors(g, 4)

# iterate over the edges
m = 0
for e in edges(g)
    m += 1
end
@assert m == ne(g)

# show distances between vertex 4 and all other vertices
dijkstra_shortest_paths(g, 4).dists

# as above, but with non-default edge distances
distmx = zeros(10,10)
distmx[4,5] = 2.5
distmx[5,4] = 2.5
dijkstra_shortest_paths(g, 4, distmx=distmx).dists

# graph I/O
g = load("mygraph.jgz", "mygraph")
save("mygraph.jgz", g, "mygraph", compress=true)
```

## Current functionality
- **core functions:** vertices and edges addition and removal, degree (in/out/histogram), neighbors (in/out/all/common)

- **distance:** eccentricity, diameter, periphery, radius, center

- **connectivity:** strongly- and weakly-connected components, bipartite checks, condensation, attracting components, neighborhood

- **operators:** complement, reverse, reverse!, union, join, intersect, difference,
symmetric difference, blkdiag, induced subgraphs, products (cartesian/scalar)

- **shortest paths:** Dijkstra, Dijkstra with predecessors, Bellman-Ford, Floyd-Warshall, A*

- **small graph generators:** see [smallgraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl/blob/master/src/datasets/smallgraphs.jl) for list

- **random graph generators:** Erdős–Rényi, Watts-Strogatz, random regular, arbitrary degree sequence, stochastic block model

- **centrality:** betweenness, closeness, degree, pagerank, Katz

- **traversal operations:** cycle detection, BFS and DFS DAGs, BFS and DFS traversals with visitors, DFS topological sort, maximum adjacency / minimum cut, multiple random walks

- **flow operations:** maximum flow

- **matching:** bipartite maximum matching

- **clique enumeration:** maximal cliques

- **linear algebra / spectral graph theory:** adjacency matrix (works as input to [GraphLayout](https://github.com/IainNZ/GraphLayout.jl) and [Metis](https://github.com/JuliaSparse/Metis.jl)), Laplacian matrix, non-backtracking matrix, integration with [GraphMatrices](https://github.com/jpfairbanks/GraphMatrices.jl)

- **community:** modularity, community detection, core-periphery, clustering coefficients

- **persistence formats:** proprietary compressed, [GraphML](http://en.wikipedia.org/wiki/GraphML), [GML](https://en.wikipedia.org/wiki/Graph_Modelling_Language), [Gexf](http://gexf.net/format), [DOT](https://en.wikipedia.org/wiki/DOT_(graph_description_language)), [Pajek NET](http://gephi.org/users/supported-graph-formats/pajek-net-format/)

- **visualization:** integration with [GraphLayout](https://github.com/IainNZ/GraphLayout.jl), [TikzGraphs](https://github.com/sisl/TikzGraphs.jl), [GraphPlot](https://github.com/afternone/GraphPlot.jl), [NetworkViz](https://github.com/abhijithanilkumar/NetworkViz.jl/)


## Documentation
Full documentation available at [ReadTheDocs](http://lightgraphsjl.readthedocs.org).
Documentation for methods is also available via the Julia REPL help system.


## Supported Versions
* Julia 0.3: LightGraphs v0.3.7 is the last version guaranteed to work with Julia 0.3.
* Julia 0.4: LightGraphs master is designed to work with the latest stable version of Julia (currently 0.4.x).
* Julia 0.5: Some functionality might not work with prerelease / unstable / nightly versions of Julia. If you run into a problem on 0.5, please file an issue.

# Contributing

We welcome all possible contributors and ask that you read these guidelines before starting to work on this project. Following these guidelines will reduce friction and improve the speed at which your code gets merged.

## Bug reports
If you notice code that is incorrect/crashes/too slow please file a bug report. The report should be raised as a github issue with a minimal working example that reproduces the error message. The example should include any data needed. If the problem is incorrectness, then please post the correct result along with an incorrect result.

Please include version numbers of all relevant libraries and Julia itself.

## Development guidelines.

- PRs should contain one logical enhancement to the codebase.
- Squash commits in a PR.
- Open an issue to discuss a feature before you start coding (this maximizes the likelihood of patch acceptance).
- Minimize dependencies on external packages. In general,
    - dependencies on core Julia packages (things under [JuliaLang](https://github.org/JuliaLang)) are ok.
    - dependencies on non-core "leaf" packages (no subdependencies except for core Julia packages) are less ok.
    - dependencies on non-core non-leaf packages require strict scrutiny and will likely not be accepted without some compelling reason (urgent bugfix or much-needed functionality).
- Put type assertions on all function arguments (use abstract types, Union, or Any if necessary).
- If the algorithm was presented in a paper, include a reference to the paper (i.e. a proper academic citation along with an eprint link).
- Take steps to ensure that code works on graphs with multiple connected components efficiently.
- Correctness is a necessary requirement; efficiency is desirable. Once you have a correct implementation, make a PR so we can help improve performance.
- We can accept code that does not work for directed graphs as long as it comes with an explanation of what it would take to make it work for directed graphs.
- Style point: prefer the short circuiting conditional over if/else when convenient ex. `condition && error("message")`
- When possible write code to reuse memory. For example:
```julia
function f(g, v)
    storage = Vector{Int}(nv(g))
    # some code operating on storage, g, and v.
    for i in 1:nv(g)
        storage[i] = v-i
    end
    return sum(storage)
end
```
should be rewritten as two functions
```julia
function f(g::SimpleGraph, v::Integer)
    storage = Vector{Int}(nv(g))
    return inner!(storage, g, v)
end

function inner!(storage::AbstractArray{Int,1}, g::SimpleGraph, v::Integer)
    # some code operating on storage, g, and v.
    for i in 1:nv(g)
        storage[i] = v-i
    end
    return sum(storage)
end
```
This allows us to reuse the memory and improve performance.
