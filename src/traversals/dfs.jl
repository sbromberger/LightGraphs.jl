# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# Depth-first visit / traversal


#################################################
#
#  Depth-first visit
#
#################################################

type DepthFirst <: SimpleGraphVisitAlgorithm
end

function depth_first_visit_impl!(
    graph::SimpleGraph,      # the graph
    stack,                          # an (initialized) stack of vertex
    vertexcolormap::Vector{Int},    # an (initialized) color-map to indicate status of vertices
    edgecolormap::Dict{Edge,Int},      # an (initialized) color-map to indicate status of edges
    visitor::SimpleGraphVisitor)  # the visitor


    while !isempty(stack)
        u, udsts, tstate = pop!(stack)
        found_new_vertex = false

        while !done(udsts, tstate) && !found_new_vertex
            v, tstate = next(udsts, tstate)
            v_color = vertexcolormap[v]
            v_edge = Edge(u,v)
            if haskey(edgecolormap, v_edge)
                e_color = edgecolormap[v_edge]
            else
                e_color = edgecolormap[reverse(v_edge)]
            end
            examine_neighbor!(visitor, u, v, v_color, e_color)

            if e_color == 0
                edgecolormap[v_edge] = 1
            end

            if v_color == 0
                found_new_vertex = true
                vertexcolormap[v] = 1
                if !discover_vertex!(visitor, v)
                    return
                end
                push!(stack, (u, udsts, tstate))

                open_vertex!(visitor, v)
                vdsts = fadj(graph, v)
                push!(stack, (v, vdsts, start(vdsts)))
            end
        end

        if !found_new_vertex
            close_vertex!(visitor, u)
            vertexcolormap[u] = 2
        end
    end
end

function _mkedgecolormap(g::SimpleGraph, n::Integer=0)
    d = Dict{Edge, Int}()
    for e in edges(g)
        d[e] = n
    end
    return d
end

function traverse_graph(
    graph::SimpleGraph,
    alg::DepthFirst,
    s::Int,
    visitor::SimpleGraphVisitor;
    vertexcolormap = zeros(Int, nv(graph)),
    edgecolormap = _mkedgecolormap(graph))

    vertexcolormap[s] = 1
    if !discover_vertex!(visitor, s)
        return
    end

    sdsts = fadj(graph, s)
    sstate = start(sdsts)
    stack = [(s, sdsts, sstate)]

    depth_first_visit_impl!(graph, stack, vertexcolormap, edgecolormap, visitor)
end


#################################################
#
#  Useful applications
#
#################################################

# Test whether a graph is cyclic

type DFSCyclicTestVisitor <: SimpleGraphVisitor
    found_cycle::Bool

    DFSCyclicTestVisitor() = new(false)
end

function examine_neighbor!(
    vis::DFSCyclicTestVisitor,
    u::Int,
    v::Int,
    vcolor::Int,
    ecolor::Int)

    if vcolor == 1 && ecolor == 0
        vis.found_cycle = true
    end
end

discover_vertex!(vis::DFSCyclicTestVisitor, v) = !vis.found_cycle

"""Tests whether a graph contains a cycle through depth-first search. It
returns `true` when it finds a cycle, otherwise `false`.
"""
function is_cyclic(graph::SimpleGraph)
    cmap = zeros(Int, nv(graph))
    visitor = DFSCyclicTestVisitor()

    for s in vertices(graph)
        if cmap[s] == 0
            traverse_graph(graph, DepthFirst(), s, visitor, vertexcolormap=cmap)
        end

        if visitor.found_cycle
            return true
        end
    end
    return false
end

# Topological sort using DFS

type TopologicalSortVisitor <: SimpleGraphVisitor
    vertices::Vector{Int}

    function TopologicalSortVisitor(n::Int)
        vs = Array(Int, 0)
        sizehint!(vs, n)
        new(vs)
    end
end


function examine_neighbor!(visitor::TopologicalSortVisitor, u::Int, v::Int, vcolor::Int, ecolor::Int)
    if vcolor == 1 && ecolor == 0
        throw(ArgumentError("The input graph contains at least one loop."))
    end
end

function close_vertex!(visitor::TopologicalSortVisitor, v::Int)
    push!(visitor.vertices, v)
end

function topological_sort_by_dfs(graph::SimpleGraph)
    nvg = nv(graph)
    cmap = zeros(Int, nvg)
    visitor = TopologicalSortVisitor(nvg)

    for s in vertices(graph)
        if cmap[s] == 0
            traverse_graph(graph, DepthFirst(), s, visitor, vertexcolormap=cmap)
        end
    end

    reverse(visitor.vertices)
end


type TreeDFSVisitor <:SimpleGraphVisitor
    tree::DiGraph
    predecessor::Vector{Int}
end

TreeDFSVisitor(n::Int) = TreeDFSVisitor(DiGraph(n), zeros(Int,n))

function examine_neighbor!(visitor::TreeDFSVisitor, u::Int, v::Int, vcolor::Int, ecolor::Int)
    if (vcolor == 0)
        visitor.predecessor[v] = u
    end
    return true
end

"""Provides a depth-first traversal of the graph `g` starting with source vertex `s`,
and returns a directed acyclic graph of vertices in the order they were discovered.
"""
function dfs_tree(g::SimpleGraph, s::Int)
    nvg = nv(g)
    visitor = TreeDFSVisitor(nvg)
    traverse_graph(g, DepthFirst(), s, visitor)
    # visitor = traverse_dfs(g, s, TreeDFSVisitor(nvg))
    h = DiGraph(nvg)
    for (v, u) in enumerate(visitor.predecessor)
        if u != 0
            add_edge!(h, u, v)
        end
    end
    return h
end
