# The Shortest Path Faster Algorithm for single-source shortest path

###################################################################
#
#The type that capsulates the state of Shortest Path Faster Algorithm
#
###################################################################

using Base.Threads


"""
    spfa_shortest_paths(g, s, distmx=weights(g))

Compute shortest paths between a source `s` and all
other nodes in graph `g` using the [Shortest Path Faster Algorithm]
(https://en.wikipedia.org/wiki/Shortest_Path_Faster_Algorithm).


"""

function spfa_shortest_paths(
    graph::AbstractGraph{U},
    source::Integer,
    distmx::AbstractMatrix{T}=weights(graph)
    ) where T<:Real where U<:Integer


    nvg = nv(graph)

    (source in 1:nvg) || throw(DomainError(source, "source should be in between 1 and $nvg"))
    dists = fill(typemax(T), nvg)
    dists[source] = 0

    count = zeros(U, nvg)           # Vector to store the count of number of times a vertex goes in the queue.

    queue = Vector{U}()             # Vector used to implement queue
    inqueue = zeros(Bool, nvg)      # Vector to mark which vertices are in queue
    push!(queue, source)
    inqueue[source] = true

    @inbounds while !isempty(queue)
        v = popfirst!(queue)
        inqueue[v] = false

        @inbounds for v_neighbor in outneighbors(graph,v)
            if dists[v] + distmx[v,v_neighbor] < dists[v_neighbor]      # Relaxing edges
                dists[v_neighbor] = dists[v] + distmx[v,v_neighbor]

                if !inqueue[v_neighbor]
                    push!(queue,v_neighbor)
                    inqueue[v_neighbor] = true
                    count[v_neighbor] = count[v_neighbor]+1      # Increment the number of times a vertex enters a queue.

                    if count[v_neighbor] > nvg      # This step is just to check negative edge cycle. If this step is not there,
                        throw(NegativeCycleError()) # the algorithm will run infinitely in case of a negative weight cycle.
                                                    # If count[i]>nvg for any i belonging to [1,nvg], it means a negative edge
                                                    # cycle is present.
                    end
                end
            end
        end
    end

    return dists
end

has_negative_edge_cycle_spfa(g::AbstractGraph) = false

function has_negative_edge_cycle_spfa(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T}
    ) where T<:Real where U<:Integer
    try
        spfa_shortest_paths(g, 1, distmx)
    catch e
        isa(e, NegativeCycleError) && return true
    end
    return false
end
