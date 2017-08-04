# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# Depth-first visit / traversal


#################################################
#
#  Depth-first visit
#
#################################################
"""
    DepthFirst
## Conventions in Breadth First Search and Depth First Search
### VertexColorMap
- color == 0    => unseen
- color < 0     => examined but not closed
- color > 0     => examined and closed

### EdgeColorMap
- color == 0    => unseen
- color == 1     => examined
"""
mutable struct DepthFirst <: AbstractGraphVisitAlgorithm end

function depth_first_visit_impl!(
    g::AbstractGraph,      # the graph
    stack,                          # an (initialized) stack of vertex
    vertexcolormap::AbstractVertexMap,    # an (initialized) color-map to indicate status of vertices
    edgecolormap::AbstractEdgeMap,      # an (initialized) color-map to indicate status of edges
    visitor::AbstractGraphVisitor)  # the visitor


    while !isempty(stack)
        u, udsts, tstate = pop!(stack)
        found_new_vertex = false

        while !done(udsts, tstate) && !found_new_vertex
            v, tstate = next(udsts, tstate)
            u_color = get(vertexcolormap, u, 0)
            v_color = get(vertexcolormap, v, 0)
            v_edge = Edge(u, v)
            e_color = get(edgecolormap, v_edge, 0)
            examine_neighbor!(visitor, u, v, u_color, v_color, e_color) #no return here

            edgecolormap[v_edge] = 1

            if v_color == 0
                found_new_vertex = true
                vertexcolormap[v] = vertexcolormap[u] - 1 #negative numbers
                discover_vertex!(visitor, v) || return
                push!(stack, (u, udsts, tstate))

                open_vertex!(visitor, v)
                vdsts = out_neighbors(g, v)
                push!(stack, (v, vdsts, start(vdsts)))
            end
        end

        if !found_new_vertex
            close_vertex!(visitor, u)
            vertexcolormap[u] *= -1
        end
    end
end

function traverse_graph!(
    g::AbstractGraph,
    alg::DepthFirst,
    s::Integer,
    visitor::AbstractGraphVisitor;
    vertexcolormap = Dict{eltype(g),Int}(),
    edgecolormap = DummyEdgeMap())

    T = eltype(g)
    vertexcolormap[s] = -1
    discover_vertex!(visitor, s) || return

    sdsts = out_neighbors(g, s)
    sstate = start(sdsts)
    stack = [(T(s), sdsts, sstate)]

    depth_first_visit_impl!(g, stack, vertexcolormap, edgecolormap, visitor)
end

#################################################
#
#  Useful applications
#
#################################################

# Test whether a graph is cyclic

mutable struct DFSCyclicTestVisitor <: AbstractGraphVisitor
    found_cycle::Bool
    DFSCyclicTestVisitor() = new(false)
end

function examine_neighbor!(
    vis::DFSCyclicTestVisitor,
    u::Integer,
    v::Integer,
    ucolor::Int,
    vcolor::Int,
    ecolor::Int)

    if vcolor < 0 && ecolor == 0
        vis.found_cycle = true
    end
end

discover_vertex!(vis::DFSCyclicTestVisitor, v) = !vis.found_cycle

"""
    is_cyclic(g)

Return `true` if graph `g` contains a cycle.

### Implementation Notes
Uses DFS.
"""
function is_cyclic end
@traitfn is_cyclic(g::::(!IsDirected)) = ne(g) > 0
@traitfn function is_cyclic(g::::IsDirected)
    cmap = zeros(Int, nv(g))
    visitor = DFSCyclicTestVisitor()

    for s in vertices(g)
        if cmap[s] == 0
            traverse_graph!(g, DepthFirst(), s, visitor, vertexcolormap=cmap)
        end
        visitor.found_cycle && return true
    end
    return false
end

# Topological sort using DFS

mutable struct TopologicalSortVisitor{T} <: AbstractGraphVisitor
    vertices::Vector{T}
end

function TopologicalSortVisitor(n::T) where T<:Integer
    vs = Vector{T}()
    sizehint!(vs, n)
    return TopologicalSortVisitor(vs)
end

function examine_neighbor!(visitor::TopologicalSortVisitor, u::Integer, v::Integer, ucolor::Int, vcolor::Int, ecolor::Int)
    (vcolor < 0 && ecolor == 0) && error("The input graph contains at least one loop.")
end

function close_vertex!(visitor::TopologicalSortVisitor, v::Integer)
    push!(visitor.vertices, v)
end

function topological_sort_by_dfs(g::AbstractGraph)
    nvg = nv(g)
    cmap = zeros(Int, nvg)
    visitor = TopologicalSortVisitor(nvg)

    for s in vertices(g)
        if cmap[s] == 0
            traverse_graph!(g, DepthFirst(), s, visitor, vertexcolormap=cmap)
        end
    end

    reverse(visitor.vertices)
end


mutable struct TreeDFSVisitor{T} <:AbstractGraphVisitor
    tree::DiGraph
    predecessor::Vector{T}
end

TreeDFSVisitor(n::T) where T<:Integer = TreeDFSVisitor(DiGraph(n), zeros(T, n))

function examine_neighbor!(visitor::TreeDFSVisitor, u::Integer, v::Integer, ucolor::Int, vcolor::Int, ecolor::Int)
    if (vcolor == 0)
        visitor.predecessor[v] = u
    end
    return true
end

"""
    dfs_tree(g, s)

Return an ordered vector of vertices representing a directed acylic graph based on
depth-first traversal of the graph `g` starting with source vertex `s`.
"""
function dfs_tree(g::AbstractGraph, s::Integer)
    nvg = nv(g)
    visitor = TreeDFSVisitor(nvg)
    traverse_graph!(g, DepthFirst(), s, visitor)
    # visitor = traverse_dfs(g, s, TreeDFSVisitor(nvg))
    h = DiGraph(nvg)
    for (v, u) in enumerate(visitor.predecessor)
        if u != 0
            add_edge!(h, u, v)
        end
    end
    return h
end

dfs_parents(g::AbstractGraph, s::Integer; dir=:out) =
    (dir == :out) ? _dfs_parents(g, s, out_neighbors) : _dfs_parents(g, s, in_neighbors)
function _dfs_parents(g::AbstractGraph, s::Integer, neighborfn::Function)
    T = eltype(g)
    S = Vector{T}()
    
    parents = zeros(T, nv(g))
    seen = falses(nv(g))
    push!(S, s)
    while !isempty(S)
        u = pop!(S)
        seen[u] = true
        neighbors = reverse(filter(x->!seen[x], neighborfn(g, u)))
        append!(S, neighbors)
        parents[neighbors] = u
    end
    return parents
end

dfs_tree2(g::AbstractGraph, s::Integer; dir=:out) = tree(dfs_parents(g, s; dir=dir))
    