# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.
"""
    connected_components!(label, g)

Fill `label` with the `id` of the connected component in `g` to which it belongs.
Return a vector representing the component assigned to each vertex. The component
value is the smallest vertex ID in the component.
"""
function connected_components!(label::Vector{T}, g::AbstractGraph) where T<:Integer
    # this version of connected components uses Breadth First Traversal
    # with custom visitor type in order to improve performance.
    # one BFS is performed for each component.
    # This algorithm is linear in the number of edges of the graph
    # each edge is touched once. memory performance is a single allocation.
    # the return type is a vector of labels which can be used directly or
    # passed to components(a)
    nvg = nv(g)
    visitor = LightGraphs.ComponentVisitorVector(label, zero(T))
    colormap = fill(0, nvg)
    queue = Vector{T}()
    sizehint!(queue, nvg)
    for v in vertices(g)
        if label[v] == zero(T)
            visitor.labels[v] = v
            visitor.seed = v
            traverse_graph!(g, BreadthFirst(), v, visitor; vertexcolormap=colormap, queue=queue)
        end
    end
    return label
end

"""
    components_dict(labels)

Convert an array of labels to a map of component id to vertices, and return
a `Dict{Integer,Vector{Int}}` with each key corresponding to a given component id
and each value containing the vertices associated with that component.
"""
function components_dict(labels::Vector{T}) where T<:Integer
    d = Dict{T,Vector{T}}()
    for (v,l) in enumerate(labels)
        vec = get(d, l, Vector{T}())
        push!(vec, v)
        d[l] = vec
    end
    return d
end

"""
    components(labels)

Given a vector of component labels, return a vector of vectors representing the vertices associated
with a given component id.
"""
function components(labels::Vector{T}) where T<:Integer
    d = Dict{T, T}()
    c = Vector{Vector{T}}()
    i = one(T)
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

