"""
Community detection using the label propagation algorithm (see [Raghavan et al.](http://arxiv.org/abs/0709.2938)).
`g`: imput Graph
`ϵ`: proportion of unsatisfied nodes
return : array containing vertex assignments
"""
function label_propagation(g::SimpleGraph, ϵ=1.0e-8)
    n = nv(g)
    label = collect(1:n)
    runing_nodes = Set(vertices(g))

    while length(runing_nodes) > n*ϵ
        order = shuffle(collect(runing_nodes))
        for u in order
            if update_label!(g, label, u)
                for v in out_neighbors(g, u)
                    push!(runing_nodes, v)
                end
            else
                delete!(runing_nodes, u)
            end
        end
    end
    permute_labels!(label)
	label
end

function label_count(g::SimpleGraph, membership::Vector{Int}, u::Int)
    label_cnt = Dict{Int, Int}()
    for v in out_neighbors(g,u)
        v_lbl = membership[v]
        label_cnt[v_lbl] = get(label_cnt, v_lbl, 0) + 1
    end
    label_cnt
end

function update_label!(g::SimpleGraph, membership::Vector{Int}, u::Int)
	running = false
	if degree(g, u) > 0
	    old_lbl = membership[u]
	    label_cnt = label_count(g, membership, u)
	    neigh_lbls = collect(keys(label_cnt))
	    neigh_lbls_cnt = collect(values(label_cnt))
	    order = collect(1:length(label_cnt))
	    shuffle!(order)
	    max_cnt = neigh_lbls_cnt[order[1]]
	    max_lbl = neigh_lbls[order[1]]
	    for i=2:length(order)
	        if neigh_lbls_cnt[order[i]] > max_cnt
	            max_cnt = neigh_lbls_cnt[order[i]]
	            max_lbl = neigh_lbls[order[i]]
	        end
	    end
	    if max_lbl != old_lbl
	        membership[u] = max_lbl
	        running = true
	    end
	end
    running
end

function permute_labels!(membership::Vector{Int})
    N = length(membership)
    if maximum(membership) > N || minimum(membership) < 1
        error("Label must between 1 and |V|")
    end
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