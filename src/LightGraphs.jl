module LightGraphs

using SimpleTraits

### Remove the following line once #915 is closed
using ArnoldiMethod
using Statistics: mean

using Inflate: InflateGzipStream
using DataStructures: IntDisjointSets, PriorityQueue, dequeue!, dequeue_pair!, enqueue!, heappop!, heappush!, in_same_set, peek, union!, find_root
using LinearAlgebra: I, Symmetric, diagm, eigen, eigvals, norm, rmul!, tril, triu
import LinearAlgebra: Diagonal, issymmetric, mul!
using Random: AbstractRNG, GLOBAL_RNG, MersenneTwister, randperm, randsubseq!, seed!, shuffle, shuffle!
using SparseArrays: SparseMatrixCSC, nonzeros, nzrange, rowvals
import SparseArrays: blockdiag, sparse

import Base: adjoint, write, ==, <, *, ≈, convert, isless, issubset, union, intersect,
            reverse, reverse!, isassigned, getindex, setindex!, show,
            print, copy, in, sum, size, eltype, length, ndims, transpose,
            join, iterate, eltype, get, Pair, Tuple, zero

export
# Interface
AbstractGraph, AbstractEdge, AbstractEdgeIter,
Edge, Graph, SimpleGraph, SimpleGraphFromIterator, DiGraph, SimpleDiGraphFromIterator,
SimpleDiGraph, vertices, edges, edgetype, nv, ne, src, dst,
is_directed, IsDirected,
has_vertex, has_edge, inneighbors, outneighbors,

# core
is_ordered, add_vertices!, indegree, outdegree, degree,
Δout, Δin, δout, δin, Δ, δ, degree_histogram,
neighbors, all_neighbors, common_neighbors,
has_self_loops, num_self_loops, density, squash, weights,

# simplegraphs
add_edge!, add_vertex!, add_vertices!, rem_edge!, rem_vertex!, rem_vertices!,

# decomposition
core_number, k_core, k_shell, k_crust, k_corona,

# distance
eccentricity, diameter, periphery, radius, center,

# distance between graphs
spectral_distance, edit_distance,

# edit path cost functions
MinkowskiCost, BoundedMinkowskiCost,

# operators
complement, reverse, reverse!, blockdiag, union, intersect,
difference, symmetric_difference,
join, tensor_product, cartesian_product, crosspath,
induced_subgraph, egonet, merge_vertices!, merge_vertices,

# bfs
gdistances, gdistances!, bfs_tree, bfs_parents, has_path,

# bipartition
is_bipartite, bipartite_map,

# dfs
is_cyclic, topological_sort_by_dfs, dfs_tree, dfs_parents,

# random
randomwalk, self_avoiding_walk, non_backtracking_randomwalk,

# diffusion
diffusion, diffusion_rate,

# coloring
greedy_color,

# connectivity
connected_components, strongly_connected_components, strongly_connected_components_kosaraju, weakly_connected_components,
is_connected, is_strongly_connected, is_weakly_connected, period,
condensation, attracting_components, neighborhood, neighborhood_dists,
isgraphical,

# cycles
simplecycles_hawick_james, maxsimplecycles, simplecycles, simplecycles_iter,
simplecyclescount, simplecycleslength, karp_minimum_cycle_mean, cycle_basis,
simplecycles_limited_length,

# maximum_adjacency_visit
mincut, maximum_adjacency_visit,

# a-star, dijkstra, bellman-ford, floyd-warshall, desopo-pape, spfa
a_star, dijkstra_shortest_paths, bellman_ford_shortest_paths,
spfa_shortest_paths,has_negative_edge_cycle_spfa,has_negative_edge_cycle, enumerate_paths,
johnson_shortest_paths, floyd_warshall_shortest_paths, transitiveclosure!, transitiveclosure, transitivereduction,
yen_k_shortest_paths, desopo_pape_shortest_paths,

# centrality
betweenness_centrality, closeness_centrality, degree_centrality,
indegree_centrality, outdegree_centrality, katz_centrality, pagerank,
eigenvector_centrality, stress_centrality, radiality_centrality,

# spectral
adjacency_matrix, laplacian_matrix, adjacency_spectrum, laplacian_spectrum,
non_backtracking_matrix, incidence_matrix, Nonbacktracking,
contract,

# persistence
loadgraph, loadgraphs, savegraph, LGFormat,

# randgraphs
erdos_renyi, expected_degree_graph, watts_strogatz, random_regular_graph, random_regular_digraph,
random_configuration_model, random_tournament_digraph, StochasticBlockModel, make_edgestream,
nearbipartiteSBM, blockcounts, blockfractions, stochastic_block_model, barabasi_albert,
barabasi_albert!, static_fitness_model, static_scale_free, kronecker, dorogovtsev_mendes, random_orientation_dag,

#community
modularity, core_periphery_deg,
local_clustering,local_clustering_coefficient, global_clustering_coefficient, triangles,
label_propagation, maximal_cliques, clique_percolation,

#generators
complete_graph, star_graph, path_graph, wheel_graph, cycle_graph,
complete_bipartite_graph, complete_multipartite_graph, turan_graph,
complete_digraph, star_digraph, path_digraph, grid, wheel_digraph, cycle_digraph,
binary_tree, double_binary_tree, roach_graph, clique_graph, ladder_graph,
circular_ladder_graph, barbell_graph, lollipop_graph,

