@testset "Core" begin
    d = DummyGraph()
    for fn in [ degree, density, all_neighbors ]
        @test_throws ErrorException fn(d)
    end

    e2 = Edge(1,3)
    e3 = Edge(1,4)
    @test is_ordered(e2)
    @test !is_ordered(reverse(e3))

    gx = Graph(10)
    for g in testgraphs(gx)
        add_vertices!(g, 5)
        @test nv(g) == 15
    end

    g5w = WheelGraph(5)
    for g in testgraphs(g5w)
        @test indegree(g,1) == outdegree(g,1) == degree(g,1) == 4
        @test indegree(g) == outdegree(g) == degree(g) == [4,3,3,3,3]

        @test Δout(g) == Δin(g) == Δ(g) == 4
        @test δout(g) == δin(g) == δ(g) == 3

        z = degree_histogram(g)
        @test z.weights == [4,0,1]

        @test neighbors(g, 2) == all_neighbors(g, 2) == [1,3,5]
        @test common_neighbors(g, 1, 5) == [2, 4]

        gsl = copy(g)
        add_edge!(gsl, 3, 3)
        add_edge!(gsl, 2, 2)

        @test !has_self_loops(g)
        @test has_self_loops(gsl)
        @test num_self_loops(g) == 0
        @test num_self_loops(gsl) == 2

        @test density(g) == 0.8
    end

    g5wd = WheelDiGraph(5)
    for g in testdigraphs(g5wd)
        @test indegree(g,2) == 2
        @test outdegree(g,2) == 1
        @test degree(g,2) == 3
        @test indegree(g) == [0,2,2,2,2]
        @test outdegree(g) == [4,1,1,1,1]
        @test degree(g) == [4,3,3,3,3]

        @test Δout(g) == Δ(g) == 4
        @test Δin(g) == 2
        @test δout(g) == 1
        @test δin(g) == 0
        @test δ(g) == 3

        z = degree_histogram(g)
        @test z.weights == [4,0,1]

        @test neighbors(g, 2) == [3]
        @test Set(all_neighbors(g, 2)) == Set([1,3,5])
        @test common_neighbors(g, 1, 5) == [2]

        gsl = copy(g)
        add_edge!(gsl, 3, 3)
        add_edge!(gsl, 2, 2)

        @test !has_self_loops(g)
        @test has_self_loops(gsl)
        @test num_self_loops(g) == 0
        @test num_self_loops(gsl) == 2

        @test density(g) == 0.4
    end
end
