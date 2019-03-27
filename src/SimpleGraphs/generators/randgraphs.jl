using Random:
    AbstractRNG, MersenneTwister, randperm, seed!, shuffle!
using Statistics: mean

using LightGraphs:
    getRNG, sample!

"""
    SimpleGraph{T}(nv, ne; seed=-1)

Construct a random `SimpleGraph{T}` with `nv` vertices and `ne` edges.
The graph is sampled uniformly from all such graphs.
If `seed >= 0`, a random generator is seeded with this value.
If not specified, the element type `T` is the type of `nv`.

### See also
[`erdos_renyi`](@ref)

## Examples
```jldoctest
julia> SimpleGraph(5, 7)
{5, 7} undirected simple Int64 graph
```
"""
function SimpleGraph{T}(nv::Integer, ne::Integer; seed::Int=-1) where T <: Integer
    tnv = T(nv)
    maxe = div(Int(nv) * (nv - 1), 2)
    @assert(ne <= maxe, "Maximum number of edges for this graph is $maxe")
    ne > (2 / 3) * maxe && return complement(SimpleGraph(nv, maxe - ne))

    rng = getRNG(seed)
    g = SimpleGraph(tnv)

    while g.ne < ne
        source = rand(rng, one(T):tnv)
        dest = rand(rng, one(T):tnv)
        source != dest && add_edge!(g, source, dest)
    end
    return g
end

SimpleGraph(nv::T, ne::Integer; seed::Int=-1) where T <: Integer =
    SimpleGraph{T}(nv, ne, seed=seed)

"""
    SimpleDiGraph{T}(nv, ne; seed=-1)

Construct a random `SimpleDiGraph{T}` with `nv` vertices and `ne` edges.
The graph is sampled uniformly from all such graphs.
If `seed >= 0`, a random generator is seeded with this value.
If not specified, the element type `T` is the type of `nv`.

### See also
[`erdos_renyi`](@ref)

## Examples
```jldoctest
julia> SimpleDiGraph(5, 7)
{5, 7} directed simple Int64 graph
```
"""
function SimpleDiGraph{T}(nv::Integer, ne::Integer; seed::Int=-1) where T <: Integer
    tnv = T(nv)
    maxe = Int(nv) * (nv - 1)
    @assert(ne <= maxe, "Maximum number of edges for this graph is $maxe")
    ne > (2 / 3) * maxe && return complement(SimpleDiGraph{T}(nv, maxe - ne))

    rng = getRNG(seed)
    g = SimpleDiGraph(tnv)
    while g.ne < ne
        source = rand(rng, one(T):tnv)
        dest = rand(rng, one(T):tnv)
        source != dest && add_edge!(g, source, dest)
    end
    return g
end

SimpleDiGraph(nv::T, ne::Integer; seed::Int=-1) where T <: Integer =
    SimpleDiGraph{Int}(nv, ne, seed=seed)

"""
	SimpleDiGraph(g, p_in, p_out; seed=-1)

Create a directed graph from an undirected graph `g` where the direction of each
edge from `u` to `v` (`u < v`) in `g` is added as a directed edge from `u` to `v`
with probability `p_out`, from `v` to `u` with probability `p_in`, or in both
directions with probability `1 - p_in - p_out`. If `p_in + p_out ≥ 1`, `p_out`
will be truncated to `1 - p_in`, and no bidirectional edges will be created.
"""
function SimpleDiGraph(g::SimpleGraph, _p_in::Real, _p_out::Real; seed::Int=-1)
    p_in, p_out = promote(_p_in, _p_out)
    T = typeof(p_in)
    edgelist = Vector{edgetype(g)}()
    ne_g = ne(g)
    p_both = max(one(T) - p_in - p_out, zero(T))
    thresh_in = (zero(T), p_in)
    thresh_out = (p_in, p_in + p_out)
    sizehint!(edgelist, ne_g + Int(ceil(ne_g * 1.2 * p_both)))
    rng = getRNG(seed)
    for e in edges(g)
        r = rand(rng)
        if thresh_in[1] <= r < thresh_in[2]
            push!(edgelist, e)
        elseif thresh_out[1] <= r < thresh_out[2]
            push!(edgelist, reverse(e))
        else
            push!(edgelist, e)
            push!(edgelist, reverse(e))
        end
    end
    d = SimpleDiGraphFromIterator(edgelist)
    if nv(d) < nv(g)
        add_vertices!(d, nv(g) - nv(d))
    end
    return d
end


