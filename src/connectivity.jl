# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

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

weakly_connected_components(g::DiGraph) = connected_components(Graph(g))

# Adapated from Graphs.jl
type TarjanVisitor <: AbstractGraphVisitor
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

# Computes the strongly connected components of a directed graph.
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