#generator deprecations
BullGraph, ChvatalGraph, CubicalGraph, DesarguesGraph, DiamondGraph,
DodecahedralGraph, FruchtGraph, HeawoodGraph, HouseGraph, HouseXGraph,
IcosahedralGraph, KarateGraph, KrackhardtKiteGraph, MoebiusKantorGraph,
OctahedralGraph, PappusGraph, PetersenGraph, SedgewickMazeGraph, TetrahedralGraph,
TruncatedCubeGraph, TruncatedTetrahedronGraph, TruncatedTetrahedronDiGraph,
TutteGraph, CompleteGraph, CompleteBipartiteGraph, CompleteMultipartiteGraph,
TuranGraph, CompleteDiGraph, StarGraph, StarDigraph, PathGraph, PathDiGraph,
CycleGraph, CycleDiGraph, WheelGraph, WheelDiGraph, Grid, BinaryTree,
Doublebinary_tree, RoachGraph, CliqueGraph, LadderGraph, Circularladder_graph,
BarbellGraph, LollipopGraph,

#smallgraphs
smallgraph,

# Euclidean graphs
euclidean_graph,

#minimum_spanning_trees
boruvka_mst, kruskal_mst, prim_mst,

#steinertree
steiner_tree,

#biconnectivity and articulation points
articulation, biconnected_components, bridges,

#graphcut
normalized_cut, karger_min_cut, karger_cut_cost, karger_cut_edges,

#dominatingset
dominating_set,

#independentset
independent_set,

#vertexcover
vertex_cover

"""
    LightGraphs

An optimized graphs package.

Simple graphs (not multi- or hypergraphs) are represented in a memory- and
time-efficient manner with adjacency lists and edge sets. Both directed and
undirected graphs are supported via separate types, and conversion is available
from directed to undirected.

The project goal is to mirror the functionality of robust network and graph
analysis libraries such as NetworkX while being simpler to use and more
efficient than existing Julian graph libraries such as Graphs.jl. It is an
explicit design decision that any data not required for graph manipulation
(attributes and other information, for example) is expected to be stored
outside of the graph structure itself. Such data lends itself to storage in
more traditional and better-optimized mechanisms.

[Full documentation](http://codecov.io/github/JuliaGraphs/LightGraphs.jl) is available,
and tutorials are available at the
[JuliaGraphsTutorials repository](https://github.com/JuliaGraphs/JuliaGraphsTutorials).
"""
LightGraphs
include("interface.jl")
include("utils.jl")
include("deprecations.jl")
include("core.jl")

include("SimpleGraphs/SimpleGraphs.jl")
using .SimpleGraphs
"""
    Graph

A datastruture representing an undirected graph.
"""
const Graph = LightGraphs.SimpleGraphs.SimpleGraph
"""
    DiGraph

A datastruture representing a directed graph.
"""
const DiGraph = LightGraphs.SimpleGraphs.SimpleDiGraph
"""
    Edge

A datastruture representing an edge between two vertices in
a `Graph` or `DiGraph`.
"""
const Edge = LightGraphs.SimpleGraphs.SimpleEdge

include("degeneracy.jl")
include("digraph/transitivity.jl")
include("cycles/johnson.jl")
include("cycles/hawick-james.jl")
include("cycles/karp.jl")
include("cycles/basis.jl")
include("cycles/limited_length.jl")
include("Traversals/Traversals.jl")
include("traversals/bfs.jl")
include("traversals/bipartition.jl")
include("traversals/greedy_color.jl")
include("traversals/dfs.jl")
include("traversals/maxadjvisit.jl")
include("traversals/randomwalks.jl")
include("traversals/diffusion.jl")
include("connectivity.jl")
include("distance.jl")
include("edit_distance.jl")
include("ShortestPaths/ShortestPaths.jl")
include("shortestpaths/astar.jl")
include("shortestpaths/bellman-ford.jl")
include("shortestpaths/dijkstra.jl")
include("shortestpaths/johnson.jl")
include("shortestpaths/desopo-pape.jl")
include("shortestpaths/floyd-warshall.jl")
include("shortestpaths/yen.jl")
include("shortestpaths/spfa.jl")
include("linalg/LinAlg.jl")
include("operators.jl")
include("persistence/common.jl")
include("persistence/lg.jl")
include("centrality/betweenness.jl")
include("centrality/closeness.jl")
include("centrality/stress.jl")
include("centrality/degree.jl")
include("centrality/katz.jl")
include("centrality/pagerank.jl")
include("centrality/eigenvector.jl")
include("centrality/radiality.jl")
include("community/modularity.jl")
include("community/label_propagation.jl")
include("community/core-periphery.jl")
include("community/clustering.jl")
include("community/cliques.jl")
include("community/clique_percolation.jl")
include("spanningtrees/boruvka.jl")
include("spanningtrees/kruskal.jl")
include("spanningtrees/prim.jl")
include("steinertree/steiner_tree.jl")
include("biconnectivity/articulation.jl")
include("biconnectivity/biconnect.jl")
include("biconnectivity/bridge.jl")
include("graphcut/normalized_cut.jl")
include("graphcut/karger_min_cut.jl")
include("dominatingset/degree_dom_set.jl")
include("dominatingset/minimal_dom_set.jl")
include("independentset/degree_ind_set.jl")
include("independentset/maximal_ind_set.jl")
include("vertexcover/degree_vertex_cover.jl")
include("vertexcover/random_vertex_cover.jl")
include("Experimental/Experimental.jl")
include("Parallel/Parallel.jl")

using .LinAlg
end # module
