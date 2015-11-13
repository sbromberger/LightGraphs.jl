type EdgeIterState
    it::Int
    v::Int
    k::Int
end

type EdgeIter
    m::Int
    adj::Vector{Vector{Int}}
    start::EdgeIterState # =[it, v, k]
    directed::Bool
end

edgeiter(g::Graph) = EdgeIter(ne(g), g.fadjlist, EdgeIterState(1,1,1), false)
edgeiter(g::DiGraph) = EdgeIter(ne(g), g.fadjlist, EdgeIterState(1,1,1), true)

start(eit::EdgeIter) = eit.start
done(eit::EdgeIter, state::EdgeIterState) = state.it > eit.m
function next(eit::EdgeIter, state::EdgeIterState)
    assert(state.v <= length(eit.adj))
    u = 0
    while state.k <= length(eit.adj[state.v])
        u  = eit.adj[state.v][state.k]
        eit.directed && break
        u >= state.v && break
        state.k += 1
    end
    while state.k > length(eit.adj[state.v])
        state.k = 1
        state.v += 1
        while state.k <= length(eit.adj[state.v])
            u  = eit.adj[state.v][state.k]
            eit.directed && break
            u >= state.v && break
            state.k += 1
        end
    end
    e = !eit.directed && u < state.v ? Edge(u, state.v) : Edge(state.v, u)
    state.k += 1
    state.it += 1
    return (e, state)
end
length(eit::EdgeIter) = eit.m

# note: e in edges(g) will not necessarily be the same as
# e in collect(edges(g)) for undirected graphs. The former will be true
# when s > d; the latter will not.
function in(e::Edge, eit::EdgeIter)
    s = src(e)
    t = dst(e)
    n = length(eit.adj)
    !(1 <=  s <= n) && return false
    !(1 <=  t <= n) && return false
    return t in eit.adj[s]
end

function getindex(eit::EdgeIter, n::Int)
    n <= eit.m || throw(BoundsError())
    offsetsum = 0
    i = 1
    while offsetsum < n
        offsetsum += length(eit.adj[i])
        i += 1
    end
    i -= 1

    offsetsum -= length(eit.adj[i])
    d = eit.adj[i][n - offsetsum]
    return Edge(i, d)
end

#TODO implement using a loop and ∈, so that no memory is allocated
==(e1::EdgeIter, e2::Set{Edge}) = Set{Edge}(e1) == e2
==(e1::Set{Edge}, e2::EdgeIter) = e1 == Set{Edge}(e2)
==(e1::EdgeIter, e2::EdgeIter) = Set{Edge}(e1) == Set{Edge}(e2)



show(io::IO, eit::EdgeIter) = write(io, "edgeit $(eit.m)")
show(io::IO, s::EdgeIterState) = write(io, "edgeitstate [ $(s.it),$(s.v),$(s.k) ]")
