@testset "DepthFirst" begin

    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
    gx = SimpleDiGraph(SGGEN.Path(3))

    @testset "dfs tree" begin
        @testset "$g" for g in testdigraphs(g5)
            z = @inferred(LT.tree(g, 1, LT.DepthFirst()))
            @test ne(z) == 3 && nv(z) == 4
            @test !has_edge(z, 1, 3)
            @test !LT.is_cyclic(g)
        end
    end

    @testset "topological_sort" begin
        @testset "$g" for g in testdigraphs(g5)
            @test @inferred(LT.topological_sort(g)) == [1, 2, 3, 4]
        end

        @testset "$g" for g in testdigraphs(gx)
            @test @inferred(LT.is_cyclic(g))
            @test_throws LT.CycleError LT.topological_sort(g)
        end

        #graph with cycle which is reachable from the source
        gt = SimpleDiGraph(3)
        add_edge!(gt, 1, 2); add_edge!(gt, 2, 3); add_edge!(gt, 3, 2)
        @testset "$g" for g in testdigraphs(gt)
            @test @inferred(LT.is_cyclic(g))
            @test_throws LT.CycleError LT.topological_sort(g)
        end

        #for #1337
        ge = SimpleDiGraph(3)
        add_edge!(ge, 3, 1); add_edge!(ge, 1, 2)
        @testset "$g" for g in testdigraphs(ge)
            @test @inferred(LT.topological_sort(g)) == [3, 1, 2]
        end

        # graph with two sources
        gts = SimpleDiGraph(5)
        add_edge!(gts, 1, 2); add_edge!(gts, 2, 3); add_edge!(gts, 2, 4); add_edge!(gts, 3, 4); add_edge!(gts, 5, 3)
        @testset "$g" for g in testdigraphs(gts)
            @test @inferred(LT.topological_sort(g))  in [ [1, 2, 5, 3, 4] , [5, 1, 2, 3, 4] ]
        end
    end

    @testset "is_cyclic" begin
        @testset "$g" for g in testgraphs(SimpleGraph(SGGEN.Path(2)))
            @test @inferred(LT.is_cyclic(g))
            @test @inferred(!LT.is_cyclic(zero(g)))
        end

        @testset "$g" for g in testgraphs(SimpleDiGraph(SGGEN.Wheel(10)))
            @test LT.is_cyclic(g)
        end

        @testset "$g" for g in testgraphs(SimpleDiGraph(SGGEN.Star(10)))
            @test !LT.is_cyclic(g)
        end
    end

    @testset "visited_vertices" begin
        gt = binary_tree(3)
        @testset "$g" for g in testgraphs(gt)
            @test LT.visited_vertices(g, 1, LT.DepthFirst()) == [1, 2, 4, 5, 3, 6, 7]
        end
    end
end
