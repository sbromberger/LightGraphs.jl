#LightGraphs Types

*LightGraphs.jl* supports both the `AbstractGraph` type and two concrete simple graph types- - `SimpleGraph` for undirected graphs and `SimpleDiGraph` for directed graphs -- that are subtypes of `AbstractGraph`.

## Concrete Types

*LightGraphs.jl* provides two concrete graph types: `SimpleGraph` is an undirected graph, and `SimpleDiGraph` is its directed counterpart. Both of these types can be parameterized to specifying how vertices are identified (by default, `SimpleGraph` and `SimpleDiGraph` use the system default integer type, usually `Int64`).

A graph *G* is described by a set of vertices *V* and edges *E*: *G = {V, E}*. *V* is an integer range `1:n`; *E* is represented as forward (and, for directed graphs, backward) adjacency lists indexed by vertices. Edges may also be accessed via an iterator that yields `Edge` types containing `(src<:Integer, dst<:Integer)` values. Both vertices and edges may be integers of any type, and the smallest type that fits the data is recommended in order to save memory.

Graphs are created using `SimpleGraph()` or `SimpleDiGraph()`; there are several options (see the tutorials for examples).

Multiple edges between two given vertices are not allowed: an attempt to add an edge that already exists in a graph will not raise an error. This event can be detected using the return value of `add_edge!`.

Note that graphs in which the number of vertices equals or approaches the `typemax` of the underlying graph element (_e.g._, a `SimpleGraph{UInt8}` with 127 vertices) may encounter arithmetic overflow errors in some functions, which should be reported as bugs. To be safe, please ensure that your graph is sized with some spare capacity.

## AbstractGraph Type

*LightGraphs.jl* is structured around a few abstract types developers can base their types on. See [Developing Alternate Graph Types](@ref) for the minimal methods to implement.

```@index
Order = [:type]
Pages   = ["types.md"]
```

To encourage experimentation and development within the JuliaGraphs ecosystem, *LightGraphs.jl* defines the `AbstractGraph` type, which is used by libraries like [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl) (for graphs with associated meta-data) and [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl) (for weighted graphs). All types that are a subset of `AbstractGraph` must implement the following functions (most of which are described in more detail in [Accessing Graph Properties](@ref) and [Making and Modifying Graphs](@ref)):

```@index
Order = [:function]
Pages   = ["types.md"]
```

## Full Docs for AbstractGraph types and functions

```@autodocs
Modules = [LightGraphs]
Pages   = ["interface.jl"]
Private = false
```
