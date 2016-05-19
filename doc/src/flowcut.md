# Flow and Cut

## Flow

*LightGraphs.jl* provides four algorithms for [maximum flow](https://en.wikipedia.org/wiki/Maximum_flow_problem)
computation:

- [Edmonds–Karp algorithm](https://en.wikipedia.org/wiki/Edmonds%E2%80%93Karp_algorithm)
- [Dinic's algorithm](https://en.wikipedia.org/wiki/Dinic%27s_algorithm)
- [Boykov-Kolmogorov algorithm](http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=1316848&tag=1)
- [Push-relabel algorithm](https://en.wikipedia.org/wiki/Push%E2%80%93relabel_maximum_flow_algorithm)

```@docs
maximum_flow
```

## Cut

Stoer's simple minimum cut gets the minimum cut of an undirected graph.

```@docs
mincut
```
