function bench_iteredges(g::AbstractGraph)
    i = 0
    for e in edges(g)
        i += 1
    end
    return i
end

function bench_has_edge(g::AbstractGraph)
    seed!(1)
    nvg = nv(g)
    srcs = rand([1:nvg;], cld(nvg, 4))
    dsts = rand([1:nvg;], cld(nvg, 4))
    i = 0
    for (s, d) in zip(srcs, dsts)
        if has_edge(g, s, d)
            i += 1
        end
    end
    return i
end


EDGEFNS = [
    bench_iteredges,
    bench_has_edge
]

@benchgroup "edges" begin

    for fun in EDGEFNS
        @benchgroup "$fun" begin
            @benchgroup "graph" begin
                for (name, g) in GRAPHS
                    @bench "$name" $fun($g)
                end
            end
            @benchgroup "digraph" begin
                for (name, g) in DIGRAPHS
                    @bench "$name" $fun($g)
                end
            end # digraph
        end # fun
    end
end # edges
