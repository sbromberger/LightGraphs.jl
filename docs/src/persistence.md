# Reading and writing Graphs

Graphs may be written to I/O streams and files using the `save` function and
read with the `load` function. Currently supported graph formats are the
 *LightGraphs.jl* format `lg` and the common formats `gml, graphml, gexf, dot, net`.

```@autodocs
Modules = [LightGraphs]
Pages   = [ "persistence/common.jl"]
Private = false
```

## Examples

```julia
save(STDOUT, g)
save("mygraph.jgz", g, "mygraph", compress=true)

savegraph("mygraph.jgz", g, compress=true)

dg = load("multiplegraphs.jgz") # dictionary of graphs
dg = load("multiplegraphs.graphml", :graphml)
dg = load("mygraph.gml", "mygraph", :gml)

g = laoadgraph("mygraph.gml",  :gml)

```
