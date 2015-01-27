abstract AbstractFastGraph

immutable Edge
    src::Int
    dst::Int
end

src(e::Edge) = e.src
dst(e::Edge) = e.dst

rev(e::Edge) = Edge(e.dst,e.src)

==(e1::Edge, e2::Edge) = (e1.src == e2.src && e1.dst == e2.dst)

function show(io::IO, e::Edge)
    print(io, "edge $(e.src) - $(e.dst)")
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

function add_vertex!(g::AbstractFastGraph)
    n = length(vertices(g)) + 1
    g.vertices = 1:n
    push!(g.binclist, Edge[])
    push!(g.finclist, Edge[])

    return n
end

function add_vertices!(g::AbstractFastGraph, n::Integer)
    for i = 1:n
        add_vertex!(g)
    end
    return nv(g)
end

has_edge(g::AbstractFastGraph, src::Int, dst::Int) = has_edge(g,Edge(src,dst))

in_edges(g::AbstractFastGraph, v::Int) = g.binclist[v]
out_edges(g::AbstractFastGraph, v::Int) = g.finclist[v]

has_vertex(g::AbstractFastGraph, v::Int) = v in vertices(g)

nv(g::AbstractFastGraph) = vertices(g)[end]
ne(g::AbstractFastGraph) = length(g.edges)

add_edge!(g::AbstractFastGraph, src::Int, dst::Int) = add_edge!(g, Edge(src,dst))

is_directed(g::AbstractFastGraph) = (typeof(g) == FastGraph? false : true)

indegree(g::AbstractFastGraph, v::Int) = length(g.binclist[v])
outdegree(g::AbstractFastGraph, v::Int) = length(g.finclist[v])


indegree(g::AbstractFastGraph, v::Vector{Int}) = [indegree(g,x) for x in v]
outdegree(g::AbstractFastGraph, v::Vector{Int}) = [outdegree(g,x) for x in v]
degree(g::AbstractFastGraph, v::Vector{Int}) = [degree(g,x) for x in v]
indegree(g::AbstractFastGraph) = [indegree(g,x) for x in vertices(g)]
outdegree(g::AbstractFastGraph) = [outdegree(g,x) for x in vertices(g)]
degree(g::AbstractFastGraph) = [degree(g,x) for x in vertices(g)]
Δ(g::AbstractFastGraph) = maximum(degree(g))
δ(g::AbstractFastGraph) = minimum(degree(g))

degree_histogram(g::AbstractFastGraph) = (hist(degree(g), 0:nv(g)-1)[2])

neighbors(g::AbstractFastGraph, v::Int) = [e.dst for e in g.finclist[v]]
common_neighbors(g::AbstractFastGraph, u::Int, v::Int) = intersect(neighbors(g,u), neighbors(g,v))
