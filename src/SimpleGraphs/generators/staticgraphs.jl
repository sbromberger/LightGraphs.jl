# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

"""
    CompleteGraph(n)

Create an undirected [complete graph](https://en.wikipedia.org/wiki/Complete_graph)
with `n` vertices.
"""
function CompleteGraph(n::T) where {T <: Integer}
    n <= 0 && return SimpleGraph{T}(0)
    ne = Int(n * (n - 1) ÷ 2)
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds @simd for u = 1:n
        listu = Vector{T}(undef, n-1)
        listu[1:(u-1)] = 1:(u - 1)
        listu[u:(n-1)] = (u + 1):n
        fadjlist[u] = listu
    end
    return SimpleGraph(ne, fadjlist)
end


"""
    CompleteBipartiteGraph(n1, n2)

Create an undirected [complete bipartite graph](https://en.wikipedia.org/wiki/Complete_bipartite_graph)
with `n1 + n2` vertices.
"""
function CompleteBipartiteGraph(n1::T, n2::T) where {T <: Integer}
    (n1 < 0 || n2 < 0) && return SimpleGraph{T}(0)
    Tw = widen(T)
    nw = Tw(n1) + Tw(n2)
    n = T(nw)  # checks if T is large enough for n1 + n2

    ne = Int(n1) * Int(n2)

    fadjlist = Vector{Vector{T}}(undef, n)
    range1 = 1:n1
    range2 = (n1 + 1):n
    @inbounds @simd for u in range1
        fadjlist[u] = Vector{T}(range2)
    end
    @inbounds @simd for u in range2
        fadjlist[u] = Vector{T}(range1)
    end
    return SimpleGraph(ne, fadjlist)
end

"""
    CompleteMultipartiteGraph(partitions)

Create an undirected [complete bipartite graph](https://en.wikipedia.org/wiki/Complete_bipartite_graph)
with `sum(partitions)` vertices. A partition with `0` vertices is skipped.

### Implementation Notes
Preserves the eltype of the partitions vector. Will error if the required number of vertices
exceeds the eltype.
"""
function CompleteMultipartiteGraph(partitions::AbstractVector{T}) where {T <: Integer}
    any(x -> x < 0, partitions) && return SimpleGraph{T}(0)
    length(partitions) == 1 && return SimpleGraph{T}(partitions[1])
    length(partitions) == 2 && return CompleteBipartiteGraph(partitions[1], partitions[2])

    n = sum(partitions)

    ne = 0
    for p in partitions # type stability fails if we use sum and a generator here
        ne += p*(Int(n)-p) # overflow if we don't convert to Int
    end
    ne = div(ne, 2)

    fadjlist = Vector{Vector{T}}(undef, n)
    cur = 1
    for p in partitions
        currange = cur:(cur+p-1) # all vertices in the current partition
        lowerrange = 1:(cur-1)   # all vertices lower than the current partition
        upperrange = (cur+p):n   # all vertices higher than the current partition
        @inbounds @simd for u in currange
            fadjlist[u] = Vector{T}(undef, length(lowerrange) + length(upperrange))
            fadjlist[u][1:length(lowerrange)] = lowerrange
            fadjlist[u][(length(lowerrange)+1):end] = upperrange
        end
        cur += p
    end

    return SimpleGraph{T}(ne, fadjlist)
end

"""
    TuranGraph(n, r)

Creates a [Turán Graph](https://en.wikipedia.org/wiki/Tur%C3%A1n_graph), a complete 
multipartite graph with `n` vertices and `r` partitions.
"""
function TuranGraph(n::T, r::T) where {T <: Integer}
    !(1 <= r <= n) && throw(DomainError("n=$n and r=$r are invalid, must satisfy 1 <= r <= n"))
    partitions = Vector{T}(undef, r)
    c = cld(n,r)
    f = fld(n,r)
    @inbounds @simd for i in 1:(n%r)
        partitions[i] = c
    end
    @inbounds @simd for i in ((n%r)+1):r
        partitions[i] = f
    end
    return CompleteMultipartiteGraph(partitions)
