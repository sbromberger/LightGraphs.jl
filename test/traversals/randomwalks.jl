@testset "Random walks" begin
    """is_nonbacktracking: a predicate that tests if a walk is nonbacktracking.
        That is that for no index i walk[i+2]==walk[i]
    """
    function is_nonbacktracking(walk)
        n = length(walk)
        if n < 3
           return true
        end
        for i in 1:n-2
            if walk[i+2] == walk[i]
                return false
            end
        end
        return true
    end

    """test_nbw: check that a walk is nonbacktracking and print it if is isn't.
        Used only for testing and debugging.
    """
    function test_nbw(g, start, len)
        w = non_backtracking_randomwalk(g, start, len)
        if is_nonbacktracking(w)
            return true
        else
            print("walk was:\n  $w")
        end
        return false
    end
    g = PathDiGraph(10)
    @test randomwalk(g, 1, 5) == [1:5;]
    @test randomwalk(g, 2, 100) == [2:10;]
    @test_throws BoundsError randomwalk(g, 20, 20)

    g = PathGraph(10)
    @test saw(g, 1, 20) == [1:10;]
    @test_throws BoundsError saw(g, 20, 20)

    g = PathGraph(10)
    @test non_backtracking_randomwalk(g, 1, 20) == [1:10;]
    @test_throws BoundsError non_backtracking_randomwalk(g, 20, 20)

    g = DiGraph(PathGraph(10))
    @test non_backtracking_randomwalk(g, 1, 20) == [1:10;]
    @test_throws BoundsError non_backtracking_randomwalk(g, 20, 20)

    g = PathDiGraph(10)
    @test non_backtracking_randomwalk(g, 10, 20) == [10]

    g = PathDiGraph(10)
    @test non_backtracking_randomwalk(g, 1, 20) == [1:10;]

    g = CycleGraph(10)
    visited = non_backtracking_randomwalk(g, 1, 20)
    @test visited == [1:10; 1:10;] || visited == [1; 10:-1:1; 10:-1:2;]

    g = CycleDiGraph(10)
    @test non_backtracking_randomwalk(g, 1, 20) == [1:10; 1:10;]

    n = 10
    g = CycleGraph(n)
    for k = 3:n-1
        add_edge!(g, 1, k)
    end

    for len = 1:3*n
        @test test_nbw(g,1,len)
        @test test_nbw(g,2,len)
    end
    #test to make sure it works with self loops.
    add_edge!(g, 1, 1)
    for len = 1:3*n
        @test test_nbw(g,1,len) == true
        @test test_nbw(g,2,len) == true
    end
end
