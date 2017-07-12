import LightGraphs.SimpleGraphs.SimpleEdge
@testset "SimpleEdge" begin
    e = SimpleEdge(1, 2)
    re = SimpleEdge(2, 1)

    for s in [0x01, UInt16(1), 1]
        T = typeof(s)
        d = s + one(T)
        p = Pair(s, d)

        ep1 = SimpleEdge(p)
        ep2 = SimpleEdge{UInt8}(p)
        ep3 = SimpleEdge{Int16}(p)

        t1 = (s, d)
        t2 = (s, d, "foo")

        @test src(ep1) == src(ep2) == src(ep3) == s
        @test dst(ep1) == dst(ep2) == dst(ep3) == s + one(T)

        @test eltype(p) == typeof(s)
        @test SimpleEdge(p) == e
        @test SimpleEdge(t1) == SimpleEdge(t2) == e
        @test SimpleEdge(t1) == SimpleEdge{UInt8}(t1) == SimpleEdge{Int16}(t1)
        @test SimpleEdge{Int64}(ep1) == e

        @test Pair(e) == p
        @test Tuple(e) == t1
        @test reverse(ep1) == re
        @test sprint(show, ep1) == "Edge 1 => 2"
    end
end
