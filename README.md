# FastGraphs

[![Build Status](https://travis-ci.org/sbromberger/FastGraphs.jl.svg?branch=master)](https://travis-ci.org/sbromberger/FastGraphs.jl)

An optimized graphs package.

Simple graphs (not multi- or hypergraphs, and no self loops) are represented in a memory- and time-efficient
manner with incidence lists and edge sets. Vertices are represented as integer ranges.

Both directed and undirected graphs are supported.

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
of `Edge` types containing `(src::Int, dst::Int, dist::Float64)` values. Edge
relationships are stored as forward and backward incidence vectors, indexed by
vertex.

Edges must be unique; an attempt to add an edge that already exists in a graph
will result in an error.

### Usage
(all examples apply equally to `FastDiGraph` unless otherwise noted):

```
# create an empty undirected graph
g = FastGraph()

# create a 10-node undirected graph with no edges
g = FastGraph(10)

# create a 10-node undirected graph with 30 randomly-selected edges using default distances
g = FastGraph(10,30)

# add an edge between vertices 4 and 5 with a default distance of 1.0
add_edge!(g, 4, 5)

# get the neighbors of vertex 4
neighbors(g, 4)

# show distances between vertex 2 and all other vertices
dijkstra_shortest_paths(g, 2).dists  

# graph I/O
g = readfastgraph("mygraph.jfz")
write(g,"mygraph.jfz")
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
    - symmetric_difference
    - compose


- shortest path
    - Dijkstra / Dijkstra with predecessors
    - Bellman-Ford
    - Floyd-Warshall
    - A*


- small graph generators
    - see [smallgraphs.jl](https://github.com/sbromberger/FastGraphs.jl/blob/master/src/smallgraphs.jl) for list


- centrality
    - betweenness
    - closeness
    - degree


- linear algebra
    - adjacency matrix
    - Laplacian matrix


- persistence (proprietary compressed format)
