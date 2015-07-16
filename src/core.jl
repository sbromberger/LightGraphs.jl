abstract AbstractPathState

if VERSION < v"0.4.0-dev+818"
    import Base.hash
    immutable Pair{T1,T2}
        first::T1
        second::T2
    end
    const _pair_seed = UInt === UInt64 ? 0x7f1aced4044ecae9 : 0xecaed7e0
    Base.hash(p::Pair) = hash(p.first, hash(p.second, _pair_seed))
end

if VERSION < v"0.4.0-dev+4103"
    reverse(p::Pair) = Pair(p.second, p.first)
end

typealias Edge Pair{Int,Int}

src(e::Edge) = e.first
dst(e::Edge) = e.second

@deprecate rev(e::Edge) reverse(e)

==(e1::Edge, e2::Edge) = (e1.first == e2.first && e1.second == e2.second)

function show(io::IO, e::Edge)
    print(io, "edge $(e.first) - $(e.second)")
end


type Graph
    vertices::UnitRange{Int}
    edges::Set{Edge}
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{Int}} # [dst]: (src, src, src)
end

type DiGraph
    vertices::UnitRange{Int}
    edges::Set{Edge}
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{Int}} # [dst]: (src, src, src)
end

typealias SimpleGraph Union(Graph, DiGraph)


vertices(g::SimpleGraph) = g.vertices
edges(g::SimpleGraph) = g.edges
fadj(g::SimpleGraph) = g.fadjlist
fadj(g::SimpleGraph, v::Int) = g.fadjlist[v]
badj(g::SimpleGraph) = g.badjlist
badj(g::SimpleGraph, v::Int) = g.badjlist[v]


function issubset{T<:SimpleGraph}(g::T, h::T)
    (gmin, gmax) = extrema(vertices(g))
    (hmin, hmax) = extrema(vertices(h))
    return (hmin <= gmin <= gmax <= hmax) && issubset(edges(g), edges(h))
end

function add_vertex!(g::SimpleGraph)
    n = length(vertices(g)) + 1
    g.vertices = 1:n
    push!(g.badjlist, Int[])
    push!(g.fadjlist, Int[])

    return n
end

function add_vertices!(g::SimpleGraph, n::Integer)
    for i = 1:n
        add_vertex!(g)
    end
    return nv(g)
end

has_edge(g::SimpleGraph, src::Int, dst::Int) = has_edge(g,Edge(src,dst))

in_edges(g::SimpleGraph, v::Int) = [Edge(x,v) for x in badj(g,v)]
out_edges(g::SimpleGraph, v::Int) = [Edge(v,x) for x in fadj(g,v)]

has_vertex(g::SimpleGraph, v::Int) = v in vertices(g)

nv(g::SimpleGraph) = length(vertices(g))
ne(g::SimpleGraph) = length(edges(g))

add_edge!(g::SimpleGraph, src::Int, dst::Int) = add_edge!(g, Edge(src,dst))

rem_edge!(g::SimpleGraph, src::Int, dst::Int) = rem_edge!(g, Edge(src,dst))

indegree(g::SimpleGraph, v::Int) = length(badj(g,v))
outdegree(g::SimpleGraph, v::Int) = length(fadj(g,v))


indegree(g::SimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [indegree(g,x) for x in v]
outdegree(g::SimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [outdegree(g,x) for x in v]
degree(g::SimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [degree(g,x) for x in v]
#Δ(g::SimpleGraph) = maximum(degree(g))
#δ(g::SimpleGraph) = minimum(degree(g))
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

degree_histogram(g::SimpleGraph) = (hist(degree(g), 0:nv(g)-1)[2])


in_neighbors(g::SimpleGraph, v::Int) = badj(g,v)
out_neighbors(g::SimpleGraph, v::Int) = fadj(g,v)

neighbors(g::SimpleGraph, v::Int) = out_neighbors(g, v)
common_neighbors(g::SimpleGraph, u::Int, v::Int) = intersect(neighbors(g,u), neighbors(g,v))

function copy{T<:SimpleGraph}(g::T)
    return T(g.vertices,copy(g.edges),deepcopy(g.fadjlist),deepcopy(g.badjlist))
end

has_self_loop(g::SimpleGraph) = any(v->has_edge(g, v, v), vertices(g))
