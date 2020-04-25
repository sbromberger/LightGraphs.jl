"""
    SimpleGraph{T}(nv, ne; rng=GLOBAL_RNG)

Construct a random `SimpleGraph{T}` with `nv` vertices and `ne` edges.
The graph is sampled uniformly from all such graphs.
If not specified, the element type `T` is the type of `nv`.

### See also
[`LightGraphs.Generators.ErdosRenyi`](@ref)

## Examples
```jldoctest
julia> SimpleGraph(5, 7)
{5, 7} undirected simple Int64 graph
```
"""
function SimpleGraph{T}(nv::Integer, ne::Integer; rng::AbstractRNG=GLOBAL_RNG) where {T<:Integer}
    tnv = T(nv)
    maxe = div(Int(nv) * (nv - 1), 2)
    @assert(ne <= maxe, "Maximum number of edges for this graph is $maxe")
    ne > div((2 * maxe), 3)  && return complement(SimpleGraph{T}(tnv, maxe - ne))

    g = SimpleGraph(tnv)

    while g.ne < ne
        source = rand(rng, one(T):tnv)
        dest = rand(rng, one(T):tnv)
        source != dest && add_edge!(g, source, dest)
    end
    return g
end

SimpleGraph(nv::T, ne::Integer; rng::AbstractRNG=GLOBAL_RNG) where {T<:Integer} =
    SimpleGraph{T}(nv, ne, rng=rng)

"""
    SimpleDiGraph{T}(nv, ne; rng=GLOBAL_RNG)

Construct a random `SimpleDiGraph{T}` with `nv` vertices and `ne` edges.
The graph is sampled uniformly from all such graphs.
If not specified, the element type `T` is the type of `nv`.

### See also
[`LightGraphs.Generators.ErdosRenyi`](@ref)

## Examples
```jldoctest
julia> SimpleDiGraph(5, 7)
{5, 7} directed simple Int64 graph
```
"""
function SimpleDiGraph{T}(nv::Integer, ne::Integer; rng::AbstractRNG=GLOBAL_RNG) where {T<:Integer}
    tnv = T(nv)
    maxe = Int(nv) * (nv - 1)
    @assert(ne <= maxe, "Maximum number of edges for this graph is $maxe")
    ne > div((2 * maxe), 3) && return complement(SimpleDiGraph{T}(tnv, maxe - ne))

    g = SimpleDiGraph(tnv)
    while g.ne < ne
        source = rand(rng, one(T):tnv)
        dest = rand(rng, one(T):tnv)
        source != dest && add_edge!(g, source, dest)
    end
    return g
end

SimpleDiGraph(nv::T, ne::Integer; rng::AbstractRNG=GLOBAL_RNG) where {T<:Integer} =
    SimpleDiGraph{T}(nv, ne, rng=rng)
    # SimpleDiGraph{Int}(nv, ne, rng=rng)

SimpleGraph(gen::Binomial) = binomial_undir(gen.n, gen.p, gen.rng)
SimpleDiGraph(gen::Binomial) = binomial_dir(gen.n, gen.p, gen.rng)

function binomial_undir(n::Integer, p::Real, rng::AbstractRNG)
    p >= 1 && return SimpleGraph(Complete(n))
    m = div(n * (n - 1), 2)
    ne = randbn(m, p, rng)
    return SimpleGraph(n, ne, rng=rng)
end

function binomial_dir(n::Integer, p::Real, rng::AbstractRNG)
    p >= 1 && return SimpleDiGraph(Complete(n))
    m =  n * (n - 1)
    ne = randbn(m, p, rng)
    return SimpleDiGraph(n, ne, rng=rng)
end

erdos_renyi_undir(n::Integer, ne::Integer, rng::AbstractRNG) =
    SimpleGraph(n, ne, rng=rng)

erdos_renyi_dir(n::Integer, ne::Integer, rng::AbstractRNG) =
    SimpleDiGraph(n, ne, rng=rng)

SimpleGraph(alg::ErdosRenyi) = erdos_renyi_undir(alg.n, alg.ne, alg.rng)
SimpleDiGraph(alg::ErdosRenyi) = erdos_renyi_dir(alg.n, alg.ne, alg.rng)

function expected_degree_graph_undir(ω::Vector{T}, rng::AbstractRNG) where {T<:Real}
    g = SimpleGraph(length(ω))
    expected_degree_graph!(g, ω, rng)
end

