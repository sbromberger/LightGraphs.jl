"""
    bfs_get_path(g, u, v)

Modification of has_path(g, u, v)
Returns the path from `u` to `v` (not including `u` and `v`) if it exists.
Else, it returns an empty vector.

### Notes
It assumes that `s` and `t` are the vertices of a `g`.
"""
function bfs_get_path(g::AbstractGraph{T}, u::Integer, v::Integer; 
        exclude_vertices::AbstractVector = Vector{T}()) where T
    
    seen = zeros(Bool, nv(g))
    @inbounds @simd for ve in exclude_vertices # mark excluded vertices as seen
        seen[ve] = true
    end
    parents = zeros(T, nv(g))

    next = Vector{T}()
    sizehint!(next, nv(g))
    push!(next, u)
    seen[u] = true
    @inbounds while !isempty(next)
        src = popfirst!(next) # get new element from queue
        @inbounds @simd for vertex in outneighbors(g, src)
            if !seen[vertex]
                push!(next, vertex) # push onto queue
                seen[vertex] = true
                parents[vertex] = src
            end
        end
        seen[v] && break
    end
    !seen[v] && (return Vector{T}())

    vertex = parents[v]
    path = Vector{T}()
    sizehint!(path, nv(g))
    while vertex != u
    	push!(path, vertex)
    	vertex = parents[vertex]
    end

    return reverse(path)
end

"""
	lower_bound_pairwise_connectivity(g, s, t)

Obtain a lower bound on the number of vertices (other than `s` and `t`) that must be removed from
`g` to disconnect `s` and `t`.

### Implementation Notes
Perform [Lower Bound Pairwise Connectivity](http://eclectic.ss.uci.edu/~drwhite/working.pdf).
"""
function lower_bound_pairwise_connectivity(
	g::AbstractGraph{T},
	s::Integer, 
    t::Integer
	) where T <: Integer

    nvg = nv(g)
	if !has_vertex(g, s) || !has_vertex(g, t) || s == t || has_edge(g, s, t)
		return typemax(T)
	end

	deleted = zeros(Bool, nvg)
	connectivity = zero(T)
	excluded = Vector{T}()
    sizehint!(excluded, nvg)

	while true
		path = bfs_get_path(g, s, t, exclude_vertices=excluded) #s and t are valid
		size(path)[1] == 0 && break
		connectivity += one(T)
		for v in path
			push!(excluded, v)
		end
	end
	return connectivity
end
