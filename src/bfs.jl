# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# Breadth-first search / traversal

#################################################
#
#  Breadth-first visit
#
#################################################

type BreadthFirst <: AbstractGraphVisitAlgorithm
end

function breadth_first_visit_impl!(
    graph::AbstractGeneralGraph,   # the graph
    queue,                  # an (initialized) queue that stores the active vertices
    colormap::Vector{Int},          # an (initialized) color-map to indicate status of vertices
    visitor::AbstractGraphVisitor)  # the visitor

    while !isempty(queue)
        u = DataStructures.dequeue!(queue)
        open_vertex!(visitor, u)

        for v in out_neighbors(graph, u)
            v_color::Int = colormap[v]
            # TODO: Incorporate edge colors to BFS
            examine_neighbor!(visitor, u, v, v_color, -1)

            if v_color == 0
                colormap[v] = 1
                if !discover_vertex!(visitor, v)
                    return
                end
                DataStructures.enqueue!(queue, v)
            end
        end

        colormap[u] = 2
        close_vertex!(visitor, u)
    end
    nothing
end


function traverse_graph(
    graph::AbstractGeneralGraph,
    alg::BreadthFirst,
    s::Int,
    visitor::AbstractGraphVisitor;
    colormap = zeros(Int, nv(graph)))

    que = Queue(Int)

    colormap[s] = 1
    if !discover_vertex!(visitor, s)
        return
    end
    DataStructures.enqueue!(que, s)

    breadth_first_visit_impl!(graph, que, colormap, visitor)
end


function traverse_graph(
    graph::AbstractGeneralGraph,
    alg::BreadthFirst,
    sources::AbstractVector{Int},
    visitor::AbstractGraphVisitor;
    colormap = zeros(Int, nv(graph)))

    que = Queue(Int)

    for s in sources
        colormap[s] = 1
        if !discover_vertex!(visitor, s)
            return
        end
        DataStructures.enqueue!(que, s)
    end

    breadth_first_visit_impl!(graph, que, colormap, visitor)
end


#################################################
#
#  Useful applications
#
#################################################

# Get the map of the (geodesic) distances from vertices to source by BFS

immutable GDistanceVisitor <: AbstractGraphVisitor
    graph::AbstractGeneralGraph
    dists::Vector{Int}
end

function examine_neighbor!(visitor::GDistanceVisitor, u, v, vcolor::Int, ecolor::Int)
    if vcolor == 0
        g = visitor.graph
        dists = visitor.dists
        dists[v] = dists[u] + 1
    end
end

function gdistances!{DMap}(graph::AbstractGeneralGraph, s::Int, dists::DMap)
    visitor = GDistanceVisitor(graph, dists)
    dists[s] = 0
    traverse_graph(graph, BreadthFirst(), s, visitor)
    dists
end

function gdistances!{DMap}(graph::AbstractGeneralGraph, sources::AbstractVector{Int}, dists::DMap)
    visitor = GDistanceVisitor(graph, dists)
    for s in sources
        dists[s] = 0
    end
    traverse_graph(graph, BreadthFirst(), sources, visitor)
    dists
end

function gdistances(graph::AbstractGeneralGraph, sources; defaultdist::Int=-1)
    dists = fill(defaultdist, nv(graph))
    gdistances!(graph, sources, dists)
end
