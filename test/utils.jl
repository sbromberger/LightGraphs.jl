using LightGraphs.Generators
const LGGEN=LightGraphs.Generators
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

    # tests if isbounded has the correct behaviour
    bounded_int_types = [Int8, Int16, Int32, Int64, Int128,
                         UInt8, UInt16, UInt32, UInt64, UInt128,
                         Int, Bool]
    unbounded_int_types = [BigInt, Signed, Unsigned, Integer, Union{Int8, UInt8}]
    for T in bounded_int_types
        @test LightGraphs.isbounded(T) == true
        @test LightGraphs.isbounded(T(0)) == true
    end
    for T in unbounded_int_types
        @test LightGraphs.isbounded(T) == false
        if isconcretetype(T)
            @test LightGraphs.isbounded(T(0)) == false
        end
    end

    A = [false, true, false, false, true, true]
    @test findall(A) == LightGraphs.findall!(A, Vector{Int16}(undef, 6))[1:3]
end




@testset "Unweighted Contiguous Partition" begin

    p = @inferred(LightGraphs.unweighted_contiguous_partition(4, 2))
    @test p == [1:2, 3:4]

    p = @inferred(LightGraphs.unweighted_contiguous_partition(10, 3))
    @test p == [1:3, 4:6, 7:10]

    p = @inferred(LightGraphs.unweighted_contiguous_partition(4, 4))
    @test p == [1:1, 2:2, 3:3, 4:4]
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

@testset "is_graphical" begin
    @test is_graphical([3, 3, 2, 1, 1, 0])
    @test !is_graphical([3, 3, 3, 1, 1]) # odd sum
    @test !is_graphical([4, 3, 2, 1])
    @test is_graphical([2, 2, 2, 2])
end
                       
@testset "distributed_generate_reduce" begin

    function make_vec(g::AbstractGraph{T}) where T<:Integer
        return Vector{T}(undef, nv(g))
    end

    function comp_vec(x::Vector, y::Vector)
        return length(x) < length(y)
    end

    g1 = SimpleGraph(LGGEN.Star(5))

    for g in testgraphs(g1)

        s = @inferred(LightGraphs.distributed_generate_reduce(g, make_vec, comp_vec, 5))
        @test length(s) == 5
    end
end

@testset "threaded_generate_reduce" begin

    function make_vec(g::AbstractGraph{T}) where T<:Integer
        return Vector{T}(undef, nv(g))
    end

    function comp_vec(x::Vector, y::Vector)
        return length(x) < length(y)
    end

    g1 = SimpleGraph(LGGEN.Star(5))

    for g in testgraphs(g1)

        s = @inferred(LightGraphs.threaded_generate_reduce(g, make_vec, comp_vec, 5))
        @test length(s) == 5
    end
end
