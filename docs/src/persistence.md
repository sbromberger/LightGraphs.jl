# Reading and writing Graphs

## Saving using *LightGraphs.jl* `lg` format.

Graphs may be written to I/O streams and files using the `savegraph` function and read with the `loadgraph` function. The default graph format is a bespoke compressed *LightGraphs.jl* format `lg`.

### Example

```julia
save(STDOUT, g)
save("mygraph.jgz", g, "mygraph", compress=true)

savegraph("mygraph.jgz", g, compress=true)

dg = load("multiplegraphs.jgz") # dictionary of graphs
```

## Reading and Writing using other formats using GraphIO

The [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl) library provides tools for importing and exporting graph objects using common file types like edgelists, GraphML, Pajek NET, and more.
