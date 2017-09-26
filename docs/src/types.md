#LightGraph Types

The LightGraph library supports both the `AbstractGraph` type and two concrete simple graph types- - `Graph` for undirected graphs and `DiGraph` for directed graphs -- that are subtypes of `AbstractGraph`.

## SimpleGraph Types

*LightGraphs.jl* provides two concrete graph types (referred to as "simple graphs"): `Graph` is an undirected graph, and `DiGraph` is its directed counterpart. Both of these types can be parameterized to specifying how vertices are identified (by default, `Graph` and `DiGraph` use the system default integer type, usually `Int64`).

A graph *G* is described by a set of vertices *V* and edges *E*: *G = {V, E}*. *V* is an integer range `1:n`; *E* is represented as forward (and, for directed graphs, backward) adjacency lists indexed by vertices. Edges may also be accessed via an iterator that yields `Edge` types containing `(src<:Integer, dst<:Integer)` values. Both vertices and edges may be integers of any type, and the smallest type that fits the data is recommended in order to save memory.

Graphs are created using `Graph()` or `DiGraph()`; there are several options (see the tutorials for examples).

Multiple edges between two given vertices are not allowed: an attempt to add an edge that already exists in a graph will result in a silent failure.


## AbstractGraph Type

To facilitate the development of other concrete graph types, *LightGraphs.jl* implements the `AbstractGraph` type, which is used by libraries like [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl) (for graphs with associated meta-data) and [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl) (for weighted graphs). All types that are a subset of `AbstractGraph` must implement the following functions (most of which are described in more detail in [Accessing Graph Properties](@ref) and [Making and Modifying Graphs](@ref)):

### Constructing and modifying the graph
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
