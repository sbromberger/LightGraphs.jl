# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

function _complete_graph(n::T) where {T<:Integer}
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

function _complete_bipartite_graph(n1::T, n2::T) where {T<:Integer}
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

function _complete_multipartite_graph(partitions::AbstractVector{T}) where {T<:Integer}
    any(x -> x < 0, partitions) && return SimpleGraph{T}(0)
    length(partitions) == 1 && return SimpleGraph{T}(partitions[1])
    length(partitions) == 2 && return SimpleGraph(CompleteBipartite(partitions[1], partitions[2]))

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

function _turan_graph(n::Integer, r::Integer)
    T = typeof(n)
    partitions = Vector{T}(undef, r)
    c = cld(n,r)
    f = fld(n,r)
    @inbounds @simd for i in 1:(n%r)
        partitions[i] = c
    end
    @inbounds @simd for i in ((n%r)+1):r
        partitions[i] = f
    end
    return _complete_multipartite_graph(partitions)
end

function _complete_digraph(n::T) where {T<:Integer}
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

function _star_graph(n::T) where {T<:Integer}
    n <= 0 && return SimpleGraph{T}(0)

    ne = Int(n - 1)
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = Vector{T}(2:n)
    @inbounds @simd for u = 2:n
        fadjlist[u] = T[1]
    end
    return SimpleGraph(ne, fadjlist)
end

function _star_digraph(n::T) where {T<:Integer}
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

function _path_graph(n::T) where {T<:Integer}
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

function _path_digraph(n::T) where {T<:Integer}
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

function _cycle_graph(n::T) where {T<:Integer}
    n <= 1 && return SimpleGraph{T}(n)
    n == 2 && return SimpleGraph(SimpleEdge{T}.([(1, 2)]))

    ne = Int(n)
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = T[2, n]
    @inbounds fadjlist[n] = T[1, n-1]

    @inbounds @simd for u = 2:(n-1)
        fadjlist[u] = T[u-1, u+1]
    end
    return SimpleGraph{T}(ne, fadjlist)
end

function _cycle_digraph(n::T) where {T<:Integer}
    n <= 1 && return SimpleDiGraph{T}(n)
    n == 2 && return SimpleDiGraph(SimpleEdge{T}.([(1, 2), (2, 1)]))

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
    return SimpleDiGraph{T}(ne, fadjlist, badjlist)
end

function _wheel_graph(n::T) where {T<:Integer}
    n <= 1 && return SimpleGraph{T}(n)
    n <= 3 && return SimpleGraph(Cycle(n))

    ne = Int(2 * (n - 1))
    fadjlist = Vector{Vector{T}}(undef, n)
    @inbounds fadjlist[1] = Vector{T}(2:n)
    @inbounds fadjlist[2] = T[1, 3, n]
    @inbounds fadjlist[n] = T[1, 2, n - 1]

    @inbounds @simd for u = 3:(n-1)
        fadjlist[u] = T[1, u - 1, u + 1]
    end
    return SimpleGraph{T}(ne, fadjlist)
end

function _wheel_digraph(n::T) where {T<:Integer}
    n <= 2 && return SimpleDiGraph(Path(n))
    n == 3 && return SimpleDiGraph(SimpleEdge{T}.([(1,2),(1,3),(2,3),(3,2)]))

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
    return SimpleDiGraph{T}(ne, fadjlist, badjlist)
end

function _grid(dims::AbstractVector{T}, periodic::Bool) where {T<:Integer}
    # checks if T is large enough for product(dims)
    Tw = widen(T)
    n = one(T)
    for d in dims
        d <= 0 && return SimpleGraph{T}(0)
        nw = Tw(n) * Tw(d)
        n = T(nw)
    end

    if periodic
        g = SimpleGraph(Cycle(dims[1]))
        for d in dims[2:end]
            g = cartesian_product(SimpleGraph(Cycle(d)), g)
        end
    else
        g = SimpleGraph(Path(dims[1]))
        for d in dims[2:end]
            g = cartesian_product(SimpleGraph(Path(d)), g)
        end
    end
    return g
end
_grid(dims::Tuple, periodic::Bool) = _grid(collect(dims), periodic)

function _binary_tree(k::T) where {T<:Integer}
    k <= 0 && return SimpleGraph{T}(0)
    k == 1 && return SimpleGraph{T}(1)
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
    return SimpleGraph{T}(ne, fadjlist)