"""
    randbn(n, p, seed=-1)

Return a binomally-distribted random number with parameters `n` and `p` and optional `seed`.

### References
- "Non-Uniform Random Variate Generation," Luc Devroye, p. 522. Retrieved via http://www.eirene.de/Devroye.pdf.
- http://stackoverflow.com/questions/23561551/a-efficient-binomial-random-number-generator-code-in-java
"""
function randbn(n::Integer, p::Real, seed::Integer=-1)
    rng = getRNG(seed)
    log_q = log(1.0 - p)
    x = 0
    sum = 0.0
    while true
        sum += log(rand(rng)) / (n - x)
        sum < log_q && break
        x += 1
    end
    return x
end

"""
    erdos_renyi(n, p)

Create an [Erdős–Rényi](http://en.wikipedia.org/wiki/Erdős–Rényi_model)
random graph with `n` vertices. Edges are added between pairs of vertices with
probability `p`.

### Optional Arguments
- `is_directed=false`: if true, return a directed graph.
- `seed=-1`: set the RNG seed.

# Examples
```jldoctest
julia> erdos_renyi(10, 0.5)
{10, 20} undirected simple Int64 graph

julia> erdos_renyi(10, 0.5, is_directed=true, seed=123)
{10, 49} directed simple Int64 graph
```
"""
function erdos_renyi(n::Integer, p::Real; is_directed=false, seed::Integer=-1)
    p >= 1 && return is_directed ? CompleteDiGraph(n) : CompleteGraph(n)
    m = is_directed ? n * (n - 1) : div(n * (n - 1), 2)
    ne = randbn(m, p, seed)
    return is_directed ? SimpleDiGraph(n, ne, seed=seed) : SimpleGraph(n, ne, seed=seed)
end

"""
    erdos_renyi(n, ne)

Create an [Erdős–Rényi](http://en.wikipedia.org/wiki/Erdős–Rényi_model) random
graph with `n` vertices and `ne` edges.

### Optional Arguments
- `is_directed=false`: if true, return a directed graph.
- `seed=-1`: set the RNG seed.

# Examples
```jldoctest
julia> erdos_renyi(10, 30)
{10, 30} undirected simple Int64 graph

julia> erdos_renyi(10, 30, is_directed=true, seed=123)
{10, 30} directed simple Int64 graph
```
"""
function erdos_renyi(n::Integer, ne::Integer; is_directed=false, seed::Integer=-1)
    return is_directed ? SimpleDiGraph(n, ne, seed=seed) : SimpleGraph(n, ne, seed=seed)
end

"""
    expected_degree_graph(ω)

Given a vector of expected degrees `ω` indexed by vertex, create a random undirected graph in which vertices `i` and `j` are
connected with probability `ω[i]*ω[j]/sum(ω)`.

### Optional Arguments
- `seed=-1`: set the RNG seed.

### Implementation Notes
The algorithm should work well for `maximum(ω) << sum(ω)`. As `maximum(ω)` approaches `sum(ω)`, some deviations
from the expected values are likely.

### References
- Connected Components in Random Graphs with Given Expected Degree Sequences, Linyuan Lu and Fan Chung. [https://link.springer.com/article/10.1007%2FPL00012580](https://link.springer.com/article/10.1007%2FPL00012580)
- Efficient Generation of Networks with Given Expected Degrees, Joel C. Miller and Aric Hagberg. [https://doi.org/10.1007/978-3-642-21286-4_10](https://doi.org/10.1007/978-3-642-21286-4_10)

# Examples
```jldoctest
# 1)
julia> g = expected_degree_graph([3, 1//2, 1//2, 1//2, 1//2])
{5, 3} undirected simple Int64 graph

julia> print(degree(g))
[3, 0, 1, 1, 1]

# 2)
julia> g = expected_degree_graph([0.5, 0.5, 0.5], seed=123)
{3, 1} undirected simple Int64 graph

julia> print(degree(g))
[1, 0, 1]
```
"""
function expected_degree_graph(ω::Vector{T}; seed::Int=-1) where T <: Real
    g = SimpleGraph(length(ω))
    expected_degree_graph!(g, ω, seed=seed)
end

function expected_degree_graph!(g::SimpleGraph, ω::Vector{T}; seed::Int=-1) where T <: Real
    n = length(ω)
    @assert all(zero(T) .<= ω .<= n - one(T)) "Elements of ω needs to be at least 0 and at most n-1"

    π = sortperm(ω, rev=true)
    rng = getRNG(seed)

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


