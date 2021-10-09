import Base: convert

suite["edges"] = BenchmarkGroup(["fille", "fillp", "tsume", "tsump"])

const P = Pair{Int,Int}

convert(::Type{Tuple}, e::Pair) = (e.first, e.second)

function fille(n)
    t = Array{LightGraphs.Edge,1}(undef, n)
    for i in 1:n
        t[i] = LightGraphs.Edge(i, i + 1)
    end
    return t
end

function fillp(n)
    t = Array{P,1}(undef, n)
    for i in 1:n
        t[i] = P(i, i + 1)
    end
    return t
end

function tsum(t)
    x = 0
    for i in 1:length(t)
        u, v = Tuple(t[i])
        x += u
        x += v
    end
    return x
end


n = 10000
suite["edges"]["fille"] = @benchmarkable fille($n)
suite["edges"]["fillp"] = @benchmarkable fillp($n)
a, b = fille(n), fillp(n)
suite["edges"]["tsume"] = @benchmarkable tsum($a)
suite["edges"]["tsump"] = @benchmarkable tsum($b)
