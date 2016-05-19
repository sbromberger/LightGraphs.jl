
<a id='Flow-and-Cut-1'></a>

# Flow and Cut


<a id='Flow-1'></a>

## Flow


*LightGraphs.jl* provides four algorithms for [maximum flow](https://en.wikipedia.org/wiki/Maximum_flow_problem) computation:


  * [Edmonds–Karp algorithm](https://en.wikipedia.org/wiki/Edmonds%E2%80%93Karp_algorithm)
  * [Dinic's algorithm](https://en.wikipedia.org/wiki/Dinic%27s_algorithm)
  * [Boykov-Kolmogorov algorithm](http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=1316848&tag=1)
  * [Push-relabel algorithm](https://en.wikipedia.org/wiki/Push%E2%80%93relabel_maximum_flow_algorithm)

<a id='LightGraphs.maximum_flow' href='#LightGraphs.maximum_flow'>#</a>
**`LightGraphs.maximum_flow`** &mdash; *Function*.



Generic maximum_flow function. Requires arguments:

  * flow_graph::DiGraph                   # the input graph
  * source::Int                           # the source vertex
  * target::Int                           # the target vertex
  * capacity_matrix::AbstractArray{T,2}   # edge flow capacities
  * algorithm::AbstractFlowAlgorithm      # keyword argument for algorithm

The function defaults to the Push-relabel algorithm. Alternatively, the algorithm to be used can also be specified through a keyword argument. A default capacity of 1 is assumed for each link if no capacity matrix is provided.

All algorithms return a tuple with 1) the maximum flow and 2) the flow matrix. For the Boykov-Kolmogorov algorithm, the associated mincut is returned as a third output.

**Usage Example:**

```julia

# Create a flow-graph and a capacity matrix
flow_graph = DiGraph(8)
flow_edges = [
    (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
    (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
    (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
]
capacity_matrix = zeros(Int, 8, 8)
for e in flow_edges
    u, v, f = e
    add_edge!(flow_graph, u, v)
    capacity_matrix[u,v] = f
end

# Run default maximum_flow without the capacity_matrix
f, F = maximum_flow(flow_graph, 1, 8)

# Run default maximum_flow with the capacity_matrix
f, F = maximum_flow(flow_graph, 1, 8)

# Run Endmonds-Karp algorithm
f, F = maximum_flow(flow_graph,1,8,capacity_matrix,algorithm=EdmondsKarpAlgorithm())

# Run Dinic's algorithm
f, F = maximum_flow(flow_graph,1,8,capacity_matrix,algorithm=DinicAlgorithm())

# Run Boykov-Kolmogorov algorithm
f, F, labels = maximum_flow(flow_graph,1,8,capacity_matrix,algorithm=BoykovKolmogorovAlgorithm())

```


<a id='Cut-1'></a>

## Cut


Stoer's simple minimum cut gets the minimum cut of an undirected graph.

<a id='LightGraphs.mincut' href='#LightGraphs.mincut'>#</a>
**`LightGraphs.mincut`** &mdash; *Function*.



Returns a tuple `(parity, bestcut)`, where `parity` is a vector of integer values that determines the partition in `g` (1 or 2) and `bestcut` is the weight of the cut that makes this partition. An optional `distmx` matrix may be specified; if omitted, edge distances are assumed to be 1.

