@testset "Random walks" begin
    """is_nonbacktracking: a predicate that tests if a walk is nonbacktracking.
        That is that for no index i walk[i+2]==walk[i]
    """
    function is_nonbacktracking(walk)
        n = length(walk)
        if n < 3
           return true
        end
        for i in 1:(n - 2)
            if walk[i + 2] == walk[i]
                return false
            end
        end
        return true
    end

    """test_nbw: check that a walk is nonbacktracking and print it if is isn't.
        Used only for testing and debugging.
    """
    function test_nbw(g, start, len)
        w = @inferred(LT.walk(g, start, LT.RandomWalk(nonbacktracking=true, niter=len)))
        return is_nonbacktracking(w)
    end
    gx = path_digraph(10)
    for g in testdigraphs(gx)
        @test @inferred(LT.walk(g, 1, LT.RandomWalk(nonbacktracking=false, niter=5))) == [1:5;]
        @test @inferred(LT.walk(g, 2, LT.RandomWalk(nonbacktracking=false, niter=100))) == [2:10;]
        @test_throws BoundsError LT.walk(g, 20, LT.RandomWalk(nonbacktracking=false, niter=20))
        @test @inferred(LT.walk(g, 10, LT.RandomWalk(nonbacktracking=true, niter=20))) == [10]
        @test @inferred(LT.walk(g, 1, LT.RandomWalk(nonbacktracking=true, niter=20))) == [1:10;]
    end

    gx = path_graph(10)
    for g in testgraphs(gx)
        @test @inferred(LT.walk(g, 1, LT.SelfAvoidingWalk(niter=20))) == [1:10;]
        @test_throws BoundsError LT.walk(g, 20, LT.SelfAvoidingWalk(niter=20))
        @test @inferred(LT.walk(g, 1, LT.RandomWalk(nonbacktracking=true, niter=20))) == [1:10;]
        @test_throws BoundsError LT.walk(g, 20, LT.RandomWalk(nonbacktracking=true, niter=20))
    end

    gx = SimpleDiGraph(path_graph(10))
    for g in testdigraphs(gx)
        @test @inferred(LT.walk(g, 1, LT.RandomWalk(nonbacktracking=true, niter=20))) == [1:10;]
        @test_throws BoundsError LT.walk(g, 20, LT.RandomWalk(nonbacktracking=true, niter=20))
    end

    gx = cycle_graph(10)
    for g in testgraphs(gx)
        visited = @inferred(LT.walk(g, 1, LT.RandomWalk(nonbacktracking=true, niter=20)))
        @test visited == [1:10; 1:10;] || visited == [1; 10:-1:1; 10:-1:2;]
    end

    gx = cycle_digraph(10)
    for g in testdigraphs(gx)
        @test @inferred(LT.walk(g, 1, LT.RandomWalk(nonbacktracking=true, niter=20))) == [1:10; 1:10;]
    end

    n = 10
    gx = cycle_graph(n)
    for k = 3:(n - 1)
        add_edge!(gx, 1, k)
    end

    for g in testgraphs(gx)
      for len = 1:(3 * n)
        @test test_nbw(g, 1, len)
        @test test_nbw(g, 2, len)
      end
    end
    #test to make sure it works with self loops.
    add_edge!(gx, 1, 1)
    for g in testgraphs(gx)
      for len = 1:(3 * n)
          @test test_nbw(g, 1, len)
          @test test_nbw(g, 2, len)
      end
    end
end
