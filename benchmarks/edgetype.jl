bg = BenchmarkGroup()
SUITE["edgetype"] = bg
import Base: convert
typealias P Pair{Int, Int}
immutable Edge
    src::Int
    dst::Int
end

function fille(n)
    t = Array{Edge,1}(n)
    for i in 1:n
        t[i] = Edge(i, i+1)
    end
    return t
end

function fillp(n)
    t = Array{P,1}(n)
    for i in 1:n
        t[i] = P(i, i+1)
    end
    return t
end

function tsum(t)
    x = 0
    for i in 1:length(t)
        u,v = Tuple(t[i])
        x += u
        x += v
    end
    return x
end

src(e) = e.src
dst(e) = e.dst
convert(::Type{Tuple}, e::Edge) = (src(e), dst(e))
convert(::Type{Tuple}, e::Pair) = (e.first, e.second)

n = 10000
bg["edgetype", "fille", "$n"] = @benchmarkable fille($n)
bg["edgetype", "fillp", "$n"] = @benchmarkable fillp($n)
a, b = fille(n), fillp(n)
bg["edgetype", "tsume", "$n"] = @benchmarkable tsum($a)
bg["edgetype", "tsump", "$n"] = @benchmarkable tsum($b)
