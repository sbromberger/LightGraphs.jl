# Checking for existence of Eulerian circuit and Eulerian trail

function multinode_component_count end
@traitfn function multinode_component_count(
    graph::AG::(!IsDirected),
    ) where {T, AG <: AbstractGraph{T}}

    components = connected_components(graph)

    count = 0
    for component in components
        if length(component) > 1
            count += 1
        end
    end

    return count
end

"""
    eulerian_trail(g)

Return `true` if graph `g` contains [Eulerian trail](https://en.wikipedia.org/wiki/Eulerian_path).
Note that a Eulerian Trail can have the same start and end vertex so all Eulerian Circuits are Trails as well.

### Implementation Notes
Uses single call to iterative version of DFS.
"""
function has_eulerian_trail end
@traitfn function has_eulerian_trail(
    graph::AG::(!IsDirected),
    ) where {T, AG <: AbstractGraph{T}}

    if multinode_component_count(graph) > 1
        return false
    end

    odd = 0
    for v in vertices(graph)
        if isodd(outdegree(graph, v))
            odd+=1
        end
    end
    odd > 2 && return false
    return true
end

"""
    eulerian_circuit(g)

Return `true` if graph `g` contains [Eulerian circuit](https://en.wikipedia.org/wiki/Eulerian_path).

### Implementation Notes
Uses single call to iterative version of DFS.
"""
function has_eulerian_circuit end
@traitfn function has_eulerian_circuit(
    graph::AG::(!IsDirected),
    ) where {T, AG <: AbstractGraph{T}}

    multinode_component_count(graph) > 1 && return false
    odd = 0
    for v in vertices(graph)
        if isodd(outdegree(graph, v))
            odd+=1
        end
    end

    odd == 0 && return true
    return false
end
