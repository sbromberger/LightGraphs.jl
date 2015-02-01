*LightGraphs.jl* includes the following distance measurements:

###Eccentricity

`eccentricity(g, v[, edge_dists])`  
`eccentricity(g[, vs, edge_dists])`  
Calculates the eccentricity[ies] of a vertex *v*, vertex vector *vs*, or the entire graph. An optional matrix of edge distances may be supplied.

The eccentricity of a vertex is the maximum shortest-path distance between it and all other vertices in the graph.

Because this function must calculate shortest paths for all vertices supplied in the argument list, it may take a long time.

The output is either a single float (when a single vertex is provided) or a vector of floats  corresponding to the vertex vector. If no vertex vector is provided, the vector returned corresponds to each vertex in the graph.

Note that the eccentricity vector returned by `eccentricity()` may be used as input for the rest of the distance measures below. If an eccentricity vector is provided, it will be used. Otherwise, an eccentricity vector will be calculated for each call to the function. It may therefore be more efficient to calculate, store, and pass the eccentricities if multiple distance measures are desired.



###Radius
`radius(ev)`  
`radius(g[, edge_dists])`  
Calculates the radius of a graph. The radius is defined as the minimum eccentricity of the graph.

###Diameter
`diameter(ev)`  
`diameter(g[, edge_dists])`  
Calculates the diameter of a graph. The diameter is defined as the maximum eccentricity of the graph.

###Center
`center(ev)`  
`center(g[, edge_dists])`  
Calculates the center of a graph. The center of a graph is the set of all vertices whose eccentricity is equal to the graph's radius (that is, the set of vertices with the smallest eccentricity).

###Periphery
`periphery(ev)`  
`periphery(g[, edge_dists])`  
Calculates the periphery of a graph. The periphery of a graph is the set of all vertices whose eccentricity is equal to the graph's diameter (that is, the set of vertices with the largest eccentricity).
