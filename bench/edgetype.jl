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
@time fille(10)
@time fillp(10)
n = 10000
@time a = fille(n)
@time b = fillp(n)
info("made arrays")
@time tsum(@show a[1:10])
@time tsum(b[1:10])
@time tsum(a)
@time tsum(b)

info("done")
