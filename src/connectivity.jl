# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

"""Returns the [connected components](https://en.wikipedia.org/wiki/Connectivity_(graph_theory))
of an undirected graph `g` as a vector of components, each represented by a
vector of vectors of vertices belonging to the component.
"""
function connected_components(g::Graph)
     nvg = nv(g)
     found = zeros(Bool, nvg)
     components = @compat Vector{Vector{Int}}()
     for v in 1:nvg
         if !found[v]
             bfstree = bfs_tree(g, v)
             found_vertices = @compat Vector{Int}()
             for e in edges(bfstree)
                 push!(found_vertices, src(e))
                 push!(found_vertices, dst(e))
             end
             found_vertices = unique(found_vertices)
             found[found_vertices] = true
             if length(found_vertices) > 0
                 push!(components, found_vertices)
            end
        end
    end
    return components
end

function connected_components!(visitor::TreeBFSVisitorVector, g::Graph)
    nvg = nv(g)
    found = zeros(Bool, nvg)
    components = @compat Vector{Vector{Int}}()
    for v in 1:nvg
        if !found[v]
            visitor.tree[:] = 0
            parents = bfs_tree!(visitor, g, v)
            found_vertices = @compat Vector{Int}()
            for i in 1:nvg
                if parents[i] > 0
                    push!(found_vertices, i)
                end
            end
            found[found_vertices] = true
            if length(found_vertices) > 0
                push!(components, found_vertices)
            end
        end
    end
    return components
end

function connected_components!(label::Vector{Int}, g::Graph)
    nvg = nv(g)
    visitor = LightGraphs.TreeBFSVisitorVector(zeros(Int, nv(g)))
    for v in 1:nvg
        if label[v] == 0
            visitor.tree[:] = 0
            parents = bfs_tree!(visitor, g, v)
            for i in 1:nvg
                if parents[i] > 0
                    label[i] = v
                end
            end
        end
    end
    return label
end

"""Returns `true` if `g` is connected.
For DiGraphs, this is equivalent to a test of weak connectivity."""
is_connected(g::Graph) = length(connected_components(g)) == 1
is_connected(g::DiGraph) = is_weakly_connected(g)

"""Returns connected components of the undirected graph of `g`."""
weakly_connected_components(g::DiGraph) = connected_components(Graph(g))

"""Returns `true` if the undirected graph of `g` is connected."""
is_weakly_connected(g::DiGraph) = length(weakly_connected_components(g)) == 1

# Adapated from Graphs.jl
type TarjanVisitor <: SimpleGraphVisitor
    stack::Vector{Int}
    lowlink::Vector{Int}
    index::Vector{Int}
    components::Vector{Vector{Int}}
end

TarjanVisitor(n::Int) = TarjanVisitor(
    @compat(Vector{Int}()),
    @compat(Vector{Int}()),
    zeros(Int, n),
    @compat(Vector{Vector{Int}}())
)

function discover_vertex!(vis::TarjanVisitor, v)
    vis.index[v] = length(vis.stack) + 1
    push!(vis.lowlink, length(vis.stack) + 1)
    push!(vis.stack, v)
    return true
end

function examine_neighbor!(vis::TarjanVisitor, v, w, w_color::Int, e_color::Int)
    if w_color > 0 # 1 means added seen, but not explored; 2 means closed
        while vis.index[w] > 0 && vis.index[w] < vis.lowlink[end]
            pop!(vis.lowlink)
        end
    end
    return true
end

function close_vertex!(vis::TarjanVisitor, v)
    if vis.index[v] == vis.lowlink[end]
        component = vis.stack[vis.index[v]:end]
        splice!(vis.stack, vis.index[v]:length(vis.stack))
        pop!(vis.lowlink)
        push!(vis.components, component)
    end
    return true
end

"""Computes the (strongly) connected components of a directed graph."""
function strongly_connected_components(g::DiGraph)
    nvg = nv(g)
    cmap = zeros(Int, nvg)
    components = @compat Vector{Vector{Int}}()

    for v in vertices(g)
        if cmap[v] == 0 # 0 means not visited yet
            visitor = TarjanVisitor(nvg)
            traverse_graph(g, DepthFirst(), v, visitor, vertexcolormap=cmap)
            for component in visitor.components
                push!(components, component)
            end
        end
    end
    return components
end

"""Returns `true` if `g` is (strongly) connected."""
is_strongly_connected(g::DiGraph) = length(strongly_connected_components(g)) == 1

"""Computes the (common) period for all nodes in a strongly connected graph."""
function period(g::DiGraph)
    !is_strongly_connected(g) && error("Graph must be strongly connected")

    # First check if there's a self loop
    has_self_loop(g) && return 1

    g_bfs_tree  = bfs_tree(g,1)
    levels      = gdistances(g_bfs_tree,1)
    tree_diff   = difference(g,g_bfs_tree)
    edge_values = @compat Vector{Int}()

    divisor = 0
    for e in edges(tree_diff)
        @inbounds value = levels[src(e)] - levels[dst(e)] + 1
        divisor = gcd(divisor,value)
        isequal(divisor,1) && return 1
    end

    return divisor
end

"""Computes the condensation graph of the strongly connected components."""
function condensation(g::DiGraph, scc::Vector{Vector{Int}})
    h = DiGraph(length(scc))

    component = @compat Vector{Int}(nv(g))

    for (i,s) in enumerate(scc)
        @inbounds component[s] = i
    end

    @inbounds for e in edges(g)
        s, d = component[src(e)], component[dst(e)]
        if (s != d) && !has_edge(h,s,d)
            add_edge!(h,s,d)
        end
    end
    return h
end

"""Returns the condensation graph associated with `g`. The condensation `h` of
a graph `g` is the directed graph where every node in `h` represents a strongly
connected component in `g`, and the presence of an edge between between nodes
in `h` indicates that there is at least one edge between the associated
strongly connected components in `g`. The node numbering in `h` corresponds to
the ordering of the components output from `strongly_connected_components`."""
condensation(g::DiGraph) = condensation(g,strongly_connected_components(g))

"""Returns a vector of vectors of integers representing lists of attracting
components in `g`. The attracting components are a subset of the strongly
connected components in which the components do not have any leaving edges."""
function attracting_components(g::DiGraph)
    scc  = strongly_connected_components(g)
    cond = condensation(g,scc)

    attracting = @compat Vector{Int}()

    for v in vertices(cond)
        if outdegree(cond,v) == 0
            push!(attracting,v)
        end
    end
    return scc[attracting]
end
