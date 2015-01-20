type FastGraph<:AbstractFastGraph
    vertices::UnitRange{Int}
    edges::Set{Edge}
    finclist::Vector{Vector{Edge}} # [src]: ((src,dst), (src,dst), (src,dst))
    binclist::Vector{Vector{Edge}} # [dst]: ((src,dst), (src,dst), (src,dst))
end

function show(io::IO, g::FastGraph)
    if length(vertices(g)) == 0
        print(io, "empty directed graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} undirected graph")
    end
end

function FastGraph(n::Int)
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
    return FastGraph(1:n, Set{Edge}(), binclist, finclist)
end

FastGraph() = FastGraph(0)

function add_edge!(g::FastGraph, e::Edge)
    reve = rev(e)
    if !(has_vertex(g,e.src) && has_vertex(g,e.dst))
        throw(BoundsError)
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

has_edge(g::FastGraph, e::Edge) = e in edges(g) || rev(e) in edges(g)

degree(g::FastGraph, v::Int) = indegree(g,v)
all_neighbors(g::FastGraph, v::Int) = union(neighbors(g,v), [e.dst for e in g.binclist[v]])
density(g::FastGraph) = (2*ne(g)) / (nv * (nv(g)-1))
