"""
    struct DEposoPapeState{T, U}

An [`AbstractPathState`](@ref) designed for D`Esopo-Pape shortest-path calculations.
"""
struct DEsopoPapeState{T <:Real, U <: Integer} <: AbstractPathState
    parents::Vector{U}
    dists::Vector{T}
end

function desopo_pape_shortest_paths(g::AbstractGraph, 
    src::Integer,
    distmx::AbstractMatrix{T} = weights(g)) where T <: Real
    U = eltype(g)
    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    state = Vector{UInt8}()
    for i=1:nvg
        push!(state, 2)
    end
    q = Vector{U}()
    push!(q, src)
    @inbounds dists[src] = 0
    
    while !isempty(q)
        @inbounds u = q[1]
        popfirst!(q)
        @inbounds state[u] = 0
        
        @inbounds for v in outneighbors(g, u)
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
