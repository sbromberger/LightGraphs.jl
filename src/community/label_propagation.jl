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
    label
end

function label_count(g::SimpleGraph, membership::Vector{Int}, u::Int)
    label_cnt = Dict{Int, Int}()
    for v in out_neighbors(g,u)
        v_lbl = membership[v]
        if haskey(label_cnt, v_lbl)
            label_cnt[v_lbl] += 1
        else
            label_cnt[v_lbl] = 1
        end
    end
    label_cnt
end

function update_label!(g::SimpleGraph, membership::Vector{Int}, u::Int)
    old_lbl = membership[u]
    label_cnt = label_count(g, membership, u)
    neigh_lbls = collect(keys(label_cnt))
    neigh_lbls_cnt = collect(values(label_cnt))
    order = collect(1:length(label_cnt))
    shuffle!(order)
    max_cnt = neigh_lbls_cnt[order[1]]
    max_lbl = neigh_lbls[order[1]]
    running = false
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
    running
end