end

"""
    CompleteDiGraph(n)

Create a directed [complete graph](https://en.wikipedia.org/wiki/Complete_graph)
with `n` vertices.
"""
function CompleteDiGraph(n::T) where {T <: Integer}
    n <= 0 && return SimpleDiGraph{T}(0)

    ne = Int(n * (n - 1))
    fadjlist = Vector{Vector{T}}(undef, n)
    badjlist = Vector{Vector{T}}(undef, n)
    @inbounds @simd for u = 1:n
        listu = Vector{T}(undef, n-1)
        listu[1:(u-1)] = 1:(u - 1)
        listu[u:(n-1)] = (u + 1):n
        fadjlist[u] = listu
        badjlist[u] = deepcopy(listu)
    end
    return SimpleDiGraph(ne, fadjlist, badjlist)
end

"""
    StarGraph(n)

Create an undirected [star graph](https://en.wikipedia.org/wiki/Star_(graph_theory))
with `n` vertices.
"""
function StarGraph(n::T) where {T <: Integer}
    n <= 0 && return SimpleGraph{T}(0)

    ne = Int(n - 1)
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = Vector{T}(2:n)
    @inbounds @simd for u = 2:n
        fadjlist[u] = T[1]
    end
    return SimpleGraph(ne, fadjlist)
end

"""
    StarDiGraph(n)

Create a directed [star graph](https://en.wikipedia.org/wiki/Star_(graph_theory))
with `n` vertices.
"""
function StarDiGraph(n::T) where {T <: Integer}
    n <= 0 && return SimpleDiGraph{T}(0)

    ne = Int(n - 1)
    fadjlist = Vector{Vector{T}}(undef, n)
    badjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = Vector{T}(2:n)
    @inbounds badjlist[1] = T[]
    @inbounds @simd for u = 2:n
        fadjlist[u] = T[]
        badjlist[u] = T[1]
    end
    return SimpleDiGraph(ne, fadjlist, badjlist)
end

"""
    PathGraph(n)

Create an undirected [path graph](https://en.wikipedia.org/wiki/Path_graph)
with `n` vertices.
"""
function PathGraph(n::T) where {T <: Integer}
    n <= 1 && return SimpleGraph(n)

    ne = Int(n - 1)
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = T[2]
    @inbounds fadjlist[n] = T[n - 1]

    @inbounds @simd for u = 2:(n-1)
        fadjlist[u] = T[u - 1, u + 1]
    end
    return SimpleGraph(ne, fadjlist)
end

"""
    PathDiGraph(n)

Creates a directed [path graph](https://en.wikipedia.org/wiki/Path_graph)
with `n` vertices.
"""
function PathDiGraph(n::T) where {T <: Integer}
    n <= 1 && return SimpleDiGraph(n)

    ne = Int(n - 1)
    fadjlist = Vector{Vector{T}}(undef, n)
    badjlist = Vector{Vector{T}}(undef, n)

    @inbounds fadjlist[1] = T[2]
    @inbounds badjlist[1] = T[]
    @inbounds fadjlist[n] = T[]
    @inbounds badjlist[n] = T[n - 1]

    @inbounds @simd for u = 2:(n-1)
        fadjlist[u] = T[u + 1]
        badjlist[u] = T[u - 1]
    end
    return SimpleDiGraph(ne, fadjlist, badjlist)
end

"""
    CycleGraph(n)

Create an undirected [cycle graph](https://en.wikipedia.org/wiki/Cycle_graph)
with `n` vertices.
"""
function CycleGraph(n::T) where {T <: Integer}
    n <= 1 && return SimpleGraph(n)
    n == 2 && return SimpleGraph(Edge{T}.([(1, 2)]))

    ne = Int(n)
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = T[2, n]
    @inbounds fadjlist[n] = T[1, n-1]

    @inbounds @simd for u = 2:(n-1)
        fadjlist[u] = T[u-1, u+1]
    end
    return SimpleGraph(ne, fadjlist)