end

function _binary_tree_digraph(k::T) where {T<:Integer}
    k <= 0 && return SimpleDiGraph{T}(0)
    k == 1 && return SimpleDiGraph{T}(1)
    n = T(2^k - 1)

    ne = Int(n - 1)
    fadjlist = [Vector{T}() for _ = one(T):n]
    badjlist = [Vector{T}() for _ = one(T):n]
    @inbounds fadjlist[1] = T[2, 3]
    @inbounds for i in 1:(k - 2)
        @simd for j in (2^i):(2^(i + 1) - 1)
            fadjlist[j] = T[2j, 2j + 1]
            badjlist[j] = T[j ÷ 2]
        end
    end
    @inbounds for j in 2^(k-1):n
        badjlist[j] = T[j ÷ 2]
    end
    return SimpleDiGraph{T}(ne, fadjlist, badjlist)
end

function _double_binary_tree(k::Integer)
    gl = SimpleGraph(BinaryTree(k))
    gr = SimpleGraph(BinaryTree(k))
    g = blockdiag(gl, gr)
    add_edge!(g, 1, nv(gl) + 1)
    return g
end

function _double_binary_tree_digraph(k::Integer)
    gl = SimpleDiGraph(BinaryTree(k))
    gr = SimpleDiGraph(BinaryTree(k))
    g = blockdiag(gl, gr)
    add_edge!(g, 1, nv(gl) + 1)
    return g
end

function _roach_graph(k::T) where {T<:Integer}
    dipole = SimpleGraph(Complete(T(2)))
    nopole = SimpleGraph(T(2))
    antannae = crosspath(k, nopole)
    body = crosspath(k, dipole)
    roach = blockdiag(antannae, body)
    add_edge!(roach, nv(antannae) - 1, nv(antannae) + 1)
    add_edge!(roach, nv(antannae), nv(antannae) + 2)
    return roach
end


function _clique_graph(k::T, n::T) where {T<:Integer}
    Tw = widen(T)
    knw = Tw(k) * Tw(n)
    kn = T(knw)  # checks if T is large enough for k * n

    g = SimpleGraph{T}(kn)
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

function _ladder_graph(n::T) where {T<:Integer}
    n <= 0 && return SimpleGraph{T}(0)
    n == 1 && return SimpleGraph(Path(T(2)))

    fadjlist = Vector{Vector{T}}(undef, 2*n)
    @inbounds @simd for i in 2:(n-1)
        fadjlist[i]   = T[i-1, i+1, i+n]
        fadjlist[n+i] = T[i, n+i-1, n+i+1]
    end
    fadjlist[1]   = T[2, n+1]
    fadjlist[n+1] = T[1, n+2]
    fadjlist[n]   = T[n-1, 2*n]
    fadjlist[2*n] = T[n, 2*n-1]

    return SimpleGraph{T}(3*n-2, fadjlist)
end

function _circular_ladder_graph(n::Integer)
    g = SimpleGraph(Ladder(n))
    add_edge!(g, 1, n)
    add_edge!(g, n+1, 2*n)
    return g
end

function _barbell_graph(n1::T, n2::T) where {T<:Integer}
    n = Base.Checked.checked_add(n1, n2) # check for overflow
    fadjlist = Vector{Vector{T}}(undef, n)

    ne = Int(n1)*(n1-1)÷2 + Int(n2)*(n2-1)÷2

    @inbounds @simd for u = 1:n1
        listu = Vector{T}(undef, n1-1)
        listu[1:(u-1)] = 1:(u-1)
        listu[u:(n1-1)] = (u+1):n1
        fadjlist[u] = listu
    end

    @inbounds for u = 1:n2
        listu = Vector{T}(undef, n2-1)
        listu[1:(u-1)] = (n1+1):(n1+(u-1))
        listu[u:(n2-1)] = (n1+u+1):(n1+n2)
        fadjlist[n1+u] = listu
    end

    g = SimpleGraph{T}(ne, fadjlist)
    add_edge!(g, n1, n1+1)
    return g
end

