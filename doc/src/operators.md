# Operators

*LightGraphs.jl* implements the following graph operators. In general,
functions with two graph arguments will require them to be of the same type
(either both `Graph` or both `DiGraph`).

```@docs
complement
reverse
reverse!
blkdiag
union
intersect
difference
symmetric_difference
induced_subgraph
join
tensor_product
cartesian_product
crosspath
```
