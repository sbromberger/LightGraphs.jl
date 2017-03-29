@testset "Transitivity" begin
    completedg = CompleteDiGraph(4)
    circledg = PathDiGraph(4)
    add_edge!(circledg, 4, 1)
    for circle in testdigraphs(circledg)
        T = eltype(circle)
        complete = DiGraph{T}(completedg)
        newcircle = @inferred(transitiveclosure(circle))
        @test newcircle == complete
        @test ne(circle) == 4
        @test newcircle == @inferred(transitiveclosure!(circle))
        @test ne(circle) == 12
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
        newcircle = @inferred(transitiveclosure(circle, true))
        @test newcircle == loopedcomplete
        @test ne(circle) == 4
        @test newcircle == @inferred(transitiveclosure!(circle, true))
        @test ne(circle) == 16
    end
end
