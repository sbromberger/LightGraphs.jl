"""
    struct DEsopoPape <: ShortestPathAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use the [D'Esopo-Pape algorithm](http://web.mit.edu/dimitrib/www/SLF.pdf).
No fields are specified or required.

### Implementation Notes
`DEsopoPape` supports the following shortest-path functionality:
- non-negative distance matrices / weights
- all destinations
"""
struct DEsopoPape <: ShortestPathAlgorithm 
    maxdist::AbstractFloat
end

DEsopoPape(; maxdist=NaN) = DEsopoPape(maxdist)

struct DEsopoPapeResult{T, U<:Integer} <: ShortestPathResult
    parents::Vector{U}
    dists::Vector{T}
end

function shortest_paths(g::AbstractGraph, src::Integer, distmx::AbstractMatrix, alg::DEsopoPape)
    T = eltype(distmx)
    U = eltype(g)
    nvg = nv(g)
    (src in 1:nvg) || throw(DomainError(src, "src should be in between 1 and $nvg"))
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    state = Vector{Int8}()
    state = fill(Int8(2), nvg)
    q = U[src]
    @inbounds dists[src] = 0
    
    @inbounds while !isempty(q)
        u = popfirst!(q)
        state[u] = 0
        
        for v in outneighbors(g, u)
            alt = dists[u] + distmx[u, v]

            if alt > alg.maxdist
                continue
            end

            if (dists[v] > alt)
                dists[v] = alt
                parents[v] = u
                
                if state[v] == 2
                    state[v] = 1
                    push!(q, v)
                elseif state[v] == 0
                    state[v] = 1
                    pushfirst!(q, v)
                end
            end
        end
    end
    
    return DEsopoPapeResult{T, U}(parents, dists)
end
