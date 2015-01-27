type SimpleDiGraph<:AbstractSimpleGraph
    vertices::UnitRange{Int}
    edges::Set{Edge}
    finclist::Vector{Vector{Edge}} # [src]: ((src,dst), (src,dst), (src,dst))
    binclist::Vector{Vector{Edge}} # [dst]: ((src,dst), (src,dst), (src,dst))
end


function show(io::IO, g::SimpleDiGraph)
    if length(vertices(g)) == 0
        print(io, "empty directed graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} directed graph")
    end
end

function SimpleDiGraph(n::Int)
    finclist = Vector{Edge}[]
    binclist = Vector{Edge}[]
    for i = 1:n
        push!(binclist, Edge[])
        push!(finclist, Edge[])
    end
    return SimpleDiGraph(1:n, Set{Edge}(), binclist, finclist)
end

SimpleDiGraph() = SimpleDiGraph(0)

function SimpleDiGraph{T<:Number}(adjmx::AbstractArray{T,2})
    dima, dimb = size(adjmx)
    if dima != dimb
        error("Adjacency matrices must be square")
    else
        g = SimpleDiGraph(dima)
        for i=1:dima, j=1:dima
            if adjmx[i,j] > 0
                add_edge!(g,i,j)
            end
        end
    end
    return g
end


function add_edge!(g::SimpleDiGraph, e::Edge)
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

has_edge(g::SimpleDiGraph, e::Edge) = e in edges(g)

degree(g::SimpleDiGraph, v::Int) = indegree(g,v) + outdegree(g,v)
all_neighbors(g::SimpleDiGraph, v::Int) = neighbors(g, v)
density(g::SimpleDiGraph) = ne(g) / (nv(g) * (nv(g)-1))