"""
    watts_strogatz(n, k, β)

Return a [Watts-Strogatz](https://en.wikipedia.org/wiki/Watts_and_Strogatz_model)
small model random graph with `n` vertices, each with degree `k`. Edges are
randomized per the model based on probability `β`.

### Optional Arguments
- `is_directed=false`: if true, return a directed graph.
- `seed=-1`: set the RNG seed.
"""
function watts_strogatz(n::Integer, k::Integer, β::Real; is_directed=false, seed::Int=-1)
    @assert k < n / 2
    if is_directed
        g = SimpleDiGraph(n)
    else
        g = SimpleGraph(n)
    end
    rng = getRNG(seed)
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

function _try_creation(n::T, k::Vector{T}, rng::AbstractRNG) where T <: Integer
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

"""
    barabasi_albert(n, k)

Create a [Barabási–Albert model](https://en.wikipedia.org/wiki/Barab%C3%A1si%E2%80%93Albert_model)
random graph with `n` vertices. It is grown by adding new vertices to an initial
graph with `k` vertices. Each new vertex is attached with `k` edges to `k`
different vertices already present in the system by preferential attachment.
Initial graphs are undirected and consist of isolated vertices by default.

### Optional Arguments
- `is_directed=false`: if true, return a directed graph.
- `complete=false`: if true, use a complete graph for the initial graph.
- `seed=-1`: set the RNG seed.
"""
barabasi_albert(n::Integer, k::Integer; keyargs...) =
barabasi_albert(n, k, k; keyargs...)

"""
    barabasi_albert(n::Integer, n0::Integer, k::Integer)

Create a [Barabási–Albert model](https://en.wikipedia.org/wiki/Barab%C3%A1si%E2%80%93Albert_model)
random graph with `n` vertices. It is grown by adding new vertices to an initial
graph with `n0` vertices. Each new vertex is attached with `k` edges to `k`
different vertices already present in the system by preferential attachment.
Initial graphs are undirected and consist of isolated vertices by default.

### Optional Arguments
- `is_directed=false`: if true, return a directed graph.
- `complete=false`: if true, use a complete graph for the initial graph.
- `seed=-1`: set the RNG seed.
"""
function barabasi_albert(n::Integer, n0::Integer, k::Integer; is_directed::Bool=false, complete::Bool=false, seed::Int=-1)
    if complete
        g = is_directed ? CompleteDiGraph(n0) : CompleteGraph(n0)
    else
        g = is_directed ? SimpleDiGraph(n0) : SimpleGraph(n0)
    end

    barabasi_albert!(g, n, k; seed=seed)
    return g
end

"""
    barabasi_albert!(g::AbstractGraph, n::Integer, k::Integer)

Create a [Barabási–Albert model](https://en.wikipedia.org/wiki/Barab%C3%A1si%E2%80%93Albert_model)
random graph with `n` vertices. It is grown by adding new vertices to an initial
graph `g`. Each new vertex is attached with `k` edges to `k` different vertices
already present in the system by preferential attachment.

### Optional Arguments
- `seed=-1`: set the RNG seed.
"""
function barabasi_albert!(g::AbstractGraph, n::Integer, k::Integer; seed::Int=-1)
    n0 = nv(g)
    1 <= k <= n0 <= n ||
        throw(ArgumentError("Barabási-Albert model requires 1 <= k <= nv(g) <= n"))
    n0 == n && return g

    # seed random number generator
    seed > 0 && seed!(seed)

    # add missing vertices
    sizehint!(g.fadjlist, n)
    add_vertices!(g, n - n0)

    # if initial graph doesn't contain any edges
    # expand it by one vertex and add k edges from this additional node
    if ne(g) == 0
        # expand initial graph
        n0 += one(n0)

        # add edges to k existing vertices
        for target in sample!(collect(1:(n0 - 1)), k)
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
            target = weightedVs[rand(1:offset)]
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


"""
    static_fitness_model(m, fitness)

Generate a random graph with ``|fitness|`` vertices and `m` edges,
in which the probability of the existence of ``Edge_{ij}`` is proportional
to ``fitness_i × fitness_j``.

### Optional Arguments
- `seed=-1`: set the RNG seed.

### Performance
Time complexity is ``\\mathcal{O}(|V| + |E| log |E|)``.

### References
- Goh K-I, Kahng B, Kim D: Universal behaviour of load distribution in scale-free networks. Phys Rev Lett 87(27):278701, 2001.
"""
function static_fitness_model(m::Integer, fitness::Vector{T}; seed::Int=-1) where T <: Real
    m < 0 && throw(ArgumentError("number of edges must be positive"))
    n = length(fitness)
    m == 0 && return SimpleGraph(n)
    nvs = 0
    for f in fitness
        # sanity check for the fitness
        f < zero(T) && throw(ArgumentError("fitness scores must be non-negative"))
        f > zero(T) && (nvs += 1)
    end
    # avoid getting into an infinite loop when too many edges are requested
    max_no_of_edges = div(nvs * (nvs - 1), 2)
    m > max_no_of_edges && throw(ArgumentError("too many edges requested ($m > $max_no_of_edges)"))
    # calculate the cumulative fitness scores
    cum_fitness = cumsum(fitness)
    g = SimpleGraph(n)
    _create_static_fitness_graph!(g, m, cum_fitness, cum_fitness, seed)
    return g
