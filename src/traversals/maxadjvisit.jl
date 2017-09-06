# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# Maximum adjacency visit / traversal

#################################################
#
#  Maximum adjacency visit
#
#################################################

abstract type AbstractGraphVisitor end
abstract type AbstractGraphVisitAlgorithm end


struct MaximumAdjacency <: AbstractGraphVisitAlgorithm
end

abstract type AbstractMASVisitor <: AbstractGraphVisitor end

function maximum_adjacency_visit_impl!(
    g::AbstractGraph,                                # the graph
    pq::DataStructures.PriorityQueue{Int,T},         # priority queue
    visitor::AbstractMASVisitor,                     # the visitor
    colormap::Vector{Int}) where T                   # traversal status

    while !isempty(pq)
        u = DataStructures.dequeue!(pq)
        discover_vertex!(visitor, u)
        for v in out_neighbors(g, u)
            if haskey(pq, v)
                ed = visitor.distmx[u, v]
                pq[v] += ed
            end
        end
    end
end

function traverse_graph!(
    g::AbstractGraph,
    T::DataType,
    alg::MaximumAdjacency,
    s::Integer,
    visitor::AbstractMASVisitor,
    colormap::Vector{Int})


    pq = DataStructures.PriorityQueue{Int, T}(Base.Order.Reverse)

    # Set number of visited neighbors for all vertices to 0
    for v in vertices(g)
        pq[v] = zero(T)
    end

    @assert haskey(pq, s)
    @assert nv(g) >= 2

    #Give the starting vertex high priority
    pq[s] = one(T)

    #start traversing the graph
    maximum_adjacency_visit_impl!(g, pq, visitor, colormap)
end


#################################################
#
#  Visitors
#
#################################################


#################################################
#
#  Minimum Cut Visitor
#
#################################################

mutable struct MinCutVisitor{T,U<:Integer} <: AbstractMASVisitor
    graph::AbstractGraph
    parities::BitVector
    colormap::Vector{Int}
    bestweight::T
    cutweight::T
    visited::Int
    distmx::AbstractMatrix{T}
    vertices::Vector{U}
end

function MinCutVisitor(g::AbstractGraph, distmx::AbstractMatrix{T}) where T
    U = eltype(g)
    n = nv(g)
    parities = falses(n)
    return MinCutVisitor(
        g,
        falses(n),
        zeros(Int, n),
        typemax(T),
        zero(T),
        zero(Int),
        distmx,
        Vector{U}()
    )
end

function discover_vertex!(vis::MinCutVisitor, v::Integer)
    vis.parities[v] = false
    vis.colormap[v] = 1
    push!(vis.vertices, v)
    return true
end

function examine_neighbor!(vis::MinCutVisitor, u::Integer, v::Integer, ucolor::Int, vcolor::Int, ecolor::Int)
    ew = vis.distmx[u, v]

    # if the target of e is already marked then decrease cutweight
    # otherwise, increase it

    if vis.colormap[v] != vcolor # here vcolor is 0
        vis.cutweight -= ew
    else
        vis.cutweight += ew
    end
    return true
end

function close_vertex!(vis::MinCutVisitor, v::Integer)
    vis.colormap[v] = 2
    vis.visited += 1

    if vis.cutweight < vis.bestweight && vis.visited < nv(vis.graph)
        vis.bestweight = vis.cutweight
        for u in vertices(vis.graph)
            vis.parities[u] = (vis.colormap[u] == 2)
        end
    end
    return true
end

#################################################
#
#  MAS Visitor
#
#################################################

struct MASVisitor{T,U<:Integer} <: AbstractMASVisitor
    io::IO
    vertices::Vector{U}
    distmx::AbstractMatrix{T}
    log::Bool
end

function discover_vertex!(visitor::MASVisitor{T}, v::Integer) where T
    push!(visitor.vertices, v)
    visitor.log ? println(visitor.io, "discover vertex: $v") : nothing
    return true
end

function examine_neighbor!(visitor::MASVisitor, u::Integer, v::Integer, ucolor::Int, vcolor::Int, ecolor::Int)
    visitor.log ? println(visitor.io, " -- examine neighbor from $u to $v") : nothing
    return true
end

function close_vertex!(visitor::MASVisitor, v::Integer)
    visitor.log ? println(visitor.io, "close vertex: $v") : nothing
    return true
end

#################################################
#
#  Minimum Cut
#
#################################################


"""
    mincut(g, distmx=weights(g))

Return a tuple `(parity, bestcut)`, where `parity` is a vector of integer
values that determines the partition in `g` (1 or 2) and `bestcut` is the
weight of the cut that makes this partition. An optional `distmx` matrix may
be specified; if omitted, edge distances are assumed to be 1.
"""
function mincut(
    g::AbstractGraph,
    distmx::AbstractMatrix{T}=weights(g)
) where T
    visitor = MinCutVisitor(g, distmx)
    colormap = zeros(Int, nv(g))
    traverse_graph!(g, T, MaximumAdjacency(), 1, visitor, colormap)
    return(visitor.parities + 1, visitor.bestweight)
end


"""
    maximum_adjacency_visit(g[, distmx][, log][, io])

Return the vertices in `g` traversed by maximum adjacency search. An optional
`distmx` matrix may be specified; if omitted, edge distances are assumed to
be 1. If `log` (default `false`) is `true`, visitor events will be printed to
`io`, which defaults to `STDOUT`; otherwise, no event information will be
displayed.
"""
function maximum_adjacency_visit(
    g::AbstractGraph,
    distmx::AbstractMatrix{T},
    log::Bool,
    io::IO
) where T
    visitor = MASVisitor(io, Vector{Int}(), distmx, log)
    traverse_graph!(g, T, MaximumAdjacency(), 1, visitor, zeros(Int, nv(g)))
    return visitor.vertices
end

maximum_adjacency_visit(g::AbstractGraph) = maximum_adjacency_visit(
    g,
    weights(g),
    false,
    STDOUT
)
