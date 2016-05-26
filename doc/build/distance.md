
<a id='Distance-1'></a>

# Distance


*LightGraphs.jl* includes the following distance measurements:

<a id='LightGraphs.eccentricity' href='#LightGraphs.eccentricity'>#</a>
**`LightGraphs.eccentricity`** &mdash; *Function*.



Calculates the eccentricity[ies] of a vertex `v`, vertex vector `vs`, or the entire graph. An optional matrix of edge distances may be supplied.

The eccentricity of a vertex is the maximum shortest-path distance between it and all other vertices in the graph.

Because this function must calculate shortest paths for all vertices supplied in the argument list, it may take a long time.

The output is either a single float (when a single vertex is provided) or a vector of floats corresponding to the vertex vector. If no vertex vector is provided, the vector returned corresponds to each vertex in the graph.

Note: the eccentricity vector returned by `eccentricity()` may be used as input for the rest of the distance measures below. If an eccentricity vector is provided, it will be used. Otherwise, an eccentricity vector will be calculated for each call to the function. It may therefore be more efficient to calculate, store, and pass the eccentricities if multiple distance measures are desired.

<a id='LightGraphs.radius' href='#LightGraphs.radius'>#</a>
**`LightGraphs.radius`** &mdash; *Function*.



Returns the minimum eccentricity of the graph.

<a id='LightGraphs.diameter' href='#LightGraphs.diameter'>#</a>
**`LightGraphs.diameter`** &mdash; *Function*.



Returns the maximum eccentricity of the graph.

<a id='LightGraphs.center' href='#LightGraphs.center'>#</a>
**`LightGraphs.center`** &mdash; *Function*.



Returns the set of all vertices whose eccentricity is equal to the graph's radius (that is, the set of vertices with the smallest eccentricity).

<a id='LightGraphs.periphery' href='#LightGraphs.periphery'>#</a>
**`LightGraphs.periphery`** &mdash; *Function*.



Returns the set of all vertices whose eccentricity is equal to the graph's diameter (that is, the set of vertices with the largest eccentricity).

