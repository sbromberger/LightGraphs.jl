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


@traitfn function is_cyclic2(g::::IsDirected)
    T = eltype(g)
    vcolor = zeros(UInt8, nv(g))
    for v in vertices(g)
        vcolor[v] != 0 && continue
        S = Vector{T}([v])
        vcolor[v] = 1
        while !isempty(S)
            u = S[end]
            w = 0
            for n in out_neighbors(g, u)
                if vcolor[n] == 1
                    return true
                elseif vcolor[n] == 0
                    w = n
                    break
                end
            end
            if w != 0
                vcolor[w] = 1
                push!(S, w)
            else
                vcolor[u] = 2
                pop!(S)
            end
        end
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

function topological_sort_by_dfs2(g::AbstractGraph)
    T = eltype(g)
    vcolor = zeros(UInt8, nv(g))
    verts = Vector{T}()
    for v in vertices(g)
        vcolor[v] != 0 && continue
        S = Vector{T}([v])
        vcolor[v] = 1
        while !isempty(S)
            u = S[end]
            w = 0
            for n in out_neighbors(g, u)
                if vcolor[n] == 1
                    error("The input graph contains at least one loop.")
                elseif vcolor[n] == 0
                    w = n
                    break
                end
            end
            if w != 0
                vcolor[w] = 1
                push!(S, w)
            else
                vcolor[u] = 2
                push!(verts, u)
                pop!(S)
            end
        end
    end
    return reverse(verts)
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

# """
# dfs_tree(g, s)

# Return an ordered vector of vertices representing a directed acylic graph based on
# depth-first traversal of the graph `g` starting with source vertex `s`.
# """
# dfs_tree(g::AbstractGraph, s::Integer; dir=:out) = tree(dfs_parents(g, s; dir=dir))

"""
dfs_parents(g, s[; dir=:out])

Perform a depth-first search of graph `g` starting from vertex `s`.
Return a vector of parent vertices indexed by vertex. If `dir` is specified,
use the corresponding edge direction (`:in` and `:out` are acceptable values).

### Implementation Notes
This version of DFS is iterative.
"""
dfs_parents(g::AbstractGraph, s::Integer; dir=:out) =
(dir == :out) ? _dfs_parents(g, s, out_neighbors) : _dfs_parents(g, s, in_neighbors)

function _dfs_parents(g::AbstractGraph, s::Integer, neighborfn::Function)
    T = eltype(g)
    parents = zeros(T, nv(g))

    seen = falses(nv(g))
    S = Vector{T}([s])
    seen[s] = true
    parents[s] = s
    while !isempty(S)
        v = S[end]
        u = 0
        for n in neighborfn(g, v)
            if !seen[n]
                u = n
                break
            end
        end
        if u == 0
            pop!(S)
        else
            seen[u] = true
            push!(S, u)
            parents[u] = v
        end
    end
    return parents
end
dfs_tree2(g::AbstractGraph, s::Integer; dir=:out) = tree(dfs_parents(g, s; dir=dir))

function _dfs_parents3(g::AbstractGraph, s::Integer, neighborfn::Function)
    T = eltype(g)
    parents = zeros(T, nv(g))

    seen = zeros(Bool, nv(g))
    S = Vector{T}([s])
    seen[s] = true
    parents[s] = s
    while !isempty(S)
        v = S[end]
        u = 0
        for n in neighborfn(g, v)
            if !seen[n]
                u = n
                break
            end
        end
        if u == 0
            pop!(S)
        else
            seen[u] = true
            push!(S, u)
            parents[u] = v
        end
    end
    return parents
end
dfs_tree3(g::AbstractGraph, s::Integer; dir=:out) = tree(_dfs_parents3(g, s, out_neighbors))