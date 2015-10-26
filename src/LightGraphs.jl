__precompile__(true)
module LightGraphs

using GZip
using StatsBase
using Base.Collections
using LightXML
using ParserCombinator
using ParserCombinator.Parsers
using Clustering

try
    using GraphMatrices
    import GraphMatrices.CombinatorialAdjacency
    nothing
catch
end

import Base: write, ==, <, *, isless, issubset, complement, union, intersect,
            reverse, reverse!, blkdiag, getindex, show, print, copy,
            sum, size, sparse, eltype, length, ndims, issym, transpose, ctranspose, join


# core
export SimpleGraph, Edge, Graph, DiGraph, vertices, edges, src, dst,
in_edges, out_edges, has_vertex, has_edge, is_directed,
nv, ne, add_edge!, rem_edge!, add_vertex!, add_vertices!,
indegree, outdegree, degree, degree_histogram, density, Δ, δ,
Δout, Δin, δout, δin, neighbors, in_neighbors, out_neighbors,
common_neighbors, all_neighbors, has_self_loop,

# distance
eccentricity, diameter, periphery, radius, center,

# operators
complement, reverse, reverse!, union, intersect,
difference, symmetric_difference,
induced_subgraph, join,

# graph visit
SimpleGraphVisitor, TrivialGraphVisitor, LogGraphVisitor,
discover_vertex!, open_vertex!, close_vertex!,
examine_neighbor!, visited_vertices, traverse_graph, traverse_graph_withlog,

# bfs
BreadthFirst, gdistances, gdistances!, bfs_tree, is_bipartite,

# dfs
DepthFirst, is_cyclic, topological_sort_by_dfs, dfs_tree,

# random
randomwalk, saw,

# connectivity
connected_components, strongly_connected_components, weakly_connected_components,
is_connected, is_strongly_connected, is_weakly_connected, period,
condensation, attracting_components,

# cliques
maximal_cliques,

# maximum_adjacency_visit
MaximumAdjacency, AbstractMASVisitor, mincut, maximum_adjacency_visit,

# a-star, dijkstra, bellman-ford, floyd-warshall
a_star, dijkstra_shortest_paths,
bellman_ford_shortest_paths, has_negative_edge_cycle, enumerate_paths,
floyd_warshall_shortest_paths,

# smallgraphs
CompleteGraph, StarGraph, PathGraph, WheelGraph,
CompleteDiGraph, StarDiGraph, PathDiGraph, WheelDiGraph,
DiamondGraph, BullGraph,
ChvatalGraph, CubicalGraph, DesarguesGraph,
DodecahedralGraph, FruchtGraph, HeawoodGraph,
HouseGraph, HouseXGraph, IcosahedralGraph,
KrackhardtKiteGraph, MoebiusKantorGraph, OctahedralGraph,
PappusGraph, PetersenGraph, SedgewickMazeGraph,
TetrahedralGraph, TruncatedCubeGraph,
TruncatedTetrahedronGraph, TruncatedTetrahedronDiGraph, TutteGraph,

# centrality
betweenness_centrality, closeness_centrality, degree_centrality,
indegree_centrality, outdegree_centrality, katz_centrality, pagerank,

# spectral
adjacency_matrix,laplacian_matrix, adjacency_spectrum, laplacian_spectrum,
CombinatorialAdjacency, non_backtracking_matrix,

# astar
a_star,

# persistence
readgraph, readgraphml, readgml, writegraphml, writegexf, readdot,

# flow
maximum_flow,

# randgraphs
erdos_renyi, watts_strogatz, random_regular_graph, random_regular_digraph, random_configuration_model,
stochastic_block_model,

#community
modularity, community_detection_nback, core_periphery_deg,
local_clustering, global_clustering

"""An optimized graphs package.

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
"""
LightGraphs

include("core.jl")
    include("digraph.jl")
    include("graph.jl")
        include("traversals/graphvisit.jl")
            include("traversals/bfs.jl")
            include("traversals/dfs.jl")
            include("traversals/maxadjvisit.jl")
            include("traversals/randomwalks.jl")
        include("connectivity.jl")
        include("cliques.jl")
        include("distance.jl")
        include("shortestpaths/astar.jl")
        include("shortestpaths/bellman-ford.jl")
        include("shortestpaths/dijkstra.jl")
        include("shortestpaths/floyd-warshall.jl")
        include("spectral.jl")
        include("operators.jl")
        include("persistence/default.jl")
        include("persistence/dot.jl")
        include("persistence/gexf.jl")
        include("persistence/gml.jl")
        include("persistence/graphml.jl")
        include("randgraphs.jl")
        include("smallgraphs.jl")
        include("centrality/betweenness.jl")
        include("centrality/closeness.jl")
        include("centrality/degree.jl")
        include("centrality/katz.jl")
        include("centrality/pagerank.jl")
        include("flow/max-flow-min-cut.jl")
        include("community/modularity.jl")
        include("community/detection.jl")
        include("community/core-periphery.jl")
        include("community/clustering.jl")


end # module
