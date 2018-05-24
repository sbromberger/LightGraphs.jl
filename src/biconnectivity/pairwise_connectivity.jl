"""
    bfs_get_path(g, u, v)

Modification of has_path(g, u, v)
Returns the path from `u` to `v` (not including `u` and `v`) if it exists.
Else, it returns an empty vector.
"""
function bfs_get_path(g::AbstractGraph{T}, u::Integer, v::Integer; 
        exclude_vertices::AbstractVector = Vector{T}()) where T
    
    seen = zeros(Bool, nv(g))
    for ve in exclude_vertices # mark excluded vertices as seen
        seen[ve] = true
    end
    parents = zeros(T, nv(g))

    next = Vector{T}()
    push!(next, u)
    seen[u] = true
    while !isempty(next)
        src = popfirst!(next) # get new element from queue
        for vertex in outneighbors(g, src)
            if !seen[vertex]
                push!(next, vertex) # push onto queue
                seen[vertex] = true
                parents[vertex] = src
                (vertex == v) && break
            end
        end
        seen[v] && break
    end
    !seen[v] && (return Vector{T}())

    vertex = parents[v]
    path = Vector{T}()
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
	s, t
	) where T <: Integer

	if s == t || has_edge(g, s, t) #Cannot be disconnected by vertex removal
		return typemax(T)
	end

	nvg = nv(g)
	deleted = zeros(Bool, nvg)
	connectivity = zero(T)
	excluded = Vector{T}()

	while true
		path = bfs_get_path(g, s, t, exclude_vertices=excluded)
		size(path)[1] == 0 && break
		connectivity += one(T)
		for v in path
			push!(excluded, v)
		end
	end
	return connectivity
end
