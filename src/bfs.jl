# Parts of this code were taken / derived from Graphs.jl:
# > Graphs.jl is licensed under the MIT License:
#
# > Copyright (c) 2012: John Myles White and other contributors.
# >
# > Permission is hereby granted, free of charge, to any person obtaining
# > a copy of this software and associated documentation files (the
# > "Software"), to deal in the Software without restriction, including
# > without limitation the rights to use, copy, modify, merge, publish,
# > distribute, sublicense, and/or sell copies of the Software, and to
# > permit persons to whom the Software is furnished to do so, subject to
# > the following conditions:
# >
# > The above copyright notice and this permission notice shall be
# > included in all copies or substantial portions of the Software.
# >
# > THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# > EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# > MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# > NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# > LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# > OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# > WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Breadth-first search / traversal

#################################################
#
#  Breadth-first visit
#
#################################################

type BreadthFirst <: AbstractGraphVisitAlgorithm
end

function breadth_first_visit_impl!(
    graph::AbstractGraph,   # the graph
    queue,                  # an (initialized) queue that stores the active vertices
    colormap::Vector{Int},          # an (initialized) color-map to indicate status of vertices
    visitor::AbstractGraphVisitor)  # the visitor

    while !isempty(queue)
        u = dequeue!(queue)
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
                enqueue!(queue, v)
            end
        end

        colormap[u] = 2
        close_vertex!(visitor, u)
    end
    nothing
end


function traverse_graph(
    graph::AbstractGraph,
    alg::BreadthFirst,
    s::Int,
    visitor::AbstractGraphVisitor;
    colormap = zeros(Int, nv(graph)))

    que = Queue(Int)

    colormap[s] = 1
    if !discover_vertex!(visitor, s)
        return
    end
    enqueue!(que, s)

    breadth_first_visit_impl!(graph, que, colormap, visitor)
end


function traverse_graph(
    graph::AbstractGraph,
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
        enqueue!(que, s)
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
    graph::AbstractGraph
    dists::Vector{Int}
end

function examine_neighbor!(visitor::GDistanceVisitor, u, v, vcolor::Int, ecolor::Int)
    if vcolor == 0
        g = visitor.graph
        dists = visitor.dists
        dists[v] = dists[u] + 1
    end
end

function gdistances!{DMap}(graph::AbstractGraph, s::Int, dists::DMap)
    visitor = GDistanceVisitor(graph, dists)
    dists[s] = 0
    traverse_graph(graph, BreadthFirst(), s, visitor)
    dists
end

function gdistances!{DMap}(graph::AbstractGraph, sources::AbstractVector{Int}, dists::DMap)
    visitor = GDistanceVisitor(graph, dists)
    for s in sources
        dists[s] = 0
    end
    traverse_graph(graph, BreadthFirst(), sources, visitor)
    dists
end

function gdistances(graph::AbstractGraph, sources; defaultdist::Int=-1)
    dists = fill(defaultdist, nv(graph))
    gdistances!(graph, sources, dists)
end
