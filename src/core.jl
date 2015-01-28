abstract AbstractGraph

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

vertices(g::AbstractGraph) = g.vertices
edges(g::AbstractGraph) = g.edges

function =={T<:AbstractGraph}(g::T, h::T)
    return (vertices(g) == vertices(h)) && (edges(g) == edges(h))
end

function issubset{T<:AbstractGraph}(g::T, h::T)
    (gmin, gmax) = extrema(vertices(g))
    (hmin, hmax) = extrema(vertices(h))
    return (hmin <= gmin <= gmax <= hmax) &&
    issubset(edges(g), edges(h))
end

function add_vertex!(g::AbstractGraph)
    n = length(vertices(g)) + 1
    g.vertices = 1:n
    push!(g.binclist, Edge[])
    push!(g.finclist, Edge[])

    return n
end

function add_vertices!(g::AbstractGraph, n::Integer)
    for i = 1:n
        add_vertex!(g)
    end
    return nv(g)
end

has_edge(g::AbstractGraph, src::Int, dst::Int) = has_edge(g,Edge(src,dst))

in_edges(g::AbstractGraph, v::Int) = g.binclist[v]
out_edges(g::AbstractGraph, v::Int) = g.finclist[v]

has_vertex(g::AbstractGraph, v::Int) = v in vertices(g)

nv(g::AbstractGraph) = vertices(g)[end]
ne(g::AbstractGraph) = length(g.edges)

add_edge!(g::AbstractGraph, src::Int, dst::Int) = add_edge!(g, Edge(src,dst))

is_directed(g::AbstractGraph) = (typeof(g) == Graph? false : true)

indegree(g::AbstractGraph, v::Int) = length(g.binclist[v])
outdegree(g::AbstractGraph, v::Int) = length(g.finclist[v])


indegree(g::AbstractGraph, v::AbstractArray{Int,1} = vertices(g)) = [indegree(g,x) for x in v]
outdegree(g::AbstractGraph, v::AbstractArray{Int,1} = vertices(g)) = [outdegree(g,x) for x in v]
degree(g::AbstractGraph, v::AbstractArray{Int,1} = vertices(g)) = [degree(g,x) for x in v]
Δ(g::AbstractGraph) = maximum(degree(g))
δ(g::AbstractGraph) = minimum(degree(g))

degree_histogram(g::AbstractGraph) = (hist(degree(g), 0:nv(g)-1)[2])

neighbors(g::AbstractGraph, v::Int) = [e.dst for e in g.finclist[v]]
common_neighbors(g::AbstractGraph, u::Int, v::Int) = intersect(neighbors(g,u), neighbors(g,v))
