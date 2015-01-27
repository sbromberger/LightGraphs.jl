abstract AbstractSimpleGraph

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

vertices(g::AbstractSimpleGraph) = g.vertices
edges(g::AbstractSimpleGraph) = g.edges

function =={T<:AbstractSimpleGraph}(g::T, h::T)
    return (vertices(g) == vertices(h)) && (edges(g) == edges(h))
end

function issubset{T<:AbstractSimpleGraph}(g::T, h::T)
    (gmin, gmax) = extrema(vertices(g))
    (hmin, hmax) = extrema(vertices(h))
    return (hmin <= gmin <= gmax <= hmax) &&
    issubset(edges(g), edges(h))
end

function add_vertex!(g::AbstractSimpleGraph)
    n = length(vertices(g)) + 1
    g.vertices = 1:n
    push!(g.binclist, Edge[])
    push!(g.finclist, Edge[])

    return n
end

function add_vertices!(g::AbstractSimpleGraph, n::Integer)
    for i = 1:n
        add_vertex!(g)
    end
    return nv(g)
end

has_edge(g::AbstractSimpleGraph, src::Int, dst::Int) = has_edge(g,Edge(src,dst))

in_edges(g::AbstractSimpleGraph, v::Int) = g.binclist[v]
out_edges(g::AbstractSimpleGraph, v::Int) = g.finclist[v]

has_vertex(g::AbstractSimpleGraph, v::Int) = v in vertices(g)

nv(g::AbstractSimpleGraph) = vertices(g)[end]
ne(g::AbstractSimpleGraph) = length(g.edges)

add_edge!(g::AbstractSimpleGraph, src::Int, dst::Int) = add_edge!(g, Edge(src,dst))

is_directed(g::AbstractSimpleGraph) = (typeof(g) == SimpleGraph? false : true)

indegree(g::AbstractSimpleGraph, v::Int) = length(g.binclist[v])
outdegree(g::AbstractSimpleGraph, v::Int) = length(g.finclist[v])


indegree(g::AbstractSimpleGraph, v::Vector{Int}) = [indegree(g,x) for x in v]
outdegree(g::AbstractSimpleGraph, v::Vector{Int}) = [outdegree(g,x) for x in v]
degree(g::AbstractSimpleGraph, v::Vector{Int}) = [degree(g,x) for x in v]
indegree(g::AbstractSimpleGraph) = [indegree(g,x) for x in vertices(g)]
outdegree(g::AbstractSimpleGraph) = [outdegree(g,x) for x in vertices(g)]
degree(g::AbstractSimpleGraph) = [degree(g,x) for x in vertices(g)]
Δ(g::AbstractSimpleGraph) = maximum(degree(g))
δ(g::AbstractSimpleGraph) = minimum(degree(g))

degree_histogram(g::AbstractSimpleGraph) = (hist(degree(g), 0:nv(g)-1)[2])

neighbors(g::AbstractSimpleGraph, v::Int) = [e.dst for e in g.finclist[v]]
common_neighbors(g::AbstractSimpleGraph, u::Int, v::Int) = intersect(neighbors(g,u), neighbors(g,v))
