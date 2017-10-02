# Light Graphs

The goal of *LightGraphs.jl* is to offer a performant platform for network and graph analysis in Julia. To this end, LightGraphs offers both (a) a set of simple, concrete graph implementations -- `Graph` (for undirected graphs) and `DiGraph` (for directed graphs), and (b) an API for the development of more sophisticated graph implementations under the `AbstractGraph` type.

As such, *LightGraphs.jl* is the central package of the JuliaGraphs ecosystem. Additional functionality like advanced IO and file formats, weighted graphs, property graphs, and optimization related functions can be found in the following packages:
  * [LightGraphsExtras.jl](https://github.com/JuliaGraphs/LightGraphsExtras.jl): extra functions for graph analysis.
  * [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl): graphs with associated meta-data.
  * [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl): weighted graphs.
  * [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl): tools for importing and exporting graph objects using common file types like edgelists, GraphML, Pajek NET, and more.

## Basic library examples

The *LightGraphs.jl* libraries includes numerous convenience functions for generating functions detailed in [Making and Modifying Graphs](@ref), such as `PathGraph`, which makes a simple undirected [path graph](https://en.wikipedia.org/wiki/Path_graph) of a given length. Once created, these graphs can be easily interrogated and modified.

```julia
julia> g = PathGraph(6)

# Number vertices
julia> nv(g)

# Number edges
julia> ne(g)

# Add an edge to make the path a loop
julia> add_edge!(g, 1, 6)
```

For an overview of basic functions for interacting with graphs, check out [Accessing Graph Properties](@ref) and [Making and Modifying Graphs](@ref).
