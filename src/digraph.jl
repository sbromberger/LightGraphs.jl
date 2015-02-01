type DiGraph<:AbstractGraph
    vertices::UnitRange{Int}
    edges::Set{Edge}
    finclist::Vector{Vector{Edge}} # [src]: ((src,dst), (src,dst), (src,dst))
    binclist::Vector{Vector{Edge}} # [dst]: ((src,dst), (src,dst), (src,dst))
end


function show(io::IO, g::DiGraph)
    if length(vertices(g)) == 0
        print(io, "empty directed graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} directed graph")
    end
end

function DiGraph(n::Int)
    finclist = Vector{Edge}[]
    binclist = Vector{Edge}[]
    for i = 1:n
        push!(binclist, Edge[])
        push!(finclist, Edge[])
    end
    return DiGraph(1:n, Set{Edge}(), binclist, finclist)
end

DiGraph() = DiGraph(0)

function DiGraph{T<:Number}(adjmx::AbstractArray{T,2})
    dima, dimb = size(adjmx)
    if dima != dimb
        error("Adjacency / distance matrices must be square")
    else
        g = DiGraph(dima)
        for i=1:dima, j=1:dima
            if adjmx[i,j] > 0 && !isinf(adjmx[i,j])
                add_edge!(g,i,j)
            end
        end
    end
    return g
end


function add_edge!(g::DiGraph, e::Edge)
    if !(has_vertex(g,e.src) && has_vertex(g,e.dst))
        throw(BoundsError())
    elseif e in edges(g)
        error("Edge $e is already in graph")
    else
        reve = rev(e)
        push!(g.finclist[e.src], e)
        push!(g.binclist[e.dst], e)
        push!(g.edges, e)
    end
    return e
end

has_edge(g::DiGraph, e::Edge) = e in edges(g)

degree(g::DiGraph, v::Int) = indegree(g,v) + outdegree(g,v)
# all_neighbors(g::DiGraph, v::Int) = neighbors(g, v)
density(g::DiGraph) = ne(g) / (nv(g) * (nv(g)-1))
