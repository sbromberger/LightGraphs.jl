type EdgeIterState
    s::Int  # src vertex
    di::Int # index into adj of dest vertex
    fin::Bool
end

type EdgeIter
    m::Int
    adj::Vector{Vector{Int}}
    start::EdgeIterState
    directed::Bool
end

eltype(::Type{EdgeIter}) = Edge


function EdgeIter(g::Graph)
    di = 1
    s = 1
    while di > length(g.fadjlist[s])    # get to the first valid edge.
        s += 1
        di = 1
        s > length(g.fadjlist) && return EdgeIter(ne(g), g.fadjlist, EdgeIterState(1,1, true), false)
    end
    return EdgeIter(ne(g), g.fadjlist, EdgeIterState(s, di, false), false)
end

function EdgeIter(g::DiGraph)
    di = 1
    s = 1
    while di > length(g.fadjlist[s])
        s += 1
        di = 1
        s > length(g.fadjlist) && return EdgeIter(ne(g), g.fadjlist, EdgeIterState(1,1, true), true)
    end
    return EdgeIter(ne(g), g.fadjlist, EdgeIterState(s, di, false), true)
end


start(eit::EdgeIter) = eit.start
done(eit::EdgeIter, state::EdgeIterState) = state.fin

_isfin(eit::EdgeIter, state::EdgeIterState) =
    state.s > length(eit.adj) || (
        state.s == length(eit.adj) &&
        state.di > length(eit.adj[state.s])
    )

function next(eit::EdgeIter, state::EdgeIterState)
    # calculate the edge we're currently looking at.
    # this is guaranteed to be valid.
    d = eit.adj[state.s][state.di]
    edge = Edge(state.s, d)
    found = false       # have we found a valid next state?

    # now, let's get the next valid state, or set fin if there are no more.

    while !found
        state.di += 1                           # increase di.
        while (state.s < length(eit.adj) &&     # if we're at the end of a vector and
            state.di > length(eit.adj[state.s]))  # not at the end of the list
            # println("end of vector $(state.s)")
            state.s += 1                        # go to the next vector, and
            state.di = 1                        # index to the first element.
        end
        if _isfin(eit, state)                   # oops, we've hit the end
            state.fin = true
            return(edge, state)             # return a finished nextstate
        end
        if !eit.directed                    # for undirected graphs
            if state.s <= eit.adj[state.s][state.di]     # skip edges where s > d
                found = true
            # else
            #     println("skipping because $(state.s) > $(eit.adj[state.s][state.di])")
            end
        else
            found = true
        end
    end
    state.fin = _isfin(eit, state)                   # oops, we've hit the end
    return (edge, state)
end

function _isequal(e1::EdgeIter, e2)
    for e in e2
        s, d = e
        found = length(searchsorted(e1.adj[s], d)) > 0
        if !e1.directed
            found = found || length(searchsorted(e1.adj[d],s)) > 0
        end
        !found && return false
    end
    return true
end
==(e1::EdgeIter, e2::AbstractArray{Edge,1}) = _isequal(e1, e2)
==(e1::AbstractArray{Edge,1}, e2::EdgeIter) = _isequal(e2, e1)
==(e1::EdgeIter, e2::Set{Edge}) = _isequal(e1, e2)
==(e1::Set{Edge}, e2::EdgeIter) = _isequal(e2, e1)


function ==(e1::EdgeIter, e2::EdgeIter)
    length(e1.adj) == length(e2.adj) || return false
    e1.directed == e2.directed || return false
    for i in 1:length(e1.adj)
        e1.adj[i] == e2.adj[i] || return false
    end
    return true
end

show(io::IO, eit::EdgeIter) = write(io, "EdgeIter $(eit.m)")
show(io::IO, s::EdgeIterState) = write(io, "EdgeIterState [$(s.s), $(s.di), $(s.fin)]")
