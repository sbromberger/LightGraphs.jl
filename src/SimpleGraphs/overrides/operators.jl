# override for performance
function reverse(g::SimpleDiGraph)
    gnv = nv(g)
    gne = ne(g)
    h = SimpleDiGraph(gnv)
    h.fadjlist = deepcopy_adjlist(g.badjlist)
    h.badjlist = deepcopy_adjlist(g.fadjlist)
    h.ne = gne
    return h
end

"""
    reverse!(g)

In-place reverse of a directed graph (modifies the original graph).
See [`reverse`](@ref) for a non-modifying version.
"""
function reverse! end
function reverse!(g::SimpleDiGraph)
    g.fadjlist, g.badjlist = g.badjlist, g.fadjlist
    return g
end

# override for performance
function symmetric_difference(g::SimpleDiGraph, h::SimpleDiGraph)
    limit, mx =
        if nv(g) < nv(h)
            nv(g), nv(h)
        else
            nv(h), nv(g)
        end
    r = SimpleDiGraph(mx)
    for u in 1:limit
        ptr1 = one(eltype(h))
        ptr2 = one(eltype(h))
        gnv = length(neighbors(g, u))
        hnv = length(neighbors(h, u))
        l1 = outneighbors(g, u)
        l2 = outneighbors(h, u)
        while ptr1 <= gnv && ptr2 <= hnv
            if l1[ptr1] < l2[ptr2]
                while ptr1 <= gnv && l1[ptr1] < l2[ptr2]
                    add_edge!(r, u, l1[ptr1])
                    ptr1 += 1
                end
            else
                while ptr2 <= hnv && l1[ptr1] > l2[ptr2]
                    add_edge!(r, u, l2[ptr2])
                    ptr2 += 1
                end
            end
            if ptr1 <= gnv && ptr2 <= hnv && l1[ptr1] == l2[ptr2]
                ptr1 += 1
                ptr2 += 1
            end
        end
        while ptr2 <= hnv
            add_edge!(r, u, l2[ptr2])
            ptr2 += 1
        end
        while ptr1 <= gnv
            add_edge!(r, u, l1[ptr1])
            ptr1 += 1
        end
    end
    if limit < nv(g)
        for u in limit+1:nv(g)
            for v in neighbors(g, u)
                add_edge!(r, u, v)
            end
        end
    end
    if limit < nv(h)
        for u in limit+1:nv(h)
            for v in neighbors(h, u)
                add_edge!(r, u, v)
            end
        end
    end
    return r
end

# override for performance
function symmetric_difference(g::SimpleGraph, h::SimpleGraph)
    limit, mx = nv(g) < nv(h) ? (nv(g), nv(h)) : (nv(h), nv(g))

    r = SimpleGraph(mx)
    for u in 1:limit
        gnv = length(neighbors(g, u))
        hnv = length(neighbors(h, u))
        l1 = outneighbors(g, u)
        l2 = outneighbors(h, u)
        ptr1 = searchsortedfirst(l1, u)
        ptr2 = searchsortedfirst(l2, u)
        while ptr1 <= gnv && ptr2 <= hnv
            if l1[ptr1] < l2[ptr2]
                while ptr1 <= gnv && l1[ptr1] < l2[ptr2]
                    add_edge!(r, u, l1[ptr1])
                    ptr1 += 1
                end
            else
                while ptr2 <= hnv && l1[ptr1] > l2[ptr2]
                    add_edge!(r, u, l2[ptr2])
                    ptr2 += 1
                end
            end
            if ptr1 <= gnv && ptr2 <= hnv && l1[ptr1] == l2[ptr2]
                ptr1 += 1
                ptr2 += 1
            end
        end
        while ptr2 <= hnv
            add_edge!(r, u, l2[ptr2])
            ptr2 += 1
        end
        while ptr1 <= gnv
            add_edge!(r, u, l1[ptr1])
            ptr1 += 1
        end
    end
    if limit < nv(g)
        for u in limit+1:nv(g)
            l1 = neighbors(g, u)
            i = searchsortedfirst(l1, u)
            while i <= length(l1)
                add_edge!(r, u, l1[i])
                i += 1
            end
        end
    end
    if limit < nv(h)
        for u in limit+1:nv(h)
            l1 = neighbors(h, u)
            i = searchsortedfirst(l1, u)
            while i <= length(l1)
                add_edge!(r, u, l1[i])
                i += 1
            end
        end
    end
    return r
end

function merge_vertices!(g::SimpleGraph{T}, vs::Vector{U}) where {U<:Integer, T}
    unique!(vs)
    sort!(vs)
    merged_vertex = popfirst!(vs)

    x = zeros(Int, nv(g))
    x[vs] .= 1
    new_vertex_ids = collect(1:nv(g)) .- cumsum(x)
    new_vertex_ids[vs] .= merged_vertex

    for i in vertices(g)
        # Adjust connections to merged vertices
        if (i != merged_vertex) && !insorted(i, vs)
            nbrs_to_rewire = Set{T}()
            for j in outneighbors(g, i)
                if insorted(j, vs)
                    push!(nbrs_to_rewire, merged_vertex)
                else
                    push!(nbrs_to_rewire, new_vertex_ids[j])
                end
            end
            g.fadjlist[new_vertex_ids[i]] = sort(collect(nbrs_to_rewire))


        # Collect connections to new merged vertex
        else
            nbrs_to_merge = Set{T}()
            for element in filter(x -> !(insorted(x, vs)) && (x != merged_vertex), g.fadjlist[i])
                push!(nbrs_to_merge, new_vertex_ids[element])
            end

            for j in vs, e in outneighbors(g, j)
                if new_vertex_ids[e] != merged_vertex
                    push!(nbrs_to_merge, new_vertex_ids[e])
                end
            end
            g.fadjlist[i] = sort(collect(nbrs_to_merge))
        end
    end

    # Drop excess vertices
    g.fadjlist = g.fadjlist[1:(end - length(vs))]

    # Correct edge counts
    g.ne = sum(degree(g, i) for i in vertices(g)) / 2

    return new_vertex_ids
end

