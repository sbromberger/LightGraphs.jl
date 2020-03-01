@testset "Cycles" begin
    completedg = complete_digraph(4)
    pathdg = path_digraph(5)
    triangle = random_regular_graph(3, 2)
    quadrangle = random_regular_graph(4, 2)
    pentagon = random_regular_graph(5, 2)

    @testset "path digraph" for g in testgraphs(pathdg)
        @test max_simple_cycles(g) == 0
        @test max_simple_cycles(g, false) == 84
        @test count_simple_cycles(g) == 0
        @test length(simple_cycles(g)) == 0
        @test isempty(simple_cycles(g)) == true
        @test isempty(simple_cycles(g, Johnson(iterative=true))) == true
        @test simple_cycles_length(g, Johnson()) == (zeros(5), 0)
        @test count_simple_cycles(g, Johnson(ceiling=10)) == 0
        @test isempty(simple_cycles(g, Johnson(iterative=true, ceiling=10))) == true
        @test simple_cycles_length(g, Johnson(ceiling=10)) == (zeros(5), 0)
    end

    @testset "max_simple_cycles(4)" begin
        @test max_simple_cycles(4) == 20
    end

    @testset "complete digraph" for g in testgraphs(completedg)
        @test max_simple_cycles(g) == 20
        @test length(simple_cycles(g)) == 20
        @test simple_cycles(g) == @inferred(simple_cycles(g, Johnson(iterative=true)))
        @test count_simple_cycles(g) == 20
        @test simple_cycles_length(g) == ([0, 6, 8, 6], 20)
        @test count_simple_cycles(g, Johnson(ceiling=10)) == 10
        @test simple_cycles_length(g, Johnson(ceiling=10))[2] == 10
    end

    @testset "triangle" for g in testgraphs(triangle)
        trianglelengths, triangletotal = simple_cycles_length(DiGraph(g))
        @test sum(trianglelengths) == triangletotal
    end

    @testset "quadrangle" for g in testgraphs(quadrangle)
        quadranglelengths, quadrangletotal = simple_cycles_length(DiGraph(g))
        @test sum(quadranglelengths) == quadrangletotal
        @test simple_cycles(DiGraph(g)) == @inferred(simple_cycles(DiGraph(g), Johnson(iterative=true)))
    end

    @testset "pentagon" for g in testgraphs(pentagon)
        pentagonlengths, pentagontotal = simple_cycles_length(DiGraph(g))
        @test sum(pentagonlengths) == pentagontotal
    end

    selfloopg = DiGraph([
        0 1 0 0;
        0 0 1 0;
        1 0 1 0;
        0 0 0 1;
    ])

    @testset "self loops" for g in testgraphs(selfloopg)
        cycles = simple_cycles(g)
        @test [3] in cycles
        @test [4] in cycles
        @test [1, 2, 3] in cycles || [2, 3, 1] in cycles || [3, 1, 2] in cycles
        @test length(cycles) == 3

        cycles2 = simple_cycles(g, Johnson(iterative=true))
        @test [3] in cycles2
        @test [4] in cycles2
        @test [1, 2, 3] in cycles2 || [2, 3, 1] in cycles2 || [3, 1, 2] in cycles2
        @test length(cycles2) == 3
    end
end
