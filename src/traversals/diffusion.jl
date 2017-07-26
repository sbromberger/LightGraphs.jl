"""
    diffusion(g, p, num_steps)

Run diffusion simulation on `g` for `num_steps` steps with spread
probabilities based on `p`. Return a vector with the set of vertices
reached at each step of the simulation.

### Optional Arguments
- `initial_infections=sample(vertices(g), 1)`: A list of vertices that
are infected at the start of the simulation.
- `watch=Set()`: While simulation is always run on the full graph,
specifying `watch` limits reporting to a specific set of vertices reached
during the simulation. If left as an empty set, all vertices will be watched.
- `normalize=false`: if `false`, set the probability of spread from a vertex ``i`` to
each of the out_neighbors of ``i`` to ``p``. If `true`, set the probability of spread
from a vertex ``i`` to each of the `out_neighbors` of ``i`` to
``\\frac{p}{outdegreee(g, i)}``.
"""

function diffusion(g::AbstractGraph,
                   p::AbstractFloat,
                   num_steps::Integer;
                   watch::Set=Set(),
                   initial_infections::Set=Set(LightGraphs::sample(vertices(g), 1)),
                   normalize::Bool=false
                   )

    # Initialize
    T = eltype(g)
    watch_set = Set{T}(watch)
    infected_vertices = IntSet(initial_infections)
    vertices_per_step::Vector{Vector{T}} = [Vector{T}() for i in 1:num_steps]

    # Record initial infection
    if !isempty(watch_set)
        watched_initial_infections = intersect(initial_infections, watch_set)
        vertices_per_step[1] = T.(collect( watched_initial_infections ))
    else
        vertices_per_step[1] = T.(collect(initial_infections))
    end

    # Run simulation
    for step in 2:num_steps
        new_infections = Set{T}()

        for i in infected_vertices
            infect_neighbors(g, i, p, normalize, new_infections)
        end

        # Record only new infections
        setdiff!(new_infections, infected_vertices)
            if !isempty(watch_set)
                vertices_per_step[step] = T.(collect(intersect(new_infections, watch_set)))
            else
                vertices_per_step[step] = collect(new_infections)
            end

        # Add new to master set of infected
        union!(infected_vertices, new_infections)
    end

    return vertices_per_step
end

function infect_neighbors(g::AbstractGraph, i, p::AbstractFloat,
                          normalize::Bool,
                          new_infections::Set)

    if normalize
        local_p = convert(Float64, p / outdegree(g, i))::Float64
    else
        local_p = convert(Float64, p)::Float64
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
diffusion_rate(g::AbstractGraph, p, num_steps;
    initial_infections=Set(LightGraphs::sample(vertices(g), 1)),
    watch=Set(),
    normalize::Bool=false
    ) = diffusion_rate(
           diffusion(g, p, num_steps,
           initial_infections=initial_infections,
           watch=watch, normalize=normalize
           )
)
