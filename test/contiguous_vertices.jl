
# Defining a new graph type without contiguous vertices

struct VSafeGraph{T, G<:LightGraphs.AbstractGraph{Int}, V<:AbstractVector{Int}} <: LightGraphs.AbstractGraph{T}
    g::G
    deleted_vertices::V
    VSafeGraph(g::G, v::V) where {T, G<:LightGraphs.AbstractGraph{T}, V<:AbstractVector{Int}} = new{T, G, V}(g, v)
end

# basic interface

LightGraphs.has_contiguous_vertices(::Type{<:VSafeGraph}) = false

# deleted vertices are stored in a cache
# not deleted from the underlying graph to maintain count
function LightGraphs.rem_vertex!(g::VSafeGraph, v1)
    (!has_vertex(g, v1) || v1 in g.deleted_vertices) && return false
    for v2 in outneighbors(g, v1)
        rem_edge!(g, v1, v2)
    end
    for v2 in inneighbors(g, v1)
        rem_edge!(g, v2, v1)
    end
    push!(g.deleted_vertices, v1)
    return true
end

VSafeGraph(g::G) where {G<:LightGraphs.AbstractGraph} = VSafeGraph(g, Vector{Int}())
VSafeGraph(nv::Integer) = VSafeGraph(SimpleGraph(nv))

LightGraphs.edges(g::VSafeGraph) = edges(g.g)
LightGraphs.edgetype(g::VSafeGraph) = edgetype(g.g)

LightGraphs.is_directed(g::VSafeGraph{T,G}) where {T,G} = is_directed(G)
LightGraphs.is_directed(::Type{<:VSafeGraph{T,G}}) where {T, G} = is_directed(G)

LightGraphs.ne(g::VSafeGraph) = LightGraphs.ne(g.g)
LightGraphs.nv(g::VSafeGraph) = LightGraphs.nv(g.g) - length(g.deleted_vertices)
LightGraphs.vertices(g::VSafeGraph) = [v for v in LightGraphs.vertices(g.g) if !(v in g.deleted_vertices)]

LightGraphs.has_vertex(g::VSafeGraph, v) = has_vertex(g.g, v) && !(v in g.deleted_vertices)

LightGraphs.has_edge(g::VSafeGraph, src, dst) = has_edge(g.g, src, dst)

LightGraphs.add_vertex!(g::VSafeGraph) = add_vertex!(g.g)

LightGraphs.rem_edge!(g::VSafeGraph, v1, v2) = rem_edge!(g.g, v1, v2)

LightGraphs.rem_edge!(g::VSafeGraph, v1, v2) = rem_edge!(g.g, v1, v2)

function LightGraphs.outneighbors(g::VSafeGraph, v)
    if has_vertex(g, v)
        outneighbors(g.g, v)
    else
        throw(ArgumentError("$v is not a valid vertex in the graph."))
    end
end

function LightGraphs.inneighbors(g::VSafeGraph, v)
    has_vertex(g, v) && return inneighbors(g.g, v)
    throw(ArgumentError("$v is not a valid vertex in the graph."))
end

function LightGraphs.add_edge!(g::VSafeGraph, v1, v2)
    (has_vertex(g, v1) && !has_vertex(g, v2)) || return false
    return add_edge!(g.g, v1, v2)
end

LightGraphs.add_edge!(g::VSafeGraph, edge::AbstractEdge) = add_edge!(g, src(edge), dst(edge))

@testset "Vertex contiguity" begin
    @testset "Custom functions for has_vertex and vertices" begin
        nv = 45
        inner = complete_graph(nv)
        g = VSafeGraph(inner)
        removed_ok = @inferred rem_vertex!(g, 42)
        @test removed_ok
        @test @inferred !has_vertex(g, 42)
        @test @inferred has_vertex(g.g, 42)
        @test @inferred !in(42, vertices(g))
        @test @inferred in(42, vertices(g.g))
    end
    @testset "Vertices contiguity required for some algorithms" begin
        nv = 45
        inner = complete_graph(nv)
        g = VSafeGraph(inner)
        removed_ok = rem_vertex!(g, rand(1:nv))
        @test removed_ok

        # LightGraphs only defines these algorithms for contiguous vertices
        # current master (1.3.0) throws BoundError in the algorithm
        @test_throws MethodError pagerank(g)
        @test_throws MethodError kruskal_mst(g)
    end
end
