### Random Graphs
*LightGraphs.jl* implements two common random graph generators:

`erdos_renyi(n, p[, is_directed=false])`  
Creates an [Erdős–Rényi](http://en.wikipedia.org/wiki/Erdős–Rényi_model) random
graph with *n* vertices. Edges are added between pairs of vertices with probability
*p*. Undirected graphs are created by default; use `is_directed=true` to override.

Note also that Erdős–Rényi graphs may be generated quickly using the `Graph(nv, ne)`
constructor, which randomly includes *ne* edges from the set of vertices.


`watts_strogatz(n, k, β[, is_directed=false])`  
Creates a [Watts-Strogatz](https://en.wikipedia.org/wiki/Watts_and_Strogatz_model)
small model random graph with *n* vertices, each with degree *k*. Edges are randomized per the model based on probability *β*. Undirected graphs are created
by default; use `is_directed=true` to override.

### Static Graphs
*LightGraphs.jl* also implements a collection of classic graph generators:


`CompleteGraph(n)`  
`CompleteDiGraph(n)`  
Creates a complete graph with *n* vertices. A complete graph has edges connecting each pair of vertices.

`StarGraph(n)`  
`StarDiGraph(n)`  
Creates a star graph with *n* vertices. A star graph has a central vertex with edges to each other vertex.

`PathGraph(n)`  
`PathDiGraph(n)`  
Creates a path graph with *n* vertices. A path graph connects each successive vertex by a single edge.

`WheelGraph(n)`  
`WheelDiGraph(n)`  
Creates a wheel graph with *n* vertices. A wheel graph is a star graph with the outer vertices connected via a closed path graph.

The following graphs are undirected only:

`DiamondGraph()`  
A [diamond graph](http://en.wikipedia.org/wiki/Diamond_graph).

`BullGraph()`  
A [bull graph](https://en.wikipedia.org/wiki/Bull_graph).

`ChvatalGraph()`  
A [Chvátal graph](https://en.wikipedia.org/wiki/Chvátal_graph).

`CubicalGraph()`  
A [Platonic cubical graph](https://en.wikipedia.org/wiki/Platonic_graph).

`DesarguesGraph()`  
A [Desargues  graph](https://en.wikipedia.org/wiki/Desargues_graph).

`DodecahedralGraph()`  
A [Platonic dodecahedral  graph](https://en.wikipedia.org/wiki/Platonic_graph).

`FruchtGraph()`  
A [Frucht  graph](https://en.wikipedia.org/wiki/Frucht_graph).

`HeawoodGraph()`  
A [Heawood  graph](https://en.wikipedia.org/wiki/Heawood_graph).

`HouseGraph()`  
A graph mimicing the classic outline of a house.

`HouseXGraph()`  
A house graph, with two edges crossing the bottom square.

`IcosahedralGraph()`  
A [Platonic icosahedral  graph](https://en.wikipedia.org/wiki/Platonic_graph).

`KrackhardtKiteGraph()`  
A [Krackhardt-Kite social network graph](http://mathworld.wolfram.com/KrackhardtKite.html).

`MoebiusKantorGraph()`  
A [Möbius-Kantor  graph](http://en.wikipedia.org/wiki/Möbius–Kantor_graph).

`OctahedralGraph()`  
A [Platonic octahedral  graph](https://en.wikipedia.org/wiki/Platonic_graph).

`PappusGraph()`  
A [Pappus  graph](http://en.wikipedia.org/wiki/Pappus_graph).

`PetersenGraph()`  
A [Petersen  graph](http://en.wikipedia.org/wiki/Petersen_graph).

`SedgewickMazeGraph()`  
A simple maze graph used in Sedgewick's *Algorithms in C++: Graph Algorithms (3rd ed.)*

`TetrahedralGraph()`  
A [Platonic tetrahedral  graph](https://en.wikipedia.org/wiki/Platonic_graph).

`TruncatedCubeGraph()`  
A skeleton of the [truncated cube  graph](https://en.wikipedia.org/wiki/Truncated_cube).

`TruncatedTetrahedronGraph()`  
A skeleton of the [truncated tetrahedron  graph](https://en.wikipedia.org/wiki/Truncated_tetrahedron).

`TutteGraph()`  
A [Tutte  graph](https://en.wikipedia.org/wiki/Tutte_graph).