function expected_degree_graph_dir(ω::Vector{T}, rng::AbstractRNG) where {T<:Real}
    g = SimpleDiGraph(length(ω))
    expected_degree_graph!(g, ω, rng)
end

function expected_degree_graph!(g::AbstractSimpleGraph, ω::Vector{T}, rng::AbstractRNG) where {T<:Real}
    n = length(ω)
    @assert all(zero(T) .<= ω .<= n - one(T)) "Elements of ω need to be between 0 and n-1, inclusive"

    π = sortperm(ω, rev=true)

    S = sum(ω)

    for u = 1:(n - 1)
        v = u + 1
        p = min(ω[π[u]] * ω[π[v]] / S, one(T))
        while v <= n && p > zero(p)
            if p != one(T)
                v += floor(Int, log(rand(rng)) / log(one(T) - p))
            end
            if v <= n
                q = min(ω[π[u]] * ω[π[v]] / S, one(T))
                if rand(rng) < q / p
                    add_edge!(g, π[u], π[v])
                end
                p = q
                v += 1
            end
        end
    end
    return g
end

SimpleGraph(alg::ExpectedDegree) = expected_degree_graph_undir(alg.ω, alg.rng)
SimpleDiGraph(alg::ExpectedDegree) = expected_degree_graph_dir(alg.ω, alg.rng)

function watts_strogatz_undir(n::Integer, k::Integer, β::Real, rng::AbstractRNG)
    @assert k < n
    g = SimpleGraph(n)
    for s in 1:n
        for i in 1:(floor(Integer, k / 2))
            target = ((s + i - 1) % n) + 1
            if rand(rng) > β && !has_edge(g, s, target) # TODO: optimize this based on return of add_edge!
                add_edge!(g, s, target)
            else
                while true
                    d = target
                    while d == target
                        d = rand(rng, 1:(n - 1))
                        if s < d
                            d += 1
                        end
                    end
                    if s != d
                        add_edge!(g, s, d) && break
                    end
                end
            end
        end
    end
    return g
end

function watts_strogatz_dir(n::Integer, k::Integer, β::Real, rng::AbstractRNG)
    @assert k < n
    g = SimpleDiGraph(n)
    for s in 1:n
        for i in 1:(floor(Integer, k / 2))
            target = ((s + i - 1) % n) + 1
            if rand(rng) > β && !has_edge(g, s, target) # TODO: optimize this based on return of add_edge!
                add_edge!(g, s, target)
            else
                while true
                    d = target
                    while d == target
                        d = rand(rng, 1:(n - 1))
                        if s < d
                            d += 1
                        end
                    end
                    if s != d
                        add_edge!(g, s, d) && break
                    end
                end
            end
        end
    end
    return g
end

SimpleGraph(alg::WattsStrogatz) = watts_strogatz_undir(alg.n, alg.k, alg.β, alg.rng)
SimpleDiGraph(alg::WattsStrogatz) = watts_strogatz_dir(alg.n, alg.k, alg.β, alg.rng)

function _suitable(edges::Set{SimpleEdge{T}}, potential_edges::Dict{T,T}) where T <: Integer
    isempty(potential_edges) && return true
    list = keys(potential_edges)
    for s1 in list, s2 in list
        s1 >= s2 && continue
        (SimpleEdge(s1, s2) ∉ edges) && return true
    end
    return false
end

_try_creation(n::Integer, k::Integer, rng::AbstractRNG) = _try_creation(n, fill(k, n), rng)

function _try_creation(n::T, k::AbstractVector{T}, rng::AbstractRNG) where T <: Integer
    edges = Set{SimpleEdge{T}}()
    m = 0
    stubs = zeros(T, sum(k))
    for i = one(T):n
        for j = one(T):k[i]
            m += 1
            stubs[m] = i
        end
    end
    # stubs = vcat([fill(i, k[i]) for i = 1:n]...) # slower

    while !isempty(stubs)
        potential_edges =  Dict{T,T}()
        shuffle!(rng, stubs)
        for i in 1:2:length(stubs)
            s1, s2 = stubs[i:(i + 1)]
            if (s1 > s2)
                s1, s2 = s2, s1
            end
            e = SimpleEdge(s1, s2)
            if s1 != s2 && ∉(e, edges)
                push!(edges, e)
            else
                potential_edges[s1] = get(potential_edges, s1, 0) + 1
                potential_edges[s2] = get(potential_edges, s2, 0) + 1
            end
        end

        if !_suitable(edges, potential_edges)
            return Set{SimpleEdge{T}}()
        end

        stubs = Vector{Int}()
        for (e, ct) in potential_edges
            append!(stubs, fill(e, ct))
        end
    end
    return edges
