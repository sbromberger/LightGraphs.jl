function show(io::IO, g::Graph)
    if nv(g) == 0
        print(io, "empty undirected graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} undirected graph")
    end
end

function Graph(n::Int)
    fadjlist = Vector{Vector{Int}}()
    sizehint!(fadjlist,n)
    for i = 1:n
        # sizehint!(i_s, n/4)
        # sizehint!(o_s, n/4)
        push!(fadjlist, Vector{Int}())
    end
    return Graph(1:n, Set{Edge}(), fadjlist)
end

Graph() = Graph(0)

function Graph{T<:Real}(adjmx::AbstractMatrix{T})
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")
    issym(adjmx) || error("Adjacency / distance matrices must be symmetric")

    g = Graph(dima)
    for i in find(triu(adjmx))
        ind = ind2sub((dima,dimb),i)
        add_edge!(g,ind...)
    end
    return g
end

function Graph(g::DiGraph)
    gnv = nv(g)

    h = Graph(gnv)

    for e in edges(g)
        if !has_edge(h, e)
            add_edge!(h, e)
        end
    end
    return h
end

"""Returns the backwards adjacency list of a graph.
For each vertex the Array of `dst` for each edge eminating from that vertex.

NOTE: returns a reference, not a copy. Do not modify result.
"""
badj(g::Graph) = fadj(g)
badj(g::Graph, v::Int) = fadj(g, v)


"""Returns the adjacency list of a graph.
For each vertex the Array of `dst` for each edge eminating from that vertex.

NOTE: returns a reference, not a copy. Do not modify result.
"""
adj(g::Graph) = fadj(g)
adj(g::Graph, v::Int) = fadj(g, v)

function ==(g::Graph, h::Graph)
    gdigraph = DiGraph(g)
    hdigraph = DiGraph(h)
    return (gdigraph == hdigraph)
end


function copy(g::Graph)
    return Graph(g.vertices,copy(g.edges),deepcopy(g.fadjlist))
end


"Returns `true` if `g` is a `DiGraph`."
is_directed(g::Graph) = false
has_edge(g::Graph, e::Edge) = (e in edges(g)) || (reverse(e) in edges(g))

function unsafe_add_edge!(g::Graph, e::Edge)
    push!(g.fadjlist[src(e)], dst(e))
    if src(e) != dst(e)
        push!(g.fadjlist[dst(e)], src(e))
    end
    push!(g.edges, e)
    return e
end

function rem_edge!(g::Graph, e::Edge)
    if !(e in edges(g))
        reve = reverse(e)
        (reve in edges(g)) || error("Edge $e is not in graph")
        e = reve
    end
    return unsafe_rem_edge!(g, e)
end

function unsafe_rem_edge!(g::Graph, e::Edge)
    i = findfirst(g.fadjlist[src(e)], dst(e))
    _swapnpop!(g.fadjlist[src(e)], i)
    if src(e) != dst(e)     # not a self loop
        i = findfirst(g.fadjlist[dst(e)], src(e))
        _swapnpop!(g.fadjlist[dst(e)], i)
    end
    return pop!(g.edges, e)
end


"""Add a new vertex to the graph `g`."""
function add_vertex!(g::Graph)
    g.vertices = 1:nv(g)+1
    push!(g.fadjlist, Vector{Int}())

    return nv(g)
end


"""Return the number of edges (both ingoing and outgoing) from the vertex `v`."""
degree(g::Graph, v::Int) = indegree(g,v)
doc"""Density is defined as the ratio of the number of actual edges to the
number of possible edges. This is $|v| |v-1|$ for directed graphs and
$(|v| |v-1|) / 2$ for undirected graphs.
"""
density(g::Graph) = (2*ne(g)) / (nv(g) * (nv(g)-1))
