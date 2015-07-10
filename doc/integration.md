*LightGraphs.jl*'s integration with other Julia packages is designed to be straightforward. Here are a few examples.

### [Graphs.jl](http://github.com/JuliaLang/Graphs.jl)
Creating a Graphs.jl `simple_graph` is easy:
```julia
julia> s = simple_graph(nv(g), is_directed=LightGraphs.is_directed(g))
julia> for e in LightGraphs.edges(g)
           add_edge!(s,src(e), dst(e))
       end
```

###[GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl)
This excellent graph visualization package can be used with *LightGraphs.jl*
as follows:

```julia
julia> g = WheelGraph(10); am = full(adjacency_matrix(g))
julia> loc_x, loc_y = layout_spring_adj(am)
julia> draw_layout_adj(am, loc_x, loc_y, filename="wheel10.svg")
```
producing a graph like this:
![Wheel Graph](https://cloud.githubusercontent.com/assets/941359/5848475/b31c41f2-a18d-11e4-8a4d-fcd148335bc9.png)

###[Metis.jl](https://github.com/JuliaSparse/Metis.jl)
The Metis graph partitioning package can interface with *LightGraphs.jl*:

```julia
julia> g = Graph(100,1000)
{100, 1000} undirected graph

julia> partGraphKway(g, 6)  # 6 partitions
```
