@testset "SimpleEdge" begin
    e = SGC.SimpleEdge(1, 2)
    re = SGC.SimpleEdge(2, 1)

    @testset "edgetype: $(typeof(s))" for s in [0x01, UInt16(1), 1]
        T = typeof(s)
        d = s + one(T)
        p = Pair(s, d)

        ep1 = SGC.SimpleEdge(p)
        ep2 = SGC.SimpleEdge{UInt8}(p)
        ep3 = SGC.SimpleEdge{Int16}(p)

        t1 = (s, d)
        t2 = (s, d, "foo")

        @test src(ep1) == src(ep2) == src(ep3) == s
        @test dst(ep1) == dst(ep2) == dst(ep3) == s + one(T)

        @test eltype(ep1) == eltype(SGC.SimpleEdge{T}) == T

        @test eltype(p) == typeof(s)
        @test SGC.SimpleEdge(p) == e
        @test SGC.SimpleEdge(t1) == SGC.SimpleEdge(t2) == e
        @test SGC.SimpleEdge(t1) == SGC.SimpleEdge{UInt8}(t1) == SGC.SimpleEdge{Int16}(t1)
        @test SGC.SimpleEdge{Int64}(ep1) == e

        @test Pair(e) == p
        @test Tuple(e) == t1
        @test reverse(ep1) == re
        @test sprint(show, ep1) == "Edge 1 => 2"
    end
end
