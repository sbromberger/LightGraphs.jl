
<a id='Generators-1'></a>

# Generators


<a id='Random-Graphs-1'></a>

## Random Graphs


*LightGraphs.jl* implements some common random graph generators:

<a id='LightGraphs.erdos_renyi' href='#LightGraphs.erdos_renyi'>#</a>
**`LightGraphs.erdos_renyi`** &mdash; *Function*.



```
erdos_renyi(n::Integer, p::Real; is_directed=false, seed=-1)
erdos_renyi(n::Integer, ne::Integer; is_directed=false, seed=-1)
```

Creates an [Erdős–Rényi](http://en.wikipedia.org/wiki/Erdős–Rényi_model) random graph with `n` vertices. Edges are added between pairs of vertices with probability `p`. Undirected graphs are created by default; use `is_directed=true` to override.

Note also that Erdős–Rényi graphs may be generated quickly using `erdos_renyi(n, ne)` or the  `Graph(nv, ne)` constructor, which randomly select `ne` edges among all the potential edges.

<a id='LightGraphs.watts_strogatz' href='#LightGraphs.watts_strogatz'>#</a>
**`LightGraphs.watts_strogatz`** &mdash; *Function*.



Creates a [Watts-Strogatz](https://en.wikipedia.org/wiki/Watts_and_Strogatz_model) small model random graph with `n` vertices, each with degree `k`. Edges are randomized per the model based on probability `β`. Undirected graphs are created by default; use `is_directed=true` to override.

<a id='LightGraphs.random_regular_graph' href='#LightGraphs.random_regular_graph'>#</a>
**`LightGraphs.random_regular_graph`** &mdash; *Function*.



```
random_regular_graph(n::Int, k::Int; seed=-1)
```

Creates a random undirected [regular graph](https://en.wikipedia.org/wiki/Regular_graph) with `n` vertices, each with degree `k`.

For undirected graphs, allocates an array of `nk` `Int`s, and takes approximately $nk^2$ time. For $k > n/2$, generates a graph of degree `n-k-1` and returns its complement.

<a id='LightGraphs.random_regular_digraph' href='#LightGraphs.random_regular_digraph'>#</a>
**`LightGraphs.random_regular_digraph`** &mdash; *Function*.



```
random_regular_digraph(n::Int, k::Int; dir::Symbol=:out, seed=-1)
```

Creates a random directed [regular graph](https://en.wikipedia.org/wiki/Regular_graph) with `n` vertices, each with degree `k`. The degree (in or out) can be specified using `dir=:in` or `dir=:out`. The default is `dir=:out`.

For directed graphs, allocates an $n \times n$ sparse matrix of boolean as an adjacency matrix and uses that to generate the directed graph.

<a id='LightGraphs.random_configuration_model' href='#LightGraphs.random_configuration_model'>#</a>
**`LightGraphs.random_configuration_model`** &mdash; *Function*.



```
random_configuration_model(n::Int, k::Array{Int}; seed=-1)
```

Creates a random undirected graph according to the [configuraton model](http://tuvalu.santafe.edu/~aaronc/courses/5352/fall2013/csci5352_2013_L11.pdf). It contains `n` vertices, the vertex `ì` having degree `k[i]`.

Defining `c = mean(k)`, it allocates an array of `nc` `Int`s, and takes approximately $nc^2$ time.

<a id='LightGraphs.stochastic_block_model' href='#LightGraphs.stochastic_block_model'>#</a>
**`LightGraphs.stochastic_block_model`** &mdash; *Function*.



```
stochastic_block_model(c::Matrix{Float64}, n::Vector{Int}; seed::Int = -1)
stochastic_block_model(cin::Float64, coff::Float64, n::Vector{Int}; seed::Int = -1)
```

Returns a Graph generated according to the Stochastic Block Model (SBM).

`c[a,b]` : Mean number of neighbors of a vertex in block `a` belonging to block `b`.            Only the upper triangular part is considered, since the lower traingular is            determined by $c[b,a] = c[a,b] * n[a]/n[b]$. `n[a]` : Number of vertices in block `a`

The second form samples from a SBM with `c[a,a]=cin`, and `c[a,b]=coff`.

For a dynamic version of the SBM see the `StochasticBlockModel` type and related functions.

<a id='LightGraphs.StochasticBlockModel' href='#LightGraphs.StochasticBlockModel'>#</a>
**`LightGraphs.StochasticBlockModel`** &mdash; *Type*.



```
type StochasticBlockModel{T<:Integer,P<:Real}
    n::T
    nodemap::Array{T}
    affinities::Matrix{P}
    rng::MersenneTwister
end
```

A type capturing the parameters of the SBM. Each vertex is assigned to a block and the probability of edge `(i,j)` depends only on the block labels of vertex `i` and vertex `j`.

The assignement is stored in nodemap and the block affinities a `k` by `k` matrix is stored in affinities.

`affinities[k,l]` is the probability of an edge between any vertex in block k and any vertex in block `l`.

We are generating the graphs by taking random `i,j in vertices(g)` and flipping a coin with probability `affinities[nodemap[i],nodemap[j]]`.

<a id='LightGraphs.make_edgestream' href='#LightGraphs.make_edgestream'>#</a>
**`LightGraphs.make_edgestream`** &mdash; *Function*.



```
make_edgestream(sbm::StochasticBlockModel)
```

Take an infinite sample from the sbm. Pass to `Graph(nvg, neg, edgestream)` to get a Graph object.


<a id='Static-Graphs-1'></a>

## Static Graphs


*LightGraphs.jl* also implements a collection of classic graph generators:

<a id='LightGraphs.CompleteGraph' href='#LightGraphs.CompleteGraph'>#</a>
**`LightGraphs.CompleteGraph`** &mdash; *Function*.



Creates a complete graph with `n` vertices. A complete graph has edges connecting each pair of vertices.

<a id='LightGraphs.CompleteBipartiteGraph' href='#LightGraphs.CompleteBipartiteGraph'>#</a>
**`LightGraphs.CompleteBipartiteGraph`** &mdash; *Function*.



Creates a complete bipartite graph with `n1+n2` vertices. It has edges connecting each pair of vertices in the two sets.

<a id='LightGraphs.CompleteDiGraph' href='#LightGraphs.CompleteDiGraph'>#</a>
**`LightGraphs.CompleteDiGraph`** &mdash; *Function*.



Creates a complete digraph with `n` vertices. A complete digraph has edges connecting each pair of vertices (both an ingoing and outgoing edge).

<a id='LightGraphs.StarGraph' href='#LightGraphs.StarGraph'>#</a>
**`LightGraphs.StarGraph`** &mdash; *Function*.



Creates a star graph with `n` vertices. A star graph has a central vertex with edges to each other vertex.

<a id='LightGraphs.StarDiGraph' href='#LightGraphs.StarDiGraph'>#</a>
**`LightGraphs.StarDiGraph`** &mdash; *Function*.



Creates a star digraph with `n` vertices. A star digraph has a central vertex with directed edges to every other vertex.

<a id='LightGraphs.PathGraph' href='#LightGraphs.PathGraph'>#</a>
**`LightGraphs.PathGraph`** &mdash; *Function*.



Creates a path graph with `n` vertices. A path graph connects each successive vertex by a single edge.

<a id='LightGraphs.PathDiGraph' href='#LightGraphs.PathDiGraph'>#</a>
**`LightGraphs.PathDiGraph`** &mdash; *Function*.



Creates a path digraph with `n` vertices. A path graph connects each successive vertex by a single directed edge.

<a id='LightGraphs.WheelGraph' href='#LightGraphs.WheelGraph'>#</a>
**`LightGraphs.WheelGraph`** &mdash; *Function*.



Creates a wheel graph with `n` vertices. A wheel graph is a star graph with the outer vertices connected via a closed path graph.

<a id='LightGraphs.WheelDiGraph' href='#LightGraphs.WheelDiGraph'>#</a>
**`LightGraphs.WheelDiGraph`** &mdash; *Function*.



Creates a wheel digraph with `n` vertices. A wheel graph is a star digraph with the outer vertices connected via a closed path graph.

<a id='LightGraphs.BinaryTree' href='#LightGraphs.BinaryTree'>#</a>
**`LightGraphs.BinaryTree`** &mdash; *Function*.



create a binary tree with k-levels vertices are numbered 1:2^levels-1

<a id='LightGraphs.DoubleBinaryTree' href='#LightGraphs.DoubleBinaryTree'>#</a>
**`LightGraphs.DoubleBinaryTree`** &mdash; *Function*.



create a double complete binary tree with k-levels used as an example for spectral clustering by Guattery and Miller 1998.

<a id='LightGraphs.RoachGraph' href='#LightGraphs.RoachGraph'>#</a>
**`LightGraphs.RoachGraph`** &mdash; *Function*.



The Roach Graph from Guattery and Miller 1998


<a id='Smallgraphs-1'></a>

## Smallgraphs


Many notorious graphs are available in the Datasets submodule:


```julia
using LightGraphs.Datasets
```

<a id='LightGraphs.Datasets.smallgraph' href='#LightGraphs.Datasets.smallgraph'>#</a>
**`LightGraphs.Datasets.smallgraph`** &mdash; *Function*.



```
smallgraph(s::Symbol)
smallgraph(s::AbstractString)
```

Creates a small graph of type `s`. Admissible values for `s` are:

`s`                       | graph type                                                                                             
:------------------------ | :------------------------------------------------------------------------------------------------------
:bull                     | A [bull graph](https://en.wikipedia.org/wiki/Bull_graph).                                              
:chvatal                  | A [Chvátal graph](https://en.wikipedia.org/wiki/Chvátal_graph).                                        
:cubical                  | A [Platonic cubical graph](https://en.wikipedia.org/wiki/Platonic_graph).                              
:desargues                | A [Desarguesgraph](https://en.wikipedia.org/wiki/Desargues_graph).                                     
:diamond                  | A [diamond graph](http://en.wikipedia.org/wiki/Diamond_graph).                                         
:dodecahedral             | A [Platonic dodecahedral  graph](https://en.wikipedia.org/wiki/Platonic_graph).                        
:frucht                   | A [Frucht graph](https://en.wikipedia.org/wiki/Frucht_graph).                                          
:heawood                  | A [Heawood graph](https://en.wikipedia.org/wiki/Heawood_graph).                                        
:house                    | A graph mimicing the classic outline of a house.                                                       
:housex                   | A house graph, with two edges crossing the bottom square.                                              
:icosahedral              | A [Platonic icosahedral   graph](https://en.wikipedia.org/wiki/Platonic_graph).                        
:krackhardtkite           | A [Krackhardt-Kite social network  graph](http://mathworld.wolfram.com/KrackhardtKite.html).           
:moebiuskantor            | A [Möbius-Kantor                                                                                       
:octahedral               | A [Platonic octahedral                                                                                 
:pappus                   | A [Pappus graph](http://en.wikipedia.org/wiki/Pappus_graph).                                           
:petersen                 | A [Petersen graph](http://en.wikipedia.org/wiki/Petersen_graph).                                       
:sedgewickmaze            | A simple maze graph used in Sedgewick's *Algorithms in C++: Graph  Algorithms (3rd ed.)*               
:tetrahedral              | A [Platonic tetrahedral  graph](https://en.wikipedia.org/wiki/Platonic_graph).                         
:truncatedcube            | A skeleton of the [truncated cube graph](https://en.wikipedia.org/wiki/Truncated_cube).                
:truncatedtetrahedron     | A skeleton of the [truncated tetrahedron  graph](https://en.wikipedia.org/wiki/Truncated_tetrahedron). 
:truncatedtetrahedron_dir | A skeleton of the [truncated tetrahedron digraph](https://en.wikipedia.org/wiki/Truncated_tetrahedron).
:tutte                    | A [Tutte graph](https://en.wikipedia.org/wiki/Tutte_graph).                                            

