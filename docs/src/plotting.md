# Plotting Graphs

*LightGraphs.jl* integrates with several other Julia packages for plotting. Here are a few examples.

## [GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl)

This excellent graph visualization package can be used with *LightGraphs.jl*
as follows:

```julia
julia> g = wheel_graph(10); am = Matrix(adjacency_matrix(g))
julia> loc_x, loc_y = layout_spring_adj(am)
julia> draw_layout_adj(am, loc_x, loc_y, filename="wheel10.svg")
```

producing a graph like this:

![Wheel Graph](https://cloud.githubusercontent.com/assets/941359/8960521/35582c1e-35c5-11e5-82d7-cd641dff424c.png)

## [TikzGraphs.jl](https://github.com/sisl/TikzGraphs.jl)

Another nice graph visualization package. ([TikzPictures.jl](https://github.com/sisl/TikzPictures.jl)
required to render/save):

```julia
julia> g = wheel_graph(10); t = plot(g)

julia> save(SVG("wheel10.svg"), t)
```

producing a graph like this:

![Wheel Graph](https://cloud.githubusercontent.com/assets/941359/8960499/17f703c0-35c5-11e5-935e-044be51bc531.png)

## [GraphPlot.jl](https://github.com/afternone/GraphPlot.jl)

Another graph visualization package that is very simple to use.
[Compose.jl](https://github.com/dcjones/Compose.jl) is required for most rendering functionality:

```julia
julia> using GraphPlot, Compose

julia> g = wheel_graph(10)

julia> draw(PNG("/tmp/wheel10.png", 16cm, 16cm), gplot(g))
```


## [NetworkViz.jl](https://github.com/abhijithanilkumar/NetworkViz.jl)
NetworkViz.jl is tightly coupled with *LightGraphs.jl*. Graphs can be visualized in 2D as well as 3D using [ThreeJS.jl](https://github.com/rohitvarkey/ThreeJS.jl) and [Escher.jl](https://github.com/shashi/Escher.jl).

```julia
#Run this code in Escher

using NetworkViz
using LightGraphs

main(window) = begin
  push!(window.assets, "widgets")
  push!(window.assets,("ThreeJS","threejs"))
  g = complete_graph(10)
  drawGraph(g)
end
```

The above code produces the following output:

![alt tag](https://raw.githubusercontent.com/abhijithanilkumar/NetworkViz.jl/master/examples/networkviz.gif)
