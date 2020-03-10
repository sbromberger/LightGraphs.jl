"""
    struct Coloring{T}

Store the number of colors used and mapping from vertex to color
"""
struct Coloring{T <: Integer}
    num_colors::T
    colors::Vector{T}
end

"""
    abstract type ColoringAlgorithm

An abstract type representing an algorithm to be used for [`greedy_color`(@ref)].
"""
abstract type ColoringAlgorithm end

"""
    struct FixedColoring <: ColoringAlgorithm

A struct representing a [`ColoringAlgorithm`](@ref) that colors a graph iteratively using
a given vertex ordering function.

### Required Arguments
- `ordering::Function g->iterable`: the function to use to order the vertices.
sortest degree).
"""
struct FixedColoring{F} <: ColoringAlgorithm
    ordering::F
end
FixedColoring(; ordering::AbstractVector) = FixedColoring(_ -> ordering)

"""
    DegreeColoring

A function that creates a [`FixedColoring`](@ref) that colors a graph iteratively in
descending order of the degree of the vertices.
"""
DegreeColoring() = FixedColoring(g -> sortperm(degree(g), rev = true))

"""
    struct RandomColoring <: ColoringAlgorithm

A struct representing a [`ColoringAlgorithm`](@ref) that colors a graph iteratively in
random order using a greedy heuristic, choosing the best coloring out of a number of
such random colorings.

### Optional Arguments
- `niter::Int`: the number of times the random coloring should be repeated (default `1`).
- `rng::AbstractRNG`: a random number generator (default `Random.GLOBAL_RNG`)
"""
struct RandomColoring{T <: Integer, R <: AbstractRNG} <: ColoringAlgorithm
    niter::T
    rng::R
end
RandomColoring(; niter = 1, rng = GLOBAL_RNG) = RandomColoring(niter, rng)

best_color(c1::Coloring, c2::Coloring) = c1.num_colors < c2.num_colors ? c1 : c2

"""
    fixed_greedy_color(g, seq)

Color graph `g` according to an order specified by `seq` using a greedy heuristic.
`seq[i] = v` implies that vertex v is the ``i^{th}`` vertex to be colored.
"""
function fixed_greedy_color(g::AbstractGraph{T}, seqfn::Function)::Coloring{T} where {T <: Integer}
    nvg::T = nv(g)
    cols = Vector{T}(undef, nvg)
    seen = zeros(Bool, nvg + 1)

    for v in seqfn(g)
        v = T(v)
        seen[v] = true
        colors_used = zeros(Bool, nvg)

        for w in neighbors(g, v)
            if seen[w]
                colors_used[cols[w]] = true
            end
        end

        for i in one(T):nvg
            if colors_used[i] == false
                cols[v] = i
                break
            end
        end
    end
    return Coloring{T}(maximum(cols), cols)
end

# if we pass in a sequence.
fixed_greedy_color(g, seq) = fixed_greedy_color(g, _ -> seq)

"""
    random_greedy_color(g, niter, rng)

Color the graph `g` iteratively in a random order using a greedy heuristic
and random number generator `rng`, and choose the best coloring out of
`niter` such random colorings.
"""
function random_greedy_color(
    g::AbstractGraph{T},
    niter::Integer,
    rng::AbstractRNG,
) where {T <: Integer}
    seq = shuffle(rng, vertices(g))
    best = fixed_greedy_color(g, seq)

    for i in 2:niter
        shuffle!(rng, seq)
        best = best_color(best, fixed_greedy_color(g, seq))
    end
    return best
end

"""
   greedy_color(g, alg)

Color graph `g` based on [Greedy Coloring Heuristics](https://en.wikipedia.org/wiki/Greedy_coloring)
using [`ColoringAlgorithm`](@ref) `alg`.

The heuristics can be described as choosing a permutation of the vertices and assigning the 
lowest color index available iteratively in that order.
"""
greedy_color(g::AbstractGraph, alg::FixedColoring) = fixed_greedy_color(g, alg.ordering)
greedy_color(g::AbstractGraph, alg::RandomColoring) = random_greedy_color(g, alg.niter, alg.rng)

greedy_color(g::AbstractGraph) = greedy_color(g, RandomColoring())
