abstract AbstractGeneralGraph
abstract AbstractDiGraph <: AbstractGeneralGraph
abstract AbstractGraph <: AbstractGeneralGraph
abstract AbstractPathState

if VERSION < v"0.4.0-dev+818"
    immutable Pair{T1,T2}
        first::T1
        second::T2
    end
end

if VERSION < v"0.4.0-dev+4103"
    reverse(p::Pair) = Pair(p.second, p.first)
end

typealias Edge Pair{Int,Int}

type Graph <: AbstractGraph
    vertices::UnitRange{Int}
    edges::Set{Edge}
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{Int}} # [dst]: (src, src, src)
end

type DiGraph <: AbstractDiGraph
    vertices::UnitRange{Int}
    edges::Set{Edge}
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{Int}} # [dst]: (src, src, src)
end

# The two graph types provided by this package, which share the
# same fields and can share a lot of the same methods
typealias SimpleGraph Union(Graph,DiGraph)

src(e::Edge) = e.first
dst(e::Edge) = e.second

@deprecate rev(e::Edge) reverse(e)

==(e1::Edge, e2::Edge) = (e1.first == e2.first && e1.second == e2.second)

function show(io::IO, e::Edge)
    print(io, "edge $(e.first) - $(e.second)")
end

vertices(g::SimpleGraph) = g.vertices
edges(g::SimpleGraph) = g.edges
fadj(g::SimpleGraph) = g.fadjlist
fadj(g::SimpleGraph, v::Int) = g.fadjlist[v]
badj(g::SimpleGraph) = g.badjlist
badj(g::SimpleGraph, v::Int) = g.badjlist[v]


function issubset{T<:AbstractGeneralGraph}(g::T, h::T)
    (gmin, gmax) = extrema(vertices(g))
    (hmin, hmax) = extrema(vertices(h))
    return (hmin <= gmin <= gmax <= hmax) &&
    issubset(edges(g), edges(h))
end

function add_vertex!(g::SimpleGraph)
    n = length(vertices(g)) + 1
    g.vertices = 1:n
    push!(g.badjlist, Int[])
    push!(g.fadjlist, Int[])

    return n
end

function add_vertices!(g::AbstractGeneralGraph, n::Integer)
    for i = 1:n
        add_vertex!(g)
    end
    return nv(g)
end

has_edge(g::AbstractGeneralGraph, src::Int, dst::Int) = has_edge(g,Edge(src,dst))
function has_edge(g::AbstractGeneralGraph, e::Edge)
    is_directed(g) ?
        e in edges(g) :
        e in edges(g) || reverse(e) in edges(g)
        
end

in_edges(g::AbstractGeneralGraph, v::Int) = [Edge(x,v) for x in badj(g,v)]
out_edges(g::AbstractGeneralGraph, v::Int) = [Edge(v,x) for x in fadj(g,v)]

has_vertex(g::AbstractGeneralGraph, v::Int) = v in vertices(g)

nv(g::AbstractGeneralGraph) = length(vertices(g))
ne(g::AbstractGeneralGraph) = length(edges(g))

add_edge!(g::AbstractGeneralGraph, src::Int, dst::Int) = add_edge!(g, Edge(src,dst))
rem_edge!(g::AbstractGeneralGraph, src::Int, dst::Int) = rem_edge!(g, Edge(src,dst))

is_directed(g::AbstractGraph) = false
is_directed(g::AbstractDiGraph) = true

indegree(g::AbstractGeneralGraph, v::Int) = length(badj(g,v))
outdegree(g::AbstractGeneralGraph, v::Int) = length(fadj(g,v))
degree(g::AbstractGraph, v::Int) = indegree(g,v)
degree(g::AbstractDiGraph, v::Int) = indegree(g,v) + outdegree(g,v)

indegree(g::AbstractGeneralGraph, v::AbstractArray{Int,1} = vertices(g)) = [indegree(g,x) for x in v]
outdegree(g::AbstractGeneralGraph, v::AbstractArray{Int,1} = vertices(g)) = [outdegree(g,x) for x in v]
degree(g::AbstractGeneralGraph, v::AbstractArray{Int,1} = vertices(g)) = [degree(g,x) for x in v]
#Δ(g::AbstractGeneralGraph) = maximum(degree(g))
#δ(g::AbstractGeneralGraph) = minimum(degree(g))
Δout(g) = noallocextreme(outdegree,(>), typemin(Int), g)
δout(g) = noallocextreme(outdegree,(<), typemax(Int), g)
δin(g)  = noallocextreme(indegree,(<), typemax(Int), g)
Δin(g)  = noallocextreme(indegree,(>), typemin(Int), g)
δ(g)    = noallocextreme(degree,(<), typemax(Int), g)
Δ(g)    = noallocextreme(degree,(>), typemin(Int), g)

#"computes the extreme value of [f(g,i) for i=i:nv(g)] without gathering them all"
function noallocextreme(f, comparison, initial, g)
    value = initial
    for i in 1:nv(g)
        funci = f(g, i)
        if comparison(funci, value)
            value = funci
        end
    end
    return value
end

degree_histogram(g::AbstractGeneralGraph) = (hist(degree(g), 0:nv(g)-1)[2])

neighbors(g::AbstractGeneralGraph, v::Int) = fadj(g,v)
in_neighbors(g::AbstractGeneralGraph, v::Int) = badj(g,v)
out_neighbors(g::AbstractGeneralGraph, v::Int) = fadj(g,v)
common_neighbors(g::AbstractGeneralGraph, u::Int, v::Int) = intersect(neighbors(g,u), neighbors(g,v))

function density(g::AbstractGraph)
    nvert = nv(g)
    nedge = ne(g)
    2 * nedge / (nvert * (nvert-1))
end
function density(g::AbstractDiGraph)
    nvert = nv(g)
    nedge = ne(g)
    nedge / (nvert * (nvert-1))
end