@testset "Transitivity" begin
    complete = CompleteDiGraph(4)
    circle = PathDiGraph(4)
    add_edge!(circle, 4, 1)
    newcircle = transitiveclosure(circle)
    @test newcircle == complete
    @test ne(circle) == 4
    @test newcircle == transitiveclosure!(circle)
    @test ne(circle) == 12

    loopedcomplete = copy(complete)
    for i in vertices(loopedcomplete)
        add_edge!(loopedcomplete, i, i)
    end
    circle = PathDiGraph(4)
    add_edge!(circle, 4, 1)
    newcircle = transitiveclosure(circle, true)
    @test newcircle == loopedcomplete
    @test ne(circle) == 4
    @test newcircle == transitiveclosure!(circle, true)
    @test ne(circle) == 16
end
