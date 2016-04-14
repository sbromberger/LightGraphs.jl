# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# Breadth-first search / traversal

#################################################
#
#  Breadth-first visit
#
#################################################

type BreadthFirst <: SimpleGraphVisitAlgorithm
end

function breadth_first_visit_impl!(
    graph::SimpleGraph,                 # the graph
    queue::Vector{Int},                 # an (initialized) queue that stores the active vertices
    vertexcolormap,                           # an (initialized) color-map to indicate status of vertices (-1=unseen, otherwise distance from root)
    edgecolormap,                           # an (initialized) color-map to indicate status of edges
    visitor::SimpleGraphVisitor,            # the visitor
    dir::Symbol)                        # direction [:in,:out]

    fneig = dir == :out ? out_neighbors : in_neighbors
    while !isempty(queue)
        u = shift!(queue)
        open_vertex!(visitor, u)
        u_color = vertexcolormap[u]

        for v in fneig(graph, u)
            v_color = get(vertexcolormap, v, -1)
            v_edge = Edge(u,v)
            e_color = get(edgecolormap, v_edge, -1)
            examine_neighbor!(visitor, u, v, u_color, v_color, e_color) || return
            edgecolormap[v_edge] = 1
            if v_color < 0
                vertexcolormap[v] = u_color + 1
                discover_vertex!(visitor, v) || return
                push!(queue, v)
            end
        end
        close_vertex!(visitor, u)
    end
end

function traverse_graph!(
    graph::SimpleGraph,
    alg::BreadthFirst,
    source,
    visitor::SimpleGraphVisitor;
    vertexcolormap = Dict{Int, Int}(),
    edgecolormap = DummyEdgeMap(),
    queue = Vector{Int}(),
    dir = :out)

    for s in source
        vertexcolormap[s] = 0
        discover_vertex!(visitor, s) || return
        push!(queue, s)
    end

    breadth_first_visit_impl!(graph, queue, vertexcolormap, edgecolormap
            , visitor, dir)
end


#################################################
#
#  Useful applications
#
#################################################

###########################################
# Get the map of the (geodesic) distances from vertices to source by BFS                  #
###########################################

immutable GDistanceVisitor <: SimpleGraphVisitor
end

"""
    gdistances!(g, source, dists) -> dists

Fills `dists` with the geodesic distances of vertices in  `g` from vertex/vertices `source`.
`dists` can be either a vector or a dictionary.
"""
function gdistances!(g::SimpleGraph, source, dists)
    visitor = GDistanceVisitor()
    traverse_graph!(g, BreadthFirst(), source, visitor, vertexcolormap=dists)
    return dists
end


"""
    gdistances(g, source) -> dists

Returns a vector filled with the geodesic distances of vertices in  `g` from vertex/vertices `source`.
For vertices in disconnected components the default distance is -1.
"""
gdistances(g, source) = gdistances!(g, source, fill(-1,nv(g)))


###########################################
# Constructing BFS trees                  #
###########################################

"""TreeBFSVisitorVector is a type for representing a BFS traversal
of the graph as a parents array. This type allows for a more performant implementation.
"""
type TreeBFSVisitorVector <: SimpleGraphVisitor
    tree::Vector{Int}
end

function TreeBFSVisitorVector(n::Int)
    return TreeBFSVisitorVector(fill(-1, n))
end

"""tree converts a parents array into a DiGraph"""
function tree(parents::AbstractVector)
    n = length(parents)
    t = DiGraph(n)
    for i in 1:n
        parent = parents[i]
        if parent > 0  && parent != i
            add_edge!(t, parent, i)
        end
    end
    return t
end

tree(parents::TreeBFSVisitorVector) = tree(parents.tree)

function examine_neighbor!(visitor::TreeBFSVisitorVector, u::Int, v::Int,
                            ucolor::Int, vcolor::Int, ecolor::Int)
    if u != v && vcolor < 0
        visitor.tree[v] = u
    end
    return true
end

