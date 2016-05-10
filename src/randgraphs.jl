function Graph(nv::Integer, ne::Integer; seed::Int = -1)
    maxe = div(nv * (nv-1), 2)
    @assert(ne <= maxe, "Maximum number of edges for this graph is $maxe")
    ne > 2/3 * maxe && return complement(Graph(nv, maxe-ne))

    rng = getRNG(seed)
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

    rng = getRNG(seed)
    g = DiGraph(nv)
    while g.ne < ne
        source = rand(rng, 1:nv)
        dest = rand(rng, 1:nv)
        source != dest && add_edge!(g,source,dest)
    end
    return g
end

"""
    erdos_renyi(n::Integer, p::Real; is_directed=false, seed=-1)
    erdos_renyi(n::Integer, ne::Integer; is_directed=false, seed=-1)

Creates an [Erdős–Rényi](http://en.wikipedia.org/wiki/Erdős–Rényi_model)
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
    ne = rand_binom(m, p) # sadly StatsBase doesn't support non-global RNG
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
    rng = getRNG(seed)
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
    list = keys(potential_edges)
    for s1 in list, s2 in list
        s1 >= s2 && continue
        (Edge(s1, s2) ∉ edges) && return true
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

"""
    barabasi_albert(n::Integer, k::Integer; is_directed=false, seed::Int=-1)

