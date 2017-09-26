```@index
Order = [:type, :function]
Pages   = ["index.md"]
```

# Light Graphs

LightGraphs offers both (a) a set of simple, concrete graph implementations -- `Graph`
(for undirected graphs) and `DiGraph` (for directed graphs), and (b) an API for
the development of more sophisticated graph implementations under the `AbstractGraph`
type.

The project goal is to mirror the functionality of robust network and graph
analysis libraries such as [NetworkX](http://networkx.github.io) while being
simpler to use and more efficient than existing Julian graph libraries such as
[Graphs.jl](https://github.com/JuliaLang/Graphs.jl). It is an explicit design
decision that any data not required for graph manipulation (attributes and
other information, for example) is expected to be stored outside of the graph
structure itself. Such data lends itself to storage in more traditional and
better-optimized mechanisms.

Additional functionality may be found in a number of companion packages, including:
  * [LightGraphsExtras.jl](https://github.com/JuliaGraphs/LightGraphsExtras.jl):
  extra functions for graph analysis.
  * [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl): graphs with
  associated meta-data.
  * [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl):
  weighted graphs.
  * [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl): tools for importing
  and exporting graph objects using common file types like edgelists, GraphML,
  Pajek NET, and more.  