end

"""
    CycleDiGraph(n)

Create a directed [cycle graph](https://en.wikipedia.org/wiki/Cycle_graph)
with `n` vertices.
"""
function CycleDiGraph(n::T) where {T <: Integer}
    n <= 1 && return SimpleDiGraph(n)
    n == 2 && return SimpleDiGraph(Edge{T}.([(1, 2), (2, 1)]))

    ne = Int(n)
    fadjlist = Vector{Vector{T}}(undef, n)
    badjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = T[2]
    @inbounds badjlist[1] = T[n]
    @inbounds fadjlist[n] = T[1]
    @inbounds badjlist[n] = T[n-1]

    @inbounds @simd for u = 2:(n-1)
        fadjlist[u] = T[u + 1]
        badjlist[u] = T[u + -1]
    end
    return SimpleDiGraph(ne, fadjlist, badjlist)
end


"""
    WheelGraph(n)

Create an undirected [wheel graph](https://en.wikipedia.org/wiki/Wheel_graph)
with `n` vertices.
"""
function WheelGraph(n::T) where {T <: Integer}
    n <= 1 && return SimpleGraph(n)
    n <= 3 && return CycleGraph(n)
 
    ne = Int(2 * (n - 1))
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = Vector{T}(2:n)
    @inbounds fadjlist[2] = T[1, 3, n]
    @inbounds fadjlist[n] = T[1, 2, n - 1]

    @inbounds @simd for u = 3:(n-1)
        fadjlist[u] = T[1, u - 1, u + 1]
    end
    return SimpleGraph(ne, fadjlist)
end

"""
    WheelDiGraph(n)

Create a directed [wheel graph](https://en.wikipedia.org/wiki/Wheel_graph)
with `n` vertices.
"""
function WheelDiGraph(n::T) where {T <: Integer}
    n <= 2 && return PathDiGraph(n)
    n == 3 && return SimpleDiGraph(Edge{T}.([(1,2),(1,3),(2,3),(3,2)]))
 
    ne = Int(2 * (n - 1))
    fadjlist = Vector{Vector{T}}(undef, n)
    badjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = Vector{T}(2:n)
    @inbounds badjlist[1] = T[]
    @inbounds fadjlist[2] = T[3]
    @inbounds badjlist[2] = T[1, n]
    @inbounds fadjlist[n] = T[2]
    @inbounds badjlist[n] = T[1, n - 1]

    @inbounds @simd for u = 3:(n-1)
        fadjlist[u] = T[u + 1]
        badjlist[u] = T[1, u - 1]
    end
    return SimpleDiGraph(ne, fadjlist, badjlist)
end

"""
    Grid(dims; periodic=false)

Create a ``|dims|``-dimensional cubic lattice, with length `dims[i]`
in dimension `i`.

### Optional Arguments
- `periodic=false`: If true, the resulting lattice will have periodic boundary
condition in each dimension.
"""
function Grid(dims::AbstractVector{T}; periodic=false) where {T <: Integer}
    # checks if T is large enough for product(dims)
    Tw = widen(T)
    n = one(T)
    for d in dims
        d <= 0 && return SimpleGraph{T}(0)
        nw = Tw(n) * Tw(d)
        n = T(nw)
    end

    if periodic
        g = CycleGraph(dims[1])
        for d in dims[2:end]
            g = cartesian_product(CycleGraph(d), g)
        end
    else
        g = PathGraph(dims[1])
        for d in dims[2:end]
            g = cartesian_product(PathGraph(d), g)
        end
    end
    return g
end

