abstract type RandomGenerator <: GraphGenerator end

"""
    struct Binomial <: RandomGenerator

A struct representing a generator for an [Erdős–Rényi](http://en.wikipedia.org/wiki/Erdős–Rényi_model)
random graph with `n` vertices. Edges are added between pairs of vertices with
probability `p`.

### Required Fields
- `n::Integer`: the number of vertices in the graph
- `p::Real`: the probability of edge creation (`0 < p ≤ 1`)

### Optional Arguments
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)
"""
struct Binomial{T<:Integer, U<:Real, R<:AbstractRNG} <: RandomGenerator
    n::T
    p::U
    rng::R
end
Binomial(n, p; rng=GLOBAL_RNG) = Binomial(n, p, rng)

"""
    struct ErdosRenyi <: RandomGenerator

Create a generator approximating an [Erdős–Rényi](http://en.wikipedia.org/wiki/Erdős–Rényi_model) random
graph with `n` vertices and `ne` edges.

### Required Fields
- `n::Integer`: the number of vertices in the graph
- `ne::Integer`: the number of edges in the graph

### Optional Arguments
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)
"""
struct ErdosRenyi{T<:Integer, U<:Integer, R<:AbstractRNG} <: RandomGenerator
    n::T
    ne::U
    rng::R
end
ErdosRenyi(n, ne; rng=GLOBAL_RNG) = ErdosRenyi(n, ne, rng)

"""
    struct ExpectedDegree <: RandomGenerator 

A struct representing a generator for a random undirected graph in which two vertices `i` and `j` are connected
with a probability (given by a vector of expected degrees `ω` indexed by vertex) of `ω[i]*ω[j]/sum(ω)`.

### Required Fields
- `ω::AbstractVector{<:Real}`: the probability vector for vertex connection

### Optional Arguments
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)

### References
- Connected Components in Random Graphs with Given Expected Degree Sequences, Linyuan Lu and Fan Chung. [https://link.springer.com/article/10.1007%2FPL00012580](https://link.springer.com/article/10.1007%2FPL00012580)
- Efficient Generation of Networks with Given Expected Degrees, Joel C. Miller and Aric Hagberg. [https://doi.org/10.1007/978-3-642-21286-4_10](https://doi.org/10.1007/978-3-642-21286-4_10)
"""
struct ExpectedDegree{T<:Real, U<:AbstractVector{T}, R<:AbstractRNG} <: RandomGenerator
    ω::U
    rng::R
end
ExpectedDegree(ω; rng=GLOBAL_RNG) = ExpectedDegree(ω, rng)

"""
    struct WattsStrogatz <: RandomGenerator

A struct representing a generator for a [Watts-Strogatz](https://en.wikipedia.org/wiki/Watts_and_Strogatz_model)
small model random graph with `n` vertices, each with degree `k`. Edges are
randomized per the model based on probability `β`.

### Required Fields
- `n::Integer`: the number of vertices in the graph
- `k::Integer`: the number of edges per vertex
- `β::Real`: the probability of edge randomization (`0 < β ≤ 1`)

### Optional Arguments
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)
"""
struct WattsStrogatz{T<:Integer, U<:Integer, V<:Real, R<:AbstractRNG} <: RandomGenerator
    n::T
    k::U
    β::V
    rng::R
end
WattsStrogatz(n, k, β; rng=GLOBAL_RNG) = WattsStrogatz(n, k, β, rng)

"""
    struct BarabasiAlbert <: RandomGenerator

A struct representing a generator for a [Barabási–Albert model](https://en.wikipedia.org/wiki/Barab%C3%A1si%E2%80%93Albert_model)
random graph with `n` vertices. It is grown by adding new vertices to an initial graph `g` with `k`
vertices). Each new vertex is attached with `k` edges to `k` different vertices already present in
the system by preferential attachment. Initial graphs are undirected and consist of isolated
vertices by default.

### Required Fields
- `n::Integer`: the number of vertices in the final graph
- `k::Integer`: the number of edges preferentially attached per vertex
- `g::AbstractGraph`: an initial graph

### Optional Arguments
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)

### Implementation Notes
`g`, if specified, MUST be convertible to the same type as the constructor using this generator.
"""
struct BarabasiAlbert{T<:Integer, AG<:AbstractGraph{T}, R<:AbstractRNG} <: RandomGenerator
    n::T
    k::T
    g::AG
    rng::R
    function BarabasiAlbert(n::T, k::T, g::AG, rng::R) where {T<:Integer, AG<:AbstractGraph{T}, R<:AbstractRNG}
        1 <= k <= nv(g) <= n || throw(ArgumentError("Barabási-Albert model requires 1 <= k <= nv(g) <= n"))
        new{T, AG, R}(n, k, g, rng)
    end
