# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.


"""
    connected_components!(label::Vector{Int}, g::SimpleGraph)

Fills `label` with the `id` of the connected component to which it belongs.

Arguments:
    label: a place to store the output
    g: the graph
Output:
    c = labels[i] => vertex i belongs to component c.
    c is the smallest vertex id in the component.
"""
function connected_components!(label::Vector{Int}, g::SimpleGraph)
    # this version of connected components uses Breadth First Traversal
    # with custom visitor type in order to improve performance.
    # one BFS is performed for each component.
    # This algorithm is linear in the number of edges of the graph
    # each edge is touched once. memory performance is a single allocation.
    # the return type is a vector of labels which can be used directly or
    # passed to components(a)
    nvg = nv(g)
    visitor = LightGraphs.ComponentVisitorVector(label, 0)
    colormap = zeros(Int,nvg)
    que = Vector{Int}()
    sizehint!(que, nvg)
    for v in 1:nvg
        if label[v] == 0
            visitor.labels[v] = v
            visitor.seed = v
            traverse_graph(g, BreadthFirst(), v, visitor; colormap=colormap, que=que)
        end
    end
    return label
end

"""components_dict(labels) converts an array of labels to a Dict{Int,Vector{Int}} of components

Arguments:
    c = labels[i] => vertex i belongs to component c.
Output:
    vs = d[c] => vertices in vs belong to component c.
"""
function components_dict(labels::Vector{Int})
    d = Dict{Int,Vector{Int}}()
    for (v,l) in enumerate(labels)
        vec = get(d, l, Vector{Int}())
        push!(vec, v)
        d[l] = vec
    end
    return d
end

"""
    components(labels::Vector{Int})

Converts an array of labels to a Vector{Vector{Int}} of components

Arguments:
    c = labels[i] => vertex i belongs to component c.
Output:
    vs = c[i] => vertices in vs belong to component i.
    a = d[i] => if labels[v]==i then v in c[a] end
"""
function components(labels::Vector{Int})
    d = Dict{Int, Int}()
    c = Vector{Vector{Int}}()
    i = 1
    for (v,l) in enumerate(labels)
        index = get!(d, l, i)
        if length(c) >= index
            push!(c[index], v)
        else
            push!(c, [v])
            i += 1
        end
    end
    return c, d
end

"""
    connected_components(g)

Returns the [connected components](https://en.wikipedia.org/wiki/Connectivity_(graph_theory))
of `g` as a vector of components, each represented by a
vector of vertices belonging to the component.
"""
function connected_components(g::SimpleGraph)
    label = zeros(Int, nv(g))
    connected_components!(label, g)
    c, d = components(label)
    return c
end

"""
    is_connected(g)

Returns `true` if `g` is connected.
For DiGraphs, this is equivalent to a test of weak connectivity.
"""
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
    Vector{Int}(),
    Vector{Int}(),
    zeros(Int, n),
    Vector{Vector{Int}}()
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
    components = Vector{Vector{Int}}()

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
    edge_values = Vector{Int}()

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

    component = Vector{Int}(nv(g))

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

    attracting = Vector{Int}()

    for v in vertices(cond)
        if outdegree(cond,v) == 0
            push!(attracting,v)
        end
    end
    return scc[attracting]
end

"""
    neighborhood(g, v::Int, d::Int; dir=:out)

Returns a vector of the vertices in `g` at distance less or equal to `d`
from `v`. If `g` is a `DiGraph` the `dir` optional argument specifies the edge direction
with respect to `v` (i.e. `:in` or `:out`) to be considered.
"""
function neighborhood(g::SimpleGraph, v::Int, d::Int; dir=:out)
    neig = Set{Int}(v)
    ∂neig = copy(neig)
    fneig = dir == :out ? out_neighbors : in_neighbors
    for l=1:d
        newneigs = Set{Int}()
        for i in ∂neig
            for j in fneig(g, i)
                if j ∉ neig
                    push!(newneigs, j)
                    push!(neig, j)
                end
            end
        end
        ∂neig = newneigs
    end
    return collect(neig)
end
