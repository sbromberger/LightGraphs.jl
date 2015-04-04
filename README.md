# LightGraphs

[![Build Status](https://travis-ci.org/JuliaGraphs/LightGraphs.jl.svg?branch=master)](https://travis-ci.org/JuliaGraphs/LightGraphs.jl)
[![Coverage Status](https://coveralls.io/repos/JuliaGraphs/LightGraphs.jl/badge.svg?branch=master)](https://coveralls.io/r/JuliaGraphs/LightGraphs.jl?branch=master)
[![LightGraphs](http://pkg.julialang.org/badges/LightGraphs_release.svg)](http://pkg.julialang.org/?pkg=LightGraphs&ver=release)
[![Documentation Status](https://readthedocs.org/projects/lightgraphsjl/badge/?version=latest)](https://readthedocs.org/projects/lightgraphsjl/?badge=latest)



An optimized graphs package.

Simple graphs (not multi- or hypergraphs, and no self loops) are represented in a memory- and time-efficient
manner with incidence lists and edge sets. Both directed and undirected graphs are supported via separate types, and conversion is available from directed to undirected.

The project goal is to mirror the functionality of robust network and graph
analysis libraries such as [NetworkX](http://networkx.github.io) while being simpler
to use and more efficient than existing Julian graph libraries such as
[Graphs.jl](https://github.com/JuliaLang/Graphs.jl). It is an explicit design
decision that any data not required for graph manipulation (attributes and other
information, for example) is expected to be stored outside of the graph
structure itself. Such data lends itself to storage in more traditional and
better-optimized mechanisms.

### Core Concepts
A graph *G* is described by a set of vertices *V* and edges *E*:
*G = {V, E}*. *V* is an integer range `1:n`; *E* is stored as a set
of `Edge` types containing `(src::Int, dst::Int)` values. Edge
relationships are stored as forward and backward incidence vectors, indexed by
vertex.

Edges must be unique; an attempt to add an edge that already exists in a graph
will result in an error.

Edge distances for most traversals may be passed in as a sparse or dense matrix
of `Float64` values, indexed by `[src,dst]` vertices. That is, `edge_dists[2,4] = 2.5`
assigns the distance `2.5` to the (directed) edge connecting vertex 2 and vertex 4.
Note that for undirected graphs, `edge_dists[4,2]` should also be set.

Edge distances for undefined edges are ignored, and edge distances cannot be zero: any unassigned values (for sparse matrices) or zero values (for sparse or dense matrices) in the edge distance matrix are assumed to be the default distance of 1.0.

### Basic Usage
(all examples apply equally to `DiGraph` unless otherwise noted):

```
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

### Current functionality
- core functions
    - degree (in/out/histogram)
    - neighbors (in/out/all/common)


- distance
    - eccentricity
    - diameter
    - periphery
    - radius
    - center


- operators
    - complement
    - reverse, reverse!
    - union
    - intersect
    - difference
    - symmetric difference
    - merge
    - induced subgraphs


- shortest path
    - Dijkstra / Dijkstra with predecessors
    - Bellman-Ford
    - Floyd-Warshall
    - A*


- small graph generators
    - see [smallgraphs.jl](https://github.com/sbromberger/LightGraphs.jl/blob/master/src/smallgraphs.jl) for list


- random graph generators
    - Erdős–Rényi
    - Watts-Strogatz


- centrality
    - betweenness
    - closeness
    - degree


- linear algebra
    - adjacency matrix (works as input to [GraphLayout](https://github.com/IainNZ/GraphLayout.jl) and [Metis](https://github.com/JuliaSparse/Metis.jl))
    - Laplacian matrix


- persistence (proprietary compressed format)

###Documentation
Full documentation available at [ReadTheDocs](http://lightgraphsjl.readthedocs.org).
