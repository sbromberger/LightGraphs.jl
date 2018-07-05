@testset "Static graphs" begin
    g = @inferred(CompleteDiGraph(5))
    @test nv(g) == 5 && ne(g) == 20
    @test isvalid_simplegraph(g)
    # tests for extreme values
    g = CompleteDiGraph(0)
    @test nv(g) == 0 && ne(g) == 0
    g = CompleteDiGraph(1)
    @test nv(g) == 1 && ne(g) == 0
    g = CompleteDiGraph(2)
    @test nv(g) == 2 && ne(g) == 2
    g = @inferred CompleteDiGraph(Int8(127))
    @test nv(g) == 127 && ne(g) == 127 * (127 - 1)
    @test eltype(g) == Int8

    g = @inferred(CompleteGraph(5))
    @test nv(g) == 5 && ne(g) == 10
    @test isvalid_simplegraph(g)
    # tests for extreme values
    g = CompleteGraph(0)
    @test nv(g) == 0 && ne(g) == 0
    g = CompleteGraph(1)
    @test nv(g) == 1 && ne(g) == 0
    g = CompleteGraph(2)
    @test nv(g) == 2 && ne(g) == 1
    g = @inferred CompleteGraph(Int8(127))
    @test nv(g) == 127 && ne(g) == 127 * (127 - 1) ÷ 2
    @test eltype(g) == Int8


    g = @inferred(CompleteBipartiteGraph(5, 8))
    @test nv(g) == 13 && ne(g) == 40
    @test isvalid_simplegraph(g)
    # tests for extreme values
    g = CompleteBipartiteGraph(0,0)
    @test nv(g) == 0 && ne(g) == 0
    g = CompleteBipartiteGraph(5,0)
    @test nv(g) == 5 && ne(g) == 0
    g = CompleteBipartiteGraph(0,5)
    @test nv(g) == 5 && ne(g) == 0
    g = @inferred CompleteBipartiteGraph(Int8(100), Int8(27))
    @test nv(g) == 127 && ne(g) == 100 * 27
    @test eltype(g) == Int8
    g = CompleteBipartiteGraph(Int8(127), Int8(0))
    @test nv(g) == 127 && ne(g) == 0
    g = CompleteBipartiteGraph(Int8(0), Int8(127))
    @test nv(g) == 127 && ne(g) == 0


    g = @inferred(StarGraph(5))
    @test nv(g) == 5 && ne(g) == 4
    @test isvalid_simplegraph(g)
    # tests for extreme values
    g = StarGraph(0)
    @test nv(g) == 0 && ne(g) == 0
    g = StarGraph(1)
    @test nv(g) == 1 && ne(g) == 0
    g = StarGraph(2)
    @test nv(g) == 2 && ne(g) == 1
    g = @inferred StarGraph(Int8(127))
    @test nv(g) == 127 && ne(g) == 127 - 1
    @test eltype(g) == Int8

    g = @inferred(StarDiGraph(5))
    @test nv(g) == 5 && ne(g) == 4
    @test isvalid_simplegraph(g)
    # tests for extreme values
    g = StarDiGraph(0)
    @test nv(g) == 0 && ne(g) == 0
    g = StarDiGraph(1)
    @test nv(g) == 1 && ne(g) == 0
    g = StarDiGraph(2)
    @test nv(g) == 2 && ne(g) == 1
    @test first(edges(g)) == Edge(1, 2) # edges should point outwards from vertex 1
    g = @inferred StarDiGraph(Int8(127))
    @test nv(g) == 127 && ne(g) == 127 - 1
    @test eltype(g) == Int8

    g = @inferred(PathDiGraph(5))
    @test nv(g) == 5 && ne(g) == 4
    @test isvalid_simplegraph(g)
    # tests for extreme values
    g = PathDiGraph(0)
    @test nv(g) == 0 && ne(g) == 0
    g = PathDiGraph(1)
    @test nv(g) == 1 && ne(g) == 0
    g = @inferred PathDiGraph(Int8(127))
    @test nv(g) == 127 && ne(g) == 126
    @test eltype(g) == Int8

    g = @inferred(PathGraph(5))
    @test nv(g) == 5 && ne(g) == 4
    @test isvalid_simplegraph(g)
    # tests for extreme values
    g = PathGraph(0)
    @test nv(g) == 0 && ne(g) == 0
    g = PathGraph(1)
    @test nv(g) == 1 && ne(g) == 0
    g = @inferred PathGraph(Int8(127))
    @test nv(g) == 127 && ne(g) == 126
    @test eltype(g) == Int8

    g = @inferred(CycleDiGraph(5))
    @test nv(g) == 5 && ne(g) == 5
    @test isvalid_simplegraph(g)
     # tests for extreme values
    g = CycleDiGraph(0)
    @test nv(g) == 0 && ne(g) == 0
    g = CycleDiGraph(1)
    @test nv(g) == 1 && ne(g) == 0
    g = CycleDiGraph(2)
    @test nv(g) == 2 && ne(g) == 2
    g = @inferred CycleDiGraph(Int8(127))
    @test nv(g) == 127 && ne(g) == 127
    @test eltype(g) == Int8


    g = @inferred(CycleGraph(5))
    @test nv(g) == 5 && ne(g) == 5
    @test isvalid_simplegraph(g)
     # tests for extreme values
    g = CycleGraph(0)
    @test nv(g) == 0 && ne(g) == 0
    g = CycleGraph(1)
    @test nv(g) == 1 && ne(g) == 0
    g = CycleGraph(2)
    @test nv(g) == 2 && ne(g) == 1
    g = @inferred CycleGraph(Int8(127))
    @test nv(g) == 127 && ne(g) == 127
    @test eltype(g) == Int8

    g = @inferred(WheelDiGraph(5))
    @test nv(g) == 5 && ne(g) == 8
    @test isvalid_simplegraph(g)
      # tests for extreme values
    g = WheelDiGraph(0)
    @test nv(g) == 0 && ne(g) == 0
    g = WheelDiGraph(1)
    @test nv(g) == 1 && ne(g) == 0
    g = WheelDiGraph(2)
    @test nv(g) == 2 && ne(g) == 1
    g = WheelDiGraph(3)
    @test nv(g) == 3 && ne(g) == 4
    g = @inferred WheelDiGraph(Int8(127))
    @test nv(g) == 127 && ne(g) == 2 * 126
    @test eltype(g) == Int8



    g = @inferred(WheelGraph(5))
    @test nv(g) == 5 && ne(g) == 8
    @test isvalid_simplegraph(g)
      # tests for extreme values
    g = WheelGraph(0)
    @test nv(g) == 0 && ne(g) == 0
    g = WheelGraph(1)
    @test nv(g) == 1 && ne(g) == 0
    g = WheelGraph(2)
    @test nv(g) == 2 && ne(g) == 1
    g = WheelGraph(3)
    @test nv(g) == 3 && ne(g) == 3
    g = @inferred WheelGraph(Int8(127))
    @test nv(g) == 127 && ne(g) == 2 * 126
    @test eltype(g) == Int8

    g = @inferred(Grid([3, 3, 4]))
    @test nv(g) == 3 * 3 * 4
    @test ne(g) == 75
    @test Δ(g) == 6
    @test δ(g) == 3
    @test isvalid_simplegraph(g)

    g = @inferred(Grid([3, 3, 4], periodic=true))
    @test nv(g) == 3 * 3 * 4
    @test ne(g) == 108
    @test Δ(g) == 6
    @test δ(g) == 6
    @test isvalid_simplegraph(g)


    g = @inferred(CliqueGraph(3, 5))
    @test nv(g) == 15 && ne(g) == 20
    @test g[1:3] == CompleteGraph(3)
    @test isvalid_simplegraph(g)

    g = @inferred(crosspath(3, BinaryTree(2)))
    # f = Vector{Vector{Int}}[[2 3 4];
    # [1 5];
    # [1 6];
    # [1 5 6 7];
    # [2 4 8];
    # [3 4 9];
    # [4 8 9];
    # [5 7];
    # [6 7]
    # ]
    I = [1, 1, 1, 2, 2, 3, 3, 4, 4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 9, 9]
    J = [2, 3, 4, 1, 5, 1, 6, 1, 5, 6, 7, 2, 4, 8, 3, 4, 9, 4, 8, 9, 5, 7, 6, 7]
    V = ones(Int, length(I))
    Adj = sparse(I, J, V)
    @test Adj == sparse(g)
    @test isvalid_simplegraph(g)

    g = @inferred(DoubleBinaryTree(3))
    # [[3, 2, 8]
    # [4, 1, 5]
    # [1, 6, 7]
    # [2]
    # [2]
    # [3]
    # [3]
    # [10, 9, 1]
    # [11, 8, 12]
    # [8, 13, 14]
    # [9]
    # [9]
    # [10]
    # [10]]
    I = [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 5, 6, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 12, 13, 14]
    J = [3, 2, 8, 4, 1, 5, 1, 6, 7, 2, 2, 3, 3, 10, 9, 1, 11, 8, 12, 8, 13, 14, 9, 9, 10, 10]
    V = ones(Int, length(I))
    Adj = sparse(I, J, V)
    @test Adj == sparse(g)
    @test isvalid_simplegraph(g)

    rg3 = @inferred(RoachGraph(3))
    # [3]
    # [4]
    # [1, 5]
    # [2, 6]
    # [3, 7]
    # [4, 8]
    # [9, 8, 5]
    # [10, 7, 6]
    # [11, 10, 7]
    # [8, 9, 12]
    # [9, 12]
    # [10, 11]
    I = [1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 12, 12]
    J = [3, 4, 1, 5, 2, 6, 3, 7, 4, 8, 9, 8, 5, 10, 7, 6, 11, 10, 7, 8, 9, 12, 9, 12, 10, 11]
    V = ones(Int, length(I))
    Adj = sparse(I, J, V)
    @test Adj == sparse(rg3)
    @test isvalid_simplegraph(g)
end