end

function barabasi_albert(n::Integer, k::Integer, g0::AbstractSimpleGraph, rng::AbstractRNG)
    g = copy(g0)
    barabasi_albert!(g, n, k, rng)
    return g
end

function barabasi_albert!(g::AbstractGraph, n::Integer, k::Integer, rng::AbstractRNG)
    n0 = nv(g)
    n0 == n && return g

    # add missing vertices
    sizehint!(g.fadjlist, n)
    add_vertices!(g, n - n0)

    # if initial graph doesn't contain any edges
    # expand it by one vertex and add k edges from this additional node
    if ne(g) == 0
        # expand initial graph
        n0 += one(n0)

        # add edges to k existing vertices
        for target in sample!(rng, collect(1:(n0 - 1)), k)
            add_edge!(g, n0, target)
        end
    end

    # vector of weighted vertices (each node is repeated once for each adjacent edge)
    weightedVs = Vector{Int}(undef, 2 * (n - n0) * k + 2 * ne(g))

    # initialize vector of weighted vertices
    offset = 0
    for e in edges(g)
        weightedVs[offset += 1] = src(e)
        weightedVs[offset += 1] = dst(e)
    end

    # array to record if a node is picked
    picked = fill(false, n)

    # vector of targets
    targets = Vector{Int}(undef, k)

    for source in (n0 + 1):n
        # choose k targets from the existing vertices
        # pick uniformly from weightedVs (preferential attachement)
        i = 0
        while i < k
            target = weightedVs[rand(rng, 1:offset)]
            if !picked[target]
                targets[i += 1] = target
                picked[target] = true
            end
        end

        # add edges to k targets
        for target in targets
            add_edge!(g, source, target)

            weightedVs[offset += 1] = source
            weightedVs[offset += 1] = target
            picked[target] = false
        end
    end
    return g
end

BarabasiAlbert(n::Integer, k::Integer; rng::AbstractRNG=GLOBAL_RNG) = BarabasiAlbert(n, k, SimpleGraph(k), rng)
function SimpleGraph(alg::BarabasiAlbert)
    return barabasi_albert(alg.n, alg.k, SimpleGraph(alg.g), alg.rng)
end

function SimpleDiGraph(alg::BarabasiAlbert)
    return barabasi_albert(alg.n, alg.k, SimpleDiGraph(alg.g), alg.rng)
end

function static_fitness_model_undir(m::Integer, fitness::Vector{T}, rng::AbstractRNG) where {T<:Real}
    n = length(fitness)
    m == 0 && return SimpleGraph(n)
    nvs = sum(fitness .> zero(T))
    # avoid getting into an infinite loop when too many edges are requested
    max_no_of_edges = div(nvs * (nvs - 1), 2)
    m > max_no_of_edges && throw(ArgumentError("too many edges requested ($m > $max_no_of_edges)"))
    # calculate the cumulative fitness scores
    cum_fitness = cumsum(fitness)
    g = SimpleGraph(n)
    _create_static_fitness_graph!(g, m, cum_fitness, cum_fitness, rng)
    return g
end

function static_fitness_model_dir(m::Integer, fitness_out::Vector{T}, fitness_in::Vector{S}, rng::AbstractRNG) where {T<:Real, S<:Real}
    n = length(fitness_out)
    m == 0 && return SimpleDiGraph(n)
    # avoid getting into an infinite loop when too many edges are requested
    noutvs = ninvs = nvs = 0
    @inbounds for i = 1:n
        # sanity check for the fitness
        fitness_out[i] > zero(T) && (noutvs += 1)
        fitness_in[i] > zero(S) && (ninvs += 1)
        (fitness_out[i] > zero(T) && fitness_in[i] > zero(S)) && (nvs += 1)
    end
    max_no_of_edges = noutvs * ninvs - nvs
    m > max_no_of_edges && throw(ArgumentError("too many edges requested ($m > $max_no_of_edges)"))
    # calculate the cumulative fitness scores
    cum_fitness_out = cumsum(fitness_out)
    cum_fitness_in = cumsum(fitness_in)
    g = SimpleDiGraph(n)
    _create_static_fitness_graph!(g, m, cum_fitness_out, cum_fitness_in, rng)
    return g
end
SimpleGraph(alg::StaticFitnessModel) = static_fitness_model_undir(alg.m, alg.fitness_out, alg.rng)
SimpleDiGraph(alg::StaticFitnessModel) = static_fitness_model_dir(alg.m, alg.fitness_out, alg.fitness_in, alg.rng)