Return the [connected components](https://en.wikipedia.org/wiki/Connectivity_(graph_theory))
of `g` as a vector of components, with each element a vector of vertices
belonging to the component.
"""
function connected_components(g::AbstractGraph)
    T = eltype(g)
    label = zeros(T, nv(g))
    connected_components!(label, g)
    c, d = components(label)
    return c
end

"""
    is_connected(g)

Return `true` if `g` is connected. For directed graphs, this is equivalent to
a test of weak connectivity.
"""
function is_connected end
@traitfn is_connected(g::::(!IsDirected)) = ne(g)+1 >= nv(g) && length(connected_components(g)) == 1
@traitfn is_connected(g::::IsDirected) = ne(g)+1 >= nv(g) && is_weakly_connected(g)

"""
    weakly_connected_components(g)
Return the weakly connected components of the directed graph `g`. This
is equivalent to the connected components of the undirected equivalent of `g`.
"""
function weakly_connected_components end
@traitfn weakly_connected_components(g::::IsDirected) = connected_components(Graph(g))

"""
    is_weakly_connected(g)

Return `true` if the directed graph `g` is connected.
"""
function is_weakly_connected end
@traitfn is_weakly_connected(g::::IsDirected) = length(weakly_connected_components(g)) == 1

# Adapated from Graphs.jl
mutable struct TarjanVisitor{T<:Integer} <: AbstractGraphVisitor
    stack::Vector{T}
    onstack::BitVector
    lowlink::Vector{T}
    index::Vector{T}
    components::Vector{Vector{T}}
end

TarjanVisitor(n::T) where T<:Integer = TarjanVisitor(
    Vector{T}(),
    falses(n),
    Vector{T}(),
    zeros(T, n),
    Vector{Vector{T}}()
)

function discover_vertex!(vis::TarjanVisitor, v)
    vis.index[v] = length(vis.stack) + 1
    push!(vis.lowlink, length(vis.stack) + 1)
    push!(vis.stack, v)
    vis.onstack[v] = true
    return true
end

function examine_neighbor!(vis::TarjanVisitor, v, w, v_color::Int, w_color::Int, e_color::Int)
    if w_color != 0 && vis.onstack[w] # != 0 means seen
        while vis.index[w] > 0 && vis.index[w] < vis.lowlink[end]
            pop!(vis.lowlink)
        end
    end
    return true
end

function close_vertex!(vis::TarjanVisitor, v)
    if vis.index[v] == vis.lowlink[end]
        component = splice!(vis.stack, vis.index[v]:length(vis.stack))
        vis.onstack[component] = false
        pop!(vis.lowlink)
        push!(vis.components, component)
    end
    return true
end

"""
    strongly_connected_components(g)

Computes the strongly connected components of a directed graph `g`.
"""
function strongly_connected_components end
@traitfn function strongly_connected_components(g::::IsDirected)
    T = eltype(g)
    nvg = nv(g)
    cmap = zeros(Int, nvg)
    components = Vector{Vector{T}}()

    for v in vertices(g)
        if cmap[v] == 0 # 0 means not visited yet
            visitor = TarjanVisitor(nvg)
            traverse_graph!(g, DepthFirst(), v, visitor, vertexcolormap=cmap)
            for component in visitor.components
                push!(components, component)
            end
        end
    end
    return components
end

"""
    is_strongly_connected(g)

Return `true` if directed graph `g` is strongly connected.
"""
function is_strongly_connected end
@traitfn is_strongly_connected(g::::IsDirected) = length(strongly_connected_components(g)) == 1

"""
    period(g)

Return the (common) period for all nodes in a strongly connected directed graph.
Will throw an error if the graph is not strongly connected.
"""
function period end
@traitfn function period(g::::IsDirected)
    T = eltype(g)
    !is_strongly_connected(g) && error("Graph must be strongly connected")

    # First check if there's a self loop
    has_self_loops(g) && return 1

    g_bfs_tree  = bfs_tree(g,1)
    levels      = gdistances(g_bfs_tree,1)
    tree_diff   = difference(g,g_bfs_tree)
    edge_values = Vector{T}()

    divisor = 0
    for e in edges(tree_diff)
        @inbounds value = levels[src(e)] - levels[dst(e)] + 1
        divisor = gcd(divisor,value)
        isequal(divisor,1) && return 1
    end

    return divisor
end

"""
    condensation(g, scc)
Return the condensation graph of the strongly connected components `scc`
in graph `g`.
"""
function condensation end
@traitfn function condensation{T<:Integer}(g::::IsDirected, scc::Vector{Vector{T}})
    h = DiGraph{T}(length(scc))

    component = Vector{T}(nv(g))

    for (i,s) in enumerate(scc)
        @inbounds component[s] = i
    end

    @inbounds for e in edges(g)
        s, d = component[src(e)], component[dst(e)]
        if (s != d)
            add_edge!(h,s,d)
        end
    end
    return h
end

"""
    attracting_components(g)

Return the condensation graph associated with `g`.

The condensation `h` of a graph `g` is the directed graph where every node
in `h` represents a strongly connected component in `g`, and the presence
of an edge between between nodes in `h` indicates that there is at least one
edge between the associated strongly connected components in `g`. The node
numbering in `h` corresponds to the ordering of the components output from
`strongly_connected_components`.
"""
condensation(g) = condensation(g,strongly_connected_components(g))

"""
    attracting_components(g)
Return a vector of vectors of integers representing lists of attracting
components in `g`.

The attracting components are a subset of the strongly
connected components in which the components do not have any leaving edges.
"""
function attracting_components end
@traitfn function attracting_components(g::::IsDirected)
    T = eltype(g)
    scc  = strongly_connected_components(g)
    cond = condensation(g,scc)

    attracting = Vector{T}()

    for v in vertices(cond)
        if outdegree(cond,v) == 0
            push!(attracting,v)
        end
    end
    return scc[attracting]
end

mutable struct NeighborhoodVisitor{T<:Integer} <: AbstractGraphVisitor
    d::T
    neigs::Vector{T}
end

NeighborhoodVisitor(d::T) where T<:Integer = NeighborhoodVisitor(d, Vector{T}())

function examine_neighbor!(visitor::NeighborhoodVisitor, u::Integer, v::Integer, ucolor::Int, vcolor::Int, ecolor::Int)
    -ucolor > visitor.d && return false # color is negative for not-closed vertices
    if vcolor == 0
        push!(visitor.neigs, v)
    end
    return true
end


"""
    neighborhood(g, v, d)

Return a vector of the vertices in `g` at a geodesic distance less or equal to `d`
from `v`.

### Optional arguments
- `dir=:out`: If `g` is directed, this argument specifies the edge direction
with respect to `v` of the edges to be considered. Possible values: `:in` or `:out`.
"""
function neighborhood(g::AbstractGraph, v::Integer, d::Integer; dir=:out)
    @assert d >= 0 "Distance has to be greater then zero."
    T = eltype(g)
    visitor = NeighborhoodVisitor(d)
    push!(visitor.neigs, T(v))
    traverse_graph!(g, BreadthFirst(), v, visitor,
        vertexcolormap=Dict{T,Int}(), dir=dir)
    return visitor.neigs
end

"""
    isgraphical(degs)

Check whether the degree sequence `degs` is graphical, according to
[Erdös-Gallai condition](http://mathworld.wolfram.com/GraphicSequence.html).

### Performance
    Time complexity: ``\\mathcal{O}(|degs|^2)``
"""
function isgraphical(degs::Vector{Int})
    iseven(sum(degs)) || return false
    n = length(degs)
    for r=1:n-1
        cond = sum(i->degs[i], 1:r) <= r*(r-1) + sum(i->min(r,degs[i]), r+1:n)
        cond || return false
    end
    return true
end
