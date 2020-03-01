@testset "Static graphs" begin
    @testset "DiGraphs" begin
        g = @inferred(complete_digraph(5))
        @test nv(g) == 5 && ne(g) == 20
        @test isvalid_simplegraph(g)
        # tests for extreme values
        g = complete_digraph(0)
        @test nv(g) == 0 && ne(g) == 0
        g = complete_digraph(1)
        @test nv(g) == 1 && ne(g) == 0
        g = complete_digraph(2)
        @test nv(g) == 2 && ne(g) == 2
        g = @inferred complete_digraph(Int8(127))
        @test nv(g) == 127 && ne(g) == 127 * (127 - 1)
        @test eltype(g) == Int8
    end

    @testset "Graphs" begin
        g = @inferred(complete_graph(5))
        @test nv(g) == 5 && ne(g) == 10
        @test isvalid_simplegraph(g)
        # tests for extreme values
        g = complete_graph(0)
        @test nv(g) == 0 && ne(g) == 0
        g = complete_graph(1)
        @test nv(g) == 1 && ne(g) == 0
        g = complete_graph(2)
        @test nv(g) == 2 && ne(g) == 1
        g = @inferred complete_graph(Int8(127))
        @test nv(g) == 127 && ne(g) == 127 * (127 - 1) ÷ 2
        @test eltype(g) == Int8
    end


    @testset "Bipartite Graphs" begin
        g = @inferred(complete_bipartite_graph(5, 8))
        @test nv(g) == 13 && ne(g) == 40
        @test isvalid_simplegraph(g)
        # tests for extreme values
        g = complete_bipartite_graph(0,0)
        @test nv(g) == 0 && ne(g) == 0
        g = complete_bipartite_graph(5,0)
        @test nv(g) == 5 && ne(g) == 0
        g = complete_bipartite_graph(0,5)
        @test nv(g) == 5 && ne(g) == 0
        g = @inferred complete_bipartite_graph(Int8(100), Int8(27))
        @test nv(g) == 127 && ne(g) == 100 * 27
        @test eltype(g) == Int8
        g = complete_bipartite_graph(Int8(127), Int8(0))
        @test nv(g) == 127 && ne(g) == 0
        g = complete_bipartite_graph(Int8(0), Int8(127))
        @test nv(g) == 127 && ne(g) == 0
    end

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

    @testset "Multipartite Graphs" begin
        g = @inferred(complete_multipartite_graph([5, 8, 3]))
        @test nv(g) == 16 && ne(g) == 79
        @test isvalid_simplegraph(g)
        @test iscompletemultipartite(g, [5, 8, 3])
        # tests for extreme values
        g = complete_multipartite_graph([0, 0, 0])
        @test nv(g) == 0 && ne(g) == 0
        g = complete_multipartite_graph(Int[])
        @test nv(g) == 0 && ne(g) == 0
        g = complete_multipartite_graph([5, 0, 3])
        @test nv(g) == 8 && ne(g) == 15
        @test iscompletemultipartite(g, [5, 0, 3])
        g = complete_multipartite_graph(Int8[100, 25, 2])
        @test nv(g) == 127 && ne(g) == 2750
        @test eltype(g) == Int8
        @test iscompletemultipartite(g, [100, 25, 2])
        g = complete_multipartite_graph([0, 10, 0, 2, 0, 3, 0, 0, 6, 0])
        @test nv(g) == 21 && ne(g) == 146
        @test iscompletemultipartite(g, [0, 10, 0, 2, 0, 3, 0, 0, 6, 0])
        g = complete_multipartite_graph([5, 3, -1])
        @test nv(g) == 0 && ne(g) == 0
        g = complete_multipartite_graph([-5, 0, -11])
        @test nv(g) == 0 && ne(g) == 0
        g = complete_multipartite_graph([5, 3])
        h = complete_multipartite_graph([5, 0, 3])
        j = complete_multipartite_graph([0, 5, 0, 3, 0, 0])
        @test g == h == j
        @test_throws InexactError complete_multipartite_graph(Int8[100, 20, 20])
    end

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

    @testset "Turan Graphs" begin
        g = @inferred(turan_graph(13, 4))
        @test nv(g) == 13 && ne(g) == 63
        @test isvalid_simplegraph(g)
        @test iscompletemultipartite(g, retrievepartitions(13, 4))
        # testing smaller int types
        g = turan_graph(Int8(11), Int8(6))
        @test nv(g) == 11 && ne(g) == 50
        @test iscompletemultipartite(g, retrievepartitions(11, 6))
        g = turan_graph(Int16(35), Int16(17))
        @test nv(g) == 35 && ne(g) == 576
        @test iscompletemultipartite(g, retrievepartitions(35, 17))
        # tests for extreme values
        g = turan_graph(15,15)
        @test nv(g) == 15 && ne(g) == 105
        @test iscompletemultipartite(g, retrievepartitions(15, 15))
        g = turan_graph(10, 1)
        @test nv(g) == 10 && ne(g) == 0
        @test iscompletemultipartite(g, retrievepartitions(10, 1))
        @test_throws DomainError turan_graph(3,0)
        @test_throws DomainError turan_graph(0,4)
        @test_throws DomainError turan_graph(3,4)
        @test_throws DomainError turan_graph(-1,5)
        @test_throws DomainError turan_graph(3,-6)
    end

    @testset "Star Graphs" begin
        g = @inferred(star_graph(5))
        @test nv(g) == 5 && ne(g) == 4
        @test isvalid_simplegraph(g)
        # tests for extreme values
        g = star_graph(0)
        @test nv(g) == 0 && ne(g) == 0
        g = star_graph(1)
        @test nv(g) == 1 && ne(g) == 0
        g = star_graph(2)
        @test nv(g) == 2 && ne(g) == 1
        g = @inferred star_graph(Int8(127))
        @test nv(g) == 127 && ne(g) == 127 - 1
        @test eltype(g) == Int8
    end

    @testset "Star DiGraphs" begin
        g = @inferred(star_digraph(5))
        @test nv(g) == 5 && ne(g) == 4
        @test isvalid_simplegraph(g)
        # tests for extreme values
        g = star_digraph(0)
        @test nv(g) == 0 && ne(g) == 0
        g = star_digraph(1)
        @test nv(g) == 1 && ne(g) == 0
        g = star_digraph(2)
        @test nv(g) == 2 && ne(g) == 1
        @test first(edges(g)) == Edge(1, 2) # edges should point outwards from vertex 1
        g = @inferred star_digraph(Int8(127))
        @test nv(g) == 127 && ne(g) == 127 - 1
        @test eltype(g) == Int8

    end

    @testset "Path DiGraphs" begin
        g = @inferred(path_digraph(5))
        @test nv(g) == 5 && ne(g) == 4
        @test isvalid_simplegraph(g)
        # tests for extreme values
        g = path_digraph(0)
        @test nv(g) == 0 && ne(g) == 0
        g = path_digraph(1)
        @test nv(g) == 1 && ne(g) == 0
        g = @inferred path_digraph(Int8(127))
        @test nv(g) == 127 && ne(g) == 126
        @test eltype(g) == Int8

    end

    @testset "Path Graphs" begin
        g = @inferred(path_graph(5))
        @test nv(g) == 5 && ne(g) == 4
        @test isvalid_simplegraph(g)
        # tests for extreme values
        g = path_graph(0)
        @test nv(g) == 0 && ne(g) == 0
        g = path_graph(1)
        @test nv(g) == 1 && ne(g) == 0
        g = @inferred path_graph(Int8(127))
        @test nv(g) == 127 && ne(g) == 126
        @test eltype(g) == Int8
    end

    @testset "Cycle DiGraphs" begin
        g = @inferred(cycle_digraph(5))
        @test nv(g) == 5 && ne(g) == 5
        @test isvalid_simplegraph(g)
         # tests for extreme values
        g = cycle_digraph(0)
        @test nv(g) == 0 && ne(g) == 0
        g = cycle_digraph(1)
        @test nv(g) == 1 && ne(g) == 0
        g = cycle_digraph(2)
        @test nv(g) == 2 && ne(g) == 2
        g = @inferred cycle_digraph(Int8(127))
        @test nv(g) == 127 && ne(g) == 127
        @test eltype(g) == Int8
    end

    @testset "Cycle Graphs" begin
        g = @inferred(cycle_graph(5))
        @test nv(g) == 5 && ne(g) == 5
        @test isvalid_simplegraph(g)
         # tests for extreme values
        g = cycle_graph(0)
        @test nv(g) == 0 && ne(g) == 0
        g = cycle_graph(1)
        @test nv(g) == 1 && ne(g) == 0
        g = cycle_graph(2)
        @test nv(g) == 2 && ne(g) == 1
        g = @inferred cycle_graph(Int8(127))
        @test nv(g) == 127 && ne(g) == 127
        @test eltype(g) == Int8
    end

    @testset "Wheel DiGraphs" begin
        g = @inferred(wheel_digraph(5))
        @test nv(g) == 5 && ne(g) == 8
        @test isvalid_simplegraph(g)
          # tests for extreme values
        g = wheel_digraph(0)
        @test nv(g) == 0 && ne(g) == 0
        g = wheel_digraph(1)
        @test nv(g) == 1 && ne(g) == 0
        g = wheel_digraph(2)
        @test nv(g) == 2 && ne(g) == 1
        g = wheel_digraph(3)
        @test nv(g) == 3 && ne(g) == 4
        g = @inferred wheel_digraph(Int8(127))
        @test nv(g) == 127 && ne(g) == 2 * 126
        @test eltype(g) == Int8
    end

    @testset "Wheel Graphs" begin
        g = @inferred(wheel_graph(5))
        @test nv(g) == 5 && ne(g) == 8
        @test isvalid_simplegraph(g)
          # tests for extreme values
        g = wheel_graph(0)
        @test nv(g) == 0 && ne(g) == 0
        g = wheel_graph(1)
        @test nv(g) == 1 && ne(g) == 0
        g = wheel_graph(2)
        @test nv(g) == 2 && ne(g) == 1
        g = wheel_graph(3)
        @test nv(g) == 3 && ne(g) == 3
        g = @inferred wheel_graph(Int8(127))
        @test nv(g) == 127 && ne(g) == 2 * 126
        @test eltype(g) == Int8
    end

    @testset "grids" begin
        g = @inferred(grid([3, 3, 4]))
        @test nv(g) == 3 * 3 * 4
        @test ne(g) == 75
        @test Δ(g) == 6
        @test δ(g) == 3
        @test isvalid_simplegraph(g)

        g2 = @inferred(grid((3, 3, 4)))
        @test g2 == g

        g = @inferred(grid([3, 3, 4], periodic=true))
        @test nv(g) == 3 * 3 * 4
        @test ne(g) == 108
        @test Δ(g) == 6
        @test δ(g) == 6
        @test isvalid_simplegraph(g)

        g2 = @inferred(grid((3, 3, 4), periodic=true))
        @test g2 == g
    end

    @testset "Clique Graphs" begin
        g = @inferred(clique_graph(3, 5))
        @test nv(g) == 15 && ne(g) == 20
        @test g[1:3] == complete_graph(3)
        @test isvalid_simplegraph(g)
    end

    @testset "Binary Trees" begin
        g = @inferred(crosspath(3, binary_tree(2)))
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
        @test_throws DomainError binary_tree(Int8(8))

        g = @inferred(double_binary_tree(3))
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
    end

    @testset "Roach Graphs" begin
        rg3 = @inferred(roach_graph(3))
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
        @test isvalid_simplegraph(rg3)
    end

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

    @testset "Ladder Graphs" begin
        g = @inferred(ladder_graph(5))
        @test nv(g) == 10 && ne(g) == 13
        @test isvalid_simplegraph(g)
        @test isladdergraph(g)
        # tests for extreme values
        g = ladder_graph(0)
        @test nv(g) == 0 && ne(g) == 0
        g = ladder_graph(1)
        @test nv(g) == 2 && ne(g) == 1
        g = @inferred ladder_graph(-1)
        @test nv(g) == 0 && ne(g) == 0
        g = ladder_graph(Int8(63))
        @test nv(g) == 126 && ne(g) == 187
        @test eltype(g) == Int8
        @test isladdergraph(g)
        # tests for errors
        @test_throws InexactError ladder_graph(Int8(64))
    end

    function iscircularladdergraph(g)
      n = nv(g)÷2
      for i in 1:n
        !(degree(g, i) == 3 && degree(g, n+i) == 3) && return false
        !(has_edge(g, i, i%n +1) && has_edge(g, i, i+n)) && return false
        !(has_edge(g, n+i,n+(i%n +1)) && has_edge(g, n+i, i)) && return false
      end
      return true
    end

    @testset "Circular Ladder Graphs" begin
        g = @inferred(circular_ladder_graph(5))
        @test nv(g) == 10 && ne(g) == 15
        @test isvalid_simplegraph(g)
        @test iscircularladdergraph(g)
        # tests for extreme values
        g = circular_ladder_graph(3)
        @test nv(g) == 6 && ne(g) == 9
        @test iscircularladdergraph(g)
        g = circular_ladder_graph(Int8(63))
        @test nv(g) == 126 && ne(g) == 189
        @test eltype(g) == Int8
        @test iscircularladdergraph(g)
        # tests for errors
        @test_throws InexactError circular_ladder_graph(Int8(64))
        @test_throws DomainError circular_ladder_graph(-1)
        @test_throws DomainError circular_ladder_graph(0)
        @test_throws DomainError circular_ladder_graph(1)
        @test_throws DomainError circular_ladder_graph(2)
    end

    # checking that the nodes are organized correctly
    # see the docstring implementation notes for lollipop_graph
    function isbarbellgraph(g, n1, n2)
      nv(g) != n1+n2 && return false
      ne(g) != n1*(n1-1)÷2+n2*(n2-1)÷2 +1 && return false
      for i in 1:n1
        for j in (i+1):n1
          !has_edge(g, i, j) && return false
        end
      end

      for i in n1 .+ 1:n2
        for j in (i+1):(n1+n2)
          !has_edge(g, i, j) && return false
        end
      end

      !has_edge(g, n1, n1+1) && return false
      return true
    end

    @testset "Barbell Graphs" begin
        g = @inferred(barbell_graph(5, 6))
        @test nv(g) == 11 && ne(g) == 26
        @test isvalid_simplegraph(g)
        @test isbarbellgraph(g, 5, 6)
        g = barbell_graph(Int8(5), Int8(6))
        @test nv(g) == 11 && ne(g) == 26
        @test isvalid_simplegraph(g)
        @test isbarbellgraph(g, 5, 6)
        # extreme values
        g = barbell_graph(1, 5)
        @test nv(g) == 6 && ne(g) == 11
        @test isbarbellgraph(g, 1, 5)
        g = barbell_graph(5, 1)
        @test nv(g) == 6 && ne(g) == 11
        @test isbarbellgraph(g, 5, 1)
        g = barbell_graph(1, 1)
        @test nv(g) == 2 && ne(g) == 1
        @test isbarbellgraph(g, 1, 1)
        @test_throws OverflowError barbell_graph(Int8(100), Int8(50))
        @test_throws DomainError barbell_graph(1, 0)
        @test_throws DomainError barbell_graph(0, 1)
        @test_throws DomainError barbell_graph(-1, -1)
    end

    # checking that the nodes are organized correctly
    # see the docstring implementation notes for lollipop_graph
    function islollipopgraph(g, n1, n2)
      nv(g) != n1+n2 && return false
      ne(g) != n1*(n1-1)÷2+n2 && return false
      for i in 1:n1
        for j in (i+1):n1
          !has_edge(g, i, j) && return false
        end
      end

      for i in n1 .+ 1:(n2-1)
        !has_edge(g, i, i+1) && return false
      end

      !has_edge(g, n1, n1+1) && return false

      return true
    end

    @testset "Lollipop Graphs" begin
        g = @inferred(lollipop_graph(3, 5))
        @test nv(g) == 8 && ne(g) == 8
        @test isvalid_simplegraph(g)
        @test islollipopgraph(g, 3, 5)
        g = lollipop_graph(Int8(7), Int8(6))
        @test nv(g) == 13 && ne(g) == 27
        @test isvalid_simplegraph(g)
        @test islollipopgraph(g, 7, 6)
        # extreme values
        g = lollipop_graph(1, 3)
        @test nv(g) == 4 && ne(g) == 3
        @test islollipopgraph(g, 1, 3)
        g = lollipop_graph(3, 1)
        @test nv(g) == 4 && ne(g) == 4
        @test islollipopgraph(g, 3, 1)
        g = lollipop_graph(1, 1)
        @test nv(g) == 2 && ne(g) == 1
        @test islollipopgraph(g, 1, 1)
        @test_throws OverflowError lollipop_graph(Int8(100), Int8(50))
        @test_throws DomainError lollipop_graph(1, 0)
        @test_throws DomainError lollipop_graph(0, 1)
        @test_throws DomainError lollipop_graph(-1, -1)
    end
   @testset "Friendship Graphs" begin
        # the Friendship Graphs is connected graph consist of n cycle of lenght 3 share only one node 
        for n in [10, 15, 20]
         g=friendship_graph(n)
         @test length(connected_components(g)) == 1
         @test articulation(g) == [1]
         compents=biconnected_components(g)
         @test length(compents) == n
         for i in 1:n
            @test length(compents[i]) == 3 # the only biconnected simple graph of 3 edges is c3 
         end
        end
    end
    
end

