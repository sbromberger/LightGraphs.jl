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
    graph::SimpleGraph,   # the graph
    queue::Vector{Int},                  # an (initialized) queue that stores the active vertices
    colormap::Vector{Int},          # an (initialized) color-map to indicate status of vertices
    visitor::SimpleGraphVisitor)  # the visitor

    while !isempty(queue)
        u = shift!(queue)
        open_vertex!(visitor, u)

        for v in out_neighbors(graph, u)
            v_color::Int = colormap[v]
            # TODO: Incorporate edge colors to BFS
            if !(examine_neighbor!(visitor, u, v, v_color, -1))
                return
            end

            if v_color == 0
                colormap[v] = 1
                if !discover_vertex!(visitor, v)
                    return
                end
                push!(queue, v)
            end
        end

        colormap[u] = 2
        close_vertex!(visitor, u)
    end
    nothing
end


function traverse_graph(
    graph::SimpleGraph,
    alg::BreadthFirst,
    s::Int,
    visitor::SimpleGraphVisitor;
    colormap = zeros(Int, nv(graph)))

    que = @compat Vector{Int}()

    colormap[s] = 1
    if !discover_vertex!(visitor, s)
        return
    end
    push!(que, s)

    breadth_first_visit_impl!(graph, que, colormap, visitor)
end


function traverse_graph(
    graph::SimpleGraph,
    alg::BreadthFirst,
    sources::AbstractVector{Int},
    visitor::SimpleGraphVisitor;
    colormap = zeros(Int, nv(graph)))

    que = @compat Vector{Int}()

    for s in sources
        colormap[s] = 1
        if !discover_vertex!(visitor, s)
            return
        end
        push!(que, s)
    end

    breadth_first_visit_impl!(graph, que, colormap, visitor)
end


#################################################
#
#  Useful applications
#
#################################################

# Get the map of the (geodesic) distances from vertices to source by BFS

immutable GDistanceVisitor <: SimpleGraphVisitor
    graph::SimpleGraph
    dists::Vector{Int}
end

function examine_neighbor!(visitor::GDistanceVisitor, u, v, vcolor::Int, ecolor::Int)
    if vcolor == 0
        g = visitor.graph
        dists = visitor.dists
        dists[v] = dists[u] + 1
    end
    return true
end

function gdistances!{DMap}(graph::SimpleGraph, s::Int, dists::DMap)
    visitor = GDistanceVisitor(graph, dists)
    dists[s] = 0
    traverse_graph(graph, BreadthFirst(), s, visitor)
    return dists
end

function gdistances!{DMap}(graph::SimpleGraph, sources::AbstractVector{Int}, dists::DMap)
    visitor = GDistanceVisitor(graph, dists)
    for s in sources
        dists[s] = 0
    end
    traverse_graph(graph, BreadthFirst(), sources, visitor)
    return dists
end

function gdistances(graph::SimpleGraph, sources; defaultdist::Int=-1)
    dists = fill(defaultdist, nv(graph))
    gdistances!(graph, sources, dists)
end

type TreeBFSVisitor <:SimpleGraphVisitor
    tree::DiGraph
end

# Return the DAG representing the traversal of a graph.

TreeBFSVisitor(n::Int) = TreeBFSVisitor(DiGraph(n))

function examine_neighbor!(visitor::TreeBFSVisitor, u::Int, v::Int, vcolor::Int, ecolor::Int)
    # println("discovering $u -> $v, vcolor = $vcolor, ecolor = $ecolor")
    if u != v && vcolor == 0
        add_edge!(visitor.tree, u, v)
    end
    return true
end

function close_vertex!(visitor::TreeBFSVisitor, e::Edge)
    u = src(e)
    v = dst(e)
    # println("visiting $u -> $v")
    if visitor.bipartitemap[v] == visitor.bipartitemap[u]
        visitor.is_bipartite = false
    end
    return true
end

function bfs_tree(g::SimpleGraph, s::Int)
    nvg = nv(g)
    visitor = TreeBFSVisitor(nvg)
    traverse_graph(g, BreadthFirst(), s, visitor)
    return visitor.tree
end


# Test graph for bipartiteness

type BipartiteVisitor <: SimpleGraphVisitor
    bipartitemap::Vector{UInt8}
    is_bipartite::Bool
end

BipartiteVisitor(n::Int) = BipartiteVisitor(zeros(UInt8,n), true)

function examine_neighbor!(visitor::BipartiteVisitor, u::Int, v::Int, vcolor::Int, ecolor::Int)
    if vcolor == 0
        visitor.bipartitemap[v] = (visitor.bipartitemap[u] == 1)? 2:1
    else
        if visitor.bipartitemap[v] == visitor.bipartitemap[u]
            visitor.is_bipartite = false
        end
    end
    return visitor.is_bipartite
end

function is_bipartite(g::SimpleGraph, s::Int)
    nvg = nv(g)
    visitor = BipartiteVisitor(nvg)
    traverse_graph(g, BreadthFirst(), s, visitor)
    return visitor.is_bipartite
end

function is_bipartite(g::SimpleGraph)
    nvg = nv(g)
    for v in vertices(g)
        if !is_bipartite(g, v)
            return false
        end
    end
    return true
end
