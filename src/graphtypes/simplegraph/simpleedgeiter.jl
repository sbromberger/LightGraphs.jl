type SimpleEdgeIter <: AbstractEdgeIter
    m::Int
    adj::Vector{Vector{Int}}
    directed::Bool
end

immutable SimpleEdgeIterState
    s::Int  # src vertex
    di::Int # index into adj of dest vertex
    fin::Bool
end


eltype(::Type{SimpleEdgeIter}) = SimpleEdge

SimpleEdgeIter(g::SimpleGraph) = SimpleEdgeIter(ne(g), g.fadjlist, false)
SimpleEdgeIter(g::SimpleDiGraph) = SimpleEdgeIter(ne(g), g.fadjlist, true)

function _next(eit::SimpleEdgeIter, state::SimpleEdgeIterState = SimpleEdgeIterState(1,1,false), first::Bool = true)
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
        s += 1
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
        found = length(searchsorted(e1.adj[s], d)) > 0
        if !e1.directed
            found = found || length(searchsorted(e1.adj[d],s)) > 0
        end
        !found && return false
    end
    return true
end
==(e1::SimpleEdgeIter, e2::AbstractArray{SimpleEdge,1}) = _isequal(e1, e2)
==(e1::AbstractArray{SimpleEdge,1}, e2::SimpleEdgeIter) = _isequal(e2, e1)
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
