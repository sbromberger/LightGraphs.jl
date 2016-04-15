"""
Community detection using the label propagation algorithm (see [Raghavan et al.](http://arxiv.org/abs/0709.2938)).
`g`: imput Graph
return : array containing vertex assignments, the range of the output as 1:countdistinct(membership)
"""
function label_propagation(g::SimpleGraph; maxiter=1000)
    n = nv(g)
    label = collect(1:n)
    runing_nodes = Set(vertices(g))
    c = NeighComm(collect(1:n), fill(-1,n), 1)
    i = 0
    while !isempty(runing_nodes) && i < maxiter
    	i += 1
        order = shuffle(collect(runing_nodes))
        for u in order
          old_comm = label[u]
          label[u] = vote!(g, label, c, u)
            if old_comm != label[u]
                for v in out_neighbors(g, u)
                    push!(runing_nodes, v)
                end
            else
                delete!(runing_nodes, u)
            end
        end
    end
    renumber_labels!(label)
    label
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

"""Type to record neighbor labels and their count."""
type NeighComm
  neigh_pos::Vector{Int}
  neigh_cnt::Vector{Int}
  neigh_last::Int
end

"""Return the most frequency label."""
function vote!(g, m, c, u)
    for i=1:c.neigh_last-1
        c.neigh_cnt[c.neigh_pos[i]] = -1
    end
    c.neigh_last = 1
    c.neigh_pos[1] = m[u]
    c.neigh_cnt[c.neigh_pos[1]] = 0
    c.neigh_last = 2
    max_cnt = 0
    for neigh in out_neighbors(g,u)
        neigh_comm = m[neigh]
        if c.neigh_cnt[neigh_comm] < 0
            c.neigh_cnt[neigh_comm] = 0
            c.neigh_pos[c.neigh_last] = neigh_comm
            c.neigh_last += 1
        end
        c.neigh_cnt[neigh_comm] += 1
        if c.neigh_cnt[neigh_comm] > max_cnt
          max_cnt = c.neigh_cnt[neigh_comm]
        end
    end
    # ties breaking randomly
    range_shuffle!(1:c.neigh_last-1, c.neigh_pos)
    for lbl in c.neigh_pos
      if c.neigh_cnt[lbl] == max_cnt
        return lbl
      end
    end
end

function renumber_labels!(membership::Vector{Int})
    N = length(membership)
    (maximum(membership) > N || minimum(membership) < 1) && error("Label must between 1 and |V|")
    label_counters = zeros(Int, N)
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
