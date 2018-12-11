@testset "Eulerian traits and circuits" begin

    # Test with undirected graphs
    # Simple connected graph with cyclic and acyclic part
    g1 = SimpleGraph(5)
    add_edge!(g1, 2, 1)
    add_edge!(g1, 1, 3)
    add_edge!(g1, 3, 2)
    add_edge!(g1, 1, 4)
    add_edge!(g1, 4, 5)
    @test @inferred has_eulerian_trail(g1)
    @test @inferred !has_eulerian_circuit(g1)

    # Cycles with common vertex
    g2 = SimpleGraph(5)
    add_edge!(g2, 2, 1)
    add_edge!(g2, 1, 3)
    add_edge!(g2, 3, 2)
    add_edge!(g2, 1, 4)
    add_edge!(g2, 4, 5)
    add_edge!(g2, 5, 1)
    @test @inferred has_eulerian_trail(g2)
    @test @inferred has_eulerian_circuit(g2)

    # Cycles with common edge
    g3 = SimpleGraph(5)
    add_edge!(g3, 2, 1)
    add_edge!(g3, 1, 3)
    add_edge!(g3, 3, 2)
    add_edge!(g3, 1, 4)
    add_edge!(g3, 4, 5)
    add_edge!(g3, 2, 4)
    @test @inferred !has_eulerian_trail(g3)
    @test @inferred !has_eulerian_circuit(g3)

    # Simple Cyclic graph
    g4 = SimpleGraph(3)
    add_edge!(g4, 1, 2)
    add_edge!(g4, 2, 3)
    add_edge!(g4, 3, 1)
    @test @inferred has_eulerian_trail(g4)
    @test @inferred has_eulerian_circuit(g4)

    # SimpleGraph with no edge
    g5 = SimpleGraph(3)
    @test @inferred has_eulerian_trail(g5)
    @test @inferred has_eulerian_circuit(g5)

    #SimpleGraph with disconnected components
    g6 = SimpleGraph(6)
    add_edge!(g6, 2, 1)
    add_edge!(g6, 1, 3)
    add_edge!(g6, 3, 2)
    add_edge!(g6, 4, 5)
    add_edge!(g6, 5, 6)
    add_edge!(g6, 6, 4)
    @test @inferred !has_eulerian_trail(g6)
    @test @inferred !has_eulerian_circuit(g6)

    #SimpleGraph with zero node
    g7 = SimpleGraph(0)
    @test @inferred has_eulerian_trail(g7)
    @test @inferred has_eulerian_circuit(g7)
    
    #SimpleGraph with one node and no edge
    g8 = SimpleGraph(1)
    @test @inferred has_eulerian_trail(g8)
    @test @inferred has_eulerian_circuit(g8)

    #SimpleGraph with multiedge
    g9 = SimpleGraph(2)
    add_edge!(g9, 1, 1)
    add_edge!(g9, 1, 2)
    add_edge!(g9, 1, 2)
    add_edge!(g9, 2, 2)
    @test @inferred has_eulerian_trail(g9)
    @test @inferred has_eulerian_circuit(g9)

    #SimpleGraph with self-loops
    g10 = SimpleGraph(3)
    add_edge!(g10, 1, 1)
    add_edge!(g10, 1, 1)
    add_edge!(g10, 2, 2)
    add_edge!(g10, 3, 3)
    @test @inferred !has_eulerian_trail(g10)
    @test @inferred !has_eulerian_circuit(g10)

    # Test with directed graphs
    # Simple Cyclic graph
    dg1 = SimpleDiGraph(4)
    add_edge!(dg1, 1, 2)
    add_edge!(dg1, 2, 3)
    add_edge!(dg1, 3, 1)
    add_edge!(dg1, 3, 4)
    @test @inferred has_eulerian_trail(dg1)
    @test @inferred !has_eulerian_circuit(dg1)

    # SimpleDiGraph with no edge
    dg2 = SimpleDiGraph(3)
    @test @inferred has_eulerian_trail(dg2)
    @test @inferred has_eulerian_circuit(dg2)

    #SimpleDiGraph with disconnected components
    dg3 = SimpleDiGraph(6)
    add_edge!(dg3, 2, 1)
    add_edge!(dg3, 1, 3)
    add_edge!(dg3, 3, 2)
    add_edge!(dg3, 4, 5)
    add_edge!(dg3, 5, 6)
    add_edge!(dg3, 6, 4)
    @test @inferred !has_eulerian_trail(dg3)
    @test @inferred !has_eulerian_circuit(dg3)

    #SimpleDiGraph with zero node
    dg4 = SimpleDiGraph(0)
    @test @inferred has_eulerian_trail(dg4)
    @test @inferred has_eulerian_circuit(dg4)
    
    #SimpleDiGraph with one node and no edge
    dg5 = SimpleDiGraph(1)
    @test @inferred has_eulerian_trail(dg5)
    @test @inferred has_eulerian_circuit(dg5)

    #SimpleDiGraph with self-loops
    dg6 = SimpleDiGraph(3)
    add_edge!(dg6, 1, 1)
    add_edge!(dg6, 1, 1)
    add_edge!(dg6, 2, 2)
    add_edge!(dg6, 3, 3)
    @test @inferred !has_eulerian_trail(dg6)
    @test @inferred !has_eulerian_circuit(dg6)

end
