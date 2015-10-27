"""Performs a random walk on graph `g` starting at vertex `s` and continuing for
a maximum of `niter` steps. Returns a vector of vertices visited in order.
"""
function randomwalk(g::SimpleGraph, s::Integer, niter::Integer)
  s in vertices(g) || throw(BoundsError())
  visited = Vector{Int}()
  sizehint!(visited, niter)
  currs = s
  i = 1
  while i <= niter
    push!(visited, currs)
    i += 1
    nbrs = out_neighbors(g,currs)
    length(nbrs) == 0 && break
    currs = rand(nbrs)
  end
  return visited[1:i-1]
end

"""Performs a [self-avoiding walk](https://en.wikipedia.org/wiki/Self-avoiding_walk)
on graph `g` starting at vertex `s` and continuing for a maximum of `niter` steps.
Returns a vector of vertices visited in order.
"""
function saw(g::SimpleGraph, s::Integer, niter::Integer)
  s in vertices(g) || throw(BoundsError())
  visited = Vector{Int}()
  svisited = Set{Int}()
  sizehint!(visited, niter)
  sizehint!(svisited, niter)
  currs = s
  i = 1
  while i <= niter
    push!(visited, currs)
    push!(svisited, currs)
    i += 1
    nbrs = setdiff(Set(out_neighbors(g,currs)),svisited)
    length(nbrs) == 0 && break
    currs = rand(collect(nbrs))
  end
  return visited[1:i-1]
end
