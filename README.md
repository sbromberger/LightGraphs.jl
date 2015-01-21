# FastGraphs

[![Build Status](https://travis-ci.org/sbromberger/FastGraphs.jl.svg?branch=master)](https://travis-ci.org/sbromberger/FastGraphs.jl)

An optimized graphs package.

Simple graphs (no multi / hypergraphs; no self loops) are represented in a memory- and time-efficient
manner with incidence lists and edge sets. Vertices are represented as integer ranges.

Both directed and undirected graphs are supported.

The project goal is to mirror the functionality of robust network and graph
analysis libraries such as [NetworkX](http://networkx.github.io) while being simpler
to use and more efficient than existing Julian graph libraries such as
[Graphs.jl](https://github.com/JuliaLang/Graphs.jl).


Usage (all examples apply to `FastDiGraph` unless otherwise noted):

```
g = FastGraph()      # create an empty undirected graph
g = FastGraph(10)    # create a 10-node undirected graph with no edges
g = FastGraph(10,30) # create a 10-node undirected graph with 30 randomly-selected edges

add_edge!(g, 4, 5)   # add an edge between vertices 4 and 5

neighbors(g, 4)      # get the neighbors of vertex 4

dijkstra_shortest_paths(g, 2) # show distances between vertex 2 and all other vertices

g = readfastgraph("mygraph.jfz") # read a graph from file


```
Current functionality includes
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
    - dijkstra / dijkstra with predecessors
    - floyd-warshall
    - A*


- small graph generators
    - see [smallgraphs.jl](https://github.com/sbromberger/FastGraphs.jl/blob/master/src/smallgraphs.jl) for list


- centrality
    - betweenness
    - closeness
    - degree


- linear algebra
    - adjacency matrix
    - laplacian matrix


- persistence (proprietary compressed format)
