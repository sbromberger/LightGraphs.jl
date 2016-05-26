# Generators

## Random Graphs

*LightGraphs.jl* implements some common random graph generators:

```@docs
erdos_renyi
watts_strogatz
random_regular_graph
random_regular_digraph
random_configuration_model
stochastic_block_model
StochasticBlockModel
make_edgestream
```


## Static Graphs

*LightGraphs.jl* also implements a collection of classic graph generators:

```@docs
CompleteGraph
CompleteBipartiteGraph
CompleteDiGraph
StarGraph
StarDiGraph
PathGraph
PathDiGraph
WheelGraph
WheelDiGraph
BinaryTree
DoubleBinaryTree
RoachGraph
```

## Smallgraphs

Many notorious graphs are available in the Datasets submodule:

```julia
using LightGraphs.Datasets
```

```@docs
smallgraph
```
