# deprecations should also include a comment stating the version
# for which the deprecation should be removed.

# Deprecated to fix spelling. Can be removed for version 2.0.
@deprecate simplecycles_hadwick_james simplecycles_hawick_james

# Deprecated for more explicit function name. Can be removed for version 2.0.
@deprecate saw self_avoiding_walk


# 2.0.0 deprecations
# Traversals / SP
@deprecate dists ShortestPaths.distances

const complete_graph = LightGraphs.SimpleGraphs.Generators.complete_graph
const star_graph = LightGraphs.SimpleGraphs.Generators.star_graph
const path_graph = LightGraphs.SimpleGraphs.Generators.path_graph
const wheel_graph = LightGraphs.SimpleGraphs.Generators.wheel_graph
const cycle_graph = LightGraphs.SimpleGraphs.Generators.cycle_graph
const complete_bipartite_graph = LightGraphs.SimpleGraphs.Generators.complete_bipartite_graph
const complete_multipartite_graph = LightGraphs.SimpleGraphs.Generators.complete_multipartite_graph
const turan_graph = LightGraphs.SimpleGraphs.Generators.turan_graph
const complete_digraph = LightGraphs.SimpleGraphs.Generators.complete_digraph
const star_digraph = LightGraphs.SimpleGraphs.Generators.star_digraph
const path_digraph = LightGraphs.SimpleGraphs.Generators.path_digraph
const grid = LightGraphs.SimpleGraphs.Generators.grid
const wheel_digraph = LightGraphs.SimpleGraphs.Generators.wheel_digraph
const cycle_digraph = LightGraphs.SimpleGraphs.Generators.cycle_digraph
const binary_tree = LightGraphs.SimpleGraphs.Generators.binary_tree
const double_binary_tree = LightGraphs.SimpleGraphs.Generators.double_binary_tree
const roach_graph = LightGraphs.SimpleGraphs.Generators.roach_graph
const clique_graph = LightGraphs.SimpleGraphs.Generators.clique_graph
const ladder_graph = LightGraphs.SimpleGraphs.Generators.ladder_graph
const circular_ladder_graph = LightGraphs.SimpleGraphs.Generators.circular_ladder_graph
const barbell_graph = LightGraphs.SimpleGraphs.Generators.barbell_graph
const lollipop_graph = LightGraphs.SimpleGraphs.Generators.lollipop_graph
const friendship_graph = LightGraphs.SimpleGraphs.Generators.friendship_graph
const circulant_graph = LightGraphs.SimpleGraphs.Generators.circulant_graph
const circulant_digraph = LightGraphs.SimpleGraphs.Generators.circulant_digraph
const random_regular_graph = LightGraphs.SimpleGraphs.Generators.random_regular_graph
const smallgraph = LightGraphs.SimpleGraphs.Generators.smallgraph


const erdos_renyi = LightGraphs.SimpleGraphs.Generators.erdos_renyi
const expected_degree_graph = LightGraphs.SimpleGraphs.Generators.expected_degree_graph
const watts_strogatz = LightGraphs.SimpleGraphs.Generators.watts_strogatz
const barabasi_albert = LightGraphs.SimpleGraphs.Generators.barabasi_albert
const static_fitness_model = LightGraphs.SimpleGraphs.Generators.static_fitness_model
const static_scale_free = LightGraphs.SimpleGraphs.Generators.static_scale_free
const random_regular_graph = LightGraphs.SimpleGraphs.Generators.random_regular_graph
const random_configuration_model = LightGraphs.SimpleGraphs.Generators.random_configuration_model
const random_regular_digraph = LightGraphs.SimpleGraphs.Generators.random_regular_digraph
const random_tournament_digraph = LightGraphs.SimpleGraphs.Generators.random_tournament_digraph
const kronecker = LightGraphs.SimpleGraphs.Generators.kronecker
const dorogovtsev_mendes = LightGraphs.SimpleGraphs.Generators.dorogovtsev_mendes
const random_orientation_dag = LightGraphs.SimpleGraphs.Generators.random_orientation_dag
# Base.@deprecate SimpleGraph LightGraphs.SimpleGraphs.SimpleGraph
# Base.@deprecate SimpleDiGraph LightGraphs.SimpleGraphs.SimpleDiGraph

Base.@deprecate_binding Graph LightGraphs.SimpleGraphs.SimpleGraph
Base.@deprecate_binding DiGraph LightGraphs.SimpleGraphs.SimpleDiGraph
Base.@deprecate_binding Edge LightGraphs.SimpleGraphs.SimpleEdge

# Base.@deprecate SimpleGraphEdge LightGraphs.SimpleGraphs.SimpleGraphEdge
# Base.@deprecate SimpleDiGraphEdge LightGraphs.SimpleGraphs.SimpleDiGraphEdge
# Base.@deprecate add_edge!(g::AbstractSimpleGraph, x...) LightGraphs.SimpleGraphs.add_edge!(g, x...)
# Base.@deprecate add_vertex!(g::AbstractSimpleGraph) LightGraphs.SimpleGraphs.add_vertex!(g)
# Base.@deprecate add_vertices!(g::AbstractSimpleGraph, n) LightGraphs.SimpleGraphs.add_vertices!(g, n)
# Base.@deprecate rem_edge!(g::AbstractSimpleGraph, x...) LightGraphs.SimpleGraphs.rem_edge!(g, x...)
# Base.@deprecate rem_vertex!(g::AbstractSimpleGraph, n) LightGraphs.SimpleGraphs.rem_vertex!(g, n)
# Base.@deprecate rem_vertices!(g::AbstractSimpleGraph, x...) LightGraphs.SimpleGraphs.rem_vertices!(g, x...)