"""
    BinaryTree(k::Integer)

Create a [binary tree](https://en.wikipedia.org/wiki/Binary_tree)
of depth `k`.
"""
function BinaryTree(k::T) where {T <: Integer}
    k <= 0 && return SimpleGraph(0)
    k == 1 && return SimpleGraph(1)
    if LightGraphs.isbounded(k) && BigInt(2) ^ k - 1 > typemax(k)
        throw(DomainError(k, "2^k - 1 not representable by type $T"))
    end
    n = T(2^k - 1)

    ne = Int(n - 1)
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = T[2, 3]
    @inbounds for i in 1:(k - 2)
        @simd for j in (2^i):(2^(i + 1) - 1)
            fadjlist[j] = T[j ÷ 2, 2j, 2j + 1]
        end
    end
    i = k - 1
    @inbounds @simd for j in (2^i):(2^(i + 1) - 1)
        fadjlist[j] = T[j ÷ 2]
    end
    return SimpleGraph(ne, fadjlist)
end

"""
    BinaryTree(k::Integer)

Create a double complete binary tree with `k` levels.

### References
- Used as an example for spectral clustering by Guattery and Miller 1998.
"""
function DoubleBinaryTree(k::Integer)
    gl = BinaryTree(k)
    gr = BinaryTree(k)
    g = blockdiag(gl, gr)
    add_edge!(g, 1, nv(gl) + 1)
    return g
end


"""
    RoachGraph(k)

Create a Roach Graph of size `k`.

### References
- Guattery and Miller 1998
"""
function RoachGraph(k::Integer)
    dipole = CompleteGraph(2)
    nopole = SimpleGraph(2)
    antannae = crosspath(k, nopole)
    body = crosspath(k, dipole)
    roach = blockdiag(antannae, body)
    add_edge!(roach, nv(antannae) - 1, nv(antannae) + 1)
    add_edge!(roach, nv(antannae), nv(antannae) + 2)
    return roach
end


"""
    CliqueGraph(k, n)

Create a graph consisting of `n` connected `k`-cliques.
"""
function CliqueGraph(k::T, n::T) where {T <: Integer}
    Tw = widen(T)
    knw = Tw(k) * Tw(n)
    kn = T(knw)  # checks if T is large enough for k * n

    g = SimpleGraph(kn)
    for c = 1:n
        for i = ((c - 1) * k + 1):(c * k - 1), j = (i + 1):(c * k)
            add_edge!(g, i, j)
        end
    end
    for i = 1:(n - 1)
        add_edge!(g, (i - 1) * k + 1, i * k + 1)
    end
    add_edge!(g, 1, (n - 1) * k + 1)
    return g
end

"""
    LadderGraph(n)

Create a [ladder graph](https://en.wikipedia.org/wiki/Ladder_graph) consisting of `2n` nodes and `3n-2` edges.

### Implementation Notes
Preserves the eltype of `n`. Will error if the required number of vertices
exceeds the eltype.
"""
function LadderGraph(n::T) where {T <: Integer}
    n <= 0 && return SimpleGraph{T}(0)
    n == 1 && return PathGraph(T(2))
    Tw = widen(T)
    temp = T(Tw(n)+Tw(n)) # test to check if T is large enough

    fadjlist = Vector{Vector{T}}(undef, 2*n)
    @inbounds @simd for i in 2:(n-1)
        fadjlist[i]   = T[i-1, i+1, i+n]
        fadjlist[n+i] = T[i, n+i-1, n+i+1]
    end
    fadjlist[1]   = T[2, n+1]
    fadjlist[n+1] = T[1, n+2]
    fadjlist[n]   = T[n-1, 2*n]
    fadjlist[2*n] = T[n, 2*n-1]

    return SimpleGraph(3*n-2, fadjlist)
end

"""
    CircularLadderGraph(n)

Create a [circular ladder graph](https://en.wikipedia.org/wiki/Ladder_graph#Circular_ladder_graph) consisting of `2n` nodes and `3n` edges.
This is also known as the [prism graph](https://en.wikipedia.org/wiki/Prism_graph).

### Implementation Notes
Preserves the eltype of the partitions vector. Will error if the required number of vertices
exceeds the eltype. 
`n` must be at least 3 to avoid self-loops and multi-edges.
"""
function CircularLadderGraph(n::T) where {T <: Integer}
    n < 3 && throw(DomainError("n=$n must be at least 3"))
    g = LadderGraph(n)
    add_edge!(g, 1, n)
    add_edge!(g, n+1, 2*n)
    return g
