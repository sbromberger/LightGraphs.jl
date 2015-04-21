function show(io::IO, g::Graph)
    if length(vertices(g)) == 0
        print(io, "empty undirected graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} undirected graph")
    end
end

function Graph(n::Int)
    finclist = Vector{Edge}[]
    binclist = Vector{Edge}[]
    sizehint!(binclist,n)
    sizehint!(finclist,n)
    for i = 1:n
        # sizehint!(i_s, n/4)
        # sizehint!(o_s, n/4)
        push!(binclist, Edge[])
        push!(finclist, Edge[])
    end
    return Graph(1:n, Set{Edge}(), binclist, finclist)
end

Graph() = Graph(0)

function Graph{T<:Real}(adjmx::AbstractMatrix{T})
    dima, dimb = size(adjmx)
    if dima != dimb
        error("Adjacency / distance matrices must be square")
    elseif !issym(adjmx)
        error("Adjacency / distance matrices must be symmetric")
    else
        g = Graph(dima)
        for i=1:dima, j=i:dima
            if adjmx[i,j] > 0 && !isinf(adjmx[i,j])
                add_edge!(g,i,j)
            end
        end
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

has_edge(g::Graph, e::Edge) = e in edges(g) || rev(e) in edges(g)

function add_edge!(g::Graph, e::Edge)
    reve = rev(e)
    if !(has_vertex(g,e.src) && has_vertex(g,e.dst))
        throw(BoundsError())
    elseif (e in edges(g)) || (reve in edges(g))
        error("Edge $e is already in graph")
    else
        push!(g.finclist[e.src], e)
        push!(g.binclist[e.dst], e)

        push!(g.finclist[e.dst], reve)
        push!(g.binclist[e.src], reve)
        push!(g.edges, e)
    end
    return e
end

function rem_edge!(g::Graph, e::Edge)
    reve = rev(e)
    if !(e in edges(g))
        if !(reve in edges(g))
            error("Edge $e is not in graph")
        else
            e, reve = reve, e
        end
    end

    i = findfirst(g.finclist[e.src], e)
    splice!(g.finclist[e.src], i)
    i = findfirst(g.binclist[e.dst], e)
    splice!(g.binclist[e.dst], i)
    i = findfirst(g.finclist[e.dst], reve)
    splice!(g.finclist[e.dst], i)
    i = findfirst(g.binclist[e.src], reve)
    splice!(g.binclist[e.src], i)
    pop!(g.edges, e)
    return e
end



degree(g::Graph, v::Int) = indegree(g,v)
# all_neighbors(g::Graph, v::Int) =
#     filter(x->x!=v,
#         union(neighbors(g,v), [e.dst for e in g.binclist[v]])
#     )
density(g::Graph) = (2*ne(g)) / (nv(g) * (nv(g)-1))