end
BarabasiAlbert(n, k, g; rng=GLOBAL_RNG) = BarabasiAlbert(n, k, g, rng)

"""
    struct StaticFitnessModel <: RandomGenerator 

### For undirected graphs:
A struct representing a generator for a random graph with ``|fitness_out|`` vertices and `m` edges,
in which the probability of the existence of an outbound edge between `i` and `j` is proportional to
``fitness_i × fitness_j``.

### For directed graphs:
A struct representing a generator for a random directed graph with ``|fitness\\_out + fitness\\_in|`` vertices
and `m` edges, in which the probability of the existence of an edge between `i` and `j` is proportional with
respect to ``i ∝ fitness\\_out`` and ``j ∝ fitness\\_in``.


### Required Fields
- `m::Integer`: the number of edges in the graph
- `fitness_out::AbstractVector{<:Real}`: a vector of probabilities for outbound edges, indexed by vertex

### Optional Arguments
- `fitness_in::AbstractVector{<:Real}`: a vector of probabilities for inbound edges, indexed by vertex (default: `fitness_out`)
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)

### Performance
Time complexity is ``\\mathcal{O}(|V| + |E| log |E|)``.

### References
- Goh K-I, Kahng B, Kim D: Universal behaviour of load distribution in scale-free networks. Phys Rev Lett 87(27):278701, 2001.
"""
struct StaticFitnessModel{T<:Integer, U<:Real, V<:AbstractVector{U}, R<:AbstractRNG} <: RandomGenerator
    m::T
    fitness_out::V
    fitness_in::V
    rng::R
    function StaticFitnessModel(m::T, fitness_out::V, fitness_in::V, rng::R) where {T<:Integer, U<:Real, V<:AbstractVector{U}, R<:AbstractRNG}
        m >= 0 || throw(ArgumentError("number of edges must be positive"))
        length(fitness_out) == length(fitness_in) || throw(ArgumentError("inbound and outbound fitness scores must have the same length"))
        To = eltype(fitness_out)
        Ti = eltype(fitness_in)
        for i = 1:length(fitness_out)
            fitness_out[i] > zero(To) || throw(ArgumentError("fitness scores must be non-negative"))
            fitness_in[i] > zero(Ti) || throw(ArgumentError("fitness scores must be non-negative"))
        end
        new{T, U, V, R}(m, fitness_out, fitness_in, rng)
    end

end
StaticFitnessModel(m, fitness_out; fitness_in=fitness_out, rng=GLOBAL_RNG) = StaticFitnessModel(m, fitness_out, fitness_in, rng)
StaticFitnessModel(m, fitness_out, fitness_in; rng=GLOBAL_RNG) = StaticFitnessModel(m, fitness_out, fitness_in, rng)

"""
    struct StaticScaleFree <: RandomGenerator

### For undirected graphs:
A struct representing a generator for a random graph with `n` vertices, `m` edges and expected power-law
degree distribution with exponent `αout`.

### For directed graphs:
A struct representing a generator for a random graph with `n` vertices, `m` edges and expected outbound power-law
degree distribution with exponent `αout` and optional inbound power-law degree distribution with exponent `αin`.
#
### Required Fields
- `n::Integer`: the number of vertices in the graph
- `m::Integer`: the number of edges in the graph
- `αout::Real`: The exponent of the expected power-law degree distribution for outbound edges

### Optional Arguments
- `αin::Real`: The exponent of the expected power-law degree distribution for inbound edges (default `αout`)
- `finite_size_correction::Bool`: determines whether to use the finite size correction proposed by Cho et al. (default `true`)
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)

### Performance
Time complexity is ``\\mathcal{O}(|V| + |E| log |E|)``.

### References
- Goh K-I, Kahng B, Kim D: Universal behaviour of load distribution in scale-free networks. Phys Rev Lett 87(27):278701, 2001.
- Chung F and Lu L: Connected components in a random graph with given degree sequences. Annals of Combinatorics 6, 125-145, 2002.
- Cho YS, Kim JS, Park J, Kahng B, Kim D: Percolation transitions in scale-free networks under the Achlioptas process. Phys Rev Lett 103:135702, 2009.
"""
struct StaticScaleFree{T<:Integer, U<:Integer, V<:Real, R<:AbstractRNG} <: RandomGenerator
    n::T
    m::U
    αout::V
    αin::V
    finite_size_correction::Bool
    rng::R
    function StaticScaleFree(n::T, m::U, αout::V, αin::V, finite_size_correction::Bool, rng::R) where
        {T<:Integer, U<:Integer, V<:Real, R<:AbstractRNG}

        n < 0 && throw(ArgumentError("number of vertices must be positive"))
        αout < 2 && throw(ArgumentError("outdegree exponent must be >= 2"))
        αin < 2 && throw(ArgumentError("indegree exponent must be >= 2"))
        new{T, U, V, R}(n, m, αout, αin, finite_size_correction, rng)
    end