end

"""
    static_fitness_model(m, fitness_out, fitness_in)

Generate a random graph with ``|fitness\\_out + fitness\\_in|`` vertices and `m` edges,
in which the probability of the existence of ``Edge_{ij}`` is proportional with
respect to ``i ∝ fitness\\_out`` and ``j ∝ fitness\\_in``.

### Optional Arguments
- `seed=-1`: set the RNG seed.

### Performance
Time complexity is ``\\mathcal{O}(|V| + |E| log |E|)``.

### References
- Goh K-I, Kahng B, Kim D: Universal behaviour of load distribution in scale-free networks. Phys Rev Lett 87(27):278701, 2001.
"""
function static_fitness_model(m::Integer, fitness_out::Vector{T}, fitness_in::Vector{S}; seed::Int=-1) where T <: Real where S <: Real
    m < 0 && throw(ArgumentError("number of edges must be positive"))
    n = length(fitness_out)
    length(fitness_in) != n && throw(ArgumentError("fitness_in must have the same size as fitness_out"))
    m == 0 && return SimpleDiGraph(n)
    # avoid getting into an infinite loop when too many edges are requested
    noutvs = ninvs = nvs = 0
    @inbounds for i = 1:n
        # sanity check for the fitness
        (fitness_out[i] < zero(T) || fitness_in[i] < zero(S)) && error("fitness scores must be non-negative") # TODO 0.7: change to DomainError?
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
    _create_static_fitness_graph!(g, m, cum_fitness_out, cum_fitness_in, seed)
    return g
end

function _create_static_fitness_graph!(g::AbstractGraph, m::Integer, cum_fitness_out::Vector{T}, cum_fitness_in::Vector{S}, seed::Int) where T <: Real where S <: Real
    rng = getRNG(seed)
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

"""
    static_scale_free(n, m, α)

Generate a random graph with `n` vertices, `m` edges and expected power-law
degree distribution with exponent `α`.

### Optional Arguments
- `seed=-1`: set the RNG seed.
- `finite_size_correction=true`: determines whether to use the finite size correction
proposed by Cho et al.

### Performance
Time complexity is ``\\mathcal{O}(|V| + |E| log |E|)``.

### References
- Goh K-I, Kahng B, Kim D: Universal behaviour of load distribution in scale-free networks. Phys Rev Lett 87(27):278701, 2001.
- Chung F and Lu L: Connected components in a random graph with given degree sequences. Annals of Combinatorics 6, 125-145, 2002.
- Cho YS, Kim JS, Park J, Kahng B, Kim D: Percolation transitions in scale-free networks under the Achlioptas process. Phys Rev Lett 103:135702, 2009.
"""
function static_scale_free(n::Integer, m::Integer, α::Real; seed::Int=-1, finite_size_correction::Bool=true)
    n < 0 && throw(ArgumentError("number of vertices must be positive"))
    α < 2 && throw(ArgumentError("out-degree exponent must be >= 2"))
    fitness = _construct_fitness(n, α, finite_size_correction)
    static_fitness_model(m, fitness, seed=seed)
end

"""
    static_scale_free(n, m, α_out, α_in)

Generate a random graph with `n` vertices, `m` edges and expected power-law
degree distribution with exponent `α_out` for outbound edges and `α_in` for
inbound edges.

### Optional Arguments
- `seed=-1`: set the RNG seed.
- `finite_size_correction=true`: determines whether to use the finite size correction
proposed by Cho et al.

### Performance
Time complexity is ``\\mathcal{O}(|V| + |E| log |E|)``.

### References
- Goh K-I, Kahng B, Kim D: Universal behaviour of load distribution in scale-free networks. Phys Rev Lett 87(27):278701, 2001.
- Chung F and Lu L: Connected components in a random graph with given degree sequences. Annals of Combinatorics 6, 125-145, 2002.
- Cho YS, Kim JS, Park J, Kahng B, Kim D: Percolation transitions in scale-free networks under the Achlioptas process. Phys Rev Lett 103:135702, 2009.
"""
function static_scale_free(n::Integer, m::Integer, α_out::Real, α_in::Float64; seed::Int=-1, finite_size_correction::Bool=true)
    n < 0 && throw(ArgumentError("number of vertices must be positive"))
    α_out < 2 && throw(ArgumentError("out-degree exponent must be >= 2"))
    α_in < 2 && throw(ArgumentError("out-degree exponent must be >= 2"))
    # construct the fitness
    fitness_out = _construct_fitness(n, α_out, finite_size_correction)
    fitness_in = _construct_fitness(n, α_in, finite_size_correction)
    # eliminate correlation
    shuffle!(fitness_in)
    static_fitness_model(m, fitness_out, fitness_in, seed=seed)
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

