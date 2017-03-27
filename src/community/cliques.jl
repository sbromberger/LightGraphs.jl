##################################################################
#
#   Maximal cliques of undirected graph
#   Derived from Graphs.jl: https://github.com/julialang/Graphs.jl
#
##################################################################

"""
    maximal_cliques(g)

Return a vector of vectors representing the node indices in each of the maximal
cliques found in the undirected graph `g`.

```jldoctest
julia> using LightGraphs
julia> g = Graph(3)
julia> add_edge!(g, 1, 2)
julia> add_edge!(g, 2, 3)
julia> maximal_cliques(g)
2-element Array{Array{Int64,N},1}:
 [2,3]
 [2,1]
```
"""
function maximal_cliques end
@traitfn function maximal_cliques(g::::(!IsDirected))
    T = eltype(g)
    # Cache nbrs and find first pivot (highest degree)
    maxconn = -1
    nnbrs = Vector{Set{T}}()
    for n in vertices(g)
        push!(nnbrs, Set{T}())
    end
    pivotnbrs = Set{T}() # handle empty graph
    pivotdonenbrs = Set{T}()  # initialize

    for n in vertices(g)
        nbrs = Set{T}()
        union!(nbrs, out_neighbors(g, n))
        delete!(nbrs, n) # ignore edges between n and itself
        conn = length(nbrs)
        if conn > maxconn
            pivotnbrs = nbrs
            nnbrs[n] = pivotnbrs
            maxconn = conn
        else
            nnbrs[n] = nbrs
        end
    end

    # Initial setup
    cand = Set{T}(vertices(g))
    # union!(cand, keys(nnbrs))
    smallcand = setdiff(cand, pivotnbrs)
    done = Set{T}()
    stack = Vector{Tuple{Set{T}, Set{T}, Set{T}}}()
    clique_so_far = Vector{T}()
    cliques = Vector{Array{T}}()

    # Start main loop
    while !isempty(smallcand) || !isempty(stack)
        if !isempty(smallcand) # Any vertices left to check?
            n = pop!(smallcand)
        else
            # back out clique_so_far
            cand, done, smallcand = pop!(stack)
            pop!(clique_so_far)
            continue
        end
        # Add next node to clique
        push!(clique_so_far, n)
        delete!(cand, n)
        push!(done, n)
        nn = nnbrs[n]
        new_cand = intersect(cand, nn)
        new_done = intersect(done, nn)
        # check if we have more to search
        if isempty(new_cand)
            if isempty(new_done)
                # Found a clique!
                push!(cliques, collect(clique_so_far))
            end
            pop!(clique_so_far)
            continue
        end
        # Shortcut--only one node left!
        if isempty(new_done) && length(new_cand) == 1
            push!(cliques, cat(1, clique_so_far, collect(new_cand)))
            pop!(clique_so_far)
            continue
        end
        # find pivot node (max connected in cand)
        # look in done vertices first
        numb_cand = length(new_cand)
        maxconndone = -1
        for n in new_done
            cn = intersect(new_cand, nnbrs[n])
            conn = length(cn)
            if conn > maxconndone
                pivotdonenbrs = cn
                maxconndone = conn
                if maxconndone == numb_cand
                    break
                end
            end
        end
        # Shortcut--this part of tree already searched
        if maxconndone == numb_cand
            pop!(clique_so_far)
            continue
        end
        # still finding pivot node
        # look in cand vertices second
        maxconn = -1
        for n in new_cand
            cn = intersect(new_cand, nnbrs[n])
            conn = length(cn)
            if conn > maxconn
                pivotnbrs = cn
                maxconn = conn
                if maxconn == numb_cand - 1
                    break
                end
            end
        end
        # pivot node is max connected in cand from done or cand
        if maxconndone > maxconn
            pivotnbrs = pivotdonenbrs
        end
        # save search status for later backout
        push!(stack, (cand, done, smallcand))
        cand = new_cand
        done = new_done
        smallcand = setdiff(cand, pivotnbrs)
    end
    return cliques
end
