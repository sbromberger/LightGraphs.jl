@testset "Eulerian traits and circuits" begin

    # Simple connected graph with cyclic and acyclic part
    g1 = Graph(5)
    add_edge!(g1,2,1)
    add_edge!(g1,1,3)
    add_edge!(g1,3,2)
    add_edge!(g1,1,4)
    add_edge!(g1,4,5)
    @test LightGraphs.eulerian_trail(g1) == true
    @test LightGraphs.eulerian_circuit(g1) == false

    # Cycles with common vertex
    g2 = Graph(5)
    add_edge!(g2,2,1)
    add_edge!(g2,1,3)
    add_edge!(g2,3,2)
    add_edge!(g2,1,4)
    add_edge!(g2,4,5)
    add_edge!(g2,5,1)
    @test eulerian_trail(g2) == true
    @test eulerian_circuit(g2) == true

    # Cycles with common edge
    g3 = Graph(5)
    add_edge!(g3,2,1)
    add_edge!(g3,1,3)
    add_edge!(g3,3,2)
    add_edge!(g3,1,4)
    add_edge!(g3,4,5)
    add_edge!(g3,2,4)
    @test eulerian_trail(g3) == false
    @test eulerian_circuit(g3) == false

    # Simple Cyclic graph
    g4 = Graph(3)
    add_edge!(g4,1,2)
    add_edge!(g4,2,3)
    add_edge!(g4,3,1)
    @test eulerian_trail(g4) == true
    @test eulerian_circuit(g4) == true

    # Graph with no edge
    g5 = Graph(3)
    @test eulerian_trail(g5) == true
    @test eulerian_circuit(g5) == true

    #Graph with disconnected components
    g6 = Graph(6)
    add_edge!(g6,2,1)
    add_edge!(g6,1,3)
    add_edge!(g6,3,2)
    add_edge!(g6,4,5)
    add_edge!(g6,5,6)
    add_edge!(g6,6,4)
    @test eulerian_trail(g6) == false
    @test eulerian_circuit(g6) == false
end