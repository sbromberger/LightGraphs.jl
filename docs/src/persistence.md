# Reading and writing Graphs

Graphs may be written to I/O streams and files using the `savegraph` function and read with the `loadgraph` function. The default graph format is a proprietary compressed *LightGraphs.jl* format `lg`. Other formats are available via the *GraphPersistence* package.

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

g = loadgraph("mygraph.gml",  :gml)

```