function _lollipop_graph(n1::T, n2::T) where {T<:Integer}
    if n1 == 1
        return SimpleGraph(Path(T(n2+1)))
    elseif n1 > 1 && n2 == 1
        g = SimpleGraph(Complete(n1))
        add_vertex!(g)
        add_edge!(g, n1, n1+1)
        return g
    end

    n = Base.Checked.checked_add(n1, n2) # check for overflow
    fadjlist = Vector{Vector{T}}(undef, n)

    ne = Int(Int(n1)*(n1-1)÷2 + n2-1)

    @inbounds @simd for u = 1:n1
        listu = Vector{T}(undef, n1-1)
        listu[1:(u-1)] = 1:(u-1)
        listu[u:(n1-1)] = (u+1):n1
        fadjlist[u] = listu
    end

    @inbounds fadjlist[n1+1] = T[n1+2]
    @inbounds fadjlist[n1+n2] = T[n1+n2-1]

    @inbounds @simd for u = (n1+2):(n1+n2-1)
        fadjlist[u] = T[u-1, u+1]
    end

    g = SimpleGraph(ne, fadjlist)
    add_edge!(g, n1, n1+1)
    return g
end

function _circulant_graph(n::T, connection_set::Vector{T}) where {T<:Integer}
    g = SimpleGraph(n)

    @inbounds for u = 1:n-1, v = u+1:n
        if mod(v - u, n) in connection_set || mod(u - v, n) in connection_set
            add_edge!(g, u, v)
        end
    end

    return g
end

function _circulant_digraph(n::T, connection_set::Vector{T}) where {T<:Integer}
    g = SimpleDiGraph(n)

    @inbounds for u = 1:n-1, v = u+1:n
        if mod(v - u, n) in connection_set
            add_edge!(g, u, v)
        end
        if mod(u - v, n) in connection_set
            add_edge!(g, v, u)
        end
    end
    return g
end

function _friendship_graph(n::T) where {T<:Integer}
    n <= 0 && return SimpleGraph(1)

    g = SimpleGraph(2 * n + 1)
    for indx in 1:n
        u = indx * 2
        v = u + 1
        add_edge!(g, u, v)
        add_edge!(g, 1, v)
        add_edge!(g, u, 1)
    end
    return g
end

SimpleGraph(gen::Complete) = _complete_graph(gen.n)
SimpleGraph(gen::CompleteBipartite) = _complete_bipartite_graph(gen.n1, gen.n2)
SimpleGraph(gen::CompleteMultipartite) = _complete_multipartite_graph(gen.pvec)
SimpleGraph(gen::Turan) = _turan_graph(gen.n, gen.r)
SimpleGraph(gen::Star) = _star_graph(gen.n)
SimpleGraph(gen::Path) = _path_graph(gen.n)
SimpleGraph(gen::Cycle) = _cycle_graph(gen.n)
SimpleGraph(gen::Wheel) = _wheel_graph(gen.n)
SimpleGraph(gen::Grid) = _grid(gen.dims, gen.periodic)
SimpleGraph(gen::BinaryTree) = _binary_tree(gen.k)
SimpleGraph(gen::DoubleBinaryTree) = _double_binary_tree(gen.k)
SimpleGraph(gen::Roach) = _roach_graph(gen.k)
SimpleGraph(gen::Clique) = _clique_graph(gen.k, gen.n)
SimpleGraph(gen::Ladder) = _ladder_graph(gen.n)
SimpleGraph(gen::CircularLadder) = _circular_ladder_graph(gen.n)
SimpleGraph(gen::Barbell) = _barbell_graph(gen.n1, gen.n2)
SimpleGraph(gen::Lollipop) = _lollipop_graph(gen.n1, gen.n2)
SimpleGraph(gen::Circulant) = _circulant_graph(gen.n, gen.cset)
SimpleGraph(gen::Friendship) = _friendship_graph(gen.n)

SimpleDiGraph(gen::Complete) = _complete_digraph(gen.n)
SimpleDiGraph(gen::Star) = _star_digraph(gen.n)
SimpleDiGraph(gen::Path) = _path_digraph(gen.n)
SimpleDiGraph(gen::Cycle) = _cycle_digraph(gen.n)
SimpleDiGraph(gen::Wheel) = _wheel_digraph(gen.n)
SimpleDiGraph(gen::BinaryTree) = _binary_tree_digraph(gen.k)
SimpleDiGraph(gen::DoubleBinaryTree) = _double_binary_tree_digraph(gen.k)
SimpleDiGraph(gen::Circulant) = _circulant_digraph(gen.n, gen.cset)
