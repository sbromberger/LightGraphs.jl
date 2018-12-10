@testset "Eulerian traits and circuits" begin

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

    #SimpleGraph with self-loops and multiedge
    g9 = SimpleGraph(2)
    add_edge!(g9, 1, 1)
    add_edge!(g9, 1, 2)
    add_edge!(g9, 1, 2)
    add_edge!(g9, 2, 2)
    @test @inferred has_eulerian_trail(g9)
    @test @inferred has_eulerian_circuit(g9)

end
