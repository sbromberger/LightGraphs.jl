### Core Concepts
A graph *G* is described by a set of vertices *V* and edges *E*:
*G = {V, E}*. *V* is an integer range `1:n`; *E* is stored as a set
of `Edge` types containing `(src::Int, dst::Int)` values. Edge
relationships are stored as forward and backward incidence vectors, indexed by
vertex.

Graphs are created using `Graph()` or `DiGraph()`; there are several options
(see below for examples).

Edges are added to a graph using `add_edge!(g, e)`. Instead of an edge type
integers may be passed denoting the source and destination vertices (e.g.,
`add_edge!(g, 1, 2)`).

Edges must be unique; an attempt to add an edge that already exists in the graph
will result in an error.

Edges may be removed using `rem_edge!(g, e)`. Alternately, integers may be passed
denoting the source and destination vertices (e.g., `rem_edge!(g, 1, 2)`). Note
that, particularly for very large graphs, edge removal is a (relatively)
expensive operation.

An attempt to remove an edge that does not exist in the graph will result in an
error.

Edge distances for most traversals may be passed in as a sparse or dense matrix
of `Float64` values, indexed by `[src,dst]` vertices. That is, `edge_dists[2,4] = 2.5`
assigns the distance `2.5` to the (directed) edge connecting vertex 2 and vertex 4.
Note that for undirected graphs, `edge_dists[4,2]` should also be set.

Edge distances for undefined edges are ignored, and edge distances cannot be zero: any unassigned values (for sparse matrices) or zero values (for sparse or dense matrices) in the edge distance matrix are assumed to be the default distance of 1.0.

*LightGraphs.jl* provides two graph types: `Graph` is an undirected graph, and `DiGraph` is its directed counterpart.

### Installation
Installation is straightforward:
```julia
julia> Pkg.install("LightGraphs")
```

*LightGraphs.jl* requires the following packages:

- [Compat](https://github.com/JuliaLang/Compat.jl)
- [GZip](https://github.com/JuliaLang/GZip.jl)
- [StatsBase](https://github.com/JuliaStats/StatsBase.jl)
- [DataStructures](https://github.com/JuliaLang/DataStructures.jl)
- [Docile](https://github.com/MichaelHatherly/Docile.jl)


### Usage Examples
(all examples apply equally to `DiGraph` unless otherwise noted):

```julia
# create an empty undirected graph
g = Graph()

# create a 10-node undirected graph with no edges
g = Graph(10)

# create a 10-node undirected graph with 30 randomly-selected edges
g = Graph(10,30)

# add an edge between vertices 4 and 5
add_edge!(g, 4, 5)

# remove an edge between vertices 9 and 10
rem_edge!(g, 9, 10)

# get the neighbors of vertex 4
neighbors(g, 4)

# show distances between vertex 4 and all other vertices
dijkstra_shortest_paths(g, 4).dists  

# as above, but with non-default edge distances
edge_dists = zeros(10,10)
edge_dists[4,5] = 2.5
edge_dists[5,4] = 2.5
dijkstra_shortest_paths(g, 4, edge_dists=edge_dists).dists

# graph I/O
g = readgraph("mygraph.jgz")
write(g,"mygraph.jgz")
```
