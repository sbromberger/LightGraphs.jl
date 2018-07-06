"""
	bfs_augment!(g, s, partner, parents)

Finds an augmenting path starting from s using BFS.
Assumes `s` is a unpartnered vertex.
### Implementation Notes
if partner[u] = 0 then u is an unpartnered vertex. 
Returns the final (unpartnered) vertex of the path.
"""
function bfs_augment!(g::AbstractGraph{T}, s::T,
	partner::Vector{T}, parents::Vector{T}
	) where {T<:Integer}

    nvg = nv(g)
    visited = falses(nvg)
    cur_level = Vector{T}()
    sizehint!(cur_level, nvg)
    next_level = Vector{T}()
    sizehint!(next_level, nvg)

    push!(cur_level, s)
    while !isempty(cur_level)
        for v in cur_level
            for i in  neighbors(g, v)
            	(visited[i] || i == partner[v]) && continue

                parents[i] = v
                p = partner[i]
                if p == zero(T) #i is unpartnered
                	return i
                end
                push!(next_level, p)
                visited[p] = true
            end
        end
        empty!(cur_level)
        cur_level, next_level = next_level, cur_level
    end
    return zero(T)
end

"""
	augment_graph!(g, partner, parents, t)

Augment the part ending at from the graph containing the vertices of `g`
and the predecessor relation using `parents`. 
"""
function augment_path!(g::AbstractGraph{T},
	partner::Vector{T}, parents::Vector{T}, t::T
) where {T <: Integer}

	v = t
	while v != zero(T)
		p = parents[v]
		tmp_pp = partner[p]
		partner[v] = p
		partner[p] = v
		v = tmp_pp
	end
end

"""
    augment_matching(g, init_matching=Vector())

Algorithm to improve (Increase the size of) a `init_matching`.
Performs path augmentation repeatedly to increase the size of the matching until it converges
to the optimal solution. The number of iterations can be bounded by `reps_augment`. 
### Implementation Notes
It assumes `init_matching` is a valid matching. 
i.e. Each edge in `init_matching` is present in `g` and no two edges have a common end point.
### Performance
Each augmentation iteration takes O(|V|*(|V|+|E|)) time.
"""
function augment_matching(g::AbstractGraph{T},
	init_matching=Vector{Edge}();
	reps_augment::Integer=div(nv(g), 2),
	) where T <: Integer 

	nvg = nv(g)
	partner = zeros(T, nvg)
	for e in init_matching
		partner[e.dst] = e.src
		partner[e.src] = e.dst
	end
	unpartnered = Vector{T}()
	sizehint!(unpartnered, nvg-size(init_matching)[1])
	for v in vertices(g)
		if partner[v] == zero(T)
			push!(unpartnered, v)
		end
	end
	Random.shuffle!(unpartnered)
	
	parents = zeros(T, nvg)
	for num_it in 1:reps_augment
		(size(unpartnered)[1]< 2) && break
		t = s = zero(T)
		for v in unpartnered
			t = bfs_augment!(g, v, partner, parents)
			if t != zero(T)
				s = v
				break
			end
		end
		if t == zero(T)
			break
		else
			filter!(e->!(e in [s, t]), unpartnered)
			augment_path!(g, partner, parents, t)
		end
	end
	matching = Vector{Edge}()
	for v in vertices(g)
		p = partner[v]
		if p != zero(T) && p < v
			push!(matching, Edge(p, v))
		end 
	end
	return matching
end
