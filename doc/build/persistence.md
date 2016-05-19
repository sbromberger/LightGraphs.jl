
<a id='Reading-and-writing-Graphs-1'></a>

# Reading and writing Graphs


Graphs may be written to I/O streams and files using the `save` function and read with the `load` function. Currently supported graph formats are the  *LightGraphs.jl* format `lg` and the common formats `gml, graphml, gexf, dot, net`.

<a id='LightGraphs.save' href='#LightGraphs.save'>#</a>
**`LightGraphs.save`** &mdash; *Function*.



```
save(file, g, t=:lg)
save(file, g, name, t=:lg)
save(file, dict, t=:lg)
```

Saves a graph `g` with name `name` to `file` in the format `t`. If `name` is not given the default names "graph" and "digraph" will be used.

Currently supported formats are `:lg, :gml, :graphml, :gexf, :dot, :net`.

For some graph formats, multiple graphs in a  `dict` `"name"=>g` can be saved in the same file.

Returns the number of graphs written.

<a id='LightGraphs.load' href='#LightGraphs.load'>#</a>
**`LightGraphs.load`** &mdash; *Function*.



```
load(file, name, t=:lg)
```

Loads a graph with name `name` from `file` in format `t`.

Currently supported formats are `:lg, :gml, :graphml, :gexf, :dot, :net`.

```
load(file, t=:lg)
```

Loads multiple graphs from  `file` in the format `t`. Returns a dictionary mapping graph name to graph.

For unnamed graphs the default names "graph" and "digraph" will be used.


<a id='Examples-1'></a>

## Examples


```julia
julia> save(STDOUT, g)
julia> save("mygraph.jgz", g, "mygraph"; compress=true)
julia> g = load("multiplegraphs.jgz")
julia> g = load("multiplegraphs.xml", :graphml)
julia> g = load("mygraph.gml", "mygraph", :gml)
```

