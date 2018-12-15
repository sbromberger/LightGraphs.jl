@testset "Eulerian traits and circuits" begin

    function check_circuit(original_graph, circuit)
        
        graph = copy(original_graph)
        length(circuit) < 2 && return true
        circuit[1]!=circuit[end] && return false
        start = circuit[1]
        splice!(circuit, 1)
        while !isempty(circuit)
            v = circuit[1]
            rem_edge!(graph, start, v)
            start = v
            splice!(circuit, 1)
        end
        iszero(ne(graph)) && return true
        return false
    end

    function check_trail(original_graph, trail)
        
        graph = copy(original_graph)
        length(trail) < 2 && return true
        start = trail[1]
        splice!(trail, 1)
        while !isempty(trail)
            v = trail[1]
            rem_edge!(graph, start, v)
            start = v
            splice!(trail, 1)
        end
        iszero(ne(graph)) && return true
        return false
    end

    # Test with undirected graphs
    # Simple connected graph with cyclic and acyclic part
    g1 = SimpleGraph(5)
    add_edge!(g1, 2, 1)
    add_edge!(g1, 1, 3)
    add_edge!(g1, 3, 2)
    add_edge!(g1, 1, 4)
    add_edge!(g1, 4, 5)
    for g in testgraphs(g1)
        @test @inferred has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test_throws ArgumentError eulerian_circuit(g)
    end
    
    # Cycles with common vertex
    g2 = SimpleGraph(5)
    add_edge!(g2, 2, 1)
    add_edge!(g2, 1, 3)
    add_edge!(g2, 3, 2)
    add_edge!(g2, 1, 4)
    add_edge!(g2, 4, 5)
    add_edge!(g2, 5, 1)
    for g in testgraphs(g2)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    # Cycles with common edge
    g3 = SimpleGraph(5)
    add_edge!(g3, 2, 1)
    add_edge!(g3, 1, 3)
    add_edge!(g3, 3, 2)
    add_edge!(g3, 1, 4)
    add_edge!(g3, 4, 5)
    add_edge!(g3, 2, 4)
    for g in testgraphs(g3)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    # Simple Cyclic graph
    g4 = SimpleGraph(3)
    add_edge!(g4, 1, 2)
    add_edge!(g4, 2, 3)
    add_edge!(g4, 3, 1)
    for g in testgraphs(g4)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    # SimpleGraph with no edge
    g5 = SimpleGraph(3)
    for g in testgraphs(g5)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    #SimpleGraph with disconnected components
    g6 = SimpleGraph(6)
    add_edge!(g6, 2, 1)
    add_edge!(g6, 1, 3)
    add_edge!(g6, 3, 2)
    add_edge!(g6, 4, 5)
    add_edge!(g6, 5, 6)
    add_edge!(g6, 6, 4)
    for g in testgraphs(g6)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #SimpleGraph with zero node
    g7 = SimpleGraph(0)
    for g in testgraphs(g7)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    #SimpleGraph with one node and no edge
    g8 = SimpleGraph(1)
    for g in testgraphs(g8)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    #SimpleGraph with self-loops
    g9 = SimpleGraph(2)
    add_edge!(g9, 1, 1)
    add_edge!(g9, 1, 2)
    add_edge!(g9, 2, 2)
    for g in testgraphs(g9)
        @test @inferred has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #SimpleGraph with self-loops
    g10 = SimpleGraph(3)
    add_edge!(g10, 1, 1)
    add_edge!(g10, 1, 1)
    add_edge!(g10, 2, 2)
    add_edge!(g10, 3, 3)
    for g in testgraphs(g10)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #Complete graph with odd number of nodes
    g11 = CompleteGraph(11)
    for g in testgraphs(g11)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    #Complete graph with even number of nodes
    g12 = CompleteGraph(12)
    for g in testgraphs(g12)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #Star graph
    g13 = StarGraph(10)
    for g in testgraphs(g13)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #Path graph
    g14 = PathGraph(11)
    for g in testgraphs(g14)
        @test @inferred has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #Wheel graph
    g15 = WheelGraph(11)
    for g in testgraphs(g15)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #Complete Bipartite Graph with all even-odd combination of vertices
    g16 = CompleteBipartiteGraph(10, 12)
    for g in testgraphs(g16)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    g17 = CompleteBipartiteGraph(10, 11)
    for g in testgraphs(g17)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    g18 = CompleteBipartiteGraph(11, 10)
    for g in testgraphs(g18)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    g19 = CompleteBipartiteGraph(11, 13)
    for g in testgraphs(g19)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #Chvatal Graph
    g20 = smallgraph(:chvatal)
    for g in testgraphs(g20)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    #Frucht Graph
    g21 = smallgraph(:frucht)
    for g in testgraphs(g21)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #Simple House Graph
    g22 = smallgraph(:house)
    for g in testgraphs(g22)
        @test @inferred has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test_throws ArgumentError eulerian_circuit(g)
    end

    # Test with directed graphs
    # Simple Cyclic graph
    dg1 = SimpleDiGraph(4)
    add_edge!(dg1, 1, 2)
    add_edge!(dg1, 2, 3)
    add_edge!(dg1, 3, 1)
    add_edge!(dg1, 3, 4)
    for g in testdigraphs(dg1)
        @test @inferred has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test_throws ArgumentError eulerian_circuit(g)
    end

    # SimpleDiGraph with no edge
    dg2 = SimpleDiGraph(3)
    for g in testdigraphs(dg2)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    #SimpleDiGraph with disconnected components
    dg3 = SimpleDiGraph(6)
    add_edge!(dg3, 2, 1)
    add_edge!(dg3, 1, 3)
    add_edge!(dg3, 3, 2)
    add_edge!(dg3, 4, 5)
    add_edge!(dg3, 5, 6)
    add_edge!(dg3, 6, 4)
    for g in testdigraphs(dg3)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end
    
    #SimpleDiGraph with zero node
    dg4 = SimpleDiGraph(0)
    for g in testdigraphs(dg4)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    #SimpleDiGraph with one node and no edge
    dg5 = SimpleDiGraph(1)
    for g in testdigraphs(dg5)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    #SimpleDiGraph with self-loops
    dg6 = SimpleDiGraph(3)
    add_edge!(dg6, 1, 1)
    add_edge!(dg6, 1, 1)
    add_edge!(dg6, 2, 2)
    add_edge!(dg6, 3, 3)
    for g in testdigraphs(dg6)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #Complete graph with odd number of nodes
    dg7 = CompleteDiGraph(11)
    for g in testdigraphs(dg7)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    #Complete graph with even number of nodes
    dg8 = CompleteDiGraph(12)
    for g in testdigraphs(dg8)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    #Star graph
    dg9 = StarDiGraph(10)
    for g in testdigraphs(dg9)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #Path graph
    dg10 = PathDiGraph(11)
    for g in testdigraphs(dg10)
        @test @inferred has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #Wheel graph
    dg11 = WheelDiGraph(11)
    for g in testdigraphs(dg11)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

    #Complete graph with even number of nodes
    dg12 = CycleDiGraph(10)
    for g in testdigraphs(dg12)
        @test @inferred has_eulerian_trail(g)
        @test @inferred has_eulerian_circuit(g)
        @test @inferred check_trail(g, eulerian_trail(g))
        @test @inferred check_circuit(g, eulerian_circuit(g))
    end

    #Directed Truncated Tetrahedron Graph
    dg13 = smallgraph(:truncatedtetrahedron_dir)
    for g in testdigraphs(dg13)
        @test @inferred !has_eulerian_trail(g)
        @test @inferred !has_eulerian_circuit(g)
        @test_throws ArgumentError eulerian_trail(g)
        @test_throws ArgumentError eulerian_circuit(g)
    end

end
