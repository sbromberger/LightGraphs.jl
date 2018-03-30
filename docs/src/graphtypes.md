# Graph Types

In addition to providing `SimpleGraph` and `SimpleDiGraph` implementations, LightGraphs also serves as a framework for other graph types. Currently, there are several alternative graph types, each with its own package:

- [SimpleWeightedGraphs](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl) provides a structure for (un)directed graphs with the ability to specify weights on edges.
- [MetaGraphs](https://github.com/JuliaGraphs/MetaGraphs.jl) provides a structure (un)directed graphs that supports user-defined properties on the graph, vertices, and edges.
- [StaticGraphs](https://github.com/JuliaGraphs/StaticGraphs.jl) supports very large graph structures in a space- and time-efficient manner, but as the name implies, does not allow modification of the graph once
created.

### Which Graph Type Should I Use?

These are general guidelines to help you select the proper graph type.

- In general, prefer the native `SimpleGraphs`/`SimpleDiGraphs` structures in [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl).
- If you need edge weights and don't require large numbers of graph modifications, use [SimpleWeightedGraphs](https://github.com/JuliaGraphss/SimpleWeightedGraphs.jl).
- If you need labeling of vertices or edges, use [MetaGraphs](https://github.com/JuliaGraphs/MetaGraphs.jl).
- If you work with very large graphs (billons to tens of billions of edges) and don't need mutability, use [StaticGraphs](https://github.com/JuliaGraphs/StaticGraphs.jl).
