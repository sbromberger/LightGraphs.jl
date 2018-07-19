@testset "Utils" begin
    s = @inferred(LightGraphs.sample!([1:10;], 3))
    @test length(s) == 3
    for e in s
        @test 1 <= e <= 10
    end

    s = @inferred(LightGraphs.sample!([1:10;], 6, exclude=[1, 2]))
    @test length(s) == 6
    for e in s
        @test 3 <= e <= 10
    end

    s = @inferred(LightGraphs.sample(1:10, 6, exclude=[1, 2]))
    @test length(s) == 6
    for e in s
        @test 3 <= e <= 10
    end
end

@testset "Generate Reduce" begin

    function make_vec(g::AbstractGraph{T}) where T<:Integer
        return Vector{T}(undef, nv(g))
    end

    g1 = StarGraph(5)

    for g in testgraphs(g1)
        s = @inferred(LightGraphs.generate_max_set(g, make_vec, 5))
        @test length(s) == 5
    end

    for g in testgraphs(g1)
        s = @inferred(LightGraphs.generate_max_set(g, make_vec, 5))
        @test length(s) == 5
    end
end


@testset "Greedy Contiguous Partition" begin

    p = @inferred(LightGraphs.greedy_contiguous_partition([1, 1, 1, 3], 2))
    @test p == [1:3, 4:4]

    p = @inferred(LightGraphs.greedy_contiguous_partition([1, 2, 3, 4, 5, 100, 1, 3, 1, 1], 3))
    @test p == [1:5, 6:6, 7:10]

    p = @inferred(LightGraphs.greedy_contiguous_partition([1, 1, 1, 1], 4))
    @test p == [1:1, 2:2, 3:3, 4:4]
end

@testset "Optimal Contiguous Partition" begin

    p = @inferred(LightGraphs.optimal_contiguous_partition([1, 1, 1, 3], 2))
    @test p == [1:3, 4:4]

    p = @inferred(LightGraphs.optimal_contiguous_partition([1, 2, 3, 4, 5, 100, 1, 3, 1, 1], 3))
    @test p == [1:5, 6:6, 7:10]

    p = @inferred(LightGraphs.optimal_contiguous_partition([1, 1, 1, 1], 4))
    @test p == [1:1, 2:2, 3:3, 4:4]
end
