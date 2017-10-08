# Making and Modifying Graphs

*LightGraphs.jl* provides a number of methods for creating a graph object,
including tools for building and modifying graph objects, a wide array of graph
generator functions, and the ability to read and write graphs from files
(using [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl)).


## Modifying graphs

*LightGraphs.jl* offers a range of tools for modifying graphs, including:

```@docs
Graph
DiGraph
add_edge!
rem_edge!
add_vertex!
add_vertices!
rem_vertex!
zero
```

In addition to these core functions, more advanced operators can be found in [Operators](@ref).

## Graph Generators

*LightGraphs.jl* implements numerous graph generators, including random graph generators, constructors for classic graphs, numerous small graphs with familiar topologies, and random and static graphs embedded in Euclidean space.

```@index
Modules = [LightGraphs]
Pages   = ["generators.md"]
```

## Datasets

Other notorious graphs and integration with the `MatrixDepot.jl` package are available in the `Datasets` submodule of the companion packages [LightGraphsExtras.jl](https://github.com/JuliaGraphs/LightGraphsExtras.jl) and [SNAPDatasets.jl](https://github.com/JuliaGraphs/SNAPDatasets.jl).

### All Generators

```@autodocs
Modules = [LightGraphs]
Pages   = [
    "generators/randgraphs.jl",
    "generators/staticgraphs.jl",
    "generators/smallgraphs.jl",
    "generators/euclideangraphs.jl"]
Private = false
```
