type DiGraph<:AbstractGraph
    vertices::UnitRange{Int}
    edges::Set{Edge}
    fadjlist::Vector{Vector{Int}} # [src]: (dst), (dst), (dst)
    badjlist::Vector{Vector{Int}} # [dst]: (src), (src), (src)
end


function show(io::IO, g::DiGraph)
    if length(vertices(g)) == 0
        print(io, "empty directed graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} directed graph")
    end
end

function DiGraph(n::Int)
    fadjlist = Vector{Int}[]
    badjlist = Vector{Int}[]
    for i = 1:n
        push!(badjlist, Int[])
        push!(fadjlist, Int[])
    end
    return DiGraph(1:n, Set{Edge}(), badjlist, fadjlist)
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
    if !(has_vertex(g,src(e)) && has_vertex(g,dst(e)))
        throw(BoundsError())
    elseif e in edges(g)
        error("Edge $e is already in graph")
    else
        reve = reverse(e)
        push!(g.fadjlist[src(e)], dst(e))
        push!(g.badjlist[dst(e)], src(e))
        push!(g.edges, e)
    end
    return e
end

function rem_edge!(g::DiGraph, e::Edge)
    reve = reverse(e)
    if !(has_edge(g,e))
        error("Edge $e is not in graph")
    end

    i = findfirst(g.fadjlist[src(e)], dst(e))
    splice!(g.fadjlist[src(e)], i)
    i = findfirst(g.badjlist[dst(e)], src(e))
    splice!(g.badjlist[dst(e)], i)
    pop!(g.edges, e)
    return e
end

has_edge(g::DiGraph, e::Edge) = e in edges(g)

degree(g::DiGraph, v::Int) = indegree(g,v) + outdegree(g,v)
# all_neighbors(g::DiGraph, v::Int) = neighbors(g, v)
density(g::DiGraph) = ne(g) / (nv(g) * (nv(g)-1))
