"""
	dfs_short_circuit(g, s)

`g` is a spanning tree of some graph.
Convert a spanning tree of a Complete Graph into a tour starting at `s` outputing a permutation 
formed by the inorder traversal of the spanning tree.
The tour is represented by a permutation of the vertices of the graph. 
"""
function dfs_short_circuit(g::AbstractGraph, s::T) where T <: Integer

    nvg = nv(g)
    seen = falses(nvg)
    S = Vector{T}()
    tour = Vector{T}()
    sizehint!(S, nvg)
    sizehint!(tour, nvg)
    push!(S, s)
    push!(tour, s)
    seen[s] = true

    @inbounds while !isempty(S)
        v = S[end]
        found = false
        for n in outneighbors(g, v)
            if !seen[n]
                u = n
                seen[n] = true
                push!(S, n)
                push!(tour, n)
                found = true
                break
            end
        end
        found || pop!(S)
    end
    return tour
end

"""
	metric_travelling_salesman(g, s)

`g` is a complete undirected graph.
The weights of `g` represented by `distmx` obey the triangle inequality.
Outputs an approximate minimum weight tour `g` represented by a permutation 
of the vertices of `g`.

### Performance
Runtime: O(|V|^2*log(|V|))
Approximation Factor: 2

### Implementation Notes
Perfrom [Approximate Metric Travaelling Salesman](http://www.cs.tufts.edu/~cowen/advanced/2002/adv-lect3.pdf).
"""
function metric_travelling_salesman end

@traitfn function metric_travelling_salesman(
    g::AG::(!IsDirected),
    distmx::AbstractMatrix{U} = weights(g)
) where {U<:Real, T, AG<:AbstractGraph{T}}
    
    
    mst_tmp = prim_mst(g, distmx)
    #Prim returns Vector{Edge}, we require Vector{Edge{T}}
	mst = SimpleGraphFromIterator([Edge{T}(e.src, e.dst) for e in mst_tmp])

    return dfs_short_circuit(mst, one(T))
end
