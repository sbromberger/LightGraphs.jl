# Reading and writing Graphs

Graphs may be written to I/O streams and files using the `save` function and
read with the `load` function. Currently supported graph formats are the
 *LightGraphs.jl* format `lg` and the common formats `gml, graphml, gexf, dot, net`.

```@doc
save
load
```

## Examples

```julia
julia> save(STDOUT, g)
julia> save("mygraph.jgz", g, "mygraph"; compress=true)
julia> g = load("multiplegraphs.jgz")
julia> g = load("multiplegraphs.xml", :graphml)
julia> g = load("mygraph.gml", "mygraph", :gml)
```
