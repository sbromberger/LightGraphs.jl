abstract AbstractFastGraph

immutable Edge
    src::Int
    dst::Int
end

function show(io::IO, e::Edge)
    print(io, "edge $(e.src) - $(e.dst)")
end

type FastGraph<:AbstractFastGraph
    vertices::UnitRange{Int}
    edges::Set{Edge}
    finclist::Vector{Vector{Int}} # [src]: (dst, dst, dst, dst)
    binclist::Vector{Vector{Int}} # [dst]: (src, src, src, src)
end

function show(io::IO, g::FastGraph)
    print(io, "{$(nv(g)), $(ne(g))} undirected graph")
end

type FastDiGraph<:AbstractFastGraph
    vertices::UnitRange{Int}
    edges::Set{Edge}
    finclist::Vector{Vector{Int}} # [src]: (dst, dst, dst, dst)
    binclist::Vector{Vector{Int}} # [dst]: (src, src, src, src)
end

function show(io::IO, g::FastDiGraph)
    print(io, "{$(nv(g)), $(ne(g))} directed graph")
end

function FastGraph(n::Int)

    finclist = Vector{Int}[]
    binclist = Vector{Int}[]
    sizehint!(binclist,n)
    sizehint!(finclist,n)
    for i = 1:n
        # sizehint!(i_s, n/4)
        # sizehint!(o_s, n/4)
        push!(binclist, Int[])
        push!(finclist, Int[])
    end
    return FastGraph(1:n, Set{Edge}(), binclist, finclist)
end

function FastDiGraph(n::Int)
    finclist = Vector{Int}[]
    binclist = Vector{Int}[]
    for i = 1:n
        push!(binclist, Int[])
        push!(finclist, Int[])
    end
    return FastDiGraph(1:n, Set{Edge}(), binclist, finclist)
end

vertices(g::AbstractFastGraph) = g.vertices

edges(g::AbstractFastGraph) = g.edges

function =={T<:AbstractFastGraph}(g::T, h::T)
    return (vertices(g) == vertices(h)) && (edges(g) == edges(h))
end

function issubset{T<:AbstractFastGraph}(g::T, h::T)
    (gmin, gmax) = extrema(vertices(g))
    (hmin, hmax) = extrema(vertices(h))
    return (hmin <= gmin <= gmax <= hmax) &&
    issubset(edges(g), edges(h))
end

in_edges(g::FastGraph, v::Int) = [Edge(x,v) for x in union(g.binclist[v], g.finclist[v])]
out_edges(g::FastGraph, v::Int) = [Edge(v,x) for x in union(g.binclist[v], g.finclist[v])]
in_edges(g::FastDiGraph, v::Int) = [Edge(x,v) for x in g.binclist[v]]
out_edges(g::FastDiGraph, v::Int) = [Edge(v,x) for x in g.finclist[v]]

function has_edge(g::AbstractFastGraph, e::Edge)
    return e in edges(g)
end

has_edge(g::AbstractFastGraph, src::Int, dst::Int) = has_edge(g,Edge(src,dst))
has_vertex(g::AbstractFastGraph, v::Int) = v in vertices(g)





nv(g::AbstractFastGraph) = vertices(g)[end]
ne(g::AbstractFastGraph) = length(g.edges)

function add_edge!(g::FastGraph, e::Edge)
    if !(has_vertex(g,e.src) && has_vertex(g,e.dst))
        raise(BoundsError)
    elseif e in edges(g)
        error("Edge $e is already in graph")
    else
        push!(g.binclist[e.src], e.dst)
        push!(g.binclist[e.dst], e.src)

        push!(g.finclist[e.dst], e.src)
        push!(g.finclist[e.src], e.dst)

        push!(g.edges, e)

    end
    return e
end

function add_edge!(g::FastDiGraph, e::Edge)
    if !(has_vertex(g,e.src) && has_vertex(g,e.dst))
        raise(BoundsError)
    elseif e in edges(g)
        error("Edge $e is already in graph")
    else
        push!(g.binclist[e.dst], e.src)
        push!(g.finclist[e.src], e.dst)
        push!(g.edges, e)
    end
    return e
end

add_edge!(g::AbstractFastGraph, src::Int, dst::Int) = add_edge!(g, Edge(src,dst))

function add_vertex!(g::AbstractFastGraph)
    n = vertices(g)[end] + 1
    g.vertices = 1:n
    push!(g.binclist, Int[])
    push!(g.finclist, Int[])

    return n
end



indegree(g::AbstractFastGraph, v::Int) = length(g.binclist[v])
outdegree(g::AbstractFastGraph, v::Int) = length(g.finclist[v])
degree(g::FastGraph, v::Int) = indegree(g,v)
degree(g::FastDiGraph, v::Int) = indegree(g,v) + outdegree(g,v)

indegree(g::AbstractFastGraph, v::Vector{Int}) = [indegree(g,x) for x in v]
outdegree(g::AbstractFastGraph, v::Vector{Int}) = [outdegree(g,x) for x in v]
degree(g::AbstractFastGraph, v::Vector{Int}) = [degree(g,x) for x in v]
indegree(g::AbstractFastGraph) = [indegree(g,x) for x in vertices(g)]
outdegree(g::AbstractFastGraph) = [outdegree(g,x) for x in vertices(g)]
degree(g::AbstractFastGraph) = [degree(g,x) for x in vertices(g)]
Δ(g::AbstractFastGraph) = maximum(degree(g))
δ(g::AbstractFastGraph) = minimum(degree(g))

degree_histogram(g::AbstractFastGraph) = (hist(degree(g), 0:nv(g)-1)[2])

neighbors(g::AbstractFastGraph, v::Int) = [g.finclist[v]...]

all_neighbors(g::FastGraph, v::Int) = neighbors(g, v)
all_neighbors(g::FastGraph, v::Int) = [union(g.finclist[v], g.binclist[v])...]

density(g::FastGraph) = (2*ne) / (nv * nv-1)
density(g::FastDiGraph) = ne / (nv * nv-1)

common_neighbors(g::AbstractFastGraph, u::Int, v::Int) = intersect(neighbors(g,u), neighbors(g,v))