Creates a [Barabási–Albert model](https://en.wikipedia.org/wiki/Barab%C3%A1si%E2%80%93Albert_model)
random graph with `n` nodes is grown by attaching new nodes each with `k` edges that
are preferentially attached to existing nodes with high degree. Undirected graphs are
created by default; use `is_directed=true` to override.
"""
function barabasi_albert(n::Integer, k::Integer; is_directed=false, seed::Int=-1)
    @assert(1<=k<n, "Barabási–Albert network must have 1 <= k < n")
    g = is_directed ? DiGraph(n) : Graph(n)
    seed > 0 && srand(seed)
    # Target nodes for new edges
    targets = collect(1:k)
    # List of existing nodes, with nodes repeated once for each adjacent edge
    repeated_nodes = Vector{Int}()
    # Array to record the node is or not picked
    node_status = fill(false, n)
    sizehint!(repeated_nodes, (n-k)*k)
    source = k + 1
    while source <= n
        for target in targets
            # Add edges to k nodes from the source
            add_edge!(g, source, target)
            push!(repeated_nodes, source)
            push!(repeated_nodes, target)
            # Reset the node_status for target in targets
            node_status[target] = false
        end

        # Choose k unique nodes from the existing nodes
        # Pick uniformly from repeated_nodes (preferential attachement)
        i = 1
        while i <= k
            target = sample(repeated_nodes)
            if !node_status[target]
                targets[i] = target
                i += 1
                node_status[target] = true
            end
        end
        source += 1
    end
    return g
end

"""
    static_fitness_model{T<:Real}(m::Int, fitness::Vector{T}; seed::Int=-1)

Generates a random graph with `length(fitness)` nodes and `m` edges,
in which the probability of the existence of edge `(i, j)` is proportional
to `fitness[i]*fitness[j]`. Time complexity is O(|V| + |E| log |E|).

Reference:

* Goh K-I, Kahng B, Kim D: Universal behaviour of load distribution
in scale-free networks. Phys Rev Lett 87(27):278701, 2001.
"""
function static_fitness_model{T<:Real}(m::Int, fitness::Vector{T}; seed::Int=-1)
    @assert(m >= 0, "invalid number of edges")
    n = length(fitness)
    m == 0 && return Graph(n)
    nodes = 0
    for f in fitness
        # sanity check for the fitness
        f < zero(T) && error("fitness scores must be non-negative")
        f > zero(T) && (nodes += 1)
    end
    # avoid getting into an infinite loop when too many edges are requested
    max_no_of_edges = div(nodes*(nodes-1), 2)
    @assert(m <= max_no_of_edges, "too many edges requested")
    # calculate the cumulative fitness scores
    cum_fitness = cumsum(fitness)
    g = Graph(n)
    _create_static_fitness_graph!(g, m, cum_fitness, cum_fitness, seed)
    return g
end

function static_fitness_model{T<:Real,S<:Real}(m::Int, fitness_out::Vector{T}, fitness_in::Vector{S}; seed::Int=-1)
    @assert(m >= 0, "invalid number of edges")
    n = length(fitness_out)
    @assert(length(fitness_in) == n, "fitness_in must have the same size as fitness_out")
    m == 0 && return DiGraph(n)
    # avoid getting into an infinite loop when too many edges are requested
    outnodes = innodes = nodes = 0
    @inbounds for i=1:n
        # sanity check for the fitness
        (fitness_out[i] < zero(T) || fitness_in[i] < zero(S)) && error("fitness scores must be non-negative")
        fitness_out[i] > zero(T) && (outnodes += 1)
        fitness_in[i] > zero(S) && (innodes += 1)
        (fitness_out[i] > zero(T) && fitness_in[i] > zero(S)) && (nodes += 1)
    end
    max_no_of_edges = outnodes*innodes - nodes
    @assert(m <= max_no_of_edges, "too many edges requested")
    # calculate the cumulative fitness scores
    cum_fitness_out = cumsum(fitness_out)
    cum_fitness_in = cumsum(fitness_in)
    g = DiGraph(n)
    _create_static_fitness_graph!(g, m, cum_fitness_out, cum_fitness_in, seed)
    return g
end

function _create_static_fitness_graph!{T<:Real,S<:Real}(g::SimpleGraph, m::Int, cum_fitness_out::Vector{T}, cum_fitness_in::Vector{S}, seed::Int)
    rng = getRNG(seed)
    max_out = cum_fitness_out[end]
    max_in = cum_fitness_in[end]
    while m > 0
        source = searchsortedfirst(cum_fitness_out, rand(rng)*max_out)
        target = searchsortedfirst(cum_fitness_in, rand(rng)*max_in)
        # skip if loop edge
        (source == target) && continue
        edge = Edge(source, target)
        # is there already an edge? If so, try again
        has_edge(g, edge) && continue
        add_edge!(g, edge)
        m -= 1
    end
end

"""
    function static_scale_free(n::Int, m::Int, α::Float64; seed::Int=-1, finite_size_correction::Bool=true)

Generates a random graph with `n` vertices, `m` edges and expected power-law
degree distribution with exponent `α`. `finite_size_correction` determines
whether to use the finite size correction proposed by Cho et al.
This generator calls internally the `static_fitness_model function`.
Time complexity is O(|V| + |E| log |E|).

References:

* Goh K-I, Kahng B, Kim D: Universal behaviour of load distribution in scale-free networks. Phys Rev Lett 87(27):278701, 2001.

* Chung F and Lu L: Connected components in a random graph with given degree sequences. Annals of Combinatorics 6, 125-145, 2002.

* Cho YS, Kim JS, Park J, Kahng B, Kim D: Percolation transitions in scale-free networks under the Achlioptas process. Phys Rev Lett 103:135702, 2009.
"""
function static_scale_free(n::Int, m::Int, α::Float64; seed::Int=-1, finite_size_correction::Bool=true)
    @assert(n >= 0, "Invalid number of nodes")
    @assert(α >= 2, "out-degree exponent must be >= 2")
    fitness = _construct_fitness(n, α, finite_size_correction)
    static_fitness_model(m, fitness, seed=seed)
end

function static_scale_free(n::Int, m::Int, α_out::Float64, α_in::Float64; seed::Int=-1, finite_size_correction::Bool=true)
    @assert(n >= 0, "Invalid number of nodes")
    @assert(α_out >= 2, "out-degree exponent must be >= 2")
    @assert(α_in >= 2, "in-degree exponent must be >= 2")
    # construct the fitness
    fitness_out = _construct_fitness(n, α_out, finite_size_correction)
    fitness_in = _construct_fitness(n, α_in, finite_size_correction)
    # eliminate correlation
    shuffle!(fitness_in)
    static_fitness_model(m, fitness_out, fitness_in, seed=seed)
end

function _construct_fitness(n::Int, α::Float64, finite_size_correction::Bool)
    α = -1/(α-1)
    fitness = zeros(n)
    j = float(n)
    if finite_size_correction && α < -0.5
        # See the Cho et al paper, first page first column + footnote 7
        j += n^(1+1/2α) * (10sqrt(2)*(1+α)) ^ (-1/α) - 1
    end
    j = max(j, n)
    @inbounds for i=1:n
        fitness[i] = j ^ α
        j -= 1
    end
    return fitness
end

doc"""
    random_regular_graph(n::Int, k::Int; seed=-1)

Creates a random undirected
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

    rng = getRNG(seed)

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


doc"""
    random_configuration_model(n::Int, k::Array{Int}; seed=-1)

Creates a random undirected graph according to the [configuraton model]
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

    rng = getRNG(seed)

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

doc"""
    random_regular_digraph(n::Int, k::Int; dir::Symbol=:out, seed=-1)

Creates a random directed
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
    rng = getRNG(seed)
    cs = collect(2:n)
    i = 1
    I = Array(Int, n*k)
    J = Array(Int, n*k)
    V = fill(true, n*k)
    for r in 1:n
        l = (r-1)*k+1 : r*k
        I[l] = r
        J[l] = sample!(rng, cs, k, exclude = r)
    end

    if dir == :out
        return DiGraph(sparse(I, J, V, n, n))
    else
        return DiGraph(sparse(I, J, V, n, n)')
    end
end

doc"""
    stochastic_block_model(c::Matrix{Float64}, n::Vector{Int}; seed::Int = -1)
    stochastic_block_model(cin::Float64, coff::Float64, n::Vector{Int}; seed::Int = -1)

Returns a Graph generated according to the Stochastic Block Model (SBM).

`c[a,b]` : Mean number of neighbors of a vertex in block `a` belonging to block `b`.
           Only the upper triangular part is considered, since the lower traingular is
           determined by $c[b,a] = c[a,b] * n[a]/n[b]$.
`n[a]` : Number of vertices in block `a`

The second form samples from a SBM with `c[a,a]=cin`, and `c[a,b]=coff`.

For a dynamic version of the SBM see the `StochasticBlockModel` type and
related functions.
"""
function stochastic_block_model{T<:Real}(c::Matrix{T}, n::Vector{Int}; seed::Int = -1)
    @assert size(c,1) == length(n)
    @assert size(c,2) == length(n)
    # init dsfmt generator without altering GLOBAL_RNG
    seed > 0 && Base.dSFMT.dsfmt_gv_init_by_array(MersenneTwister(seed).seed+1)
    rng =  seed > 0 ? MersenneTwister(seed) : MersenneTwister()

    N = sum(n)
    K = length(n)
    nedg = zeros(Int,K, K)
    g = Graph(N)
    cum = [sum(n[1:a]) for a=0:K]
    for a=1:K
        ra = cum[a]+1:cum[a+1]
        for b=a:K
            @assert a==b? c[a,b] <= n[b]-1 : c[a,b] <= n[b]   "Mean degree cannot be greater than available neighbors in the block."

            m = a==b ? n[a]*(n[a]-1)/2 : n[a]*n[b]
            p = a==b ? n[a]*c[a,b] / (2m) : n[a]*c[a,b]/m
            nedg = rand_binom(m, p)
            rb = cum[b]+1:cum[b+1]
            i=0
            while i < nedg
                source = rand(rng, ra)
                dest = rand(rng, rb)
                if source != dest && !has_edge(g, source, dest)
                    i += 1
                    add_edge!(g, source, dest)
                end
            end
        end
    end
    return g
end

function stochastic_block_model{T<:Real}(cint::T, cext::T, n::Vector{Int}; seed::Int=-1)
    K = length(n)
    c = [ifelse(a==b, cint, cext) for a=1:K,b=1:K]
    stochastic_block_model(c, n, seed=seed)
end

"""
    type StochasticBlockModel{T<:Integer,P<:Real}
        n::T
        nodemap::Array{T}
        affinities::Matrix{P}
        rng::MersenneTwister
    end

A type capturing the parameters of the SBM.
Each vertex is assigned to a block and the probability of edge `(i,j)`
depends only on the block labels of vertex `i` and vertex `j`.

The assignement is stored in nodemap and the block affinities a `k` by `k`
matrix is stored in affinities.

`affinities[k,l]` is the probability of an edge between any vertex in
block k and any vertex in block `l`.

We are generating the graphs by taking random `i,j in vertices(g)` and
flipping a coin with probability `affinities[nodemap[i],nodemap[j]]`.
"""
type StochasticBlockModel{T<:Integer,P<:Real}
    n::T
    nodemap::Array{T}
    affinities::Matrix{P}
    rng::MersenneTwister
end

==(sbm::StochasticBlockModel, other::StochasticBlockModel) =
    (sbm.n == other.n) && (sbm.nodemap == other.nodemap) && (sbm.affinities == other.affinities)

"""A constructor for StochasticBlockModel that uses the sizes of the blocks
and the affinity matrix. This construction implies that consecutive
vertices will be in the same blocks, except for the block boundaries.
"""
function StochasticBlockModel{T,P}(sizes::Vector{T}, affinities::Matrix{P}; seed::Int = -1)
    csum = cumsum(sizes)
    j = 1
    nodemap = zeros(Int, csum[end])
    for i in 1:csum[end]
        if i > csum[j]
            j+=1
        end
        nodemap[i] = j
    end
    return StochasticBlockModel(csum[end], nodemap, affinities, getRNG(seed))
end


"""Produce the sbm affinity matrix where the external probabilities are the same
the internal probabilities and sizes differ by blocks.
"""
function sbmaffinity(internalp::Vector{Float64}, externalp::Float64, sizes::Vector{Int})
    numblocks = length(sizes)
    numblocks == length(internalp) || error("Inconsistent input dimensions: internalp, sizes")
    B = diagm(internalp) + externalp*(ones(numblocks, numblocks)-I)
    return B
end

function StochasticBlockModel(internalp::Float64,
                              externalp::Float64,
                              size::Int,
                              numblocks::Int;
                              seed::Int = -1)
    sizes = fill(size, numblocks)
    B = sbmaffinity(fill(internalp, numblocks), externalp, sizes)
    StochasticBlockModel(sizes, B, seed=seed)
end

function StochasticBlockModel(internalp::Vector{Float64}, externalp::Float64
        , sizes::Vector{Int}; seed::Int = -1)
    B = sbmaffinity(internalp, externalp, sizes)
    return StochasticBlockModel(sizes, B, seed=seed)
end


const biclique = ones(2,2) - eye(2)

"""Construct the affinity matrix for a near bipartite SBM.
between is the affinity between the two parts of each bipartite community
intra is the probability of an edge within the parts of the partitions.

This is a specific type of SBM with k/2 blocks each with two halves.
Each half is connected as a random bipartite graph with probability `intra`
The blocks are connected with probability `between`.
"""
function nearbipartiteaffinity(sizes::Vector{Int}, between::Float64, intra::Float64)
    numblocks = div(length(sizes), 2)
    return kron(between*eye(numblocks), biclique) + eye(2numblocks)*intra
end

"""Return a generator for edges from a stochastic block model near-bipartite graph."""
function nearbipartiteaffinity(sizes::Vector{Int}, between::Float64, inter::Float64, noise::Real)
    B = nearbipartiteaffinity(sizes, between, inter) + noise
    # info("Affinities are:\n$B")#, file=stderr)
    return B
end

function nearbipartiteSBM(sizes, between, inter, noise; seed::Int = -1)
    return StochasticBlockModel(sizes, nearbipartiteaffinity(sizes, between, inter, noise), seed=seed)
end


"""Generates a stream of random pairs in 1:n"""
function random_pair(rng::AbstractRNG, n::Int)
    while true
        produce( rand(rng, 1:n), rand(rng, 1:n) )
    end
end


"""
    make_edgestream(sbm::StochasticBlockModel)

Take an infinite sample from the sbm.
Pass to `Graph(nvg, neg, edgestream)` to get a Graph object.
"""
function make_edgestream(sbm::StochasticBlockModel)
    pairs = @task random_pair(sbm.rng, sbm.n)
    for (i,j) in pairs
    	if i == j
            continue
        end
        p = sbm.affinities[sbm.nodemap[i], sbm.nodemap[j]]
        if rand(sbm.rng) < p
            produce(i, j)
        end
    end
end

function Graph(nvg::Int, neg::Int, edgestream::Task)
    g = Graph(nvg)
    # println(g)
    for (i,j) in edgestream
        # print("$count, $i,$j\n")
        add_edge!(g,Edge(i,j))
        ne(g) >= neg && break
    end
    # println(g)
    return g
end

Graph(nvg::Int, neg::Int, sbm::StochasticBlockModel) =
    Graph(nvg, neg, @task make_edgestream(sbm))

"""counts the number of edges that go between each block"""
function blockcounts(sbm::StochasticBlockModel, A::AbstractMatrix)
    # info("making Q")
    I = collect(1:sbm.n)
    J =  [sbm.nodemap[i] for i in 1:sbm.n]
    V =  ones(sbm.n)
    Q = sparse(I,J,V)
    # Q = Q / Q'Q
    # @show Q'Q# < 1e-6
    return (Q'A)*(Q)
end


function blockcounts(sbm::StochasticBlockModel, g::SimpleGraph)
    return blockcounts(sbm, adjacency_matrix(g))
end

function blockfractions(sbm::StochasticBlockModel, g::Union{SimpleGraph, AbstractMatrix})
    bc = blockcounts(sbm, g)
    bp = bc ./ sum(bc)
    return bp
end
