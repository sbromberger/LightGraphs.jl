"""
Community detection using the label propagation algorithm (see [Raghavan et al.](http://arxiv.org/abs/0709.2938)).
`g`: imput Graph
`maxiter`: optional, maximum iterations
return : array containing vertex assignments, the range of the output as 1:countdistinct(membership)
"""
function label_propagation(g::SimpleGraph; maxiter=1000, verbose=false)
    n = nv(g)
    membership = collect(1:n)
    active_nodes = IntSet(vertices(g))
    nc = NeighComm(collect(1:n), fill(-1,n), 1)
    i = 1
    while !isempty(active_nodes) && i < maxiter
    	if verbose
    		println("iteration: ", i, ", ", length(active_nodes), " active nodes")
    	end
    	i += 1
        random_order = shuffle(collect(active_nodes))
        for u in random_order
          old_comm = membership[u]
          membership[u] = vote!(g, membership, nc, u)
            if old_comm != membership[u]
                for v in out_neighbors(g, u)
                    push!(active_nodes, v)
                end
            else
                delete!(active_nodes, u)
            end
        end
    end
    # resue nc.neigh_pos to renumber labels
    fill!(nc.neigh_pos, 0)
    renumber_labels!(membership, nc.neigh_pos)
    membership
end

"""Fast shuffle Array `a` in UnitRange `r` inplace."""
function range_shuffle!(r::UnitRange, a::AbstractVector)
	for i=length(r):-1:2
		j = rand(1:i)
		ii = i + r.start - 1
		jj = j + r.start - 1
		a[ii],a[jj] = a[jj],a[ii]
	end
end

"""Type to record neighbor labels and their counts."""
type NeighComm
	neigh_pos::Vector{Int}
	neigh_cnt::Vector{Int}
	neigh_last::Int
end

"""Return the most frequency label."""
function vote!(g::SimpleGraph, membership::Vector{Int}, nc::NeighComm, u::Int)
    for i=1:nc.neigh_last-1
        nc.neigh_cnt[nc.neigh_pos[i]] = -1
    end
    nc.neigh_last = 1
    nc.neigh_pos[1] = membership[u]
    nc.neigh_cnt[nc.neigh_pos[1]] = 0
    nc.neigh_last = 2
    max_cnt = 0
    for neigh in out_neighbors(g,u)
        neigh_comm = membership[neigh]
        if nc.neigh_cnt[neigh_comm] < 0
            nc.neigh_cnt[neigh_comm] = 0
            nc.neigh_pos[nc.neigh_last] = neigh_comm
            nc.neigh_last += 1
        end
        nc.neigh_cnt[neigh_comm] += 1
        if nc.neigh_cnt[neigh_comm] > max_cnt
          max_cnt = nc.neigh_cnt[neigh_comm]
        end
    end
    # ties breaking randomly
    range_shuffle!(1:nc.neigh_last-1, nc.neigh_pos)
    for lbl in nc.neigh_pos
      if nc.neigh_cnt[lbl] == max_cnt
        return lbl
      end
    end
end

function renumber_labels!(membership::Vector{Int}, label_counters::Vector{Int})
    N = length(membership)
    (maximum(membership) > N || minimum(membership) < 1) && error("Label must between 1 and |V|")
    j = 1
    for i=1:length(membership)
        k = membership[i]
        if k >= 1
            if label_counters[k] == 0
                # We have seen this label for the first time
                label_counters[k] = j
                k = j
                j += 1
            else
                k = label_counters[k]
            end
        end
        membership[i] = k
    end
end
