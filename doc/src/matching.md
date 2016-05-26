# Matching

## Bipartite Matching

*LightGraphs.jl* supports maximum weight maximal matching computation on bipartite graphs
through linear programming relaxation.  In fact, on bipartite graphs, the solution
of the linear problem is integer.

Installation of the `JuMP` package is required.

```@docs
maximum_weight_maximal_matching
```
