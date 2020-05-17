Base.@deprecate_binding GraphMorphismProblem LightGraphs.Structure.IsomorphismScope
Base.@deprecate_binding IsomorphismProblem LightGraphs.Structure.FullGraph
Base.@deprecate_binding SubGraphIsomorphismProblem LightGraphs.Structure.Subgraph
Base.@deprecate_binding InducedSubGraphIsomorphismProblem LightGraphs.Structure.InducedSubgraph

Base.@deprecate_binding IsomorphismAlgorithm LightGraphs.Structure.IsomorphismAlgorithm

function could_have_isomorph(g1::AbstractGraph, g2::AbstractGraph)
    Base.depwarn("`could_have_isomorph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.could_have_isomorph`.", :could_have_isomorph)
    LightGraphs.Structure.could_have_isomorph(g1, g2)
end

function has_induced_subgraphisomorph(g1::AbstractGraph, g2::AbstractGraph, alg::IsomorphismAlgorithm=VF2();
                                 vertex_relation::Union{Nothing, Function}=nothing,
                                 edge_relation::Union{Nothing, Function}=nothing)::Bool
    Base.depwarn("`has_induced_subgraphisomorph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.has_isomorph`.", :has_induced_subgraphisomorph)
    LightGraphs.Structure.has_isomorph(g1, g2, LightGraphs.Structure.InducedSubgraph(), LightGraphs.Structure.VF2(vertex_relation, edge_relation))
end

function has_subgraphisomorph(g1::AbstractGraph, g2::AbstractGraph, alg::IsomorphismAlgorithm=VF2();
                                 vertex_relation::Union{Nothing, Function}=nothing,
                                 edge_relation::Union{Nothing, Function}=nothing)::Bool
    Base.depwarn("`has_subgraphisomorph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.has_isomorph`.", :has_subgraphisomorph)
    LightGraphs.Structure.has_isomorph(g1, g2, LightGraphs.Structure.Subgraph(), LightGraphs.Structure.VF2(vertex_relation, edge_relation))
end

function has_isomorph(g1::AbstractGraph, g2::AbstractGraph, alg::IsomorphismAlgorithm=VF2();
                         vertex_relation::Union{Nothing, Function}=nothing,
                         edge_relation::Union{Nothing, Function}=nothing)::Bool
    Base.depwarn("`has_isomorph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.has_isomorph`.", :has_isomorph)
    LightGraphs.Structure.has_isomorph(g1, g2, LightGraphs.Structure.FullGraph(), LightGraphs.Structure.VF2(vertex_relation, edge_relation))
end

function count_induced_subgraphisomorph(g1::AbstractGraph, g2::AbstractGraph, alg::IsomorphismAlgorithm=VF2();
                                   vertex_relation::Union{Nothing, Function}=nothing,
                                   edge_relation::Union{Nothing, Function}=nothing)::Int
    Base.depwarn("`count_induced_subgraphisomorph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.count_isomorph`.", :count_induced_subgraphisomorph)
    LightGraphs.Structure.count_isomorph(g1, g2, LightGraphs.Structure.InducedSubgraph(), LightGraphs.Structure.VF2(vertex_relation, edge_relation))
end
function count_subgraphisomorph(g1::AbstractGraph, g2::AbstractGraph, alg::IsomorphismAlgorithm=VF2();
                                   vertex_relation::Union{Nothing, Function}=nothing,
                                   edge_relation::Union{Nothing, Function}=nothing)::Int

    Base.depwarn("`count_subgraphisomorph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.count_isomorph`.", :count_subgraphisomorph)
    LightGraphs.Structure.count_isomorph(g1, g2, LightGraphs.Structure.Subgraph(), LightGraphs.Structure.VF2(vertex_relation, edge_relation))
end

function count_isomorph(g1::AbstractGraph, g2::AbstractGraph, alg::IsomorphismAlgorithm=VF2();
                        vertex_relation::Union{Nothing, Function}=nothing,
                        edge_relation::Union{Nothing, Function}=nothing)::Int
    Base.depwarn("`count_isomorph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.count_isomorph`.", :count_subgraphisomorph)
    LightGraphs.Structure.count_isomorph(g1, g2, LightGraphs.Structure.FullGraph(), LightGraphs.Structure.VF2(vertex_relation, edge_relation))
end

function all_induced_subgraphisomorph(g1::AbstractGraph, g2::AbstractGraph, alg::IsomorphismAlgorithm=VF2();
                                      vertex_relation::Union{Nothing, Function}=nothing,
                                      edge_relation::Union{Nothing, Function}=nothing)::Channel{Vector{Tuple{eltype(g1),eltype(g2)}}}
    Base.depwarn("`all_induced_subgraphisomorph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.all_isomorph`.", :all_induced_subgraphisomorph)
    LightGraphs.Structure.all_isomorph(g1, g2, LightGraphs.Structure.InducedSubgraph(), LightGraphs.Structure.VF2(vertex_relation, edge_relation))
end

function all_subgraphisomorph(g1::AbstractGraph, g2::AbstractGraph, alg::IsomorphismAlgorithm=VF2();
                         vertex_relation::Union{Nothing, Function}=nothing,
                         edge_relation::Union{Nothing, Function}=nothing)::Channel{Vector{Tuple{eltype(g1), eltype(g2)}}}
    Base.depwarn("`all_subgraphisomorph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.all_isomorph`.", :all_subgraphisomorph)
    LightGraphs.Structure.all_isomorph(g1, g2, LightGraphs.Structure.Subgraph(), LightGraphs.Structure.VF2(vertex_relation, edge_relation))
end

function all_isomorph(g1::AbstractGraph, g2::AbstractGraph, alg::IsomorphismAlgorithm=VF2();
                 vertex_relation::Union{Nothing, Function}=nothing,
                 edge_relation::Union{Nothing, Function}=nothing)::Channel{Vector{Tuple{eltype(g1),eltype(g2)}}}

    Base.depwarn("`all_isomorph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.all_isomorph`.", :all_subgraphisomorph)
    LightGraphs.Structure.all_isomorph(g1, g2, LightGraphs.Structure.FullGraph(), LightGraphs.Structure.VF2(vertex_relation, edge_relation))
end
