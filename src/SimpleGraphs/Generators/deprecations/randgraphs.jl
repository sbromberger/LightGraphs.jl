using Random:
    AbstractRNG, MersenneTwister, randperm, seed!, shuffle!
using Statistics: mean

using LightGraphs:
    getRNG, sample!


function erdos_renyi(n::Integer, p::Real; is_directed=false, seed::Integer=-1)
    Base.depwarn("`erdos_renyi(::Integer, ::Real)` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Binomial`.", :erdos_renyi)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = Binomial(n, p, rng=rng)
    return is_directed ? SimpleDiGraph(gen) : SimpleGraph(gen)
end

function erdos_renyi(n::Integer, ne::Integer; is_directed=false, seed::Integer=-1)
    Base.depwarn("`erdos_renyi(::Integer, ::Integer)` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.ErdosRenyi`.", :erdos_renyi)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    return is_directed ? SimpleDiGraph(n, ne, rng=rng) : SimpleGraph(n, ne, rng=rng)
end

function expected_degree_graph(ω::Vector{T}; seed::Int=-1) where T <: Real
    Base.depwarn("`expected_degree_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.ExpectedDegree`.", :expected_degree_graph)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = ExpectedDegree(ω, rng=rng)
    SimpleGraph(gen)
end


function watts_strogatz(n::Integer, k::Integer, β::Real; is_directed=false, seed::Int=-1)
    Base.depwarn("`watts_strogatz` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.WattsStrogatz`.", :watts_strogatz)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = WattsStrogatz(n, k, β, rng=rng)
    is_directed ? SimpleDiGraph(gen) : SimpleGraph(gen)
end

barabasi_albert(n::Integer, k::Integer; keyargs...) =
barabasi_albert(n, k, k; keyargs...)

function barabasi_albert(n::Integer, n0::Integer, k::Integer; is_directed::Bool=false, complete::Bool=false, seed::Int=-1)
    if complete
        g = is_directed ? SimpleDiGraph(Complete(n0)) : SimpleGraph(Complete(n0))
    else
        g = is_directed ? SimpleDiGraph(n0) : SimpleGraph(n0)
    end

    Base.depwarn("`barabasi_albert` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.BarabasiAlbert`.", :barabasi_albert)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = BarabasiAlbert(n, k, g, rng=rng)

    return is_directed ? SimpleDiGraph(gen) : SimpleGraph(gen)
end

function static_fitness_model(m::Integer, fitness::Vector{T}; seed::Int=-1) where T <: Real
    Base.depwarn("`static_fitness_model` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.StaticFitnessModel`.", :static_fitness_model)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = StaticFitnessModel(m, fitness, rng=rng)
    return SimpleGraph(gen)
end

function static_fitness_model(m::Integer, fitness_out::Vector{T}, fitness_in::Vector{S}; seed::Int=-1) where T <: Real where S <: Real
    Base.depwarn("`static_fitness_model` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.StaticFitnessModel`.", :static_fitness_model)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = StaticFitnessModel(m, fitness_out, fitness_in, rng=rng)
    return SimpleDiGraph(gen)
end

function static_scale_free(n::Integer, m::Integer, α::Real; seed::Int=-1, finite_size_correction::Bool=true)
    Base.depwarn("`static_scale_free` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.StaticScaleFree`.", :static_scale_free)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = StaticScaleFree(n, m, α, rng=rng)
    return SimpleGraph(gen)
end

function static_scale_free(n::Integer, m::Integer, α_out::Real, α_in::Float64; seed::Int=-1, finite_size_correction::Bool=true)
    Base.depwarn("`static_scale_free` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.StaticScaleFree`.", :static_scale_free)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = StaticScaleFree(n, m, αout, αin, rng=rng)
    return SimpleDiGraph(gen)
end

function random_regular_graph(n::Integer, k::Integer; seed::Int=-1)
    Base.depwarn("`random_regular_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.RandomRegular`.", :random_regular_graph)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = RandomRegular(n, k, rng=rng)
    return SimpleGraph(gen)
end

function random_configuration_model(n::Integer, k::Array{T}; seed::Int=-1, check_graphical::Bool=false) where T <: Integer
    Base.depwarn("`random_configuration_model` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.RandomConfigurationModel`.", :random_configuration_model)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = RandomConfigurationModel(n, k, check_graphical=check_graphical, rng=rng)
    return SimpleGraph(gen)
end

function random_regular_digraph(n::Integer, k::Integer; dir::Symbol=:out, seed::Int=-1)
    Base.depwarn("`random_regular_digraph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.RandomRegular`.", :random_regular_digraph)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    outbound = dir == :out
    gen = RandomRegular(n, k, outbound=outbound, rng=rng)
    return SimpleDiGraph(gen)
end

function random_tournament_digraph(n::Integer; seed::Int=-1)
    Base.depwarn("`random_tournament_digraph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Tournament`.", :random_tournament_digraph)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = Tournament(n, rng=rng)
    return SimpleDiGraph(gen)
end

function kronecker(SCALE, edgefactor, A=0.57, B=0.19, C=0.19; seed::Int=-1)
    Base.depwarn("`kronecker` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Kronecker`.", :kronecker)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = Kronecker(SCALE, edgefactor, A=A, B=B, C=C, rng=rng)
    return SimpleDiGraph(gen)
end

function dorogovtsev_mendes(n::Integer; seed::Int=-1)
    Base.depwarn("`dorogovtsev_mendes` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.DorogovtsevMendes`.", :dorogovtsev_mendes)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = DorogovtsevMendes(n, rng=rng)
    return SimpleGraph(gen)
end

function random_orientation_dag(g::SimpleGraph{T}, seed::Int=-1) where {T <: Integer}
    Base.depwarn("`random_orientation_dag` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.RandomOrientationDAG`.", :random_orientation_dag)
    rng = seed == -1 ? GLOBAL_RNG : MersenneTwister(seed)
    gen = RandomOrientationDAG(g, rng=rng)
    return SimpleDiGraph(gen)
end
