"""
    AbstractFlowAlgorithm

Abstract type that allows users to pass in their preferred algorithm
"""
abstract type AbstractFlowAlgorithm end

"""
    EdmondsKarpAlgorithm <: AbstractFlowAlgorithm

Forces the maximum_flow function to use the Edmonds–Karp algorithm.
"""
struct EdmondsKarpAlgorithm <: AbstractFlowAlgorithm end

"""
    DinicAlgorithm <: AbstractFlowAlgorithm

Forces the maximum_flow function to use Dinic's algorithm.
"""
struct DinicAlgorithm <: AbstractFlowAlgorithm end

"""
    BoykovKolmogorovAlgorithm <: AbstractFlowAlgorithm

Forces the maximum_flow function to use the Boykov-Kolmogorov algorithm.
"""
struct BoykovKolmogorovAlgorithm <: AbstractFlowAlgorithm end

"""
Forces the maximum_flow function to use the Push-Relabel algorithm.
"""
struct PushRelabelAlgorithm <: AbstractFlowAlgorithm end

"""
    DefaultCapacity{T}

Structure that returns `1` if a forward edge exists in `flow_graph`, and `0` otherwise.
"""
struct DefaultCapacity{T<:Integer} <: AbstractMatrix{T}
    flow_graph::DiGraph
    nv::T
end

@traitfn DefaultCapacity(flow_graph::::IsDirected) =
    DefaultCapacity(DiGraph(flow_graph), nv(flow_graph))

getindex(d::DefaultCapacity{T}, s::Integer, t::Integer) where T = if has_edge(d.flow_graph, s, t) one(T) else zero(T) end
# isassigned{T<:Integer}(d::DefaultCapacity{T}, u::T, v::T) = (u in 1:d.nv) && (v in 1:d.nv)
size(d::DefaultCapacity) = (Int(d.nv), Int(d.nv))
transpose(d::DefaultCapacity) = DefaultCapacity(reverse(d.flow_graph))
ctranspose(d::DefaultCapacity) = DefaultCapacity(reverse(d.flow_graph))

"""
    residual(flow_graph)

Return a directed residual graph for a directed `flow_graph`.

The residual graph comprises the same node list as the orginal flow graph, but
ensures that for each edge (u,v), (v,u) also exists in the graph. This allows
flow in the reverse direction.

If only the forward edge exists, a reverse edge is created with capacity 0.
If both forward and reverse edges exist, their capacities are left unchanged.
Since the capacities in [`LightGraphs.DefaultDistance`](@ref) cannot be changed, an array of ones
is created.
"""
function residual end
@traitfn residual(flow_graph::::IsDirected) = SimpleDiGraph(Graph(flow_graph))

# Method for Edmonds–Karp algorithm

@traitfn function maximum_flow(
    flow_graph::::IsDirected,                   # the input graph
    source::Integer,                       # the source vertex
    target::Integer,                       # the target vertex
    capacity_matrix::AbstractMatrix,   # edge flow capacities
    algorithm::EdmondsKarpAlgorithm        # keyword argument for algorithm
    )
    residual_graph = residual(flow_graph)
    return edmonds_karp_impl(residual_graph, source, target, capacity_matrix)
end

# Method for Dinic's algorithm

@traitfn function maximum_flow(
    flow_graph::::IsDirected,                   # the input graph
    source::Integer,                       # the source vertex
    target::Integer,                       # the target vertex
    capacity_matrix::AbstractMatrix,   # edge flow capacities
    algorithm::DinicAlgorithm              # keyword argument for algorithm
    )
    residual_graph = residual(flow_graph)
    return dinic_impl(residual_graph, source, target, capacity_matrix)
end

# Method for Boykov-Kolmogorov algorithm

@traitfn function maximum_flow(
    flow_graph::::IsDirected,                   # the input graph
    source::Integer,                       # the source vertex
    target::Integer,                       # the target vertex
    capacity_matrix::AbstractMatrix,   # edge flow capacities
    algorithm::BoykovKolmogorovAlgorithm   # keyword argument for algorithm
    )
    residual_graph = residual(flow_graph)
    return boykov_kolmogorov_impl(residual_graph, source, target, capacity_matrix)
end

# Method for Push-relabel algorithm

@traitfn function maximum_flow(
    flow_graph::::IsDirected,                   # the input graph
    source::Integer,                       # the source vertex
    target::Integer,                       # the target vertex
    capacity_matrix::AbstractMatrix,   # edge flow capacities
    algorithm::PushRelabelAlgorithm        # keyword argument for algorithm
    )
    residual_graph = residual(flow_graph)
    return push_relabel(residual_graph, source, target, capacity_matrix)
end

"""
    maximum_flow(flow_graph, source, target[, capacity_matrix][, algorithm][, restriction])

Generic maximum_flow function for `flow_graph` from `source` to `target` with
capacities in `capacity_matrix`.
Uses flow algorithm `algorithm` and cutoff restriction `restriction`.

- If `capacity_matrix` is not specified, `DefaultCapacity(flow_graph)` will be used.
- If `algorithm` is not specified, it will default to [`PushRelabelAlgorithm`](@ref).
- If `restriction` is not specified, it will default to `0`.

Return a tuple of (maximum flow, flow matrix). For the Boykov-Kolmogorov
algorithm, the associated mincut is returned as a third output.

### Usage Example:

```jldoctest
julia> flow_graph = SimpleDiGraph(8) # Create a flow-graph
julia> flow_edges = [
(1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
(2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
(5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
]

julia> capacity_matrix = zeros(Int, 8, 8)  # Create a capacity matrix

julia> for e in flow_edges
    u, v, f = e
    add_edge!(flow_graph, u, v)
    capacity_matrix[u,v] = f
end

julia> f, F = maximum_flow(flow_graph, 1, 8) # Run default maximum_flow (push-relabel) without the capacity_matrix

julia> f, F = maximum_flow(flow_graph, 1, 8, capacity_matrix) # Run default maximum_flow with the capacity_matrix

julia> f, F = maximum_flow(flow_graph, 1, 8, capacity_matrix, algorithm=EdmondsKarpAlgorithm()) # Run Edmonds-Karp algorithm

julia> f, F = maximum_flow(flow_graph, 1, 8, capacity_matrix, algorithm=DinicAlgorithm()) # Run Dinic's algorithm

julia> f, F, labels = maximum_flow(flow_graph, 1, 8, capacity_matrix, algorithm=BoykovKolmogorovAlgorithm()) # Run Boykov-Kolmogorov algorithm

```
"""
function maximum_flow(
    flow_graph::AbstractGraph,                   # the input graph
    source::Integer,                       # the source vertex
    target::Integer,                       # the target vertex
    capacity_matrix::AbstractMatrix =  # edge flow capacities
    DefaultCapacity(flow_graph);
    algorithm::AbstractFlowAlgorithm  =    # keyword argument for algorithm
    PushRelabelAlgorithm(),
    restriction::Real = 0               # keyword argument for restriction max-flow
    )
    if restriction > 0
        return maximum_flow(flow_graph, source, target, min.(restriction, capacity_matrix), algorithm)
    end
    return maximum_flow(flow_graph, source, target, capacity_matrix, algorithm)
end
