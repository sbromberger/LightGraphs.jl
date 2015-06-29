using LightGraphs
using Base.Test

# Define an new graph type that shares nothing in common
# with the built-in Graph and DiGraph types. The goal of
# this test is to check that the AbstractGraph interface
# is sufficiently generic and does not rely on internal
# fields of the new Graph type (which won't exist)

# Our graph is a grid where each vertex is connected to
# its neighbours. The edges are undirected.
# Vertex labelling is from, e.g.
# 1 2 3
# 4 5 6
# 7 8 9
type GridGraph <: AbstractGraph
    gridsize::Int
end

# Implement minimal part of interface
grid_to_ind(g::GridGraph,r,c) =(r-1)*g.gridsize + c
LightGraphs.vertices(g::GridGraph) = 1:g.gridsize^2
function LightGraphs.edges(g::GridGraph)
    all_edges = Edge[]
    # Only add edges right and down
    for row in 1:g.gridsize, col in 1:g.gridsize
        # Right edge, if applicable
        if col < g.gridsize
            push!(all_edges, Edge(grid_to_ind(g,row,col),
                                    grid_to_ind(g,row,col+1)))
        end
        # Down edge, if applicable
        if row < g.gridsize
            push!(all_edges, Edge(grid_to_ind(g,row,col),
                                    grid_to_ind(g,row+1,col)))
        end
    end
    return all_edges
end
LightGraphs.is_directed(g::GridGraph) = false
function LightGraphs.fadj(g::GridGraph, v::Int)
    N = g.gridsize
    fadj_verts = Int[]
    # Up edge?
    v > N && push!(fadj_verts, v-N)
    # Down edge?
    v <= N^2 - N && push!(fadj_verts, v+N)
    # Left edge?
    v % N != 1 && push!(fadj_verts, v-1)
    # Right edge?
    v % N != 0 && push!(fadj_verts, v+1)
    return fadj_verts
end
LightGraphs.badj(g::GridGraph, v::Int) = LightGraphs.fadj(g,v)


# Create a small grid graph
N = 4
g = GridGraph(N)


# Basic functions & measurements
@test !is_directed(g)
@test nv(g) == N^2
@test ne(g) == 2*(N-1)*N
@test has_edge(g, Edge(1,2))
@test has_edge(g, Edge(2,1))
@test !has_edge(g, Edge(1,3))
@test has_edge(g, 1, 2)
@test has_edge(g, 2, 1)
@test !has_edge(g, Edge(1, 3))
@test has_vertex(g, N^2)
@test Edge(2,1) in in_edges(g, 1)
@test Edge(1,2) in out_edges(g, 1)
@test degree(g,1) == 2
@test indegree(g,1) == 2
@test density(GridGraph(2)) == 2/3  # Easier to verify!
@test 2 in neighbors(g,1)
@test 2 in in_neighbors(g,1)
@test 2 in out_neighbors(g,1)
@test 2 in common_neighbors(g,1,3)

# Pathing and traversal
@test test_cyclic_by_dfs(g) == true
@test mincut(g)[2] == 2
@test length(a_star(g, 1, N^2)) == (N-1)*2
@test maximum(dijkstra_shortest_paths(g, 1).dists) == 6
@test eccentricity(g,1) == 6
@test radius(GridGraph(2)) == 2
@test diameter(g) == 6
@test length(center(GridGraph(3))) == 1
@test 1 in periphery(g)

# Centrality measures - just check they run
@test degree_centrality(g) != nothing
@test closeness_centrality(g) != nothing
@test betweenness_centrality(g) != nothing
@test katz_centrality(g) != nothing
# @show pagerank(GridGraph(3)) - only created for DiGraphs

# Linear aglebra
@test adjacency_matrix(GridGraph(2)) ==[0 1 1 0;
                                        1 0 0 1;
                                        1 0 0 1;
                                        0 1 1 0]
#@show full(laplacian_matrix(GridGraph(2)))
# Is defined, but the way the code is written in src/linalg and the
# type hierachy is right now requires us to implement ourselves