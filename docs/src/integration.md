# Integration with other packages

*LightGraphs.jl*'s integration with other Julia packages is designed to be straightforward. Here are a few examples.

## [Graphs.jl](http://github.com/JuliaLang/Graphs.jl)

Creating a Graphs.jl `simple_graph` is easy:

```julia
julia> s = simple_graph(nv(g), is_directed=LightGraphs.is_directed(g))
julia> for e in LightGraphs.edges(g)
           add_edge!(s,src(e), dst(e))
       end
```

## [Metis.jl](https://github.com/JuliaSparse/Metis.jl)

The Metis graph partitioning package can interface with *LightGraphs.jl*:

```julia
julia> using LightGraphs

julia> g = SimpleGraph(100,1000)
{100, 1000} undirected graph

julia> partGraphKway(g, 6)  # 6 partitions
```
