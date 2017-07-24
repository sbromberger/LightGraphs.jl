
struct Diffusion{T}
  reached::Set{T}
  newly_reached::Set{T}
  to_watch::Set{T}
  p::Float64
  normalize_p::Bool
end

"""

    diffusion_simulation(g, p, num_steps;
                         to_watch=Set(vertices(g))
                         initial_at_risk=Set(vertices(g)),
                         normalize_p=false
                         )

### Implementation Notes

Runs diffusion simulation on `g` for `num_steps` with spread
probabilities based on `p`.

Returns an Array with number of vertices reached at each step of
simulation.

While simulation is always run on full graph, specifying `to_watch`
allows for reporting of the number of vertices reached within
a subpopulation.

If `normalized_p` is `false`, the probability of spread from a vertex i to
each of the out_neighbors of `i` is `p`.

If `normalized_p` is `true`, the probability of spread from a vertex `i` to
each of the out_neighbors of `i` is `p / degree(g, i)`.

"""

function diffusion_simulation(g::AbstractGraph,
                              p::Float64,
                              num_steps::Int64;
                              to_watch::Set=Set(vertices(g)),
                              initial_at_risk::Set=Set(vertices(g)),
                              normalize_p::Bool=false)

  # Check set types
  graph_vertex_type = eltype(vertices(g))

  to_watch::Set{T} where T <: graph_vertex_type
  initial_at_risk::Set{T} where T <: graph_vertex_type

  simulation = Diffusion{graph_vertex_type}(
                         Set{graph_vertex_type}(),
                         Set{graph_vertex_type}(),
                         to_watch,
                         p,
                         normalize_p)

  vertices_reached = zeros(Int64, num_steps)

  # Initiate
  initial_infection(simulation, initial_at_risk)

  # Run for num_steps
  for step in 1:num_steps
    for i in simulation.reached
      infect_neighbors(g, simulation, i)
    end

    # flip state vectors
    union!(simulation.reached, simulation.newly_reached)

    # Get infection rate
    vertices_reached[step] = length( intersect(simulation.reached, simulation.to_watch) )
  end

  return vertices_reached

end

function initial_infection(simulation::Diffusion, initial_at_risk::Set)
  i = rand(initial_at_risk)
  push!(simulation.reached, i)
end

function infect_neighbors(g::AbstractGraph, simulation::Diffusion, i)

  if simulation.normalize_p
    p = simulation.p / degree(g, i)
  else
    p= simulation.p
  end

  for n in out_neighbors(g, i)
    if rand(Float64) < p
      push!(simulation.newly_reached, n)
    end
  end

end
