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
    return Graph(1:n, 0, fadjlist)
end

Graph() = Graph(0)

function Graph{T<:Real}(adjmx::AbstractMatrix{T})
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")
    issymmetric(adjmx) || error("Adjacency / distance matrices must be symmetric")

    g = Graph(dima)
    for i in find(triu(adjmx))
        ind = ind2sub((dima,dimb),i)
        add_edge!(g,ind...)
    end
    return g
end

function Graph(g::DiGraph)
    gnv = nv(g)

    edgect = 0
    newfadj = deepcopy(g.fadjlist)
    for i in 1:gnv
        for j in badj(g,i)
            if (_insert_and_dedup!(newfadj[i], j))
                edgect += 2     # this is a new edge only in badjlist
            else
                edgect += 1     # this is an existing edge - we already have it
            end
        end
    end

    return Graph(vertices(g), edgect ÷ 2, newfadj)
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

function copy(g::Graph)
    return Graph(g.vertices, g.ne, deepcopy(g.fadjlist))
end

==(g::Graph, h::Graph) =
    vertices(g) == vertices(h) &&
    ne(g) == ne(h) &&
    fadj(g) == fadj(h)


"Returns `true` if `g` is a `DiGraph`."
is_directed(g::Graph) = false

function has_edge(g::Graph, e::Edge)
    u, v = e
    u > nv(g) || v > nv(g) && return false
    if degree(g,u) > degree(g,v)
        u, v = v, u
    end
    return length(searchsorted(fadj(g,u), v)) > 0
end

function add_edge!(g::Graph, e::Edge)

    s, d = e
    (s in vertices(g) && d in vertices(g)) || return false
    inserted = _insert_and_dedup!(g.fadjlist[s], d)
    if inserted
        g.ne += 1
    end
    if s != d
        inserted = _insert_and_dedup!(g.fadjlist[d], s)
    end
    return inserted
end

function rem_edge!(g::Graph, e::Edge)
    i = searchsorted(g.fadjlist[src(e)], dst(e))
    length(i) > 0 || return false   # edge not in graph
    i = i[1]
    deleteat!(g.fadjlist[src(e)], i)
    if src(e) != dst(e)     # not a self loop
        i = searchsorted(g.fadjlist[dst(e)], src(e))[1]
        deleteat!(g.fadjlist[dst(e)], i)
    end
    g.ne -= 1
    return true # edge successfully removed
end


"""Add a new vertex to the graph `g`."""
function add_vertex!(g::Graph)
    g.vertices = 1:nv(g)+1
    push!(g.fadjlist, Vector{Int}())

    return true
end


"""Return the number of edges (both ingoing and outgoing) from the vertex `v`."""
degree(g::Graph, v::Int) = indegree(g,v)

doc"""Density is defined as the ratio of the number of actual edges to the
number of possible edges. This is $|v| |v-1|$ for directed graphs and
$(|v| |v-1|) / 2$ for undirected graphs.
"""
density(g::Graph) = (2*ne(g)) / (nv(g) * (nv(g)-1))