end

"""
    BarbellGraph(n)

Create a [barbell graph](https://en.wikipedia.org/wiki/Barbell_graph) consisting of a clique of size `n1` connected by an edge to a clique of size `n2`.

### Implementation Notes
Preserves the eltype of `n1` and `n2`. Will error if the required number of vertices
exceeds the eltype.
`n1` and `n2` must be at least 1 so that both cliques are non-empty.
"""
function BarbellGraph(n1::T, n2::T) where {T <: Integer}
    (n1 < 1 || n2 < 1) && throw(DomainError("n1=$n1 and n2=$n2 must be at least 1"))

    if n1 == 1 && n2 == 1
        return PathGraph(T(2))
    elseif n1 > 1 && n2 == 1
        g = CompleteGraph(n1)
        add_vertex!(g)
        add_edge!(g, n1, n1+1)
        return g
    elseif n1 == 1 && n2 > 1
        g = blockdiag(PathGraph(T(1)), CompleteGraph(n2))
        add_edge!(g, 1, 2)
        return g
    end

    Tw = widen(T)
    temp = T(Tw(n1)+Tw(n2)) # test to check if T is large enough

    fadjlist = Vector{Vector{T}}(undef, n1+n2)
    ne = Int(n1*(n1-1)/2 + n2*(n2-1)/2)

    @inbounds @simd for u = 1:n1
        listu = Vector{T}(undef, n1-1)
        listu[1:(u-1)] = 1:(u - 1)
        listu[u:(n1-1)] = (u + 1):n1
        fadjlist[u] = listu
    end

    @inbounds for u = 1:n2
        listu = Vector{T}(undef, n2-1)
        listu[1:(u-1)] = (n1+1):(n1+(u-1))
        listu[u:(n2-1)] = (n1+u+1):(n1+n2)
        fadjlist[n1+u] = listu
    end

    g = SimpleGraph(ne, fadjlist)
    add_edge!(g, n1, n1+1)
    return g
end

"""
    LollipopGraph(n)

Create a [lollipop graph](https://en.wikipedia.org/wiki/Lollipop_graph) consisting of a clique of size `n1` connected by an edge to a path of size `n2`.

### Implementation Notes
Preserves the eltype of `n1` and `n2`. Will error if the required number of vertices
exceeds the eltype.
`n1` and `n2` must be at least 1 so that both the clique and the path have at least one vertex.
"""
function LollipopGraph(n1::T, n2::T) where {T <: Integer}
    (n1 < 1 || n2 < 1) && throw(DomainError("n1=$n1 and n2=$n2 must be at least 1"))

    if n1 == 1
        return PathGraph(T(n2+1))
    elseif n1 > 1 && n2 == 1
        g = CompleteGraph(n1)
        add_vertex!(g)
        add_edge!(g, n1, n1+1)
        return g
    end

    Tw = widen(T)
    temp = T(Tw(n1)+Tw(n2)) # test to check if T is large enough
    ne = Int(n1*(n1-1)/2 + n2-1)

    fadjlist = Vector{Vector{T}}(undef, n1+n2)

    @inbounds @simd for u = 1:n1
        listu = Vector{T}(undef, n1-1)
        listu[1:(u-1)] = 1:(u - 1)
        listu[u:(n1-1)] = (u + 1):n1
        fadjlist[u] = listu
    end

    @inbounds fadjlist[n1+1] = T[n1+2]
    @inbounds fadjlist[n1+n2] = T[n1+n2-1]

    @inbounds @simd for u = (n1+2):(n1+n2-1)
        fadjlist[u] = T[u - 1, u + 1]
    end

    g = SimpleGraph(ne, fadjlist)
    add_edge!(g, n1, n1+1)
    return g
end