function _create_static_fitness_graph!(g::AbstractGraph, m::Integer, cum_fitness_out::Vector{T}, cum_fitness_in::Vector{S}, rng::AbstractRNG) where {S<:Real, T<:Real}
    max_out = cum_fitness_out[end]
    max_in = cum_fitness_in[end]
    while m > 0
        source = searchsortedfirst(cum_fitness_out, rand(rng) * max_out)
        target = searchsortedfirst(cum_fitness_in, rand(rng) * max_in)
        # skip if loop edge
        (source == target) && continue
        # is there already an edge? If so, try again
        add_edge!(g, source, target) || continue
        m -= one(m)
    end
end

function _construct_fitness(n::Integer, α::Real, finite_size_correction::Bool)
    α = -1 / (α - 1)
    fitness = zeros(n)
    j = float(n)
    if finite_size_correction && α < -0.5
        # See the Cho et al paper, first page first column + footnote 7
        j += n^(1 + 1 / 2 * α) * (10 * sqrt(2) * (1 + α))^(-1 / α) - 1
    end
    j = max(j, n)
    @inbounds for i = 1:n
        fitness[i] = j^α
        j -= 1
    end
    return fitness
end

function static_scale_free_undir(n::Integer, m::Integer, α::Real, finite_size_correction::Bool, rng::AbstractRNG)
    n < 0 && throw(ArgumentError("number of vertices must be positive"))
    α < 2 && throw(ArgumentError("out-degree exponent must be >= 2"))
    fitness = _construct_fitness(n, α, finite_size_correction)
    static_fitness_model_undir(m, fitness, rng)
end

function static_scale_free_dir(n::Integer, m::Integer, α_out::Real, α_in::Float64, finite_size_correction::Bool, rng::AbstractRNG)
    # construct the fitness
    fitness_out = _construct_fitness(n, α_out, finite_size_correction)
    fitness_in = _construct_fitness(n, α_in, finite_size_correction)
    # eliminate correlation
    shuffle!(fitness_in)
    static_fitness_model_dir(m, fitness_out, fitness_in, rng)
end

SimpleGraph(alg::StaticScaleFree) = static_scale_free_undir(alg.n, alg.m, alg.αout, alg.finite_size_correction, alg.rng)
SimpleDiGraph(alg::StaticScaleFree) = static_scale_free_dir(alg.n, alg.m, alg.αout, alg.αin, alg.finite_size_correction, alg.rng)

function random_regular_undir(n::Integer, k::Integer, rng::AbstractRNG)
    !iseven(n * k) && throw(ArgumentError("n * k must be even"))
    if k == 0
        return SimpleGraph(n)
    end
    if (k > n / 2) && iseven(n * (n - k - 1))
        return complement(random_regular_undir(n, n-k-1, rng))
    end

    edges = _try_creation(n, k, rng)
    while isempty(edges)
        edges = _try_creation(n, k, rng)
    end

    g = SimpleGraph(n)
    for edge in edges
        add_edge!(g, edge)
    end

    return g
end

function random_regular_dir(n::T, k::Integer, outbound::Bool, rng::AbstractRNG)::SimpleDiGraph{T} where {T<:Integer}
    k == 0 && return SimpleDiGraph(n)
    (k > n / 2) && iseven(n * (n - k - 1)) && return complement(random_regular_dir(n, n - k - 1, outbound, rng))

    cs = collect(T(2):n)
    i = 1
    I = Vector{T}(undef, n * k)
    J = Vector{T}(undef, n * k)
    V = fill(true, n * k)
    for r in 1:n
        l = ((r - 1) * k + 1):(r * k)
        I[l] .= r
        J[l] = sample!(rng, cs, k, exclude=r)
    end

    a = outbound ? sparse(I, J, V, n, n) : sparse(I, J, V, n, n)'
    return SimpleDiGraph{T}(a)
end

SimpleGraph(alg::RandomRegular) = random_regular_undir(alg.n, alg.k, alg.rng)
SimpleDiGraph(alg::RandomRegular) = random_regular_dir(alg.n, alg.k, alg.outbound, alg.rng)

function random_configuration_model_undir(n::Integer, k::AbstractVector{T}, rng::AbstractRNG) where {T<:Integer}
    m = sum(k)
    edges = _try_creation(n, k, rng)
    while m > 0 && isempty(edges)
        edges = _try_creation(n, k, rng)
    end

    g = SimpleGraphFromIterator(edges)
    if nv(g) < n
        add_vertices!(g, n - nv(g))
    end
    return g
