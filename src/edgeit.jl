import Base: start, next, done, length, show,
            in, ==

type EdgeItState
    it::Int
    v::Int
    k::Int
end

type EdgeIt
    m::Int
    adj::Vector{Vector{Int}}
    start::EdgeItState # =[it, v, k]
    directed::Bool
end

edge_it(g::Graph) = EdgeIt(ne(g), g.fadjlist, EdgeItState(1,1,1), false)
edge_it(g::DiGraph) = EdgeIt(ne(g), g.fadjlist, EdgeItState(1,1,1), true)

start(eit::EdgeIt) = eit.start
done(eit::EdgeIt, state::EdgeItState) = state.it > eit.m
function next(eit::EdgeIt, state::EdgeItState)
    # println("$eit, $state")
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
length(eit::EdgeIt) = eit.m

function in(e::Edge, eit::EdgeIt)
    s = src(e)
    t = dst(e)
    n = length(eit.adj)
    !(1 <=  s <= n) && return false
    !(1 <=  t <= n) && return false
    return t in eit.adj[s]
end

#TODO implement using a loop and ∈, so that no memory is allocated
==(e1::EdgeIt, e2::Set{Edge}) = Set{Edge}(e1) == e2
==(e1::Set{Edge}, e2::EdgeIt) = e1 == Set{Edge}(e2)
==(e1::EdgeIt, e2::EdgeIt) = Set{Edge}(e1) == Set{Edge}(e2)



show(io::IO, eit::EdgeIt) = write(io, "edgeit $(eit.m)")
show(io::IO, s::EdgeItState) = write(io, "edgeitstate [ $(s.it),$(s.v),$(s.k) ]")