end

StaticScaleFree(n, m, αout; αin=αout, finite_size_correction=true, rng=GLOBAL_RNG) =
    StaticScaleFree(n, m, αout, αin, finite_size_correction, rng)

StaticScaleFree(n, m, αout, αin; finite_size_correction=true, rng=GLOBAL_RNG) =
    StaticScaleFree(n, m, αout, αin, finite_size_correction, rng)

"""
    struct RandomRegular <: RandomGenerator 

A struct representing a generator for a random [regular graph](https://en.wikipedia.org/wiki/Regular_graph)
with `n` vertices, each with degree `k`. For directed graphs, an optional `outbound` variable indicates whether
the degree is for outbound or inbound edges.

### Required Fields
- `n::Integer`: the number of vertices in the graph
- `k::Integer`: the degree for each vertex in the graph

### Optional Arguments
- `outbound::Bool`: If `true`, `k` represents the outdegree. Otherwise, `k` represents the indegree. (Default: `true`)
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)

### Performance
Time complexity is approximately ``\\mathcal{O}(nk^2)``.

### Implementation Notes
For undirected graphs, allocates an array of `nk` `Int`s, and . For ``k > \\frac{n}{2}``, generates a graph of degree
``n-k-1`` and returns its complement.
For directed graphs, allocates an ``n × n`` sparse matrix of boolean as an adjacency matrix and uses that to generate
the graph.
"""
struct RandomRegular{T<:Integer, U<:Integer, R<:AbstractRNG}
    n::T
    k::U
    outbound::Bool
    rng::R
    function RandomRegular(n::T, k::U, outbound::Bool, rng::R) where {T<:Integer, U<:Integer, R<:AbstractRNG}

        !(0 <= k < n) && throw(ArgumentError("the 0 <= k < n inequality must be satisfied"))
        new{T, U, R}(n, k, outbound, rng)
    end
end
RandomRegular(n, k; outbound=true, rng=GLOBAL_RNG) = RandomRegular(n, k, outbound, rng)

"""
    struct RandomConfigurationModel <: RandomGenerator

A struct representing a generator for a random graph constructed according to the
[configuration model] (http://tuvalu.santafe.edu/~aaronc/courses/5352/fall2013/csci5352_2013_L11.pdf)
containing `n` vertices, with each node `i` having degree `k[i]`.

### Required Fields
- `n::Integer`: the number of vertices in the graph
- `k::AbstractVector{<:Integer}`: a vector with values representing the degree of the vertex represented by its index.

### Optional Arguments
- `check_graphical::Bool`: if `true`, ensure that `k` is a graphical sequence (see
[`LightGraphs.Connectivity.is_graphical`](@ref)) (default: `false`)
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)

### Performance
Time complexity is approximately ``\\mathcal{O}(n \\bar{k}^2)``.

### Implementation Notes
Allocates an array of ``n \\bar{k}`` `Int`s.
"""
struct RandomConfigurationModel{T<:Integer, U<:AbstractVector{T}, R<:AbstractRNG} <: RandomGenerator
    n::T
    k::U
    rng::R
    function RandomConfigurationModel(n::T, k::U, check_graphical::Bool, rng::R) where
        {T<:Integer, U<:AbstractVector{T}, R<:AbstractRNG}

        n != length(k) && throw(ArgumentError("a degree sequence of length n must be provided"))
        all(0 .<= k .< n) || throw(ArgumentError("the 0 <= k[i] < n inequality must be satisfied"))
        (check_graphical && !is_graphical(k)) && throw(ArgumentError("degree sequence must be graphical"))
        new{T, U, R}(n, k, rng)
    end

