@traitfn function boruvka_mst(graph::AG::(!IsDirected), 
    distmx::AbstractMatrix{T} = weights(graph); 
    minimize = true) where {T<:Real,U,AG<:AbstractGraph{U}}
    
    f_distmx = minimize ? copy(distmx) : copy(-distmx)

    djSet = IntDisjointSets(nv(graph))

    mst = Vector{edgetype(graph)}()
    sizehint!(mst, nv(graph) - 1)

    weight = 0.0
    while (num_groups(djSet) > 1)

        cheapest = Array{Union{edgetype(graph), Bool}}(undef, nv(graph))

        for edge in edges(graph)
            set1 = find_root(djSet, src(edge))
            set2 = find_root(djSet, dst(edge))
            if (set1 != set2)
                e1 = cheapest[set1]
                if (cheapest[set1] == false || f_distmx[src(e1), dst(e1)] > f_distmx[src(edge), dst(edge)])
                    cheapest[set1] = edge
                end

                e2 = cheapest[set2]
                if (cheapest[set2] == false || f_distmx[src(e2), dst(e2)] > f_distmx[src(edge), dst(edge)])
                    cheapest[set2] = edge
                end

            end

        end

        for v in vertices(graph)

            if (cheapest[v] != false)
                edge = cheapest[v]
                
                if (!in_same_set(djSet, src(edge), dst(edge)))
                    weight += distmx[src(edge), dst(edge)]
                    union!(djSet, src(edge), dst(edge))
                    push!(mst, edge)
                end

            end

        end

    end

    return mst,weight

end


