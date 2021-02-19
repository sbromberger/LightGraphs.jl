suite["core"] = BenchmarkGroup(["nv", "edges", "has_edge"])

function all_has_edge(g::AbstractGraph)
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

function iter_edges(g::AbstractGraph)
    i = 0
    for e in edges(g)
        i += 1
    end
    return i
end

# nv
suite["core"]["nv"] = BenchmarkGroup(["graphs", "digraphs"])
suite["core"]["nv"]["graphs"] = @benchmarkable [nv(g) for (n,g) in $GRAPHS]
suite["core"]["nv"]["digraphs"] = @benchmarkable [nv(g) for (n,g) in $DIGRAPHS]

# iter edges
suite["core"]["edges"] = BenchmarkGroup(["graphs", "digraphs"])
suite["core"]["edges"]["graphs"] = @benchmarkable [iter_edges(g) for (n,g) in $GRAPHS]
suite["core"]["edges"]["digraphs"] = @benchmarkable [iter_edges(g) for (n,g) in $DIGRAPHS]

# has edge
suite["core"]["has_edge"] = BenchmarkGroup(["graphs", "digraphs"])
suite["core"]["has_edge"]["graphs"] = @benchmarkable [all_has_edge(g) for (n,g) in $GRAPHS]
suite["core"]["has_edge"]["digraphs"] = @benchmarkable [all_has_edge(g) for (n,g) in $DIGRAPHS]
