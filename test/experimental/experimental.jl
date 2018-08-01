const testdir = dirname(@__FILE__)

tests = ["isomorphism"]

@testset "Experimental" begin
    @test length(description()) > 1

    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