"""
    random_regular_graph(n, k)

Create a random undirected
[regular graph](https://en.wikipedia.org/wiki/Regular_graph) with `n` vertices,
each with degree `k`.

### Optional Arguments
- `seed=-1`: set the RNG seed.

### Performance
Time complexity is approximately ``\\mathcal{O}(nk^2)``.

### Implementation Notes
Allocates an array of `nk` `Int`s, and . For ``k > \\frac{n}{2}``, generates a graph of degree
``n-k-1`` and returns its complement.
"""
function random_regular_graph(n::Integer, k::Integer; seed::Int=-1)
    !iseven(n * k) && throw(ArgumentError("n * k must be even"))
    !(0 <= k < n) && throw(ArgumentError("the 0 <= k < n inequality must be satisfied"))
    if k == 0
        return SimpleGraph(n)
    end
    if (k > n / 2) && iseven(n * (n - k - 1))
        return complement(random_regular_graph(n, n - k - 1, seed=seed))
    end

    rng = getRNG(seed)

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

"""
    random_configuration_model(n, ks)

Create a random undirected graph according to the [configuration model]
(http://tuvalu.santafe.edu/~aaronc/courses/5352/fall2013/csci5352_2013_L11.pdf)
containing `n` vertices, with each node `i` having degree `k[i]`.

### Optional Arguments
- `seed=-1`: set the RNG seed.
- `check_graphical=false`: if true, ensure that `k` is a graphical sequence
(see [`isgraphical`](@ref)).

### Performance
Time complexity is approximately ``\\mathcal{O}(n \\bar{k}^2)``.
### Implementation Notes
Allocates an array of ``n \\bar{k}`` `Int`s.
"""
function random_configuration_model(n::Integer, k::Array{T}; seed::Int=-1, check_graphical::Bool=false) where T <: Integer
    n != length(k) && throw(ArgumentError("a degree sequence of length n must be provided"))
    m = sum(k)
    !iseven(m) && throw(ArgumentError("sum(k) must be even"))
    !all(0 .<= k .< n) && throw(ArgumentError("the 0 <= k[i] < n inequality must be satisfied"))
    if check_graphical
        isgraphical(k) || throw(ArgumentError("degree sequence must be graphical"))
    end
    rng = getRNG(seed)

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

