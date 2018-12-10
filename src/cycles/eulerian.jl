# Checking for existence of Eulerian circuit and Eulerian trail

function isConnected(
    graph::AbstractGraph{U},
    ) where U<:Integer

    visited = zeros(UInt8, nv(graph))

    for v in vertices(graph)
        if length(outneighbors(graph, v)) == 0
            visited[v] = 2
        end
    end

    for v in vertices(graph)

        if length(outneighbors(graph, v)) == 0
            continue
        end
        S = Vector{U}([v])
        visited[v] = 1
        while !isempty(S)
            u = S[end]
            w = 0
            for n in outneighbors(graph, u)
                if visited[n] == 0
                    w = n
                    break
                end
            end
            if w != 0
                visited[w] = 1
                push!(S, w)
            else
                visited[u] = 2
                pop!(S)
            end
        end

        break
    end

    for v in vertices(graph)
        if(visited[v]==0)
            return false
        end
    end

    return true
end

"""
    eulerian_trail(g)

Return `true` if graph `g` contains [Eulerian trail](https://en.wikipedia.org/wiki/Eulerian_path).

### Implementation Notes
Uses single call to iterative version of DFS.
"""
function eulerian_trail(
    graph::AbstractGraph{U},
    ) where U<:Integer

    if(!isConnected(graph))
        return false
    end

    odd = 0
    for v in vertices(graph)
        if (length(outneighbors(graph, v))%2 == 1)
            odd+=1
        end
    end

    if odd > 2
        return false
    end

    return true
end

"""
    eulerian_circuit(g)

Return `true` if graph `g` contains [Eulerian circuit](https://en.wikipedia.org/wiki/Eulerian_path).

### Implementation Notes
Uses single call to iterative version of DFS.
"""
function eulerian_circuit(
    graph::AbstractGraph{U},
    ) where U<:Integer

    if !eulerian_trail(graph)
        return false
    end

    odd = 0
    for v in vertices(graph)
        if (length(outneighbors(graph, v))%2 == 1)
            odd+=1
        end
    end

    if odd == 0
        return true
    end

    return false
end