@testset "All Simple Paths" begin
    
    # single path
    g = path_graph(4)
    paths = all_simple_paths(g, 1, 4)
    @test Set(p for p in paths) == Set([[1, 2, 3, 4]])
    @test Set(collect(paths)) == Set([[1, 2, 3, 4]])
    @test 1 == length(paths)

    # two paths
    g = path_graph(4)
    add_vertex!(g)
    add_edge!(g, 3, 5)
    paths = all_simple_paths(g, 1, [4, 5])
    @test Set(p for p in paths) == Set([[1, 2, 3, 4], [1, 2, 3, 5]])
    @test Set(collect(paths)) == Set([[1, 2, 3, 4], [1, 2, 3, 5]])
    @test 2 == length(paths)

    # two paths with cutoff
    g = path_graph(4)
    add_vertex!(g)
    add_edge!(g, 3, 5)
    paths = all_simple_paths(g, 1, [4, 5], cutoff=3)
    @test Set(p for p in paths) == Set([[1, 2, 3, 4], [1, 2, 3, 5]])

    # two targets in line emits two paths
    g = path_graph(4)
    add_vertex!(g)
    paths = all_simple_paths(g, 1, [3, 4])
    @test Set(p for p in paths) == Set([[1, 2, 3], [1, 2, 3, 4]])

    # two paths digraph
    g = SimpleDiGraph(5)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 3, 5)    
    paths = all_simple_paths(g, 1, [4, 5])
    @test Set(p for p in paths) == Set([[1, 2, 3, 4], [1, 2, 3, 5]])

    # two paths digraph with cutoff
    g = SimpleDiGraph(5)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 3, 5)    
    paths = all_simple_paths(g, 1, [4, 5], cutoff=3)
    @test Set(p for p in paths) == Set([[1, 2, 3, 4], [1, 2, 3, 5]])

    # digraph with a cycle
    g = SimpleDiGraph(4)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 1)
    add_edge!(g, 2, 4)
    paths = all_simple_paths(g, 1, 4)
    @test Set(p for p in paths) == Set([[1, 2, 4]])

    # digraph with a cycle. paths with two targets share a node in the cycle.
    g = SimpleDiGraph(4)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 1)
    add_edge!(g, 2, 4)
    paths = all_simple_paths(g, 1, [3, 4])
    @test Set(p for p in paths) == Set([[1, 2, 3], [1, 2, 4]])

    # source equals targets
    g = SimpleGraph(4)
    paths = all_simple_paths(g, 1, 1)
    @test Set(p for p in paths) == Set([])

    # cutoff prones paths
    # Note, a path lenght is node - 1
    g = complete_graph(4)
    paths = all_simple_paths(g, 1, 2; cutoff=1)
    @test Set(p for p in paths) == Set([[1, 2]])

    paths = all_simple_paths(g, 1, 2; cutoff=2)
    @test Set(p for p in paths) == Set([[1, 2], [1, 3, 2], [1, 4, 2]])

    # non trivial graph
    g = SimpleDiGraph(6)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 4, 5)

    add_edge!(g, 1, 6)
    add_edge!(g, 2, 6)
    add_edge!(g, 2, 4)
    add_edge!(g, 6, 5)
    add_edge!(g, 5, 3)
    add_edge!(g, 5, 4)

    paths = all_simple_paths(g, 2, [3, 4])
    @test Set(p for p in paths) == Set([
         [2, 3],
         [2, 4, 5, 3],
         [2, 6, 5, 3],
         [2, 4],
         [2, 3, 4],
         [2, 6, 5, 4],
         [2, 6, 5, 3, 4],
    ])

    paths = all_simple_paths(g, 2, [3, 4], cutoff=3)
    @test Set(p for p in paths) == Set([
         [2, 3],
         [2, 4, 5, 3],
         [2, 6, 5, 3],
         [2, 4],
         [2, 3, 4],
         [2, 6, 5, 4],
    ])

    paths = all_simple_paths(g, 2, [3, 4], cutoff=2)
    @test Set(p for p in paths) == Set([
         [2, 3],
         [2, 4],
         [2, 3, 4],
    ])
    
end
