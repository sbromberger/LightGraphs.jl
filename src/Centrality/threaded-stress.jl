"""
    struct ThreadedStress{T<:AbstractVector{<:Integer}} <: CentralityMeasure
        k::Int
        vs::T
    end

A struct representing a threaded algorithm to calculate the [stress centrality](http://med.bioinf.mpi-inf.mpg.de/netanalyzer/help/2.7/#stressDist)
of a graph `g` across all vertices, a specified subset of vertices `vs`, and/or a random subset of `k` vertices.

The stress centrality of a vertex ``n`` is defined as the number of shortest paths passing through ``n``.

See [`Stress`](@ref) for more information.

### Optional Arguments
- `k=0`: If `k>0`, randomly sample `k` vertices from `vs` if provided, or from `vertices(g)` if empty.
- `vs=[]`: if `vs` is nonempty, run betweenness centrality only from these vertices.
"""
struct ThreadedStress{T<:AbstractVector{<:Integer}} <: CentralityMeasure
    k::Int
    vs::T
end

ThreadedStress(;k=0, vs=Vector{Int}()) = ThreadedStress(k, vs)

function centrality(g::AbstractGraph, alg::ThreadedStress)::Vector{Int64}
    vs = isempty(alg.vs) ? vertices(g) : alg.vs
    if alg.k > 0
        vs = sample(vs, alg.k)
    end

    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    # Parallel reduction
    local_stress = [zeros(Int, n_v) for _ in 1:nthreads()]

    spalg = ShortestPaths.TrackingBFS()
    Base.Threads.@threads for s in vs
        if degree(g, s) > 0  # this might be 1?
            result = ShortestPaths.shortest_paths(g, s, spalg)
            _stress_accumulate_basic!(local_stress[Base.Threads.threadid()], result, g, s)
        end
    end
    return reduce(+, local_stress)
end
