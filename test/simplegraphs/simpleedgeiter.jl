@testset "SimpleEdgeIter" begin
    ga = @inferred(SimpleGraph(10, 20; seed=1))
    gb = @inferred(SimpleGraph(10, 20; seed=1))
    dga = @inferred(SimpleDiGraph(10, 20; seed=1))
    dgb = @inferred(SimpleDiGraph(10, 20; seed=1))
    @testset "string representation" begin
        @test sprint(show, edges(ga)) == "SimpleEdgeIter 20"
    end

    @test length(collect(edges(Graph(0, 0)))) == 0

    @testset "collection operations" begin
        @test @inferred(edges(ga)) == edges(gb)
        @test @inferred(edges(ga)) == collect(Edge, edges(gb))
        @test edges(ga) != collect(Edge, Base.Iterators.take(edges(gb), 5))
        @test collect(Edge, edges(gb)) == edges(ga)
        @test Set{Edge}(collect(Edge, edges(gb))) == edges(ga)
        @test @inferred(edges(ga)) == Set{Edge}(collect(Edge, edges(gb)))

        @test @inferred(edges(dga)) == edges(dgb)
        @test @inferred(edges(dga)) == collect(SimpleEdge, edges(dgb))
        @test edges(dga) != collect(Edge, Base.Iterators.take(edges(dgb), 5))
        @test collect(SimpleEdge, edges(dgb)) == edges(dga)
        @test Set{Edge}(collect(SimpleEdge, edges(dgb))) == edges(dga)
        @test @inferred(edges(dga)) == Set{SimpleEdge}(collect(SimpleEdge, edges(dgb)))
    end
    @testset "eltype" begin
        @test @inferred(eltype(edges(ga))) == eltype(typeof(edges(ga))) == edgetype(ga)
        @test eltype(collect(edges(ga))) == edgetype(ga)
        @test eltype(collect(edges(dga))) == edgetype(dga)
        #
        # codecov for eltype(::Type{SimpleEdgeIter{SimpleDiGraph{T}}}) where {T} = SimpleDiGraphEdge{T}
        gd = SimpleDiGraph{UInt8}(10, 20)
        @test @inferred(eltype(edges(gd))) == eltype(typeof(edges(gd))) == edgetype(gd) == SimpleDiGraphEdge{UInt8}
    end

    ga = SimpleGraph(10)
    add_edge!(ga, 3, 2)
    add_edge!(ga, 3, 10)
    add_edge!(ga, 5, 10)
    add_edge!(ga, 10, 3)

    dga = SimpleDiGraph(10)
    add_edge!(dga, 3, 2)
    add_edge!(dga, 3, 10)
    add_edge!(dga, 5, 10)
    add_edge!(dga, 10, 3)

    e1 = Edge(3, 10)
    e2 = (3, 10)
    @testset "membership operations" begin
        @test e1 ∈ edges(ga)
        @test e2 ∈ edges(ga)
        @test (3, 9) ∉ edges(ga)

        for u in 1:12, v in 1:12
            b = has_edge(ga, u, v)
            @test b == @inferred (u, v) ∈ edges(ga)
            @test b == @inferred (u => v) ∈ edges(ga)
            @test b == @inferred Edge(u, v) ∈ edges(ga)

            db = has_edge(dga, u, v)
            @test db == @inferred (u, v) ∈ edges(dga)
            @test db == @inferred (u => v) ∈ edges(dga)
            @test db == @inferred Edge(u, v) ∈ edges(dga)
        end
    end

    @testset "iterator protocol" begin
        eit = edges(ga)
        # @inferred not valid for new interface anymore (return type is a Union)
        @test collect(eit) == [Edge(2, 3), Edge(3, 10), Edge(5, 10)]

        eit = @inferred(edges(dga))
        @test collect(eit) == [
            SimpleEdge(3, 2), SimpleEdge(3, 10),
            SimpleEdge(5, 10), SimpleEdge(10, 3)
        ]
    end

    @testset "graph modifications" begin
        gb = copy(ga)
        add_vertex!(gb)
        @test edges(ga) == edges(gb)
        @test edges(gb) == edges(ga)

        dgb = copy(dga)
        add_vertex!(dgb)
        @test edges(dga) == edges(dgb)
        @test edges(dgb) == edges(dga)
    end
end
