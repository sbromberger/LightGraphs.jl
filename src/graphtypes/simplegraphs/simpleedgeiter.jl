"""
    SimpleEdgeIter

The function [`edges`](@ref) returns a `SimpleEdgeIter` for `AbstractSimpleGraphs`.
The iterates are in lexicographical order, smallest first. The iterator is valid for
one pass over the edges, and is invalidated by changes to the graph.
"""
struct SimpleEdgeIter{T<:Integer} <: AbstractEdgeIter
    m::Int
    adj::Vector{Vector{T}}
    directed::Bool
end

struct SimpleEdgeIterState{T<:Integer}
    s::T  # src vertex
    di::Int # index into adj of dest vertex
    fin::Bool
end


eltype(::Type{SimpleEdgeIter{T}}) where T<:Integer = SimpleEdge{T}

SimpleEdgeIter(g::SimpleGraph) = SimpleEdgeIter(ne(g), g.fadjlist, false)
SimpleEdgeIter(g::SimpleDiGraph) = SimpleEdgeIter(ne(g), g.fadjlist, true)

function _next(
    eit::SimpleEdgeIter{T},
    state::SimpleEdgeIterState{T} = SimpleEdgeIterState(one(T), 1, false),
    first::Bool = true) where T <: Integer
    s = state.s
    di = state.di
    if !first
        di += 1
    end
    fin = state.fin
    while s <= length(eit.adj)
        arr = eit.adj[s]
        while di <= length(arr)
            if eit.directed || s <= arr[di]
                return SimpleEdgeIterState(s, di, fin)
            end
            di += 1
        end
        s += one(T)
        di = 1
    end
    fin = true
    return SimpleEdgeIterState(s, di, fin)
end

start(eit::SimpleEdgeIter) = _next(eit)
done(eit::SimpleEdgeIter, state::SimpleEdgeIterState) = state.fin
length(eit::SimpleEdgeIter) = eit.m

function next(eit::SimpleEdgeIter, state::SimpleEdgeIterState)
    edge = SimpleEdge(state.s, eit.adj[state.s][state.di])
    return(edge, _next(eit, state, false))
end

function _isequal(e1::SimpleEdgeIter, e2)
    for e in e2
        s, d = Tuple(e)
        found = insorted(e1.adj[s], d)
        if !e1.directed
            found = found || insorted(e1.adj[d], s)
        end
        !found && return false
    end
    return true
end
==(e1::SimpleEdgeIter, e2::AbstractVector{SimpleEdge}) = _isequal(e1, e2)
==(e1::AbstractVector{SimpleEdge}, e2::SimpleEdgeIter) = _isequal(e2, e1)
==(e1::SimpleEdgeIter, e2::Set{SimpleEdge}) = _isequal(e1, e2)
==(e1::Set{SimpleEdge}, e2::SimpleEdgeIter) = _isequal(e2, e1)


function ==(e1::SimpleEdgeIter, e2::SimpleEdgeIter)
    length(e1.adj) == length(e2.adj) || return false
    e1.directed == e2.directed || return false
    for i in 1:length(e1.adj)
        e1.adj[i] == e2.adj[i] || return false
    end
    return true
end

show(io::IO, eit::SimpleEdgeIter) = write(io, "SimpleEdgeIter $(eit.m)")
show(io::IO, s::SimpleEdgeIterState) = write(io, "SimpleEdgeIterState [$(s.s), $(s.di), $(s.fin)]")
