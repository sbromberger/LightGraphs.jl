# Checking for existence of Eulerian circuit and Eulerian trail

function single_nonzero_degree_component(
    graph::AG,
    ) where {T, AG <: AbstractGraph{T}}

    visited = zeros(UInt8, nv(graph))
    for v in vertices(graph)
        if (outdegree(graph, v) + indegree(graph, v)) == 0
            visited[v] = 2
        end
    end
    for v in vertices(graph)
        if (outdegree(graph, v) + indegree(graph, v)) == 0
            continue
        end
        S = Vector{T}([v])
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
        visited[v] > 0 || return false
    end
    return true
end

"""
    has_eulerian_trail(g)

Return `true` if graph `g` contains [Eulerian trail](https://en.wikipedia.org/wiki/Eulerian_path).
Note that a Eulerian Trail can have the same start and end vertex so all Eulerian Circuits are Trails as well.

### Implementation Notes
Uses single call to iterative version of DFS to check for the existence of a single component with non-zero degree in single_nonzero_degree_component().
Condition for Eulerian trail :
For undirected graph, if nodes with odd degree are at most 2.
For directed graph,  if at most one vertex has (out-degree) − (in-degree) = 1, at most one vertex has (in-degree) − (out-degree) = 1
"""
function has_eulerian_trail end
@traitfn function has_eulerian_trail(
    graph::AG::(!IsDirected),
    ) where {T, AG <: AbstractGraph{T}}

    single_nonzero_degree_component(graph) || return false
    odd = 0
    for v in vertices(graph)
        if isodd(outdegree(graph, v))
            odd+=1
        end
    end

    odd > 2 && return false
    return true
end

function has_eulerian_trail end
@traitfn function has_eulerian_trail(
    graph::AG::(IsDirected),
    ) where {T, AG <: AbstractGraph{T}}

    single_nonzero_degree_component(graph) || return false
    out_more = 0
    in_more = 0
    for v in vertices(graph)
        out = outdegree(graph, v)
        in = indegree(graph, v)
        if out - in == 1
            out_more+=1
        elseif in - out == 1
            in_more+=1
        elseif out != in
            return false
        end
    end

    (out_more > 1 || in_more > 1) && return false
    return true
end

"""
    has_eulerian_circuit(g)

Return `true` if graph `g` contains [Eulerian circuit](https://en.wikipedia.org/wiki/Eulerian_path).

### Implementation Notes
Uses single call to iterative version of DFS to check for the existence of a single component with non-zero degree in single_nonzero_degree_component().
Condition for Eulerian circuit :
For undirected graph, if all nodes have even degree.
For directed graph,  if all nodes have (out-degree) = (in-degree).
"""
function has_eulerian_circuit end
@traitfn function has_eulerian_circuit(
    graph::AG::(!IsDirected),
    ) where {T, AG <: AbstractGraph{T}}

    single_nonzero_degree_component(graph) || return false
    odd = 0
    for v in vertices(graph)
        if isodd(outdegree(graph, v))
            odd+=1
        end
    end

    odd == 0 && return true
    return false
end

function has_eulerian_circuit end
@traitfn function has_eulerian_circuit(
    graph::AG::(IsDirected),
    ) where {T, AG <: AbstractGraph{T}}

    single_nonzero_degree_component(graph) || return false
    for v in vertices(graph)
        (outdegree(graph, v) != indegree(graph, v)) && return false
    end

    return true
end
