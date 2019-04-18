using ArnoldiMethod
#computes normalized cut cost for partition `cut`
function _normalized_cut_cost(cut, W::AbstractMatrix, D)
    cut_cost = zero(eltype(W))
    for j in axes(W, 2)
        for i in axes(W, 1)
            if cut[i] != cut[j]
                cut_cost += W[i, j]
            end
        end
    end
    half_cut_cost = cut_cost / 2
    return half_cut_cost / sum(D * cut) + half_cut_cost / sum(D * (.~cut))
end

function _normalized_cut_cost(cut, W::SparseMatrixCSC, D)
    cut_cost = zero(eltype(W))
    rows = rowvals(W)
    vals = nonzeros(W)
    n = size(W, 2)
    for i = 1:n
        for j in nzrange(W, i)
            row = rows[j]
            if cut[i] != cut[row]
                cut_cost += vals[j]
            end
        end
    end
    half_cut_cost = cut_cost / 2
    return half_cut_cost / sum(D * cut) + half_cut_cost / sum(D * (.~cut))
end

function _partition_weightmx(cut, W::AbstractMatrix)
    nv = length(cut)
    nv2 = sum(cut)
    nv1 = nv - nv2
    newvid = Vector{Int}(undef, nv)
    vmap1 = Vector{Int}(undef, nv1)
    vmap2 = Vector{Int}(undef, nv2)
    j1 = 1
    j2 = 1
    for i in eachindex(cut)
        if cut[i] == false
            newvid[i] = j1
            vmap1[j1] = i
            j1 += 1
        else
            newvid[i] = j2
            vmap2[j2] = i
            j2 += 1
        end
    end

    W1 = similar(W, (nv1, nv1))
    W2 = similar(W, (nv2, nv2))

    for j in axes(W, 2)
        for i in axes(W, 1)
            if cut[i] == cut[j] == false
                W1[newvid[i], newvid[j]] = W[i, j]
            elseif cut[i] == cut[j] == true
                W2[newvid[i], newvid[j]] = W[i, j]
            end
        end
    end

    return (W1, W2, vmap1, vmap2)
end

function _partition_weightmx(cut, W::SparseMatrixCSC)
    nv = length(cut)
    nv2 = sum(cut)
    nv1 = nv - nv2
    newvid = Vector{Int}(undef, nv)
    vmap1 = Vector{Int}(undef, nv1)
    vmap2 = Vector{Int}(undef, nv2)
    j1 = 1
    j2 = 1
    for i in eachindex(cut)
        if cut[i] == false
            newvid[i] = j1
            vmap1[j1] = i
            j1 += 1
        else
            newvid[i] = j2
            vmap2[j2] = i
            j2 += 1
        end
    end

    rows = rowvals(W)
    vals = nonzeros(W)
    I1 = Vector{Int}(); I2 = Vector{Int}()
    J1 = Vector{Int}(); J2 = Vector{Int}()
    V1 = Vector{Float64}(); V2 = Vector{Float64}()
    for i = 1:nv
        for j in nzrange(W, i)
            row = rows[j]
            if cut[i] == cut[row] == false
                push!(I1, newvid[i])
                push!(J1, newvid[row])
                push!(V1, vals[j])
            elseif cut[i] == cut[row] == true
                push!(I2, newvid[i])
                push!(J2, newvid[row])
                push!(V2, vals[j])
            end
        end
    end
    W1 = sparse(I1, J1, V1)
    W2 = sparse(I2, J2, V2)
    return (W1, W2, vmap1, vmap2)
end

function _recursive_normalized_cut(W, thres=thres, num_cuts=num_cuts)
    m, n = size(W)
    D = Diagonal(vec(sum(W, dims=2)))

    m == 1 && return [1]

    #get eigenvector corresponding to second smallest eigenvalue
    # v = eigs(D-W, D, nev=2, which=SR())[2][:,2]
    # At least some versions of ARPACK have a bug, this is a workaround
    invDroot = sqrt.(inv(D)) # equal to Cholesky factorization for diagonal D
    if n > 12
        λ, Q = eigs(invDroot' * (D - W) * invDroot, nev=12, which=SR())
        ret = real(Q[:,2])
    else
        ret = eigen(Matrix(invDroot' * (D - W) * invDroot)).vectors[:,2]
    end
    v = invDroot * ret

    #perform n-cuts with different partitions of v and find best one
    min_cost = Inf
    best_thres = -1
    for t in range(minimum(v), stop=maximum(v), length=num_cuts)
        cut = v .> t
        cost = _normalized_cut_cost(cut, W, D)
        if cost < min_cost
            min_cost = cost
            best_thres = t
        end
    end

    if min_cost < thres
        #split graph, compute normalized_cut for each subgraph recursively and merge indices.
        cut = v .> best_thres
        W1, W2, vmap1, vmap2 = _partition_weightmx(cut, W)
        labels1 = _recursive_normalized_cut(W1, thres, num_cuts)
        labels2 = _recursive_normalized_cut(W2, thres, num_cuts)

        labels = Vector{Int}(undef, m)
        offset = maximum(labels1)

        for i in eachindex(labels1)
            labels[vmap1[i]] = labels1[i]
        end
        for i in eachindex(labels2)
            labels[vmap2[i]] = labels2[i] + offset
        end

        return labels
    else
        return ones(Int, m)
    end
end

"""
    normalized_cut(g, thres, distmx=weights(g), [num_cuts=10]);

Perform [recursive two-way normalized graph-cut](https://en.wikipedia.org/wiki/Segmentation-based_object_categorization#Normalized_cuts)
on a graph, partitioning the vertices into disjoint sets.
Return a vector that contains the set index for each vertex.

It is important to identify a good threshold for your application. A bisection search over the range (0,1) will help determine a good value of thres.

### Keyword Arguments
- `thres`: Subgraphs aren't split if best normalized cut is above this threshold
- `num_cuts`: Number of cuts performed to determine optimal cut

### References
"Normalized Cuts and Image Segmentation" - Jianbo Shi and Jitendra Malik
"""
function normalized_cut(g::AbstractGraph,
    thres::Real,
    W::AbstractMatrix{T}=adjacency_matrix(g),
    num_cuts::Int=10) where T <: Real

    return _recursive_normalized_cut(W, thres, num_cuts)
end

