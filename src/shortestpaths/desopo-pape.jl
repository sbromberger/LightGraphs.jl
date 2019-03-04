"""
    struct DEposoPapeState{T, U}

An [`AbstractPathState`](@ref) designed for D`Esopo-Pape shortest-path calculations.
"""
struct DEsopoPapeState{T <:Real, U <: Integer} <: AbstractPathState
    parents::Vector{U}
    dists::Vector{T}
end

function DEsopoPape_shortest_path(g::AbstractGraph, 
    src::U,
    distmx::AbstractMatrix{T} = weights(g)) where T <: Real where U <: Integer
    
    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    state = fill(2, nvg)
    q = Array{U,1}()
    push!(q, src)
    dists[src] = 0
    
    while !isempty(q)
        u = q[1]
        popfirst!(q)
        state[u] = 0
        
        for v in outneighbors(g, u)
            alt = dists[u] + distmx[u, v]
            if (dists[v] > alt)
                dists[v] = alt
                parents[v] = u
                
                if (state[v] == 2)
                    state[v] = 1
                    push!(q, v)
                elseif (state[v] == 0)
                    state[v] = 1
                    pushfirst!(q, v)
                end
            end
        end
    end
    
    return DEsopoPapeState{T, U}(parents, dists)
end
