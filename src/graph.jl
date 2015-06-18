function show(io::IO, g::Graph)
    if length(vertices(g)) == 0
        print(io, "empty undirected graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} undirected graph")
    end
end

function Graph(n::Int)
    fadjlist = Vector{Int}[]
    badjlist = Vector{Int}[]
    sizehint!(badjlist,n)
    sizehint!(fadjlist,n)
    for i = 1:n
        # sizehint!(i_s, n/4)
        # sizehint!(o_s, n/4)
        push!(badjlist, Int[])
        push!(fadjlist, Int[])
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

has_edge(g::Graph, e::Edge) = e in edges(g) || reverse(e) in edges(g)

function add_edge!(g::Graph, e::Edge)
    if !(has_vertex(g,src(e)) && has_vertex(g,dst(e)))
        throw(BoundsError())
    elseif (src(e) == dst(e))
        error("LightGraphs does not support self-loops")
    elseif has_edge(g,e)
        error("Edge $e is already in graph")
    else
        push!(g.fadjlist[src(e)], dst(e))
        push!(g.badjlist[dst(e)], src(e))

        push!(g.fadjlist[dst(e)], src(e))
        push!(g.badjlist[src(e)], dst(e))
        push!(g.edges, e)
    end
    return e
end

function rem_edge!(g::Graph, e::Edge)
    reve = reverse(e)
    if !(e in edges(g))
        if !(reve in edges(g))
            error("Edge $e is not in graph")
        else
            e, reve = reve, e
        end
    end

    i = findfirst(g.fadjlist[src(e)], dst(e))
    splice!(g.fadjlist[src(e)], i)
    i = findfirst(g.badjlist[dst(e)], src(e))
    splice!(g.badjlist[dst(e)], i)
    i = findfirst(g.fadjlist[dst(e)], src(e))
    splice!(g.fadjlist[dst(e)], i)
    i = findfirst(g.badjlist[src(e)], dst(e))
    splice!(g.badjlist[src(e)], i)
    pop!(g.edges, e)
    return e
end



degree(g::Graph, v::Int) = indegree(g,v)
# all_neighbors(g::Graph, v::Int) =
#     filter(x->x!=v,
#         union(neighbors(g,v), [dst(e) for e in g.binclist[v]])
#     )
density(g::Graph) = (2*ne(g)) / (nv(g) * (nv(g)-1))
