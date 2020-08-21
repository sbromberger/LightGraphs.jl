@testset "SimpleEdge" begin
    e = SG.SimpleEdge(1, 2)
    re = SG.SimpleEdge(2, 1)

    @testset "edgetype: $(typeof(s))" for s in [0x01, UInt16(1), 1]
        T = typeof(s)
        d = s + one(T)
        p = Pair(s, d)

        ep1 = SG.SimpleEdge(p)
        ep2 = SG.SimpleEdge{UInt8}(p)
        ep3 = SG.SimpleEdge{Int16}(p)

        t1 = (s, d)
        t2 = (s, d, "foo")

        @test src(ep1) == src(ep2) == src(ep3) == s
        @test dst(ep1) == dst(ep2) == dst(ep3) == s + one(T)

        @test eltype(ep1) == eltype(SG.SimpleEdge{T}) == T

        @test eltype(p) == typeof(s)
        @test SG.SimpleEdge(p) == e
        @test SG.SimpleEdge(t1) == SG.SimpleEdge(t2) == e
        @test SG.SimpleEdge(t1) == SG.SimpleEdge{UInt8}(t1) == SG.SimpleEdge{Int16}(t1)
        @test SG.SimpleEdge{Int64}(ep1) == e

        @test Pair(e) == p
        @test Tuple(e) == t1
        @test reverse(ep1) == re
        @test sprint(show, ep1) == "Edge 1 => 2"
    end
end
