```@index
Order = [:type, :function]
Pages   = ["simplegraphs.md"]
```

```@autodocs
Modules = [LightGraphs]
Order = [:type, :function]
Pages   = ["interface.jl", "core.jl", "graph.jl", "digraph.jl", "edgeiter.jl","connectivity.jl"]
Private = false
```


# Simple Graphs

*LightGraphs.jl* provides two concrete graph types (referred to as "simple graphs"):
`Graph` is an undirected graph, and `DiGraph` is its directed counterpart.

A graph *G* is described by a set of vertices *V* and edges *E*:
*G = {V, E}*. *V* is an integer range `1:n`; *E* is represented as forward
(and, for directed graphs, backward) adjacency lists indexed by vertices. Edges
may also be accessed via an iterator that yields `Edge` types containing
`(src<:Integer, dst<:Integer)` values. Both vertices and edges may be integers
of any type, and the smallest type that fits the data is recommended in order
to save memory.

Graphs are created using `Graph()` or `DiGraph()`; there are several options
(see the tutorials for examples).

Multiple edges between two given vertices are not allowed: an attempt to
add an edge that already exists in a graph will result in a silent failure.