function bfs_tree!(visitor::TreeBFSVisitorVector,
        g::SimpleGraph,
        s::Int;
        vertexcolormap = Dict{Int,Int}(),
        queue = Vector{Int}())
    # this version of bfs_tree! allows one to reuse the memory necessary to compute the tree
    # the output is stored in the visitor.tree array whose entries are the vertex id of the
    # parent of the index. This function checks if the scratch space is too small for the graph.
    # and throws an error if it is too small.
    # the source is represented in the output by a fixed point v[root] == root.
    # this function is considered a performant version of bfs_tree for useful when the parent
    # array is more helpful than a DiGraph struct, or when performance is critical.
    nvg = nv(g)
    length(visitor.tree) >= nvg || error("visitor.tree too small for graph")
    visitor.tree[s] = s
    traverse_graph!(g, BreadthFirst(), s, visitor; vertexcolormap=vertexcolormap, queue=queue)
end

"""Provides a breadth-first traversal of the graph `g` starting with source vertex `s`,
and returns a directed acyclic graph of vertices in the order they were discovered.

This function is a high level wrapper around bfs_tree!, use that function for more performance.
"""
function bfs_tree(g::SimpleGraph, s::Int)
    nvg = nv(g)
    visitor = TreeBFSVisitorVector(nvg)
    bfs_tree!(visitor, g, s)
    return tree(visitor)
end

############################################
# Connected Components with BFS            #
############################################
"""Performing connected components with BFS starting from seed"""
type ComponentVisitorVector <: SimpleGraphVisitor
    labels::Vector{Int}
    seed::Int
end

function examine_neighbor!(visitor::ComponentVisitorVector, u::Int, v::Int,
                            ucolor::Int, vcolor::Int, ecolor::Int)
    if u != v && vcolor <  0
        visitor.labels[v] = visitor.seed
    end
    return true
end

############################################
# Test graph for bipartiteness             #
############################################
type BipartiteVisitor <: SimpleGraphVisitor
    bipartitemap::Vector{UInt8}
    is_bipartite::Bool
end

BipartiteVisitor(n::Int) = BipartiteVisitor(zeros(UInt8,n), true)

function examine_neighbor!(visitor::BipartiteVisitor, u::Int, v::Int,
        ucolor::Int, vcolor::Int, ecolor::Int)
    if vcolor < 0
        visitor.bipartitemap[v] = (visitor.bipartitemap[u] == 1) ? 2 : 1
    else
        if visitor.bipartitemap[v] == visitor.bipartitemap[u]
            visitor.is_bipartite = false
        end
    end
    return visitor.is_bipartite
end

"""
    is_bipartite(g)
    is_bipartite(g, v)

Will return `true` if graph `g` is [bipartite](https://en.wikipedia.org/wiki/Bipartite_graph).
If a node `v` is specified, only the connected component to which it belongs is considered.
"""
function is_bipartite(g::SimpleGraph)
    cc = filter(x->length(x)>2, connected_components(g))
    vmap = Dict{Int,Int}()
    return all(x->_is_bipartite(g,x[1], vmap=vmap), cc)
end

is_bipartite(g::SimpleGraph, v::Int) = _is_bipartite(g, v)

_is_bipartite(g::SimpleGraph, v::Int; vmap = Dict{Int,Int}()) = _bipartite_visitor(g, v, vmap=vmap).is_bipartite

function _bipartite_visitor(g::SimpleGraph, s::Int; vmap=Dict{Int,Int}())
    nvg = nv(g)
    visitor = BipartiteVisitor(nvg)
    for v in keys(vmap) #have to reset vmap, otherway problems with digraphs
        vmap[v] = -1
    end
    traverse_graph!(g, BreadthFirst(), s, visitor, vertexcolormap=vmap)
    return visitor
end

"""
If the graph is bipartite returns a vector `c`  of size `nv(g)` containing
the assignment of each vertex to one of the two sets (`c[i] == 1` or `c[i]==2`).
If `g` is not bipartite returns an empty vector.
"""
function bipartite_map(g::SimpleGraph)
    cc = connected_components(g)
    visitors = [_bipartite_visitor(g, x[1]) for x in cc]
    !all([v.is_bipartite for v in visitors]) && return zeros(Int, 0)
    m = zeros(Int, nv(g))
    for i=1:nv(g)
        m[i] = any(v->v.bipartitemap[i] == 1, visitors) ? 2 : 1
    end
    m
end
