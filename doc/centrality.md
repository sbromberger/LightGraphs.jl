# Centrality Measures

[Centrality measures](https://en.wikipedia.org/wiki/Centrality) describe the
importance of a vertex to the rest of the graph using some set of criteria.
Centrality measures implemented in *LightGraphs.jl* include the following:

###Degree Centrality
`degree_centrality(g[, normalize=true])`  
`indegree_centrality(g[, normalize=true])`  
`outdegree_centrality(g[, normalize=true)`  
Calculates the [degree centrality](https://en.wikipedia.org/wiki/Centrality#Degree_centrality)
of the graph `g`, with optional (default) normalization.

###Closeness Centrality
`closeness_centrality(g[, normalize=true])`  
Calculates the [closeness centrality](https://en.wikipedia.org/wiki/Centrality#Closeness_centrality) of the graph `g`.

###Betweenness Centrality
`betweenness_centrality(g, [k=0, normalize=true, endpoints=false])`  
Calculates the [betweenness centrality](https://en.wikipedia.org/wiki/Centrality#Betweenness_centrality) of
the graph `g`, or, optionally, of a random subset of `k` vertices. Can
optionally include endpoints in the calculations. Normalization is enabled by
default.

###Katz Centrality
`katz_centrality(g)`  
Calculates the [Katz centrality](https://en.wikipedia.org/wiki/Katz_centrality)
of the graph `g`.

###PageRank
`pagerank(g[, α=0.85, n=100, ϵ=1.0e-6])`  
Calculates the [PageRank](https://en.wikipedia.org/wiki/PageRank) of the graph
`g`. Can optionally specify a different damping factor (`α`), number of
iterations (`n`), and convergence threshold (`ϵ`). If convergence is not
reached within `n` iterations, an error will be returned.
