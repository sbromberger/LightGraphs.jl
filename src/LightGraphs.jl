__precompile__(true)
module LightGraphs

import CodecZlib
using DataStructures
using SimpleTraits

import Base: write, ==, <, *, ≈, convert, isless, issubset, union, intersect,
            reverse, reverse!, blkdiag, isassigned, getindex, setindex!, show,
            print, copy, in, sum, size, sparse, eltype, length, ndims, transpose,
            ctranspose, join, start, next, done, eltype, get, issymmetric, A_mul_B!,
            Pair, Tuple, zero
export
# Interface
AbstractGraph, AbstractEdge, AbstractEdgeIter,
Edge, Graph, DiGraph, vertices, edges, edgetype, nv, ne, src, dst,
is_directed, add_vertex!, add_edge!, rem_vertex!, rem_edge!,
has_vertex, has_edge, in_neighbors, out_neighbors,

# core
is_ordered, add_vertices!, indegree, outdegree, degree,
Δout, Δin, δout, δin, Δ, δ, degree_histogram,
neighbors, all_neighbors, common_neighbors,
has_self_loops, num_self_loops, density, squash, weights,

# decomposition
core_number, k_core, k_shell, k_crust, k_corona,

# distance
eccentricity, diameter, periphery, radius, center,
parallel_eccentricity, parallel_diameter, parallel_periphery, parallel_radius, parallel_center,

# distance between graphs
spectral_distance, edit_distance,

# edit path cost functions
MinkowskiCost, BoundedMinkowskiCost,

# operators
complement, reverse, reverse!, blkdiag, union, intersect,
difference, symmetric_difference,
join, tensor_product, cartesian_product, crosspath,
induced_subgraph, egonet, merge_vertices!, merge_vertices,

# graph visit
AbstractGraphVisitor,
discover_vertex!, close_vertex!,
examine_neighbor!, traverse_graph,

# bfs
gdistances, gdistances!, bfs_tree, bfs_parents, has_path,

# bipartition
is_bipartite, bipartite_map,

# dfs
is_cyclic, topological_sort_by_dfs, dfs_tree,

# random
randomwalk, saw, non_backtracking_randomwalk,

# diffusion
diffusion, diffusion_rate,

# connectivity
connected_components, strongly_connected_components, weakly_connected_components,
is_connected, is_strongly_connected, is_weakly_connected, period,
condensation, attracting_components, neighborhood, neighborhood_dists,
isgraphical,

# cycles
simplecycles_hadwick_james, maxsimplecycles, simplecycles, simplecycles_iter,
simplecyclescount, simplecycleslength, karp_minimum_cycle_mean,

# maximum_adjacency_visit
MaximumAdjacency, AbstractMASVisitor, mincut, maximum_adjacency_visit,

# a-star, dijkstra, bellman-ford, floyd-warshall
a_star, dijkstra_shortest_paths, bellman_ford_shortest_paths,
has_negative_edge_cycle, enumerate_paths, floyd_warshall_shortest_paths,
transitiveclosure!, transitiveclosure, yen_k_shortest_paths,
parallel_multisource_dijkstra_shortest_paths,

# centrality
betweenness_centrality, closeness_centrality, degree_centrality,
indegree_centrality, outdegree_centrality, katz_centrality, pagerank,
eigenvector_centrality, stress_centrality, radiality_centrality,

parallel_betweenness_centrality, parallel_closeness_centrality,
parallel_stress_centrality, parallel_radiality_centrality,

# spectral
adjacency_matrix, laplacian_matrix, adjacency_spectrum, laplacian_spectrum,
non_backtracking_matrix, incidence_matrix, nonbacktrack_embedding, Nonbacktracking,
contract,

# persistence
loadgraph, loadgraphs, savegraph, LGFormat,

# flow
maximum_flow, EdmondsKarpAlgorithm, DinicAlgorithm, BoykovKolmogorovAlgorithm, PushRelabelAlgorithm,
multiroute_flow, KishimotoAlgorithm, ExtendedMultirouteFlowAlgorithm,

# randgraphs
erdos_renyi, watts_strogatz, random_regular_graph, random_regular_digraph, random_configuration_model,
random_tournament_digraph, StochasticBlockModel, make_edgestream, nearbipartiteSBM, blockcounts,
blockfractions, stochastic_block_model, barabasi_albert, barabasi_albert!, static_fitness_model,
static_scale_free, kronecker,

#community
modularity, core_periphery_deg,
local_clustering,local_clustering_coefficient, global_clustering_coefficient, triangles,
label_propagation, maximal_cliques,

#generators
CompleteGraph, StarGraph, PathGraph, WheelGraph, CycleGraph,
CompleteBipartiteGraph, CompleteDiGraph, StarDiGraph, PathDiGraph, Grid,
WheelDiGraph, CycleDiGraph, BinaryTree, DoubleBinaryTree, RoachGraph, CliqueGraph,

#smallgraphs
smallgraph,

# Euclidean graphs
euclidean_graph,

#minimum_spanning_trees
kruskal_mst, prim_mst,

#biconnectivity and articulation points
articulation, biconnected_components,

#graphcut
normalized_cut

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
include("utils.jl")
include("interface.jl")
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
include("digraph/cycles/johnson.jl")
include("digraph/cycles/hadwick-james.jl")
include("digraph/cycles/karp.jl")
include("traversals/bfs.jl")
include("traversals/bipartition.jl")
include("traversals/parallel_bfs.jl")
include("traversals/dfs.jl")
include("traversals/maxadjvisit.jl")
include("traversals/randomwalks.jl")
include("traversals/diffusion.jl")
include("connectivity.jl")
include("distance.jl")
include("edit_distance.jl")
include("shortestpaths/astar.jl")
include("shortestpaths/bellman-ford.jl")
include("shortestpaths/dijkstra.jl")
include("shortestpaths/floyd-warshall.jl")
include("shortestpaths/yen.jl")
include("linalg/LinAlg.jl")
include("operators.jl")
include("persistence/common.jl")
include("persistence/lg.jl")
include("generators/staticgraphs.jl")
include("generators/randgraphs.jl")
include("generators/euclideangraphs.jl")
include("generators/smallgraphs.jl")
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
include("flow/maximum_flow.jl")
include("flow/edmonds_karp.jl")
include("flow/dinic.jl")
include("flow/boykov_kolmogorov.jl")
include("flow/push_relabel.jl")
include("flow/multiroute_flow.jl")
include("flow/kishimoto.jl")
include("flow/ext_multiroute_flow.jl")
include("spanningtrees/kruskal.jl")
include("spanningtrees/prim.jl")
include("biconnectivity/articulation.jl")
include("biconnectivity/biconnect.jl")
include("graphcut/normalized_cut.jl")

using .LinAlg
end # module
