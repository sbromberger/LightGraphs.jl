function Graph(nv::Integer, ne::Integer; seed::Int = -1)
    maxe = div(nv * (nv-1), 2)
    @assert(ne <= maxe, "Maximum number of edges for this graph is $maxe")
    ne > 2/3 * maxe && return complement(Graph(nv, maxe-ne))

    rng = seed >= 0 ? MersenneTwister(seed) : MersenneTwister()
    g = Graph(nv)
    while g.ne < ne
        source = rand(rng, 1:nv)
        dest = rand(rng, 1:nv)
        source != dest && add_edge!(g,source,dest)
    end
    return g
end

function DiGraph(nv::Integer, ne::Integer; seed::Int = -1)
    maxe = nv * (nv-1)
    @assert(ne <= maxe, "Maximum number of edges for this graph is $maxe")
    ne > 2/3 * maxe && return complement(DiGraph(nv, maxe-ne))

    rng = seed >= 0 ? MersenneTwister(seed) : MersenneTwister()
    g = DiGraph(nv)
    while g.ne < ne
        source = rand(rng, 1:nv)
        dest = rand(rng, 1:nv)
        source != dest && add_edge!(g,source,dest)
    end
    return g
end

"""Creates an [Erdős–Rényi](http://en.wikipedia.org/wiki/Erdős–Rényi_model)
random graph with `n` vertices. Edges are added between pairs of vertices with
probability `p`. Undirected graphs are created by default; use
`is_directed=true` to override.

Note also that Erdős–Rényi graphs may be generated quickly using `erdos_renyi(n, ne)`
or the  `Graph(nv, ne)` constructor, which randomly select `ne` edges among all the potential
edges.
"""
function erdos_renyi(n::Integer, p::Real; is_directed=false, seed::Integer=-1)
    m = is_directed ? n*(n-1) : div(n*(n-1),2)
    if seed >= 0
        # init dsfmt generator without altering GLOBAL_RNG
        Base.dSFMT.dsfmt_gv_init_by_array(MersenneTwister(seed).seed+1)
    end
    ne = StatsBase.rand_binom(m, p) # sadly Distributions.jl doesn't support non-global RNG
    return is_directed ? DiGraph(n, ne, seed=seed) : Graph(n, ne, seed=seed)
end

function erdos_renyi(n::Integer, ne::Integer; is_directed=false, seed::Integer=-1)
    return is_directed ? DiGraph(n, ne, seed=seed) : Graph(n, ne, seed=seed)
end


"""Creates a [Watts-Strogatz](https://en.wikipedia.org/wiki/Watts_and_Strogatz_model)
small model random graph with `n` vertices, each with degree `k`. Edges are
randomized per the model based on probability `β`. Undirected graphs are
created by default; use `is_directed=true` to override.
"""
function watts_strogatz(n::Integer, k::Integer, β::Real; is_directed=false, seed::Int = -1)
    @assert k < n/2
    if is_directed
        g = DiGraph(n)
    else
        g = Graph(n)
    end
    rng = seed >= 0 ? MersenneTwister(seed) : MersenneTwister()
    for s in 1:n
        for i in 1:(floor(Integer, k/2))
            target = ((s + i - 1) % n) + 1
            if rand(rng) > β && !has_edge(g,s,target)
                add_edge!(g, s, target)
            else
                while true
                    d = target
                    while d == target
                        d = rand(rng, 1:n-1)
                        if s < d
                            d += 1
                        end
                    end
                    if !has_edge(g, s, d) && s != d
                        add_edge!(g, s, d)
                        break
                    end
                end
            end
        end
    end
    return g
end

function _suitable(edges::Set{Edge}, potential_edges::Dict{Int, Int})
    isempty(potential_edges) && return true
    for (s1, s2) in combinations(collect(keys(potential_edges)), 2)
        if (s1 > s2)
            s1, s2 = s2, s1
        end
        ∉(Edge(s1, s2), edges) && return true
    end
    return false
end

_try_creation(n::Int, k::Int, rng::AbstractRNG) = _try_creation(n, fill(k,n), rng)

function _try_creation(n::Int, k::Vector{Int}, rng::AbstractRNG)
    edges = Set{Edge}()
    m = 0
    stubs = zeros(Int, sum(k))
    for i=1:n
        for j = 1:k[i]
            m += 1
            stubs[m] = i
        end
    end
    # stubs = vcat([fill(i, k[i]) for i=1:n]...) # slower

    while !isempty(stubs)
        potential_edges =  Dict{Int,Int}()
        shuffle!(rng, stubs)
        for i in 1:2:length(stubs)
            s1,s2 = stubs[i:i+1]
            if (s1 > s2)
                s1, s2 = s2, s1
            end
            e = Edge(s1, s2)
            if s1 != s2 && ∉(e, edges)
                push!(edges, e)
            else
                potential_edges[s1] = get(potential_edges, s1, 0) + 1
                potential_edges[s2] = get(potential_edges, s2, 0) + 1
            end
        end

        if !_suitable(edges, potential_edges)
            return Set{Edge}()
        end

        stubs = Vector{Int}()
        for (e, ct) in potential_edges
            append!(stubs, fill(e, ct))
        end
    end
    return edges