"""
    random_regular_digraph(n, k)

Create a random directed [regular graph](https://en.wikipedia.org/wiki/Regular_graph)
with `n` vertices, each with degree `k`.

### Optional Arguments
- `dir=:out`: the direction of the edges for degree parameter.
- `seed=-1`: set the RNG seed.

### Implementation Notes
Allocates an ``n × n`` sparse matrix of boolean as an adjacency matrix and
uses that to generate the directed graph.
"""
function random_regular_digraph(n::Integer, k::Integer; dir::Symbol=:out, seed::Int=-1)
    #TODO remove the function sample from StatsBase for one allowing the use
    # of a local rng
    !(0 <= k < n) && throw(ArgumentError("the 0 <= k < n inequality must be satisfied"))

    if k == 0
        return SimpleDiGraph(n)
    end
    if (k > n / 2) && iseven(n * (n - k - 1))
        return complement(random_regular_digraph(n, n - k - 1, dir=dir, seed=seed))
    end
    rng = getRNG(seed)
    cs = collect(2:n)
    i = 1
    I = Vector{Int}(undef, n * k)
    J = Vector{Int}(undef, n * k)
    V = fill(true, n * k)
    for r in 1:n
        l = ((r - 1) * k + 1):(r * k)
        I[l] .= r
        J[l] = sample!(rng, cs, k, exclude=r)
    end

    if dir == :out
        return SimpleDiGraph(sparse(I, J, V, n, n))
    else
        return SimpleDiGraph(sparse(I, J, V, n, n)')
    end
end

"""
    random_tournament_digraph(n)

Create a random directed [tournament graph]
(https://en.wikipedia.org/wiki/Tournament_%28graph_theory%29)
with `n` vertices.

### Optional Arguments
- `seed=-1`: set the RNG seed.

# Examples
```jldoctest
julia> random_tournament_digraph(5)
{5, 10} directed simple Int64 graph

julia> random_tournament_digraph(Int8(10), seed=123)
{10, 45} directed simple Int8 graph
```
"""
function random_tournament_digraph(n::Integer; seed::Int=-1)

    rng = getRNG(seed)
    g = SimpleDiGraph(n)

    for i = 1:n, j = i + 1:n
        rand(rng, Bool) ? add_edge!(g, SimpleEdge(i, j)) : add_edge!(g, SimpleEdge(j, i))
    end

    return g
end

"""
    stochastic_block_model(c, n)

Return a Graph generated according to the Stochastic Block Model (SBM).

`c[a,b]` : Mean number of neighbors of a vertex in block `a` belonging to block `b`.
           Only the upper triangular part is considered, since the lower traingular is
           determined by ``c[b,a] = c[a,b] * \\frac{n[a]}{n[b]}``.
`n[a]` : Number of vertices in block `a`

### Optional Arguments
- `seed=-1`: set the RNG seed.

For a dynamic version of the SBM see the [`StochasticBlockModel`](@ref) type and
related functions.
"""
function stochastic_block_model(c::Matrix{T}, n::Vector{U}; seed::Int=-1) where T <: Real where U <: Integer
    size(c, 1) == size(c, 2) == length(n) || throw(ArgumentError("matrix-vector size mismatch"))

    # init dsfmt generator without altering GLOBAL_RNG
    rng = getRNG(seed)
    N = sum(n)
    K = length(n)
    nedg = zeros(Int, K, K)
    g = SimpleGraph(N)
    cum = [sum(n[1:a]) for a = 0:K]
    for a = 1:K
        ra = (cum[a] + 1):cum[a + 1]
        for b = a:K
            ((a == b) && !(c[a, b] <= n[b] - 1)) || ((a != b) && !(c[a, b] <= n[b])) &&
                error("Mean degree cannot be greater than available neighbors in the block.") # TODO 0.7: turn into some other error?

            m = a == b ? div(n[a] * (n[a] - 1), 2) : n[a] * n[b]
            p = a == b ? n[a] * c[a, b] / (2m) : n[a] * c[a, b] / m
            nedg = randbn(m, p, seed)
            rb = (cum[b] + 1):cum[b + 1]
            i = 0
            while i < nedg
                source = rand(rng, ra)
                dest = rand(rng, rb)
                if source != dest
                    if add_edge!(g, source, dest)
                        i += 1
                    end
                end
            end
        end
    end
    return g
end

"""
    stochastic_block_model(cint, cext, n)

Return a Graph generated according to the Stochastic Block Model (SBM), sampling
from an SBM with ``c_{a,a}=cint``, and ``c_{a,b}=cext``.
"""
function stochastic_block_model(cint::T, cext::T, n::Vector{U}; seed::Int=-1) where T <: Real where U <: Integer
    K = length(n)
    c = [ifelse(a == b, cint, cext) for a = 1:K, b = 1:K]
    stochastic_block_model(c, n, seed=seed)
end

"""
    StochasticBlockModel{T,P}

A type capturing the parameters of the SBM.
Each vertex is assigned to a block and the probability of edge `(i,j)`
depends only on the block labels of vertex `i` and vertex `j`.

The assignement is stored in nodemap and the block affinities a `k` by `k`
matrix is stored in affinities.

`affinities[k,l]` is the probability of an edge between any vertex in
block `k` and any vertex in block `l`.

### Implementation Notes
Graphs are generated by taking random ``i,j ∈ V`` and
flipping a coin with probability `affinities[nodemap[i],nodemap[j]]`.
"""
mutable struct StochasticBlockModel{T <: Integer,P <: Real}
    n::T
    nodemap::Array{T}
    affinities::Matrix{P}
    rng::MersenneTwister
end

==(sbm::StochasticBlockModel, other::StochasticBlockModel) =
    (sbm.n == other.n) && (sbm.nodemap == other.nodemap) && (sbm.affinities == other.affinities)


# A constructor for StochasticBlockModel that uses the sizes of the blocks
# and the affinity matrix. This construction implies that consecutive
# vertices will be in the same blocks, except for the block boundaries.
function StochasticBlockModel(sizes::AbstractVector, affinities::AbstractMatrix; seed::Int=-1)
    csum = cumsum(sizes)
    j = 1
    nodemap = zeros(Int, csum[end])
    for i in 1:csum[end]
        if i > csum[j]
            j += 1
        end
        nodemap[i] = j
    end
    return StochasticBlockModel(csum[end], nodemap, affinities, getRNG(seed))
end


### TODO: This documentation needs work. sbromberger 20170326
"""
    sbmaffinity(internalp, externalp, sizes)

Produce the sbm affinity matrix with internal probabilities `internalp`
and external probabilities `externalp`.
"""
function sbmaffinity(internalp::Vector{T}, externalp::Real, sizes::Vector{U}) where T <: Real where U <: Integer
    numblocks = length(sizes)
    numblocks == length(internalp) || throw(ArgumentError("Inconsistent input dimensions: internalp, sizes"))
    B = diagm(0 => internalp) + externalp * (ones(numblocks, numblocks) - I)
    return B
end

function StochasticBlockModel(internalp::Real,
                              externalp::Real,
                              size::Integer,
                              numblocks::Integer;
                              seed::Int=-1)
    sizes = fill(size, numblocks)
    B = sbmaffinity(fill(internalp, numblocks), externalp, sizes)
    StochasticBlockModel(sizes, B, seed=seed)
end

function StochasticBlockModel(internalp::Vector{T}, externalp::Real,
    sizes::Vector{U}; seed::Int=-1) where T <: Real where U <: Integer
    B = sbmaffinity(internalp, externalp, sizes)
    return StochasticBlockModel(sizes, B, seed=seed)
end


const biclique = ones(2, 2) - Matrix{Float64}(I, 2, 2)

#TODO: this documentation needs work. sbromberger 20170326
"""
    nearbipartiteaffinity(sizes, between, intra)

Construct the affinity matrix for a near bipartite SBM.
`between` is the affinity between the two parts of each bipartite community.
`intra` is the probability of an edge within the parts of the partitions.

This is a specific type of SBM with ``\\frac{k}{2} blocks each with two halves.
Each half is connected as a random bipartite graph with probability `intra`
The blocks are connected with probability `between`.
"""
function nearbipartiteaffinity(sizes::Vector{T}, between::Real, intra::Real) where T <: Integer
    numblocks = div(length(sizes), 2)
    return kron(between * Matrix{Float64}(I, numblocks, numblocks), biclique) + Matrix{Float64}(I, 2 * numblocks, 2 * numblocks) * intra
end

#Return a generator for edges from a stochastic block model near-bipartite graph.
nearbipartiteaffinity(sizes::Vector{T}, between::Real, inter::Real, noise::Real) where T <: Integer =
    nearbipartiteaffinity(sizes, between, inter) .+ noise

nearbipartiteSBM(sizes, between, inter, noise; seed::Int=-1) =
    StochasticBlockModel(sizes, nearbipartiteaffinity(sizes, between, inter, noise), seed=seed)

"""
    random_pair(rng, n)

Generate a stream of random pairs in `1:n` using random number generator `RNG`.
"""
function random_pair(rng::AbstractRNG, n::Integer)
    f(ch) = begin
        while true
            put!(ch, SimpleEdge(rand(rng, 1:n), rand(rng, 1:n)))
        end
    end
    return f
end


"""
    make_edgestream(sbm)

Take an infinite sample from the Stochastic Block Model `sbm`.
Pass to `Graph(nvg, neg, edgestream)` to get a Graph object based on `sbm`.
"""
function make_edgestream(sbm::StochasticBlockModel)
    pairs = Channel(random_pair(sbm.rng, sbm.n), ctype=SimpleEdge, csize=32)
    edges(ch) = begin
        for e in pairs
            i, j = Tuple(e)
            i == j && continue
            p = sbm.affinities[sbm.nodemap[i], sbm.nodemap[j]]
            if rand(sbm.rng) < p
                put!(ch, e)
            end
        end
    end
    return Channel(edges, ctype=SimpleEdge, csize=32)
end

"""
    SimpleGraph{T}(nv, ne, edgestream::Channel)

Construct a `SimpleGraph{T}` with `nv` vertices and `ne` edges from `edgestream`.
Can result in less than `ne` edges if the channel `edgestream` is closed prematurely.
Duplicate edges are only counted once.
The element type is the type of `nv`.
"""
function SimpleGraph(nvg::Integer, neg::Integer, edgestream::Channel)
    g = SimpleGraph(nvg)
    # println(g)
    for e in edgestream
        add_edge!(g, e)
        ne(g) >= neg && break
    end
    # println(g)
    return g
end

"""
    SimpleGraph{T}(nv, ne, smb::StochasticBlockModel)

Construct a random `SimpleGraph{T}` with `nv` vertices and `ne` edges.
The graph is sampled according to the stochastic block model `smb`.
The element type is the type of `nv`.
"""
SimpleGraph(nvg::Integer, neg::Integer, sbm::StochasticBlockModel) =
    SimpleGraph(nvg, neg, make_edgestream(sbm))

#TODO: this documentation needs work. sbromberger 20170326
"""
    blockcounts(sbm, A)

Count the number of edges that go between each block.
"""
function blockcounts(sbm::StochasticBlockModel, A::AbstractMatrix)
    I = collect(1:sbm.n)
    J =  [sbm.nodemap[i] for i in 1:sbm.n]
    V =  ones(sbm.n)
    Q = sparse(I, J, V)
    return (Q'A) * Q
end


function blockcounts(sbm::StochasticBlockModel, g::AbstractGraph)
    return blockcounts(sbm, adjacency_matrix(g))
end

function blockfractions(sbm::StochasticBlockModel, g::Union{AbstractGraph,AbstractMatrix})
    bc = blockcounts(sbm, g)
    bp = bc ./ sum(bc)
    return bp
end

"""
    kronecker(SCALE, edgefactor, A=0.57, B=0.19, C=0.19)

Generate a directed [Kronecker graph](https://en.wikipedia.org/wiki/Kronecker_graph)
with the default Graph500 parameters.

###
References
- http://www.graph500.org/specifications#alg:generator
"""
function kronecker(SCALE, edgefactor, A=0.57, B=0.19, C=0.19)
    N = 2^SCALE
    M = edgefactor * N
    ij = ones(Int, M, 2)
    ab = A + B
    c_norm = C / (1 - (A + B))
    a_norm = A / (A + B)

    for ib = 1:SCALE
        ii_bit = rand(M) .> (ab)  # bitarray
        jj_bit = rand(M) .> (c_norm .* (ii_bit) + a_norm .* .!(ii_bit))
        ij .+= 2^(ib - 1) .* (hcat(ii_bit, jj_bit))
    end

    p = randperm(N)
    ij = p[ij]

    p = randperm(M)
    ij = ij[p, :]

    g = SimpleDiGraph(N)
    for (s, d) in zip(@view(ij[:, 1]), @view(ij[:, 2]))
        add_edge!(g, s, d)
    end
    return g
end

"""
    dorogovtsev_mendes(n)

Generate a random `n` vertex graph by the Dorogovtsev-Mendes method (with `n \\ge 3`).

The Dorogovtsev-Mendes process begins with a triangle graph and inserts `n-3` additional vertices.
Each time a vertex is added, a random edge is selected and the new vertex is connected to the two 
endpoints of the chosen edge. This creates graphs with a many triangles and a high local clustering coefficient.

It is often useful to track the evolution of the graph as vertices are added, you can access the graph from
the `t`th stage of this algorithm by accessing the first `t` vertices with `g[1:t]`.

### References
- http://graphstream-project.org/doc/Generators/Dorogovtsev-Mendes-generator/
- https://arxiv.org/pdf/cond-mat/0106144.pdf#page=24

# Examples
```jldoctest
julia> dorogovtsev_mendes(10)
{10, 17} undirected simple Int64 graph

julia> dorogovtsev_mendes(11, seed=123)
{11, 19} undirected simple Int64 graph
```
"""
function dorogovtsev_mendes(n::Integer; seed::Int=-1)
    n < 3 && throw(DomainError("n=$n must be at least 3"))
    rng = getRNG(seed)
    g = CycleGraph(3)

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

"""
    random_orientation_dag(g)

Generate a random oriented acyclical digraph. The function takes in a simple
graph and a random number generator as an argument. The probability of each
directional acyclic graph randomly being generated depends on the architecture
of the original directed graph.

DAG's have a finite topological order; this order is randomly generated via "order = randperm()". 

# Examples
```jldoctest
julia> random_orientation_dag(CompleteGraph(10))
{10, 45} directed simple Int64 graph

julia> random_orientation_dag(StarGraph(Int8(10)), 123)
{10, 9} directed simple Int8 graph
```
"""
function random_orientation_dag(g::SimpleGraph{T}, seed::Int=-1) where T <: Integer
    nvg = length(g.fadjlist)
    rng = getRNG(seed)
    order = randperm(rng, nvg)
    g2 = SimpleDiGraph(nv(g))
    @inbounds for i in vertices(g)
        for j in outneighbors(g, i)
            if order[i] < order[j]
                add_edge!(g2, i, j)
            end
        end
    end
    return g2
end
