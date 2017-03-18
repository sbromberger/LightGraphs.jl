bg = BenchmarkGroup()
SUITE["core"] = bg

function bench_iteredges(g::AbstractGraph)
  i = 0
  for e in edges(g)
    i += 1
  end
  return i
end

function bench_has_edge(g::AbstractGraph)
    srand(1)
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

for fun in EDGEFNS
    for (name, g) in GRAPHS
        bg["edges","$fun","graph","$name"] = @benchmarkable $fun($g)
    end

    for (name, g) in DIGRAPHS
        bg["edges","$fun","digraph","$name"] = @benchmarkable $fun($g)
    end

end