end
RandomConfigurationModel(n, k; check_graphical=false, rng=GLOBAL_RNG) = RandomConfigurationModel(n, k, check_graphical, rng)


"""
    struct Tournament <: RandomGenerator

Create a random [tournament graph] (https://en.wikipedia.org/wiki/Tournament_%28graph_theory%29)
with `n` vertices.

### Required Fields
- `n::Integer`: the number of vertices in the graph

### Optional Arguments
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)
"""
struct Tournament{T<:Integer, R<:AbstractRNG} <: RandomGenerator
    n::T
    rng::R
end
Tournament(n; rng=GLOBAL_RNG) = Tournament(n, rng)

"""
    struct Kronecker <: RandomGenerator

    kronecker(SCALE, edgefactor, A=0.57, B=0.19, C=0.19; seed=-1)

Generate a directed [Kronecker graph](https://en.wikipedia.org/wiki/Kronecker_graph)
with a given `SCALE` and `edgefactor` and the default Graph500 parameters.

### Required Fields
- `SCALE::Integer`: The scale of the graph to produce
- `edgefactor::Integer`: the average degree of a node in the graph

### Optional Parameters
- `A::Real`: probability of edge in partition A (default `0.57`)
- `B::Real`: probability of edge in partition B (default `0.19`)
- `C::Real`: probability of edge in partition C (default `0.19`)
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)

###
References
- http://www.graph500.org/specifications#alg:generator
"""
struct Kronecker{T<:Integer, U<:Real, R<:AbstractRNG} <: RandomGenerator
    SCALE::T
    edgefactor::T
    A::U
    B::U
    C::U
    rng::R
end

Kronecker(SCALE, edgefactor; A=0.57, B=0.19, C=0.19, rng=GLOBAL_RNG) = Kronecker(SCALE, edgefactor, A, B, C, rng)

"""
    struct DorogovtsevMendes <: RandomGenerator dorogovtsev_mendes(n)

A struct representing a generator for random `n` vertex graph using the Dorogovtsev-Mendes method (with `n \\ge 3`).

The Dorogovtsev-Mendes process begins with a triangle graph and inserts `n-3` additional vertices.
Each time a vertex is added, a random edge is selected and the new vertex is connected to the two
endpoints of the chosen edge. This creates graphs with a many triangles and a high local clustering coefficient.

It is often useful to track the evolution of the graph as vertices are added, you can access the graph from
the `t`th stage of this algorithm by accessing the first `t` vertices with `g[1:t]`.

### Required Fields
- `n::Integer`: The number of vertices in the graph

### Optional Parameters
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)

### References
- http://graphstream-project.org/doc/Generators/Dorogovtsev-Mendes-generator/
- https://arxiv.org/pdf/cond-mat/0106144.pdf#page=24
"""
struct DorogovtsevMendes{T<:Integer, R<:AbstractRNG} <: RandomGenerator
    n::T
    rng::R
    function DorogovtsevMendes(n::T, rng::R) where {T<:Integer, R<:AbstractRNG}
        n < 3 && throw(DomainError("n=$n must be at least 3"))
        new{T, R}(n, rng)
    end
end
DorogovtsevMendes(n; rng=GLOBAL_RNG) = DorogovtsevMendes(n, rng)

"""
    struct RandomOrientationDAG <: RandomGenerator

Generate a random oriented acyclical digraph. The function takes in a simple
graph and an optional random number generator as an argument. The probability
of each directional acyclic graph randomly being generated depends on the
architecture of the original directed graph.

### Required Fields
- `g::AbstractGraph`: the original graph

### Optional Parameters
- `rng::AbstractRNG`: set the random number generator (default: `Random.GLOBAL_RNG`)

### Implementation Notes
- The graph `g` does not have to be of the same type as the output.
- DAG's have a finite topological order; this order is randomly generated via "order = randperm()".
"""
struct RandomOrientationDAG{T<:Integer, AG<:AbstractGraph{T}, R<:AbstractRNG} <: RandomGenerator
    g::AG
    rng::R
end
RandomOrientationDAG(g; rng=GLOBAL_RNG) = RandomOrientationDAG(g, rng)
