"""
```
labels                = normalized_cut(W, [num_cuts], [thres])
```

Performs recursive two-way normalized graph cut as described in this paper - "Normalized Cuts and Image Segmentation" by Shi and Malik

Parameters:  
-    W              = Weighted adjacency matrix for graph.
-    thres          = Subgraphs aren't split if best normalized cut is above this threshold
-    num_cuts       = Number of cuts performed to determine optimal cut

# Example
```julia
using LightGraphs, SimpleWeightedGraphs
g = SimpleWeightedGraph(6)
add_edge!(g, 1, 2, 1)
add_edge!(g, 2, 3, 1)
add_edge!(g, 1, 3, 1)
add_edge!(g, 4, 5, 1)
add_edge!(g, 4, 6, 1)
add_edge!(g, 5, 6, 1)
add_edge!(g, 1, 6, 0.1)
add_edge!(g, 3, 4, 0.2)

labels = normalized_cut(g.weights, 0.1)
```
"""
function ncut{T<:Real}(W::SparseMatrixCSC{T,Int}, thres::Real = 0.01 ,num_cuts::Int = 10)

    #returns normalized cut score
    function ncut_cost(mask)
        cut_cost = 0
        rows = rowvals(W)
        vals = nonzeros(W)
        for i = 1:n
            for j in nzrange(W, i)
                row = rows[j]
                if mask[i] != mask[row]
                    cut_cost += vals[j]/2
                end
            end
        end
        return cut_cost/sum(D*mask) + cut_cost/sum(D*(.~mask))
    end

    m, n = size(W)
    D = Diagonal(vec(sum(W, 2)))

    if m == 1
        return [1]
    end

    #get eigenvector corresponding to second smallest eigenvalue
    v = eigvecs(full(D-W), full(D))[:, 2]

    #perform n-cuts with different partitions of v and find best one
    min_cost = Inf
    best_thres = -1
    for t in linspace(minimum(v), maximum(v), num_cuts)
        mask = v.>t
        cost = ncut_cost(mask)
        if cost < min_cost
            min_cost = cost
            best_thres = t
        end
    end

    if min_cost < thres
        #split graph, compute ncut for each subgraph recursively and merge index labels
        mask = v.>best_thres

        if sum(mask) == 0 || sum(mask) == m
            return ones(Int, m)
        end

        inds = Vector{Int}(m)
        rev_inds1 = Vector{Int}(m - sum(mask))
        rev_inds2 = Vector{Int}(sum(mask))
        i1 = 1
        i2 = 1
        for j in 1:m
            if !mask[j]
                inds[j] = i1
                rev_inds1[i1] = j
                i1 += 1
            else
                inds[j] = i2
                rev_inds2[i2] = j
                i2 += 1
            end
        end

        rows = rowvals(W)
        vals = nonzeros(W)
        I1 = Vector{Int}(); I2 = Vector{Int}()
        J1 = Vector{Int}(); J2 = Vector{Int}()
        V1 = Vector{Float64}(); V2 = Vector{Float64}()
        for i = 1:n
            for j in nzrange(W, i)
                row = rows[j]
                if mask[i] == mask[row] == false
                    push!(I1, inds[i])
                    push!(J1, inds[row])
                    push!(V1, vals[j])
                elseif mask[i] == mask[row] == true
                    push!(I2, inds[i])
                    push!(J2, inds[row])
                    push!(V2, vals[j])
                end
            end
        end
        W1 = sparse(I1, J1, V1)
        W2 = sparse(I2, J2, V2)
        labels1 = ncut(W1, thres, num_cuts)
        labels2 = ncut(W2, thres, num_cuts)

        labels = Vector{Int}(m)
        n1 = maximum(labels1)

        for i in 1:(m - sum(mask))
            labels[rev_inds1[i]] = labels1[i]
        end
        for i in 1:sum(mask)
            labels[rev_inds2[i]] = labels2[i] + n1
        end
        return labels
    else
        #don't cut graph further
        return ones(Int, m)
    end
end