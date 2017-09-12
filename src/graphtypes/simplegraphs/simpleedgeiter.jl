"""
    SimpleEdgeIter

The function [`edges`](@ref) returns a `SimpleEdgeIter` for `AbstractSimpleGraphs`.
The iterates are in lexicographical order, smallest first. The iterator is valid for
one pass over the edges, and is invalidated by changes to the graph.
"""
struct SimpleEdgeIter{G} <: AbstractEdgeIter
    g::G
end

struct SimpleEdgeIterState{T<:Integer}
    s::T  # src vertex or zero if done
    di::Int # index into adj of dest vertex
end

eltype(::Type{SimpleEdgeIter{SimpleGraph{T}}}) where {T} = SimpleGraphEdge{T}
eltype(::Type{SimpleEdgeIter{SimpleDiGraph{T}}}) where {T} = SimpleDiGraphEdge{T}

function edge_start(g::Union{SimpleGraph{T}, SimpleDiGraph{T}}) where {T <: Integer}
    s = one(T)
    while s <= nv(g)
        isempty(fadj(g, s)) || return SimpleEdgeIterState(s, 1)
        s += one(T)
    end
    return SimpleEdgeIterState(zero(T), 1)
end

function edge_next(g::Union{SimpleGraph{T}, SimpleDiGraph{T}}, 
    state::SimpleEdgeIterState{T}) where {T <: Integer}
    s = state.s
    di = state.di
    e = SimpleEdge(s, fadj(g, s)[di])
    di += 1
    while s <= nv(g)
        sadj = fadj(g, s)
        while di <= length(sadj)
            if is_directed(g) || s <= sadj[di]
                return e, SimpleEdgeIterState(s, di)
            end
            di += 1
        end
        s += one(T)
        di = 1
    end
    return e, SimpleEdgeIterState(zero(T), 1)
end

start(eit::SimpleEdgeIter) = edge_start(eit.g)
done(eit::SimpleEdgeIter, state::SimpleEdgeIterState) = state.s == 0
length(eit::SimpleEdgeIter) = ne(eit.g)
next(eit::SimpleEdgeIter, state::SimpleEdgeIterState) = edge_next(eit.g, state)

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
    g.ne == g.ne || return false
    m = min(nv(g), nv(h))
    for i in 1:m
        fadj(g, i) == fadj(h, i) || return false
    end
    nv(g) == nv(h) && return true
    for i in m+1:nv(g)
        isempty(fadj(g, i)) || return false
    end
    for i in m+1:nv(h)
        isempty(fadj(h, i)) || return false
    end
    return true   
end

in(e, es::SimpleEdgeIter) = has_edge(es.g, e)

show(io::IO, eit::SimpleEdgeIter) = write(io, "SimpleEdgeIter $(ne(eit.g))")
show(io::IO, s::SimpleEdgeIterState) = write(io, "SimpleEdgeIterState [$(s.s), $(s.di)]")
