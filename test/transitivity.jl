@testset "Transitivity" begin
    completedg = CompleteDiGraph(4)
    circledg = PathDiGraph(4)
    add_edge!(circledg, 4, 1)
    for circle in testdigraphs(circledg)
        T = eltype(circle)
        complete = DiGraph{T}(completedg)
        newcircle = transitiveclosure(circle)
        @test @inferred(newcircle) == complete
        @test @inferred(ne(circle)) == 4
        @test @inferred(newcircle) == transitiveclosure!(circle)
        @test @inferred(ne(circle)) == 12
    end

    loopedcompletedg = copy(completedg)
    for i in vertices(loopedcompletedg)
        add_edge!(loopedcompletedg, i, i)
    end
    circledg = PathDiGraph(4)
    add_edge!(circledg, 4, 1)
    for circle in testdigraphs(circledg)
        T = eltype(circle)
        loopedcomplete = DiGraph{T}(loopedcompletedg)
        newcircle = transitiveclosure(circle, true)
        @test @inferred(newcircle) == loopedcomplete
        @test @inferred(ne(circle)) == 4
        @test @inferred(newcircle) == transitiveclosure!(circle, true)
        @test @inferred(ne(circle)) == 16
    end
end
