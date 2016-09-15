"""
Computes the edit distance between graphs G₁ and G₂.

Returns the minimum edit cost and edit path to transform graph
G₁ into graph G₂. An edit path consists of a sequence of pairs
of vertices (u,v) ∈ [0,|G₁|] × [0,|G₂|] representing vertex
operations:

- (0,v): insertion of vertex v ∈ G₂
- (u,0): deletion of vertex u ∈ G₁
- (u>0,v>0): substitution of vertex u ∈ G₁ by vertex v ∈ G₂

By default, the algorithm uses constant operation costs. The
user can provide classical Minkowski costs computed from vertex
labels μ₁ (for G₁) and μ₂ (for G₂) in order to further guide the
search, for example:

```
edit_distance(G₁, G₂, subst_cost=MinkowskiCost(μ₁, μ₂))
```

A custom heuristic can be provided to the A* search in case the
default heuristic is not satisfactory.

Performance tips:
-----------------
- Given two graphs |G₁| < |G₂|, `edit_distance(G₁, G₂)` is faster to
compute than `edit_distance(G₂, G₁)`. Consider swapping the arguments
if involved costs are ``symmetric''.
- The use of simple Minkowski costs can improve performance considerably.
- Exploit vertex attributes when designing operation costs.

For further details, please refer to:

RIESEN, K., 2015. Structural Pattern Recognition with Graph Edit
Distance: Approximation Algorithms and Applications. (Chapter 2)

Author: Júlio Hoffimann Mendes (juliohm@stanford.edu)
"""
function edit_distance(G₁::SimpleGraph, G₂::SimpleGraph;
                       insert_cost::Function=v->1.0,
                       delete_cost::Function=u->1.0,
                       subst_cost::Function=(u,v)->0.5,
                       heuristic::Function=DefaultEditHeuristic)

  # A* search heuristic
  h(λ) = heuristic(λ, G₁, G₂)

  # initialize open set
  OPEN = PriorityQueue(Vector{Tuple}, Float64)
  for v in 1:nv(G₂)
    enqueue!(OPEN, [(1,v)], subst_cost(1,v) + h([(1,v)]))
  end
  enqueue!(OPEN, [(1,0)], delete_cost(1) + h([(1,0)]))

  while true
    # minimum (partial) edit path
    λ, cost = Collections.peek(OPEN)
    dequeue!(OPEN)

    if is_complete_path(λ, G₁, G₂)
      return cost, λ
    else
      k, _ = λ[end]
      vs = setdiff(1:nv(G₂), [v for (u,v) in λ])

      if k < nv(G₁) # there are still vertices to process in G₁?
        for v in vs
          λ⁺ = [λ; (k+1,v)]
          enqueue!(OPEN, λ⁺, cost + subst_cost(k+1,v) + h(λ⁺) - h(λ))
        end
        λ⁺ = [λ; (k+1,0)]
        enqueue!(OPEN, λ⁺, cost + delete_cost(k+1) + h(λ⁺) - h(λ))
      else
        # add remaining vertices of G₂ to the path
        λ⁺ = [λ; [(0,v) for v in vs]]
        total_insert_cost = sum([insert_cost(v) for v in vs])
        enqueue!(OPEN, λ⁺, cost + total_insert_cost + h(λ⁺) - h(λ))
      end
    end
  end
end

function is_complete_path(λ, G₁, G₂)
  us = Set(); vs = Set()
  for (u,v) in λ
    push!(us, u)
    push!(vs, v)
  end
  delete!(us, 0)
  delete!(vs, 0)

  return length(us) == nv(G₁) && length(vs) == nv(G₂)
end

function DefaultEditHeuristic(λ, G₁::SimpleGraph, G₂::SimpleGraph)
  vs = Set()
  for (u,v) in λ
    push!(vs, v)
  end
  delete!(vs, 0)

  nv(G₂) - length(vs)
end

#-------------------------
# Edit path cost functions
#-------------------------

function MinkowskiCost(μ₁::AbstractVector, μ₂::AbstractVector; p::Real=1)
  (u,v) -> norm(μ₁[u] - μ₂[v], p)
end

function BoundedMinkowskiCost(μ₁::AbstractVector, μ₂::AbstractVector; p::Real=1, τ::Real=1)
  (u,v) -> 1 / (1/(2τ) + exp(-norm(μ₁[u] - μ₂[v], p)))
end
