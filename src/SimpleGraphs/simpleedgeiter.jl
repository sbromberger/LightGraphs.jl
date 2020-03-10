"""
    SimpleEdgeIter

The function [`edges`](@ref) returns a `SimpleEdgeIter` for `AbstractSimpleGraph`s.
The iterates are in lexicographical order, smallest first. The iterator is valid for
one pass over the edges, and is invalidated by changes to the graph.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = path_graph(3);

julia> es = edges(g)
SimpleEdgeIter 2

julia> e_it = iterate(es)
(Edge 1 => 2, SimpleEdgeIterState [2, 2])

julia> iterate(es, e_it[2])
(Edge 2 => 3, SimpleEdgeIterState [0, 1])
```
"""
struct SimpleEdgeIter{G} <: AbstractEdgeIter
    g::G
end

eltype(::Type{SimpleEdgeIter{SimpleGraph{T}}}) where {T} = SimpleGraphEdge{T}
eltype(::Type{SimpleEdgeIter{SimpleDiGraph{T}}}) where {T} = SimpleDiGraphEdge{T}

@traitfn @inline function iterate(
    eit::SimpleEdgeIter{G},
    state = (one(eltype(eit.g)), 1),
) where {G <: AbstractSimpleGraph!IsDirected{G}}
    g = eit.g
    fadjlist = fadj(g)
    T = eltype(g)
    n = T(nv(g))
    u, i = state

    @inbounds while u < n
        list_u = fadjlist[u]
        if i > length(list_u)
            u += one(u)
            i = searchsortedfirst(fadjlist[u], u)
            continue
        end
        e = SimpleEdge(u, list_u[i])
        state = (u, i + 1)
        return e, state
    end

    @inbounds (n == 0 || i > length(fadjlist[n])) && return nothing

    e = SimpleEdge(n, n)
    state = (u, i + 1)
    return e, state
end

@traitfn @inline function iterate(
    eit::SimpleEdgeIter{G},
    state = (one(eltype(eit.g)), 1),
) where {G <: AbstractSimpleGraphIsDirected{G}}
    g = eit.g
    fadjlist = fadj(g)
    T = eltype(g)
    n = T(nv(g))
    u, i = state

    n == 0 && return nothing

    @inbounds while true
        list_u = fadjlist[u]
        if i > length(list_u)
            u == n && return nothing

            u += one(u)
            list_u = fadjlist[u]
            i = 1
            continue
        end
        e = SimpleEdge(u, list_u[i])
        state = (u, i + 1)
        return e, state
    end

    return nothing
end

length(eit::SimpleEdgeIter) = ne(eit.g)

function _isequal(e1::SimpleEdgeIter, e2)
    k = 0
    for e in e2
        has_edge(e1.g, e) || return false
        k += 1
    end
    return k == ne(e1.g)
end
==(e1::SimpleEdgeIter, e2::AbstractVector{SimpleEdge}) = _isequal(e1, e2)
==(e1::AbstractVector{SimpleEdge}, e2::SimpleEdgeIter) = _isequal(e2, e1)
==(e1::SimpleEdgeIter, e2::Set{SimpleEdge}) = _isequal(e1, e2)
==(e1::Set{SimpleEdge}, e2::SimpleEdgeIter) = _isequal(e2, e1)

function ==(e1::SimpleEdgeIter, e2::SimpleEdgeIter)
    g = e1.g
    h = e2.g
    ne(g) == ne(h) || return false
    m = min(nv(g), nv(h))
    for i = 1:m
        fadj(g, i) == fadj(h, i) || return false
    end
    nv(g) == nv(h) && return true
    for i = m+1:nv(g)
        isempty(fadj(g, i)) || return false
    end
    for i = m+1:nv(h)
        isempty(fadj(h, i)) || return false
    end
    return true
end

in(e, es::SimpleEdgeIter) = has_edge(es.g, e)

show(io::IO, eit::SimpleEdgeIter) = write(io, "SimpleEdgeIter $(ne(eit.g))")