end

function random_configuration_model_dir(n::Integer, k::AbstractVector{T}, rng::AbstractRNG) where {T<:Integer}
    m = sum(k)
    !iseven(m) && throw(ArgumentError("sum(k) must be even"))

    edges = _try_creation(n, k, rng)
    while m > 0 && isempty(edges)
        edges = _try_creation(n, k, rng)
    end

    g = SimpleDiGraphFromIterator(edges)
    if nv(g) < n
        add_vertices!(g, n - nv(g))
    end
    return g
end

SimpleGraph(alg::RandomConfigurationModel) = random_configuration_model_undir(alg.n, alg.k, alg.rng)
SimpleDiGraph(alg::RandomConfigurationModel) = random_configuration_model_dir(alg.n, alg.k, alg.rng)

function random_tournament_dir(n::Integer, rng::AbstractRNG)
    g = SimpleDiGraph(n)
    for i = 1:n, j = i + 1:n
        rand(rng, Bool) ? add_edge!(g, SimpleEdge(i, j)) : add_edge!(g, SimpleEdge(j, i))
    end

    return g
end

# not defined for undirected graphs
SimpleDiGraph(alg::Tournament) = random_tournament_dir(alg.n, alg.rng)

function kronecker(SCALE, edgefactor, A, B, C, rng::AbstractRNG)
    N = 2^SCALE
    M = edgefactor * N
    ij = ones(Int, M, 2)
    ab = A + B
    c_norm = C / (1 - (A + B))
    a_norm = A / (A + B)

    for ib = 1:SCALE
        ii_bit = rand(rng, M) .> (ab)  # bitarray
        jj_bit = rand(rng, M) .> (c_norm .* (ii_bit) + a_norm .* .!(ii_bit))
        ij .+= 2^(ib - 1) .* (hcat(ii_bit, jj_bit))
    end

    p = randperm(rng, N)
    ij = p[ij]

    p = randperm(rng, M)
    ij = ij[p, :]

    g = SimpleDiGraph(N)
    for (s, d) in zip(@view(ij[:, 1]), @view(ij[:, 2]))
        add_edge!(g, s, d)
    end
    return g
end

# not defined for undirected graphs
SimpleDiGraph(alg::Kronecker) = kronecker(alg.SCALE, alg.edgefactor, alg.A, alg.B, alg.C, alg.rng)

function dorogovtsev_mendes_undir(n::Integer, rng::AbstractRNG)
    g = SimpleGraph(Cycle(3))

    for iteration in 1:(n-3)
        chosenedge = rand(rng, 1:(2*ne(g))) # undirected so each edge is listed twice in adjlist
        u, v = -1, -1
        for i in 1:nv(g)
            edgelist = outneighbors(g, i)
            if chosenedge > length(edgelist)
                chosenedge -= length(edgelist)
            else
                u = i
                v = edgelist[chosenedge]
                break
            end
        end

        add_vertex!(g)
        add_edge!(g, nv(g), u)
        add_edge!(g, nv(g), v)
    end
    return g
end

SimpleGraph(alg::DorogovtsevMendes) = dorogovtsev_mendes_undir(alg.n, alg.rng)
# not defined for directed graphs

"""
    random_orientation_dag(g)

Generate a random oriented acyclical digraph. The function takes in a simple
graph and a random number generator as an argument. The probability of each
directional acyclic graph randomly being generated depends on the architecture
of the original directed graph.

DAG's have a finite topological order; this order is randomly generated via "order = randperm()".

# Examples
```jldoctest
julia> random_orientation_dag(complete_graph(10))
{10, 45} directed simple Int64 graph

julia> random_orientation_dag(star_graph(Int8(10)), 123)
{10, 9} directed simple Int8 graph
```
"""
function random_orientation_dag_dir(g::SimpleGraph{T}, rng::AbstractRNG) where {T<:Integer}
    nvg = nv(g)
    order = randperm(rng, nvg)
    g2 = SimpleDiGraph(nvg)
    @inbounds for i in vertices(g)
        for j in outneighbors(g, i)
            if order[i] < order[j]
                add_edge!(g2, i, j)
            end
        end
    end
    return g2
end

# not defined for undirected graphs
SimpleDiGraph(alg::RandomOrientationDAG) = random_orientation_dag_dir(alg.g, alg.rng)
