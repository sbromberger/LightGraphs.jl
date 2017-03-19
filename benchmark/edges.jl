import Base: convert
typealias P Pair{Int, Int}

convert(::Type{Tuple}, e::Pair) = (e.first, e.second)

function fille(n)
    t = Array{LightGraphs.Edge,1}(n)
    for i in 1:n
        t[i] = LightGraphs.Edge(i, i+1)
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

n = 10000
@benchgroup "edges" begin
  @bench "$(n): fille" fille($n)
  @bench "$(n): fillp" fillp($n)
  a, b = fille(n), fillp(n)
  @bench "$(n): tsume" tsum($a)
  @bench "$(n): tsump" tsum($b)
end # edges
