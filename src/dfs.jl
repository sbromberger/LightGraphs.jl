# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# Depth-first visit / traversal


#################################################
#
#  Depth-first visit
#
#################################################

type DepthFirst <: AbstractGraphVisitAlgorithm
end

function depth_first_visit_impl!(
    graph::AbstractGraph,      # the graph
    stack,                          # an (initialized) stack of vertex
    vertexcolormap::Vector{Int},    # an (initialized) color-map to indicate status of vertices
    edgecolormap::Dict{Edge,Int},      # an (initialized) color-map to indicate status of edges
    visitor::AbstractGraphVisitor)  # the visitor


    while !isempty(stack)
        u, uegs, tstate = pop!(stack)
        found_new_vertex = false

        while !done(uegs, tstate) && !found_new_vertex
            v_edge, tstate = next(uegs, tstate)
            v = dst(v_edge)
            v_color = vertexcolormap[v]
            if haskey(edgecolormap, v_edge)
                e_color = edgecolormap[v_edge]
            else
                e_color = edgecolormap[rev(v_edge)]
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
                push!(stack, (u, uegs, tstate))

                open_vertex!(visitor, v)
                vegs = out_edges(graph, v)
                push!(stack, (v, vegs, start(vegs)))
            end
        end

        if !found_new_vertex
            close_vertex!(visitor, u)
            vertexcolormap[u] = 2
        end
    end
end

function _mkedgecolormap(g::AbstractGraph, n::Integer=0)
    d = Dict{Edge, Int}()
    for e in edges(g)
        d[e] = n
    end
    return d
end

function traverse_graph(
    graph::AbstractGraph,
    alg::DepthFirst,
    s::Int,
    visitor::AbstractGraphVisitor;
    vertexcolormap = zeros(Int, nv(graph)),
    edgecolormap = _mkedgecolormap(graph))

    vertexcolormap[s] = 1
    if !discover_vertex!(visitor, s)
        return
    end

    segs = out_edges(graph, s)
    sstate = start(segs)
    stack = [(s, segs, sstate)]

    depth_first_visit_impl!(graph, stack, vertexcolormap, edgecolormap, visitor)
end


#################################################
#
#  Useful applications
#
#################################################

# Test whether a graph is cyclic

type DFSCyclicTestVisitor <: AbstractGraphVisitor
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

function test_cyclic_by_dfs(graph::AbstractGraph)
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

type TopologicalSortVisitor <: AbstractGraphVisitor
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

function topological_sort_by_dfs(graph::AbstractGraph)
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
