@testset "Transitivity" begin
    completeg = CompleteGraph(4)
    circleg = PathGraph(4)
    add_edge!(circleg, 4, 1)
    @testset "$circle" for circle in testgraphs(circleg)
        T = eltype(circle)
        complete = Graph{T}(completeg)
        @testset "no self-loops" begin
            newcircle = @inferred(transitiveclosure(circle))
            @test newcircle == complete
            @test ne(circle) == 4
            c = copy(circle)
            @test newcircle == @inferred(transitiveclosure!(c))
            @test ne(c) == ne(newcircle) == 6
        end

        loopedcomplete = copy(complete)
        for i in vertices(loopedcomplete)
            add_edge!(loopedcomplete, i, i)
        end
        @testset "self-loops" begin
            newcircle = @inferred(transitiveclosure(circle, true))
            @test newcircle == loopedcomplete
            @test ne(circle) == 4
            c = copy(circle)
            @test newcircle == @inferred(transitiveclosure!(c, true))
            @test ne(c) == ne(newcircle) == 10
        end
    end
end
