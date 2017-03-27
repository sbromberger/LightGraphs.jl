"""
    boykov_kolmogorov_impl(residual_graph, source, target, capacity_matrix)

Compute the max-flow/min-cut between `source` and `target` for `residual_graph`
using the Boykov-Kolmogorov algorithm.

Return the maximum flow in the network, the flow matrix and the partition
`{S,T}` in the form of a vector of 0's, 1's and 2's.

### References
- BOYKOV, Y.; KOLMOGOROV, V., 2004. An Experimental Comparison of
Min-Cut/Max-Flow Algorithms for Energy Minimization in Vision.

### Author
- Júlio Hoffimann Mendes (juliohm@stanford.edu)
"""
function boykov_kolmogorov_impl end
@traitfn function boykov_kolmogorov_impl(
    residual_graph::::IsDirected,          # the input graph
    source::Integer,                           # the source vertex
    target::Integer,                           # the target vertex
    capacity_matrix::AbstractMatrix    # edge flow capacities
    )

    T = eltype(capacity_matrix)
    U = eltype(residual_graph)

    n = nv(residual_graph)

    flow = 0
    flow_matrix = zeros(T, n, n)

    TREE = zeros(U, n)
    TREE[source] = U(1)
    TREE[target] = U(2)

    PARENT = zeros(U, n)

    A = [source,target]
    O = Vector{U}()

    while true
        # growth stage
        path = find_path!(residual_graph, source, target, flow_matrix, capacity_matrix, PARENT, TREE, A)

        isempty(path) && break

        # augmentation stage
        flow += augment!(path, flow_matrix, capacity_matrix, PARENT, TREE, O)

        # adoption stage
        adopt!(residual_graph, source, target, flow_matrix, capacity_matrix, PARENT, TREE, A, O)
    end

    return flow, flow_matrix, TREE
end

@traitfn function find_path!(
    residual_graph::::IsDirected,            # the input graph
    source::Integer,                       # the source vertex
    target::Integer,                       # the target vertex
    flow_matrix::AbstractMatrix,       # the current flow matrix
    capacity_matrix::AbstractMatrix,   # edge flow capacities
    PARENT::Vector,                     # parent table
    TREE::Vector,                       # tree table
    A::Vector                           # active set
    )
    T = eltype(residual_graph)
    tree_cap(p,q) = TREE[p] == one(T) ? capacity_matrix[p,q] - flow_matrix[p,q] :
    capacity_matrix[q,p] - flow_matrix[q,p]
    while !isempty(A)
        p = last(A)
        for q in neighbors(residual_graph, p)
            if tree_cap(p,q) > 0
                if TREE[q] == zero(T)
                    TREE[q] = TREE[p]
                    PARENT[q] = p
                    unshift!(A, q)
                end
                if TREE[q] ≠ zero(T) && TREE[q] ≠ TREE[p]
                    # p -> source
                    path_to_source = [p]
                    while PARENT[p] ≠ zero(T)
                        p = PARENT[p]
                        push!(path_to_source, p)
                    end

                    # q -> target
                    path_to_target = [q]
                    while PARENT[q] ≠ zero(T)
                        q = PARENT[q]
                        push!(path_to_target, q)
                    end

                    # source -> target
                    path = [reverse!(path_to_source); path_to_target]

                    if path[1] == source && path[end] == target
                        return path
                    elseif path[1] == target && path[end] == source
                        return reverse!(path)
                    end
                end
            end
        end
        pop!(A)
    end

    return Vector{T}()
end

function augment!(
    path::AbstractVector,                  # path from source to target
    flow_matrix::AbstractMatrix,       # the current flow matrix
    capacity_matrix::AbstractMatrix,   # edge flow capacities
    PARENT::Vector,                     # parent table
    TREE::Vector,                       # tree table
    O::Vector                           # orphan set
    )

    T = eltype(path)
    # bottleneck capacity
    Δ = Inf
    for i=1:length(path)-1
        p, q = path[i:i+1]
        cap = capacity_matrix[p,q] - flow_matrix[p,q]
        cap < Δ && (Δ = cap)
    end

    # update residual graph
    for i=1:length(path)-1
        p, q = path[i:i+1]
        flow_matrix[p,q] += Δ
        flow_matrix[q,p] -= Δ

        # create orphans
        if flow_matrix[p,q] == capacity_matrix[p,q]
            if TREE[p] == TREE[q] == one(T)
                PARENT[q] = zero(T)
                unshift!(O, q)
            end
            if TREE[p] == TREE[q] == 2
                PARENT[p] = zero(T)
                unshift!(O, p)
            end
        end
    end

    return Δ
end

@traitfn function adopt!(
    residual_graph::::IsDirected,               # the input graph
    source::Integer,                             # the source vertex
    target::Integer,                             # the target vertex
    flow_matrix::AbstractMatrix,       # the current flow matrix
    capacity_matrix::AbstractMatrix,   # edge flow capacities
    PARENT::Vector,                     # parent table
    TREE::Vector,                       # tree table
    A::Vector,                             # active set
    O::Vector                           # orphan set
    )

    T = eltype(residual_graph)
    tree_cap(p,q) = TREE[p] == 1 ? capacity_matrix[p,q] - flow_matrix[p,q] :
    capacity_matrix[q,p] - flow_matrix[q,p]
    while !isempty(O)
        p = pop!(O)
        # try to find parent that is not an orphan
        parent_found = false
        for q in neighbors(residual_graph, p)
            if TREE[q] == TREE[p] && tree_cap(q,p) > 0
                # check if "origin" is either source or target
                o = q
                while PARENT[o] ≠ 0
                    o = PARENT[o]
                end
                if o == source || o == target
                    parent_found = true
                    PARENT[p] = q
                    break
                end
            end
        end

        if !parent_found
            # scan all neighbors and make the orphan a free node
            for q in neighbors(residual_graph, p)
                if TREE[q] == TREE[p]
                    if tree_cap(q,p) > 0
                        unshift!(A, q)
                    end
                    if PARENT[q] == p
                        PARENT[q] = zero(T)
                        unshift!(O, q)
                    end
                end
            end

            TREE[p] = zero(T)
            B = setdiff(A, p)
            resize!(A, length(B))[:] = B
        end
    end
end
