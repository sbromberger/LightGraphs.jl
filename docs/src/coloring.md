# Coloring

*LightGraphs.jl* defines a structure and basic interface for coloring algorithms.
Since coloring is a hard problem in the general case, users can extend the behavior
and define their own function taking a graph as input and returning the `Coloring` structure.

```@index
Order = [:type, :function]
Pages = ["coloring.md"]
```

```@autodocs
Modules = [LightGraphs]
Pages   = [
    "traversals/greedy_color.jl",
]
```