end

doc"""Creates a random undirected
[regular graph](https://en.wikipedia.org/wiki/Regular_graph) with `n` vertices,
each with degree `k`.

For undirected graphs, allocates an array of `nk` `Int`s, and takes
approximately $nk^2$ time. For $k > n/2$, generates a graph of degree
`n-k-1` and returns its complement.
"""
function random_regular_graph(n::Int, k::Int; seed::Int=-1)
    @assert(iseven(n*k), "n * k must be even")
    @assert(0 <= k < n, "the 0 <= k < n inequality must be satisfied")
    if k == 0
        return Graph(n)
    end
    if (k > n/2) && iseven(n * (n-k-1))
        return complement(random_regular_graph(n, n-k-1, seed=seed))
    end

    rng = seed >= 0 ? MersenneTwister(seed) : MersenneTwister()

    edges = _try_creation(n, k, rng)
    while isempty(edges)
        edges = _try_creation(n, k, rng)
    end

    g = Graph(n)
    for edge in edges
        add_edge!(g, edge)
    end

    return g
end


doc"""Creates a random undirected graph according to the [configuraton model]
(http://tuvalu.santafe.edu/~aaronc/courses/5352/fall2013/csci5352_2013_L11.pdf).
It contains `n` vertices, the vertex `ì` having degree `k[i]`.

Defining `c = mean(k)`, it allocates an array of `nc` `Int`s, and takes
approximately $nc^2$ time.
"""
function random_configuration_model(n::Int, k::Array{Int}; seed::Int=-1)
    @assert(n == length(k), "a degree sequence of length n has to be provided")
    m = sum(k)
    @assert(iseven(m), "sum(k) must be even")
    @assert(all(0 .<= k .< n), "the 0 <= k[i] < n inequality must be satisfied")

    rng = seed >= 0 ? MersenneTwister(seed) : MersenneTwister()

    edges = _try_creation(n, k, rng)
    while m > 0 && isempty(edges)
        edges = _try_creation(n, k, rng)
    end

    g = Graph(n)
    for edge in edges
        add_edge!(g, edge)
    end

    return g
end

doc"""Creates a random directed
[regular graph](https://en.wikipedia.org/wiki/Regular_graph) with `n` vertices,
each with degree `k`. The degree (in or out) can be
specified using `dir=:in` or `dir=:out`. The default is `dir=:out`.

For directed graphs, allocates an $n \times n$ sparse matrix of boolean as an
adjacency matrix and uses that to generate the directed graph.
"""
function random_regular_digraph(n::Int, k::Int; dir::Symbol=:out, seed::Int=-1)
    #TODO remove the function sample from StatsBase for one allowing the use
    # of a local rng
    @assert(0 <= k < n, "the 0 <= k < n inequality must be satisfied")

    if k == 0
        return DiGraph(n)
    end
    if (k > n/2) && iseven(n * (n-k-1))
        return complement(random_regular_digraph(n, n-k-1, dir=dir, seed=seed))
    end
    # rng = seed >= 0 ? MersenneTwister(seed) : MersenneTwister()

    cs = collect(2:n)
    i = 1
    I = Array(Int, n*k)
    J = Array(Int, n*k)
    V = fill(true, n*k)
    for r in 1:n
        l = (r-1)*k+1 : r*k
        I[l] = r
        J[l] = sample(cs, k; replace=false)
        if r<n
            cs[r] -= 1
        end
    end

    if dir == :out
        return DiGraph(sparse(I, J, V, n, n))
    else
        return DiGraph(sparse(I, J, V, n, n)')
    end
end


"""Samples a random graph with `n` vertices
according to the [Stochastic Block Model](https://en.wikipedia.org/wiki/Stochastic_block_model).
Nodes are dived in blocks of `r` elements.
 Edges between pairs of vertices in the same block are added
probability `pint`. Edges between pairs of vertices in different blocks are added
probability `pext`.
"""
function stochastic_block_model(n::Integer, r::Integer, pint::Real, pext::Real; seed::Int=-1)
    n % r != 0 && error("n should be divisible by r.")
    rng = seed >= 0 ? MersenneTwister(seed) : MersenneTwister()
    g = Graph(n)
    for i = 1:n
        for j = i+1 : n
            if div(i-1, r) == div(j-1, r)
                rand(rng) < pint && add_edge!(g, i, j)
            else
                rand(rng) < pext && add_edge!(g, i, j)
            end
        end
    end
    return g
end
