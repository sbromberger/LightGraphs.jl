@testset "Parallel.Generate Reduce" begin

    function make_vec(g::AbstractGraph{T}) where T<:Integer
        return Vector{T}(undef, nv(g))
    end

    function comp_vec(x::Vector, y::Vector)
        return length(x) < length(y)
    end

    g1 = StarGraph(5)

    for parallel in [:distributed, :threads]
        for g in testgraphs(g1)

            s = @inferred(LightGraphs.Parallel.generate_reduce(g, make_vec, comp_vec, 5; parallel=parallel))
            @test length(s) == 5
        end
    end
end
