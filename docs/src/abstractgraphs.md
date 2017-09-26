```@index
Order = [:type, :function]
Pages   = ["abstractgraphs.md"]
```


# Abstract Graphs

We implement `AbstractGraph` type too! All Abstract graphs support:

### Constructing and modifying the graph
- `Graph`
- `DiGraph`
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

```@autodocs
Modules = [LightGraphs]
Order = [:type, :function]
Pages   = ["interface.jl", "core.jl", "graph.jl", "digraph.jl", "edgeiter.jl","connectivity.jl"]
Private = false
```
