# Test of Depth-first visit

using LightGraphs
using Base.Test

type GraphTest
    graph_edges::Array{@compat(Tuple{Int,Int}),1}
    dfs_path::Array{Int,1}
    is_cyclic::Bool
    topo_sort::Array{Int,1}

    GraphTest(gedges, dfspath, iscyclic, toposort) =
        new(gedges, dfspath, iscyclic, toposort)
end

dir_acyclic = GraphTest(
    [(1,2), (1,3), (1,6), (2,4), (2,5), (3,5), (3,6)],
    [1, 2, 4, 5, 3, 6],
    false,
    [1,3,6,2,5,4])
undir_acyclic = GraphTest(
    [(1,2), (1,3), (1,6), (2,4), (2,5)],
    [],
    false,
    [1,6,3,2,5,4])
cyclic  = GraphTest(
    [(1,2), (1,3), (1,6), (2,4), (2,5), (3,5), (3,6), (5,1)],
    [1, 2, 4, 5, 3, 6],
    true,
    [])

testsets = [
    (true, [dir_acyclic, cyclic]),
    (false, [undir_acyclic, cyclic])]

for tset in testsets
    is_dir, graphtests = tset

    for gtest in graphtests
        if is_dir
            g = DiGraph(6)
        else
            g = Graph(6)
        end
        map((edg) -> add_edge!(g, edg[1], edg[2]), gtest.graph_edges)

        # gEx = graph(ExVertex[], ExEdge{ExVertex}[], is_directed = is_dir)
        # map((x) -> add_vertex!(gEx, "edge:" * string(x)), 1:6)
        # V = vertices(gEx)
        # map((edg) -> add_edge!(gEx, V[edg[1]], V[edg[2]]), gtest.graph_edges)


        # DFS traversal
        if !isempty(gtest.dfs_path)
            vs1 = visited_vertices(g, DepthFirst(), 1)
            @assert vs1 == gtest.dfs_path

            # vs2 = visited_vertices(gEx, DepthFirst(), V[1])
            # @assert vs2 == collect(map((x) -> gEx.vertices[x], gtest.dfs_path))
        end

        # Cyclic test
        @assert test_cyclic_by_dfs(g) == gtest.is_cyclic
        # @assert test_cyclic_by_dfs(gEx) == gtest.is_cyclic

        # Topological sort
        if gtest.is_cyclic
            @test_throws ArgumentError topological_sort_by_dfs(g)  # g2 contains a loop
            # @test_throws ArgumentError topological_sort_by_dfs(gEx)  # g2 contains a loop

        elseif !isempty(gtest.topo_sort)
            ts = topological_sort_by_dfs(g)
            @assert ts == gtest.topo_sort

            # ts = topological_sort_by_dfs(gEx)
            # @assert [vertex_index(e,gEx) for e in ts] == gtest.topo_sort
        end
    end
end
