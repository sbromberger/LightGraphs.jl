@testset "SimpleEdgeIter" begin
    rng1 = MersenneTwister(1)
    rng2 = MersenneTwister(1)
    ga = @inferred(SGC.SimpleGraph(10, 20; rng=rng1))
    gb = @inferred(SGC.SimpleGraph(10, 20; rng=rng2))
    dga = @inferred(SGC.SimpleDiGraph(10, 20; rng=rng1))
    dgb = @inferred(SGC.SimpleDiGraph(10, 20; rng=rng2))
    @testset "string representation" begin
        @test sprint(show, edges(ga)) == "SimpleEdgeIter 20"
    end

    @test length(collect(edges(SGC.SimpleGraph(0, 0)))) == 0

    @testset "collection operations" begin
        @test @inferred(edges(ga)) == edges(gb)
        @test @inferred(edges(ga)) == collect(SGC.SimpleEdge, edges(gb))
        @test edges(ga) != collect(SGC.SimpleEdge, Base.Iterators.take(edges(gb), 5))
        @test collect(SGC.SimpleEdge, edges(gb)) == edges(ga)
        @test Set{SGC.SimpleEdge}(collect(SGC.SimpleEdge, edges(gb))) == edges(ga)
        @test @inferred(edges(ga)) == Set{SGC.SimpleEdge}(collect(SGC.SimpleEdge, edges(gb)))

        @test @inferred(edges(dga)) == edges(dgb)
        @test @inferred(edges(dga)) == collect(SGC.SimpleEdge, edges(dgb))
        @test edges(dga) != collect(SGC.SimpleEdge, Base.Iterators.take(edges(dgb), 5))
        @test collect(SGC.SimpleEdge, edges(dgb)) == edges(dga)
        @test Set{SGC.SimpleEdge}(collect(SGC.SimpleEdge, edges(dgb))) == edges(dga)
        @test @inferred(edges(dga)) == Set{SGC.SimpleEdge}(collect(SGC.SimpleEdge, edges(dgb)))
    end
    @testset "eltype" begin
        @test @inferred(eltype(edges(ga))) == eltype(typeof(edges(ga))) == edgetype(ga)
        @test eltype(collect(edges(ga))) == edgetype(ga)
        @test eltype(collect(edges(dga))) == edgetype(dga)
        #
        # codecov for eltype(::Type{SimpleEdgeIter{SimpleDiGraph{T}}}) where {T} = SimpleDiGraphEdge{T}
        gd = SGC.SimpleDiGraph{UInt8}(10, 20)
        @test @inferred(eltype(edges(gd))) == eltype(typeof(edges(gd))) == edgetype(gd) == SGC.SimpleDiGraphEdge{UInt8}
    end

    ga = SGC.SimpleGraph(10)
    SGC.add_edge!(ga, 3, 2)
    SGC.add_edge!(ga, 3, 10)
    SGC.add_edge!(ga, 5, 10)
    SGC.add_edge!(ga, 10, 3)

    dga = SGC.SimpleDiGraph(10)
    SGC.add_edge!(dga, 3, 2)
    SGC.add_edge!(dga, 3, 10)
    SGC.add_edge!(dga, 5, 10)
    SGC.add_edge!(dga, 10, 3)

    e1 = SGC.SimpleEdge(3, 10)
    e2 = (3, 10)
    @testset "membership operations" begin
        @test e1 ∈ edges(ga)
        @test e2 ∈ edges(ga)
        @test (3, 9) ∉ edges(ga)

        for u in 1:12, v in 1:12
            b = has_edge(ga, u, v)
            @test b == @inferred (u, v) ∈ edges(ga)
            @test b == @inferred (u => v) ∈ edges(ga)
            @test b == @inferred SGC.SimpleEdge(u, v) ∈ edges(ga)

            db = has_edge(dga, u, v)
            @test db == @inferred (u, v) ∈ edges(dga)
            @test db == @inferred (u => v) ∈ edges(dga)
            @test db == @inferred SGC.SimpleEdge(u, v) ∈ edges(dga)
        end
    end

    @testset "iterator protocol" begin
        eit = edges(ga)
        # @inferred not valid for new interface anymore (return type is a Union)
        @test collect(eit) == [SGC.SimpleEdge(2, 3), SGC.SimpleEdge(3, 10), SGC.SimpleEdge(5, 10)]

        eit = @inferred(edges(dga))
        @test collect(eit) == [
            SGC.SimpleEdge(3, 2), SGC.SimpleEdge(3, 10),
            SGC.SimpleEdge(5, 10), SGC.SimpleEdge(10, 3)
        ]
    end

    @testset "graph modifications" begin
        gb = copy(ga)
        SGC.add_vertex!(gb)
        @test edges(ga) == edges(gb)
        @test edges(gb) == edges(ga)

        dgb = copy(dga)
        SGC.add_vertex!(dgb)
        @test edges(dga) == edges(dgb)
        @test edges(dgb) == edges(dga)
    end
end
