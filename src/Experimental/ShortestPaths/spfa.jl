# The Shortest Path Faster Algorithm for single-source shortest path

###################################################################
#
#The type that capsulates the state of Shortest Path Faster Algorithm
#
###################################################################

using LightGraphs: nv, weights, outneighbors

"""
    struct SPFA <: ShortestPathAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use the [Shortest Path Faster Algorithm](https://en.wikipedia.org/wiki/Shortest_Path_Faster_Algorithm).

### Optional Fields
`maxdist` (default: `Inf`) option is the same as in [`Dijkstra`](@ref).

### Implementation Notes
`SPFA` supports the following shortest-path functionality:
- non-negative distance matrices / weights
- all destinations
"""
struct SPFA <: ShortestPathAlgorithm 
    maxdist::Float64
end

SPFA(; maxdist=typemax(Float64)) = SPFA(maxdist)

struct SPFAResult{T, U<:Integer} <: ShortestPathResult
    parents::Vector{U}
    dists::Vector{T}
end

function shortest_paths(g::AbstractGraph{U}, source::Integer, distmx::AbstractMatrix{T}, alg::SPFA) where {T, U<:Integer}


    nvg = nv(g)

    (source in 1:nvg) || throw(DomainError(source, "source should be in between 1 and $nvg"))
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    dists[source] = 0

    count = zeros(U, nvg)           # Vector to store the count of number of times a vertex goes in the queue.

    queue = Vector{U}()             # Vector used to implement queue
    inqueue = falses(nvg,1)         # BitArray to mark which vertices are in queue
    push!(queue, source)
    inqueue[source] = true

    @inbounds while !isempty(queue)
        v = popfirst!(queue)
        inqueue[v] = false

        @inbounds for v_neighbor in outneighbors(g, v)
            d = distmx[v,v_neighbor]
            alt = dists[v] + d

            alt > alg.maxdist && continue

            if alt < dists[v_neighbor]         # Relaxing edges
                dists[v_neighbor] = alt
                parents[v_neighbor] = v

                if !inqueue[v_neighbor]
                    push!(queue,v_neighbor)
                    inqueue[v_neighbor] = true                   # Mark the vertex as inside queue.
                    count[v_neighbor] = count[v_neighbor]+1      # Increment the number of times a vertex enters a queue.

                    if count[v_neighbor] > nvg          # This step is just to check negative edge cycle. If this step is not there,
                        throw(NegativeCycleError())     # the algorithm will run infinitely in case of a negative weight cycle.
                                                        # If count[i]>nvg for any i belonging to [1,nvg], it means a negative edge
                                                        # cycle is present.
                    end
                end
            end
        end
    end

    return SPFAResult(parents, dists)
end

shortest_paths(g::AbstractGraph, s::Integer, alg::SPFA) = shortest_paths(g, s, weights(g), alg)

"""
Function which returns true if there is any negative weight cycle in the graph.
# Examples

```jldoctest
julia> g = complete_graph(3);

julia> d = [1 -3 1; -3 1 1; 1 1 1];

julia> has_negative_weight_cycle(g, d, SPFA())
true

julia> g = complete_graph(4);

julia> d = [1 1 -1 1; 1 1 -1 1; 1 1 1 1; 1 1 1 1];

julia> has_negative_weight_cycle(g, d, SPFA());
false
```
"""
function has_negative_weight_cycle(g::AbstractGraph, distmx::AbstractMatrix, alg::SPFA)
    try
        shortest_paths(g, 1, distmx, alg)
    catch e
        isa(e, ShortestPaths.NegativeCycleError) && return true
    end

    return false
end
has_negative_weight_cycle(g::AbstractGraph, ::SPFA) = false

