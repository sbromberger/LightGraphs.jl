@testset "SimpleEdgeIter" begin
    rng1 = MersenneTwister(1)
    rng2 = MersenneTwister(1)
    ga = @inferred(SG.SimpleGraph(10, 20; rng=rng1))
    gb = @inferred(SG.SimpleGraph(10, 20; rng=rng2))
    dga = @inferred(SG.SimpleDiGraph(10, 20; rng=rng1))
    dgb = @inferred(SG.SimpleDiGraph(10, 20; rng=rng2))
    @testset "string representation" begin
        @test sprint(show, edges(ga)) == "SimpleEdgeIter 20"
    end

    @test length(collect(edges(SG.SimpleGraph(0, 0)))) == 0

    @testset "collection operations" begin
        @test @inferred(edges(ga)) == edges(gb)
        @test @inferred(edges(ga)) == collect(SG.SimpleEdge, edges(gb))
        @test edges(ga) != collect(SG.SimpleEdge, Base.Iterators.take(edges(gb), 5))
        @test collect(SG.SimpleEdge, edges(gb)) == edges(ga)
        @test Set{SG.SimpleEdge}(collect(SG.SimpleEdge, edges(gb))) == edges(ga)
        @test @inferred(edges(ga)) == Set{SG.SimpleEdge}(collect(SG.SimpleEdge, edges(gb)))

        @test @inferred(edges(dga)) == edges(dgb)
        @test @inferred(edges(dga)) == collect(SG.SimpleEdge, edges(dgb))
        @test edges(dga) != collect(SG.SimpleEdge, Base.Iterators.take(edges(dgb), 5))
        @test collect(SG.SimpleEdge, edges(dgb)) == edges(dga)
        @test Set{SG.SimpleEdge}(collect(SG.SimpleEdge, edges(dgb))) == edges(dga)
        @test @inferred(edges(dga)) == Set{SG.SimpleEdge}(collect(SG.SimpleEdge, edges(dgb)))
    end
    @testset "eltype" begin
        @test @inferred(eltype(edges(ga))) == eltype(typeof(edges(ga))) == edgetype(ga)
        @test eltype(collect(edges(ga))) == edgetype(ga)
        @test eltype(collect(edges(dga))) == edgetype(dga)
        #
        # codecov for eltype(::Type{SimpleEdgeIter{SimpleDiGraph{T}}}) where {T} = SimpleDiGraphEdge{T}
        gd = SG.SimpleDiGraph{UInt8}(10, 20)
        @test @inferred(eltype(edges(gd))) == eltype(typeof(edges(gd))) == edgetype(gd) == SG.SimpleDiGraphEdge{UInt8}
    end

    ga = SG.SimpleGraph(10)
    SG.add_edge!(ga, 3, 2)
    SG.add_edge!(ga, 3, 10)
    SG.add_edge!(ga, 5, 10)
    SG.add_edge!(ga, 10, 3)

    dga = SG.SimpleDiGraph(10)
    SG.add_edge!(dga, 3, 2)
    SG.add_edge!(dga, 3, 10)
    SG.add_edge!(dga, 5, 10)
    SG.add_edge!(dga, 10, 3)

    e1 = SG.SimpleEdge(3, 10)
    e2 = (3, 10)
    @testset "membership operations" begin
        @test e1 ∈ edges(ga)
        @test e2 ∈ edges(ga)
        @test (3, 9) ∉ edges(ga)

        for u in 1:12, v in 1:12
            b = has_edge(ga, u, v)
            @test b == @inferred (u, v) ∈ edges(ga)
            @test b == @inferred (u => v) ∈ edges(ga)
            @test b == @inferred SG.SimpleEdge(u, v) ∈ edges(ga)

            db = has_edge(dga, u, v)
            @test db == @inferred (u, v) ∈ edges(dga)
            @test db == @inferred (u => v) ∈ edges(dga)
            @test db == @inferred SG.SimpleEdge(u, v) ∈ edges(dga)
        end
    end

    @testset "iterator protocol" begin
        eit = edges(ga)
        # @inferred not valid for new interface anymore (return type is a Union)
        @test collect(eit) == [SG.SimpleEdge(2, 3), SG.SimpleEdge(3, 10), SG.SimpleEdge(5, 10)]

        eit = @inferred(edges(dga))
        @test collect(eit) == [
            SG.SimpleEdge(3, 2), SG.SimpleEdge(3, 10),
            SG.SimpleEdge(5, 10), SG.SimpleEdge(10, 3)
        ]
    end

    @testset "graph modifications" begin
        gb = copy(ga)
        SG.add_vertex!(gb)
        @test edges(ga) == edges(gb)
        @test edges(gb) == edges(ga)

        dgb = copy(dga)
        SG.add_vertex!(dgb)
        @test edges(dga) == edges(dgb)
        @test edges(dgb) == edges(dga)
    end
end
