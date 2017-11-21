# Reading and writing Graphs

## Saving using *LightGraphs.jl* `lg` format.

Graphs may be written to I/O streams and files using the `savegraph` function and read with the `loadgraph` function. The default graph format is a bespoke compressed *LightGraphs.jl* format `LG`.

### Example

```julia

g = erdos_renyi(5, 0.2)

savegraph("mygraph.lgz", g)
reloaded_g = loadgraph("mygraph.lgz")
```

In addition, graphs can also be saved in an uncompressed format using the `compress=false` option.

```julia

savegraph("mygraph.lg", g, compress=false)

reloaded_g = loadgraph("mygraph.lg")
```

Finally, dictionaries of graphs can also be saved and subsequently re-loaded one by one.

```julia
graph_dict = {"g1" => erdos_renyi(5, 0.1),
              "g2" => erdos_renyi(10, 0.2),
              "g3" => erdos_renyi(2, 0.9)}

savegraph("mygraph_dict.lg", graph_dict)

# Re-load only graph g1
reloaded_g1 = loadgraph("mygraph_dict.lg", "g1")
```

## Reading and Writing using other formats using GraphIO

The [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl) library provides tools for importing and exporting graph objects using common file types like edgelists, GraphML, Pajek NET, and more.
