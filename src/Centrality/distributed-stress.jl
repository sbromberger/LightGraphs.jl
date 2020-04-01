"""
    struct DistributedStress{T<:AbstractVector{<:Integer}} <: CentralityMeasure
        k::Int
        vs::T
    end

A struct representing a distributed algorithm to calculate the [stress centrality](http://med.bioinf.mpi-inf.mpg.de/netanalyzer/help/2.7/#stressDist)
of a graph `g` across all vertices, a specified subset of vertices `vs`, and/or a random subset of `k` vertices.

The stress centrality of a vertex ``n`` is defined as the number of shortest paths passing through ``n``.

See [`Stress`](@ref) for more information.

### Optional Arguments
- `k=0`: If `k>0`, randomly sample `k` vertices from `vs` if provided, or from `vertices(g)` if empty.
- `vs=[]`: if `vs` is nonempty, run betweenness centrality only from these vertices.
"""
struct DistributedStress{T<:AbstractVector{<:Integer}} <: CentralityMeasure
    k::Int
    vs::T
end

DistributedStress(;k=0, vs=Vector{Int}()) = DistributedStress(k, vs)

function centrality(g::AbstractGraph, alg::DistributedStress)::Vector{Int64}
    vs = isempty(alg.vs) ? vertices(g) : alg.vs
    if alg.k > 0
        vs = sample(vs, alg.k)
    end
    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    spalg = ShortestPaths.TrackingBFS()
    # Parallel reduction
    stress = @distributed (+) for s in vs
        temp_stress = zeros(Int64, n_v)
        if degree(g, s) > 0  # this might be 1?
            result = ShortestPaths.shortest_paths(g, s, spalg)
            _stress_accumulate_basic!(temp_stress, result, g, s)
        end
        temp_stress
    end
    return stress
end
