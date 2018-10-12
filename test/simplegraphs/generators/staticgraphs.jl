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

    function iscompletemultipartite(g, partitions)
      sum(partitions) != nv(g) && return false
      n = nv(g)

      edges = 0
      for p in partitions
        edges += p*(Int(n)-p)
      end
      edges = div(edges, 2)

      edges != ne(g) && return false

      cur = 1
      for p in partitions
        currange = cur:(cur+p-1)
        lowerrange = 1:(cur-1)
        upperrange = (cur+p):n
        for u in currange
          for v in currange # check that no vertices are connected to vertices in the same partition
            has_edge(g, u, v) && return false
          end

          for v in lowerrange # check all lower partition vertices
            !has_edge(g, u, v) && return false
          end

          for v in upperrange # check all higher partition vertices
            !has_edge(g, u, v) && return false
          end
        end
        cur += p
      end
      return true
    end

    g = @inferred(CompleteMultipartiteGraph([5, 8, 3]))
    @test nv(g) == 16 && ne(g) == 79
    @test isvalid_simplegraph(g)
    @test iscompletemultipartite(g, [5, 8, 3])
    # tests for extreme values
    g = CompleteMultipartiteGraph([0, 0, 0])
    @test nv(g) == 0 && ne(g) == 0
    g = CompleteMultipartiteGraph(Int[])
    @test nv(g) == 0 && ne(g) == 0
    g = CompleteMultipartiteGraph([5, 0, 3])
    @test nv(g) == 8 && ne(g) == 15
    @test iscompletemultipartite(g, [5, 0, 3])
    g = CompleteMultipartiteGraph(Int8[100, 25, 2])
    @test nv(g) == 127 && ne(g) == 2750
    @test eltype(g) == Int8
    @test iscompletemultipartite(g, [100, 25, 2])
    g = CompleteMultipartiteGraph([0, 10, 0, 2, 0, 3, 0, 0, 6, 0])
    @test nv(g) == 21 && ne(g) == 146
    @test iscompletemultipartite(g, [0, 10, 0, 2, 0, 3, 0, 0, 6, 0])
    g = CompleteMultipartiteGraph([5, 3, -1])
    @test nv(g) == 0 && ne(g) == 0
    g = CompleteMultipartiteGraph([-5, 0, -11])
    @test nv(g) == 0 && ne(g) == 0
    g = CompleteMultipartiteGraph([5, 3])
    h = CompleteMultipartiteGraph([5, 0, 3])
    j = CompleteMultipartiteGraph([0, 5, 0, 3, 0, 0])
    @test g == h == j
    @test_throws InexactError CompleteMultipartiteGraph(Int8[100, 20, 20])

    function retrievepartitions(n, r)
      partitions = partitions = Vector{Int}(undef, r)
      c = cld(n,r)
      f = fld(n,r)
      for i in 1:(n%r)
        partitions[i] = c
      end
      for i in ((n%r)+1):r
        partitions[i] = f
      end
      return partitions
    end

    g = @inferred(TuranGraph(13, 4))
    @test nv(g) == 13 && ne(g) == 63
    @test isvalid_simplegraph(g)
    @test iscompletemultipartite(g, retrievepartitions(13, 4))
    # testing smaller int types
    g = TuranGraph(Int8(11), Int8(6))
    @test nv(g) == 11 && ne(g) == 50
    @test iscompletemultipartite(g, retrievepartitions(11, 6))
    g = TuranGraph(Int16(35), Int16(17))
    @test nv(g) == 35 && ne(g) == 576
    @test iscompletemultipartite(g, retrievepartitions(35, 17))
    # tests for extreme values
    g = TuranGraph(15,15)
    @test nv(g) == 15 && ne(g) == 105
    @test iscompletemultipartite(g, retrievepartitions(15, 15))
    g = TuranGraph(10, 1)
    @test nv(g) == 10 && ne(g) == 0
    @test iscompletemultipartite(g, retrievepartitions(10, 1))
    @test_throws DomainError TuranGraph(3,0)
    @test_throws DomainError TuranGraph(0,4)
    @test_throws DomainError TuranGraph(3,4)
    @test_throws DomainError TuranGraph(-1,5)
    @test_throws DomainError TuranGraph(3,-6)

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
    @test_throws DomainError BinaryTree(Int8(8))

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

    function isladdergraph(g)
      n = nv(g)÷2
      !(degree(g, 1) == degree(g, n) == degree(g, n+1) == degree(g, 2*n) == 2) && return false
      !(has_edge(g, 1, n+1) && has_edge(g, n, 2*n)) && return false
      !(has_edge(g, 1, 2) && has_edge(g, n, n-1) && has_edge(g, n+1, n+2) && has_edge(g, 2*n, 2*n-1) ) && return false
      for i in 2:(n-1)
        !(degree(g, i) == 3 && degree(g, n+i) == 3) && return false
        !(has_edge(g, i, i%n +1) && has_edge(g, i, i+n)) && return false
        !(has_edge(g, n+i,n+(i%n +1)) && has_edge(g, n+i, i)) && return false
      end
      return true
    end

    g = @inferred(LadderGraph(5))
    @test nv(g) == 10 && ne(g) == 13
    @test isvalid_simplegraph(g)
    @test isladdergraph(g)
    # tests for extreme values
    g = LadderGraph(0)
    @test nv(g) == 0 && ne(g) == 0
    g = LadderGraph(1)
    @test nv(g) == 2 && ne(g) == 1
    g = @inferred LadderGraph(-1)
    @test nv(g) == 0 && ne(g) == 0
    g = LadderGraph(Int8(63))
    @test nv(g) == 126 && ne(g) == 187
    @test eltype(g) == Int8
    @test isladdergraph(g)
    # tests for errors
    @test_throws InexactError LadderGraph(Int8(64))

    function iscircularladdergraph(g)
      n = nv(g)÷2
      for i in 1:n
        !(degree(g, i) == 3 && degree(g, n+i) == 3) && return false
        !(has_edge(g, i, i%n +1) && has_edge(g, i, i+n)) && return false
        !(has_edge(g, n+i,n+(i%n +1)) && has_edge(g, n+i, i)) && return false
      end
      return true
    end

    g = @inferred(CircularLadderGraph(5))
    @test nv(g) == 10 && ne(g) == 15
    @test isvalid_simplegraph(g)
    @test iscircularladdergraph(g)
    # tests for extreme values
    g = CircularLadderGraph(3)
    @test nv(g) == 6 && ne(g) == 9
    @test iscircularladdergraph(g)
    g = CircularLadderGraph(Int8(63))
    @test nv(g) == 126 && ne(g) == 189
    @test eltype(g) == Int8
    @test iscircularladdergraph(g)
    # tests for errors
    @test_throws InexactError CircularLadderGraph(Int8(64))
    @test_throws DomainError CircularLadderGraph(-1)
    @test_throws DomainError CircularLadderGraph(0)
    @test_throws DomainError CircularLadderGraph(1)
    @test_throws DomainError CircularLadderGraph(2)
end
