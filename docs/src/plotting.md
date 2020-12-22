# Plotting Graphs

*LightGraphs.jl* integrates with several other Julia packages for plotting. Here are a few examples.

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

## [GraphRecipes.jl](https://github.com/JuliaPlots/GraphRecipes.jl)

GraphRecipes is a collection of recipes for visualizing graphs. Users specify a graph through an adjacency matrix, an adjacency list, or an AbstractGraph via LightGraphs.

```julia
julia> using GraphRecipes, Plots
julia> using LightGraphs

julia> g = wheel_graph(10)
julia> graphplot(g, curves=false)
```

![WheelGraph](https://user-images.githubusercontent.com/8610352/74631053-de196b80-51c0-11ea-8cba-ddbdc2c6312f.png)

Example of using GraphRecipes to plot a directed graph given an asymmetric adjacency matrix:
```julia
using GraphRecipes, Plots
g = [0 1 1;
     0 0 1;
     0 1 0]

graphplot(g, names=1:3, curvature_scalar=0.1)
```

![](https://user-images.githubusercontent.com/8610352/74631107-04d7a200-51c1-11ea-87c1-be9cbf1b02eb.png)

More examples of using GraphRecipes are here:
http://docs.juliaplots.org/latest/graphrecipes/examples/
