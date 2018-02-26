# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

#################################################
#
#  Minimum Cut
#
#################################################


"""
    mincut(g, distmx=weights(g))

Return a tuple `(parity, bestcut)`, where `parity` is a vector of integer
values that determines the partition in `g` (1 or 2) and `bestcut` is the
weight of the cut that makes this partition. An optional `distmx` matrix may
be specified; if omitted, edge distances are assumed to be 1.
"""
function mincut(
    g::AbstractGraph,
    distmx::AbstractMatrix{T}=weights(g)
) where T <: Real

    U = eltype(g)
    colormap = zeros(UInt8, nv(g))   ## 0 if unseen, 1 if processing and 2 if seen and closed
    parities = falses(nv(g))
    bestweight = typemax(T)
    cutweight = zero(T)
    visited = zero(U)               ## number of vertices visited
    pq = DataStructures.PriorityQueue{U, T}(Base.Order.Reverse)

    # Set number of visited neighbors for all vertices to 0
    for v in vertices(g)
        pq[v] = zero(T)
    end

    # make sure we have at least two vertices, otherwise, there's nothing to cut,
    # in which case we'll return immediately.
    (haskey(pq, one(U)) && nv(g) > one(U)) || return (Vector{Int8}([1]), cutweight)

    #Give the starting vertex high priority
    pq[one(U)] = one(T)

    while !isempty(pq)
        u = DataStructures.dequeue!(pq)
        colormap[u] = 1

        for v in outneighbors(g, u)
            # if the target of e is already marked then decrease cutweight
            # otherwise, increase it
            ew = distmx[u, v]
            if colormap[v] != 0
                cutweight -= ew
            else
                cutweight += ew
            end
            if haskey(pq, v)
                pq[v] += distmx[u, v]
            end
        end

        colormap[u] = 2
        visited += one(U)
        if cutweight < bestweight && visited < nv(g)
            bestweight = cutweight
            for u in vertices(g)
                parities[u] = (colormap[u] == 2)
            end
        end
    end
    return(convert(Vector{Int8}, parities) .+ one(Int8), bestweight)
end


"""
    maximum_adjacency_visit(g[, distmx][, log][, io])

Return the vertices in `g` traversed by maximum adjacency search. An optional
`distmx` matrix may be specified; if omitted, edge distances are assumed to
be 1. If `log` (default `false`) is `true`, visitor events will be printed to
`io`, which defaults to `STDOUT`; otherwise, no event information will be
displayed.
"""
function maximum_adjacency_visit(
    g::AbstractGraph,
    distmx::AbstractMatrix{T},
    log::Bool=false,
    io::IO=stdout
) where T<:Real

    U = eltype(g)
    pq = DataStructures.PriorityQueue{U, T}(Base.Order.Reverse)
    vertices_order = Vector{U}()
    has_key = ones(Bool, nv(g))
    sizehint!(vertices_order, nv(g))
    # if the graph only has one vertex, we return the vertex by itself.
    nv(g) > one(U) || return collect(vertices(g))

    # Setting intial count to 0
    for v in vertices(g)
        pq[v] = zero(T)
    end


    #Give vertex `1` maximum priority
    pq[one(U)] = one(T)

    #start traversing the graph
    while !isempty(pq)
        u = dequeue!(pq)
        has_key[u] = false
        push!(vertices_order, u)
        log && println(io, "discover vertex: $u")
        for v in outneighbors(g, u)
            log && println(io, " -- examine neighbor from $u to $v")
            if has_key[v]
                ed = distmx[u, v]
                pq[v] += ed
            end
        end
        log && println(io, "close vertex: $u")
    end
    return vertices_order
end

maximum_adjacency_visit(g::AbstractGraph) = maximum_adjacency_visit(
    g,
    weights(g),
    false,
    stdout
)
