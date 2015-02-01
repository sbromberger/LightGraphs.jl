# Centrality Measures

[Centrality measures](https://en.wikipedia.org/wiki/Centrality) describe the importance of a vertex to the rest of the graph using some set of criteria. Centrality measures implemented in *LightGraphs.jl* include the following:

###Degree Centrality
`degree_centrality(g[, normalize=true])`  
`indegree_centrality(g[, normalize=true])`  
`outdegree_centrality(g[, normalize=true)`  
Calculates the [degree centrality](https://en.wikipedia.org/wiki/Centrality#Degree_centrality) of the graph, with optional (default) normalization.

###Closeness Centrality
`closeness_centrality(g[, normalize=true])`  
Calculates the [closeness centrality](https://en.wikipedia.org/wiki/Centrality#Closeness_centrality) of the graph.

###Betweenness Centrality
`betweenness_centrality(g, [k=0, normalize=true, endpoints=false])`  
Calculates the [betweenness centrality](https://en.wikipedia.org/wiki/Centrality#Betweenness_centrality) of the graph, or, optionally, of a random subset of *k* vertices. Can optionally include endpoints in the calculations. Normalization is enabled by default.
