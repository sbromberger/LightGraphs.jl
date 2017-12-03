# Graph Types

In addition to providing a simplegraph implementation, LightGraphs also serves as a framework for other graph types. Currently, there are several alternative graph types, each with its own package:

- [SimpleWeightedGraphs](https://github.com/JuliaGraphs/SimpleGraphs.jl) provides a graph structure with the ability to specify weights on edges.
- [MetaGraphs](https://github.com/JuliaGraphs/MetaGraphs.jl) provides a graph structure that supports user-defined properties on the graph, vertices, and edges.
- [StaticGraphs](https://github.com/JuliaGraphs/StaticGraphs.jl) supports very large graph structures in a space- and time-efficient manner, but as the name implies, does not allow modification of the graph once
created.

### Which Graph Type Should I Use?

These are general guidelines to help you select the proper graph type.

- In general, prefer SimpleGraphs.
- If you need edge weights and don't require large numbers of graph modifications, use SimpleWeightedGraphs.
- If you need labeling of vertices or edges, use MetaGraphs.
- If you work with very large graphs (billons to tens of billions of edges) and don't
need mutability, use StaticGraphs.


