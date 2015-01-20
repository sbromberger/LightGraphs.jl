abstract AbstractFastGraph

immutable Edge
    src::Int
    dst::Int
    dist::Float64
end

Edge(s::Int, d::Int) = Edge(s, d, 1.0)

src(e::Edge) = e.src
dst(e::Edge) = e.dst
dist(e::Edge) = e.dist

rev(e::Edge) = Edge(e.dst,e.src,e.dist)

==(e1::Edge, e2::Edge) = (e1.src == e2.src && e1.dst == e2.dst && e1.dist == e2.dist)

# immutable TargetIterator
#     g::AbstractFastGraph
#     lst::Vector{Edge}
# end
#
# length(a::TargetIterator) = length(a.lst)
# isempty(a::TargetIterator) = isempty(a.lst)
# getindex(a::TargetIterator, i::Integer) = dst(a.lst[i], a.g)
#
# start(a::TargetIterator) = start(a.lst)
# done(a::TargetIterator, s) = done(a.lst, s)
# next(a::TargetIterator, s::Int) = ((e, s) = next(a.lst, s); (dst(e, a.g), s))

function show(io::IO, e::Edge)
    print(io, "edge $(e.src) - $(e.dst) with dist $(e.dist)")
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
end

has_edge(g::AbstractFastGraph, src::Int, dst::Int) = has_edge(g,Edge(src,dst))

in_edges(g::AbstractFastGraph, v::Int) = g.binclist[v]
# out_edges(g::FastGraph, v::Int) = filter(x->x.src in union(g.binclist[v], g.finclist[v]), edges(g))
# out_edges(g::FastGraph, v::Int) = [Edge(v,x) for x in union(g.binclist[v], g.finclist[v])]
out_edges(g::AbstractFastGraph, v::Int) = g.finclist[v]
# in_edges(g::FastDiGraph, v::Int) = [Edge(x,v) for x in g.binclist[v]]
# out_edges(g::FastGraph, v::Int) = filter(x->x.src in g.finclist[v], edges(g))
# out_edges(g::FastDiGraph, v::Int) = [Edge(v,x) for x in g.finclist[v]]


has_vertex(g::AbstractFastGraph, v::Int) = v in vertices(g)

nv(g::AbstractFastGraph) = vertices(g)[end]
ne(g::AbstractFastGraph) = length(g.edges)

add_edge!(g::AbstractFastGraph, src::Int, dst::Int) = add_edge!(g, Edge(src,dst))
add_edge!(g::AbstractFastGraph, src::Int, dst::Int, dist::Float64) = add_edge!(g, Edge(src,dst,dist))

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
