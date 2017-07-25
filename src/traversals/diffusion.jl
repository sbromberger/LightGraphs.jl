"""
    diffusion(g, p, n)

Run diffusion simulation on `g` for `n` steps with spread
probabilities based on `p`. Return a vector with the set of vertices
reached at each step of the simulation.

### Optional Arguments
- `initial_infections=sample(vertices(g), 1)`: A list of vertices that
are infected at the start of the simulation.
- `watch=vertices(g)`: While simulation is always run on the full graph,
specifying `watch` limits reporting to a specific set of vertices reached
during the simulation.
- `normalize=false`: if `false`, set the probability of spread from a vertex ``i`` to
each of the out_neighbors of ``i`` to ``p``. If `true`, set the probability of spread
from a vertex ``i`` to each of the `out_neighbors` of ``i`` to ``\\frac{p}{out_degreee(g, i)}``.
"""

function diffusion(g::AbstractGraph,
                   p::AbstractFloat,
                   num_steps::Integer;
                   watch::Set=Set(vertices(g)),
                   initial_infections::Set=Set(LightGraphs::sample(vertices(g), 1)),
                   normalize::Bool=false
                   )

    # Initialize
    T = eltype(g)
    watch_set = Set{T}(watch)
    infected_vertices = IntSet(initial_infections)
    vertices_per_step = [Vector{T}() for i in 1:num_steps]

    # Record initial infection
    vertices_per_step[1] = collect(infected_vertices)

    # Run simulation
    for step in 2:num_steps
        new_infections = Set{T}()

        for i in infected_vertices
            infect_neighbors(g, i, p, normalize, new_infections)
        end

        # Record only new infections
        setdiff!(new_infections, infected_vertices)
        vertices_per_step[step] = collect(intersect(new_infections, watch_set))

        # Add new to master set of infected
        union!(infected_vertices, new_infections)
    end

    return vertices_per_step
end

function infect_neighbors(g, i, p, normalize, new_infections)
    if normalize
        local_p = p / out_degree(g, i)
    else
        local_p = p
    end

    union!(new_infections, randsubseq(out_neighbors(g, i), local_p))
end

"""
    diffusion_rate(results)
    diffusion_rate(g, p, n; ...)
Given the results of a `diffusion` output or the parameters
to the `diffusion` simulation itself, (run and) return the rate of
diffusion as a vector representing the cumulative number of vertices
infected at each simulation step, restricted to vertices included
in `watch`, if specified.
"""
diffusion_rate(x::Vector{Vector{T}}) where T <: Integer = cumsum(length.(x))
diffusion_rate(g::AbstractGraph, p, n;
    initial_infections=LightGraphs.sample(vertices(g), 1),
    watch=vertices(g),
    normalize::Bool=false
    ) = diffusion_rate(
           diffusion(g, p, n,
           initial_infections=initial_infections,
           watch=watch, normalize=normalize
           )
)
