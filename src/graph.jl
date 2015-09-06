function show(io::IO, g::Graph)
    if nv(g) == 0
        print(io, "empty undirected graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} undirected graph")
    end
end

function Graph(n::Int)
    fadjlist = @compat Vector{Vector{Int}}()
    badjlist = @compat Vector{Vector{Int}}()
    sizehint!(badjlist,n)
    sizehint!(fadjlist,n)
    for i = 1:n
        # sizehint!(i_s, n/4)
        # sizehint!(o_s, n/4)
        push!(badjlist, @compat(Vector{Int}()))
        push!(fadjlist, @compat(Vector{Int}()))
    end
    return Graph(1:n, Set{Edge}(), badjlist, fadjlist)
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

function ==(g::Graph, h::Graph)
    gdigraph = DiGraph(g)
    hdigraph = DiGraph(h)
    return (gdigraph == hdigraph)
end

"Returns `true` if `g` is a `DiGraph`."
is_directed(g::Graph) = false
is_directed(g::SparseGraph) = false
has_edge(g::Graph, e::Edge) = (e in edges(g)) || (reverse(e) in edges(g))
has_edge(g::SparseGraph, e::Edge) = g.m[src(e),dst(e)] != 0

function unsafe_add_edge!(g::Graph, e::Edge)
    push!(g.fadjlist[src(e)], dst(e))
    push!(g.badjlist[dst(e)], src(e))
    push!(g.fadjlist[dst(e)], src(e))
    push!(g.badjlist[src(e)], dst(e))
    push!(g.edges, e)
    return e
end

function rem_edge!(g::Graph, e::Edge)
    if !(e in edges(g))
        reve = reverse(e)
        (reve in edges(g)) || error("Edge $e is not in graph")
        e = reve
    end

    i = findfirst(g.fadjlist[src(e)], dst(e))
    deleteat!(g.fadjlist[src(e)], i)
    i = findfirst(g.badjlist[dst(e)], src(e))
    deleteat!(g.badjlist[dst(e)], i)
    i = findfirst(g.fadjlist[dst(e)], src(e))
    deleteat!(g.fadjlist[dst(e)], i)
    i = findfirst(g.badjlist[src(e)], dst(e))
    deleteat!(g.badjlist[src(e)], i)
    return pop!(g.edges, e)
end


"""Return the number of edges (both ingoing and outgoing) from the vertex `v`."""
degree(g::Graph, v::Int) = indegree(g,v)

degree(g::SparseGraph, v::Int) = indegree(g, v)
degree(g::SparseGraph, v::AbstractVector{Int}) = indegree(g, v)
degree(g::SparseGraph) = indegree(g)


doc"""Density is defined as the ratio of the number of actual edges to the
number of possible edges. This is $|v| |v-1|$ for directed graphs and
$(|v| |v-1|) / 2$ for undirected graphs.
"""
density(g::Graph) = (2*ne(g)) / (nv(g) * (nv(g)-1))
density(g::SparseGraph) = (2*ne(g)) / (nv(g) * (nv(g)-1))
