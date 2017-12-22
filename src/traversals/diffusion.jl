"""
    diffusion(g, p, n)

Run diffusion simulation on `g` for `n` steps with spread
probabilities based on `p`. Return a vector with the set of new
vertices reached at each step of the simulation.

### Optional Arguments
- `initial_infections=sample(vertices(g), 1)`: A list of vertices that
are infected at the start of the simulation.
- `watch=Vector()`: While simulation is always run on the full graph,
specifying `watch` limits reporting to a specific set of vertices reached
during the simulation. If left empty, all vertices will be watched.
- `normalize=false`: if `false`, set the probability of spread from a vertex ``i`` to
each of the out_neighbors of ``i`` to ``p``. If `true`, set the probability of spread
from a vertex ``i`` to each of the `out_neighbors` of ``i`` to
``\\frac{p}{outdegreee(g, i)}``.
"""

function diffusion(g::AbstractGraph{T},
                   p::Real,
                   n::Integer;
                   watch::AbstractVector=Vector{Int}(),
                   initial_infections::AbstractVector=LightGraphs.sample(vertices(g), 1),
                   normalize::Bool=false
                   ) where T

    # Initialize
    watch_set = Set{T}(watch)
    infected_vertices = IntSet(initial_infections)
    vertices_per_step::Vector{Vector{T}} = [Vector{T}() for i in 1:n]

    # Record initial infection
    if !isempty(watch_set)
        watched_initial_infections = intersect(watch_set, initial_infections)
        vertices_per_step[1] = T.(collect(watched_initial_infections))
    else
        vertices_per_step[1] = T.(initial_infections)
    end

    # Run simulation
    randsubseq_buf = zeros(T, Δout(g))

    for step in 2:n
        new_infections = Set{T}()

        for i in infected_vertices
            outn = out_neighbors(g, i)
            outd = length(outn)

            if outd > 0
                if normalize
                    local_p = p / outdegree(g, i)
                else
                    local_p = p
                end

                randsubseq!(randsubseq_buf, outn, local_p)
                union!(new_infections, randsubseq_buf)
            end
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
diffusion_rate(g::AbstractGraph, p::Real, n::Integer;
    initial_infections::AbstractVector=LightGraphs.sample(vertices(g), 1),
    watch::AbstractVector=Vector{Int}(),
    normalize::Bool=false
    ) = diffusion_rate(
           diffusion(g, p, n,
           initial_infections=initial_infections,
           watch=watch, normalize=normalize
           )
)
