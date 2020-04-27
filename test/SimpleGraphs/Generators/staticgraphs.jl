@testset "Static graphs" begin
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
    function teststatic(gtype, gentype, params, nvexp, neexp; elt=Int, testmp=false, mpart=[], gridperiodic=false)
        gen = gentype == SGGEN.Grid ? @inferred(gentype(params..., periodic=gridperiodic)) : @inferred(gentype(params...))
        g = @inferred(gtype(gen))
        @testset "$gtype / $gentype / $params" begin
            @test nv(g) == nvexp
            @test ne(g) == neexp
            @test isvalid_simplegraph(g)
            @test eltype(g) == elt
            if testmp
                pt = isempty(mpart) ? params[1] : mpart
                @test iscompletemultipartite(g, pt) 
            end
        end
        return g
    end

    @testset "Complete Graphs" begin
        teststatic(SG.SimpleGraph, SGGEN.Complete, 5, 5, 10)
        teststatic(SG.SimpleDiGraph, SGGEN.Complete, 5, 5, 20)
        teststatic(SG.SimpleGraph, SGGEN.Complete, 0, 0, 0)
        teststatic(SG.SimpleDiGraph, SGGEN.Complete, 0, 0, 0)
        teststatic(SG.SimpleGraph, SGGEN.Complete, 1, 1, 0)
        teststatic(SG.SimpleDiGraph, SGGEN.Complete, 1, 1, 0)
        teststatic(SG.SimpleGraph, SGGEN.Complete, 2, 2, 1)
        teststatic(SG.SimpleDiGraph, SGGEN.Complete, 2, 2, 2)
        teststatic(SG.SimpleGraph, SGGEN.Complete, Int8(127), 127, 127*(127-1)÷2, elt=Int8)
        teststatic(SG.SimpleDiGraph, SGGEN.Complete, Int8(127), 127, 127*(127-1), elt=Int8)
    end

    @testset "Bipartite Graphs" begin
        teststatic(SG.SimpleGraph, SGGEN.CompleteBipartite, (5, 8), 13, 40)
        teststatic(SG.SimpleGraph, SGGEN.CompleteBipartite, (0, 0), 0, 0)
        teststatic(SG.SimpleGraph, SGGEN.CompleteBipartite, (5, 0), 5, 0)
        teststatic(SG.SimpleGraph, SGGEN.CompleteBipartite, (0, 5), 5, 0)
        teststatic(SG.SimpleGraph, SGGEN.CompleteBipartite, (Int8(100), Int8(27)), 127, 2700, elt=Int8)
        teststatic(SG.SimpleGraph, SGGEN.CompleteBipartite, (Int8(127), Int8(0)), 127, 0, elt=Int8)
        teststatic(SG.SimpleGraph, SGGEN.CompleteBipartite, (Int8(0), Int8(127)), 127, 0, elt=Int8)
    end


    @testset "CompleteMultipartite" begin
        teststatic(SG.SimpleGraph, SGGEN.CompleteMultipartite, ([5, 8, 3],), 16, 79, testmp=true)
        teststatic(SG.SimpleGraph, SGGEN.CompleteMultipartite, ([0, 0, 0],), 0, 0, testmp=false)
        teststatic(SG.SimpleGraph, SGGEN.CompleteMultipartite, (Int[],), 0, 0, testmp=false)
        teststatic(SG.SimpleGraph, SGGEN.CompleteMultipartite, ([5, 0, 3],), 8, 15, testmp=true)
        teststatic(SG.SimpleGraph, SGGEN.CompleteMultipartite, (Int8[100, 25, 2],), 127, 2750, elt=Int8, testmp=true)
        teststatic(SG.SimpleGraph, SGGEN.CompleteMultipartite, ([0, 10, 0, 2, 0, 3, 0, 0, 6, 0],), 21, 146, testmp=true)
        teststatic(SG.SimpleGraph, SGGEN.CompleteMultipartite, ([5, 3, -1],), 0, 0, testmp=false)
        teststatic(SG.SimpleGraph, SGGEN.CompleteMultipartite, ([-5, 0, -11],), 0, 0, testmp=false)
        
        mgen9 = SGGEN.CompleteMultipartite([5, 3])
        g = @inferred(SG.SimpleGraph(mgen9))
        mgen10 = SGGEN.CompleteMultipartite([5, 0, 3])
        h = @inferred(SG.SimpleGraph(mgen10))
        mgen11 = SGGEN.CompleteMultipartite([0, 5, 0, 3, 0, 0])
        j = @inferred(SG.SimpleGraph(mgen11))
        @test g == h == j
        @test_throws OverflowError SGGEN.CompleteMultipartite(Int8[100, 20, 20])
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
        teststatic(SG.SimpleGraph, SGGEN.Turan, (13, 4), 13, 63, testmp=true, mpart=retrievepartitions(13, 4))
        teststatic(SG.SimpleGraph, SGGEN.Turan, (Int8(11), Int8(6)), 11, 50, elt=Int8, testmp=true, mpart=retrievepartitions(11, 6))
        teststatic(SG.SimpleGraph, SGGEN.Turan, (Int16(35), Int16(17)), 35, 576, elt=Int16, testmp=true, mpart=retrievepartitions(35, 17))
        teststatic(SG.SimpleGraph, SGGEN.Turan, (15, 15), 15, 105, testmp=true, mpart=retrievepartitions(15, 15))
        teststatic(SG.SimpleGraph, SGGEN.Turan, (10, 1), 10, 0, testmp=true, mpart=retrievepartitions(10, 1))
        for args in [(3, 0), (0, 4), (3, 4), (-1, 5), (3, -6)]
            @test_throws DomainError SGGEN.Turan(args...)
        end
    end

    @testset "Star" begin
        teststatic(SG.SimpleGraph, SGGEN.Star, 5, 5, 4)
        teststatic(SG.SimpleDiGraph, SGGEN.Star, 5, 5, 4)
        
        teststatic(SG.SimpleGraph, SGGEN.Star, 0, 0, 0)
        teststatic(SG.SimpleDiGraph, SGGEN.Star, 0, 0, 0)
        teststatic(SG.SimpleGraph, SGGEN.Star, 1, 1, 0)
        teststatic(SG.SimpleDiGraph, SGGEN.Star, 1, 1, 0)
        teststatic(SG.SimpleGraph, SGGEN.Star, 2, 2, 1)
        dg = teststatic(SG.SimpleDiGraph, SGGEN.Star, 2, 2, 1)
        @test first(edges(dg)) == SG.SimpleEdge(1, 2) # edges should point outwards from vertex 1
        teststatic(SG.SimpleGraph, SGGEN.Star, Int8(127), 127, 126, elt=Int8)
        teststatic(SG.SimpleDiGraph, SGGEN.Star, Int8(127), 127, 126, elt=Int8)
    end

    @testset "Path" begin
        teststatic(SG.SimpleGraph, SGGEN.Path, 5, 5, 4)
        teststatic(SG.SimpleDiGraph, SGGEN.Path, 5, 5, 4)
        teststatic(SG.SimpleGraph, SGGEN.Path, 0, 0, 0)
        teststatic(SG.SimpleDiGraph, SGGEN.Path, 0, 0, 0)
        teststatic(SG.SimpleGraph, SGGEN.Path, 1, 1, 0)
        teststatic(SG.SimpleDiGraph, SGGEN.Path, 1,1, 0)
        teststatic(SG.SimpleGraph, SGGEN.Path, Int8(127), 127, 126, elt=Int8)
        teststatic(SG.SimpleDiGraph, SGGEN.Path, Int8(127),127, 126, elt=Int8)
    end

    @testset "Cycle" begin
        teststatic(SG.SimpleGraph, SGGEN.Cycle, 5, 5, 5)
        teststatic(SG.SimpleDiGraph, SGGEN.Cycle, 5, 5, 5)
        teststatic(SG.SimpleGraph, SGGEN.Cycle, 0, 0, 0) 
        teststatic(SG.SimpleDiGraph, SGGEN.Cycle, 0, 0, 0) 
        teststatic(SG.SimpleGraph, SGGEN.Cycle, 1, 1, 0) 
        teststatic(SG.SimpleDiGraph, SGGEN.Cycle, 1, 1, 0) 
        teststatic(SG.SimpleGraph, SGGEN.Cycle, 2, 2, 1) 
        teststatic(SG.SimpleDiGraph, SGGEN.Cycle, 2, 2, 2) 
        teststatic(SG.SimpleGraph, SGGEN.Cycle, Int8(127), 127, 127, elt=Int8) 
        teststatic(SG.SimpleDiGraph, SGGEN.Cycle, Int8(127), 127, 127, elt=Int8) 
    end

    @testset "Wheel" begin
        teststatic(SG.SimpleGraph, SGGEN.Wheel, 5, 5, 8)
        teststatic(SG.SimpleDiGraph, SGGEN.Wheel, 5, 5, 8)
        teststatic(SG.SimpleGraph, SGGEN.Wheel, 0, 0, 0)
        teststatic(SG.SimpleDiGraph, SGGEN.Wheel, 0, 0, 0)
        teststatic(SG.SimpleGraph, SGGEN.Wheel, 1, 1, 0)
        teststatic(SG.SimpleDiGraph, SGGEN.Wheel, 1, 1, 0)
        teststatic(SG.SimpleGraph, SGGEN.Wheel, 2, 2, 1)
        teststatic(SG.SimpleDiGraph, SGGEN.Wheel, 2, 2, 1)
        teststatic(SG.SimpleGraph, SGGEN.Wheel, 3, 3, 3)
        teststatic(SG.SimpleDiGraph, SGGEN.Wheel, 3, 3, 4)
        teststatic(SG.SimpleGraph, SGGEN.Wheel, Int8(127), 127, 252, elt=Int8)
        teststatic(SG.SimpleDiGraph, SGGEN.Wheel, Int8(127), 127, 252, elt=Int8)
    end

    @testset "Grid" begin
        g = teststatic(SG.SimpleGraph, SGGEN.Grid, ([3, 3, 4],), 36, 75)
        @test Δ(g) == 6
        @test δ(g) == 3

        g2 = teststatic(SG.SimpleGraph, SGGEN.Grid, ((3, 3, 4),), 36, 75)
        @test g2 == g

        g = teststatic(SG.SimpleGraph, SGGEN.Grid, ([3, 3, 4],), 36, 108, gridperiodic=true)
        @test Δ(g) == 6
        @test δ(g) == 6

        g2 = teststatic(SG.SimpleGraph, SGGEN.Grid, ((3, 3, 4),), 36, 108, gridperiodic=true)
        @test g2 == g
    end

    @testset "Clique Graphs" begin
        g = teststatic(SG.SimpleGraph, SGGEN.Clique, (3, 5), 15, 20)
        @test g[1:3] == SG.SimpleGraph(SGGEN.Complete(3))
    end

    @testset "Binary Trees" begin
        teststatic(SG.SimpleGraph, SGGEN.BinaryTree, 2, 3, 2)
        teststatic(SG.SimpleGraph, SGGEN.BinaryTree, 4, 15, 14)
        teststatic(SG.SimpleGraph, SGGEN.BinaryTree, 5, 31, 30)
        teststatic(SG.SimpleGraph, SGGEN.BinaryTree, Int16(5), 31, 30, elt=Int16)
        @test_throws OverflowError SGGEN.BinaryTree(Int8(8))

        teststatic(SG.SimpleGraph, SGGEN.DoubleBinaryTree, 2, 6, 5)
        teststatic(SG.SimpleGraph, SGGEN.DoubleBinaryTree, 4, 30, 29)
        teststatic(SG.SimpleGraph, SGGEN.DoubleBinaryTree, 5, 62, 61)
        teststatic(SG.SimpleGraph, SGGEN.DoubleBinaryTree, Int16(5), 62, 61, elt=Int16)
        @test_throws OverflowError SGGEN.DoubleBinaryTree(Int8(8))
    end

    @testset "Roach" begin
        teststatic(SG.SimpleGraph, SGGEN.Roach, 3, 12, 13)
        teststatic(SG.SimpleGraph, SGGEN.Roach, 5, 20, 23)
        teststatic(SG.SimpleGraph, SGGEN.Roach, 0, 0, 0)
        teststatic(SG.SimpleGraph, SGGEN.Roach, 1, 4, 3)
        teststatic(SG.SimpleGraph, SGGEN.Roach, Int8(5), 20, 23, elt=Int8)

        @test_throws OverflowError SGGEN.Roach(Int8(32))
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

    @testset "Ladder" begin
        g = teststatic(SG.SimpleGraph, SGGEN.Ladder, 5, 10, 13)
        @test isladdergraph(g)
        teststatic(SG.SimpleGraph, SGGEN.Ladder, 0, 0, 0)
        teststatic(SG.SimpleGraph, SGGEN.Ladder, 1, 2, 1)
        teststatic(SG.SimpleGraph, SGGEN.Ladder, -1, 0, 0)
        g = teststatic(SG.SimpleGraph, SGGEN.Ladder, Int8(63), 126, 187, elt=Int8)
        @test isladdergraph(g)
        # tests for errors
        @test_throws OverflowError SGGEN.Ladder(Int8(64))
    end

    function iscircularladdergraph(g)
        n = nv(g) ÷ 2
        for i in 1:n
            !(degree(g, i) == 3 && degree(g, n+i) == 3) && return false
            !(has_edge(g, i, i%n +1) && has_edge(g, i, i+n)) && return false
            !(has_edge(g, n+i,n+(i%n +1)) && has_edge(g, n+i, i)) && return false
        end
        return true
    end

    @testset "CircularLadder" begin
        g = teststatic(SG.SimpleGraph, SGGEN.CircularLadder, 5, 10, 15)
        @test iscircularladdergraph(g)
        # tests for extreme values
        g = teststatic(SG.SimpleGraph, SGGEN.CircularLadder, 3, 6, 9)
        @test iscircularladdergraph(g)
        g = teststatic(SG.SimpleGraph, SGGEN.CircularLadder, Int8(63), 126, 189, elt=Int8)
        @test iscircularladdergraph(g)
        # tests for errors
        @test_throws OverflowError SGGEN.CircularLadder(Int8(64))
        for i = -1:2
            @test_throws DomainError SGGEN.CircularLadder(i)
        end
    end

    # checking that the nodes are organized correctly
    # see the docstring implementation notes for lollipop_graph
    function isbarbellgraph(g, n1, n2)
        nv(g) != n1 + n2 && return false
        ne(g) != n1 * (n1 - 1) ÷ 2 + n2 * (n2 - 1) ÷2 +1 && return false
        for i in 1:n1
            for j in (i + 1):n1
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

    @testset "Barbell" begin
        g = teststatic(SG.SimpleGraph, SGGEN.Barbell, (5, 6), 11, 26)
        @test isbarbellgraph(g, 5, 6)
        g = teststatic(SG.SimpleGraph, SGGEN.Barbell, (Int8(5), Int8(6)), 11, 26, elt=Int8)
        @test nv(g) == 11 && ne(g) == 26
        @test isbarbellgraph(g, 5, 6)
        # extreme values
        g = teststatic(SG.SimpleGraph, SGGEN.Barbell, (1, 5), 6, 11)
        @test isbarbellgraph(g, 1, 5)
        g = teststatic(SG.SimpleGraph, SGGEN.Barbell, (5, 1), 6, 11)
        @test isbarbellgraph(g, 5, 1)
        g = teststatic(SG.SimpleGraph, SGGEN.Barbell, (1, 1), 2, 1)
        @test isbarbellgraph(g, 1, 1)
        @test_throws OverflowError SGGEN.Barbell(Int8(100), Int8(50))
        @test_throws DomainError SGGEN.Barbell(1, 0)
        @test_throws DomainError SGGEN.Barbell(0, 1)
        @test_throws DomainError SGGEN.Barbell(-1, -1)
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
        g = teststatic(SG.SimpleGraph, SGGEN.Lollipop, (3, 5), 8, 8)
        @test islollipopgraph(g, 3, 5)
        g = teststatic(SG.SimpleGraph, SGGEN.Lollipop, (Int8(7), Int8(6)), 13, 27, elt=Int8)
        @test islollipopgraph(g, 7, 6)
        # extreme values
        g = teststatic(SG.SimpleGraph, SGGEN.Lollipop, (1, 3), 4, 3)
        @test islollipopgraph(g, 1, 3)
        g = teststatic(SG.SimpleGraph, SGGEN.Lollipop, (3, 1), 4, 4)
        @test islollipopgraph(g, 3, 1)
        g = teststatic(SG.SimpleGraph, SGGEN.Lollipop, (1, 1), 2, 1)
        @test islollipopgraph(g, 1, 1)
        @test_throws OverflowError SGGEN.Lollipop(Int8(100), Int8(50))
        @test_throws DomainError SGGEN.Lollipop(1, 0)
        @test_throws DomainError SGGEN.Lollipop(0, 1)
        @test_throws DomainError SGGEN.Lollipop(-1, -1)
    end

    # checking if edgeset of g is equal to edges
    function isEdgeSet(g, edges)
        ne(g) != length(edges) && return false

        for (i, j) in edges
            !has_edge(g, i, j) && return false
        end

        return true
    end

    @testset "Circulant" begin
        teststatic(SG.SimpleGraph, SGGEN.Circulant, (1, Int64[]), 1, 0)
        teststatic(SG.SimpleDiGraph, SGGEN.Circulant, (1, Int64[]), 1, 0)
        # path graph
        teststatic(SG.SimpleGraph, SGGEN.Circulant, (2, [1]), 2, 1)
        dg = teststatic(SG.SimpleDiGraph, SGGEN.Circulant, (2, [1]), 2, 2)
        @test isEdgeSet(dg, [(1, 2), (2, 1)])
        # triangle graph
        g = teststatic(SG.SimpleGraph, SGGEN.Circulant, (3, [1]), 3, 3)
        @test isEdgeSet(g, [(1, 2), (1, 3), (2, 3)])
        dg = teststatic(SG.SimpleDiGraph, SGGEN.Circulant, (3, [1]), 3, 3)
        @test isEdgeSet(dg, [(1, 2), (2, 3), (3, 1)])
        # tetrahedral graph
        teststatic(SG.SimpleGraph, SGGEN.Circulant, (4, [1, 2]), 4, 6)
        # utility graph
        g = teststatic(SG.SimpleGraph, SGGEN.Circulant, (6, [1, 3]), 6, 9)
        @test isEdgeSet(g, [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (1, 6), (1, 4), (2, 5), (3, 6)])
        dg = teststatic(SG.SimpleDiGraph, SGGEN.Circulant, (6, [1, 3]), 6, 12)
        @test isEdgeSet(dg, [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 1), (1, 4), (4, 1), (2, 5), (3, 6), (5, 2), (6, 3)])
        @test_throws DomainError SGGEN.Circulant(0, [1, 2])
    end

    @testset "Friendship Graphs" begin
        # the friendship graph is a connected graph consisting of n cycles of length 3 sharing a common vertex
        for n in [10, 15, 20, 0x0a, 0x0f, 0x14]
            g = SG.SimpleGraph(SGGEN.Friendship(n))
            @test eltype(g) == eltype(n)
            @test !has_self_loops(g)
            @test !is_directed(g)
            @test degree(g, 1) == 2 * n
            @test nv(g) == 2 * n + 1
            for v in 2:nv(g)
                @test degree(g, v) == 2
            end
        end

        for n in [-5, 0]
            g = SG.SimpleGraph(SGGEN.Friendship(n))
            @test nv(g) == 1
        end
    end 
end
