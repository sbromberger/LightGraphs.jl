# Checking for existence of Eulerian circuit and Eulerian trail

function single_nonzero_degree_component(
    graph::AG,
    ) where {T <: Integer, AG <: AbstractGraph{T}}

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
        stack = Vector{T}([v])
        visited[v] = 1
        while !isempty(stack)
            u = stack[end]
            # assuming valid vertices never take zero value
            w = zero(eltype(graph))
            for v in outneighbors(graph, u)
                if visited[v] == 0
                    w = v
                    break
                end
            end
            if w != zero(eltype(graph))
                visited[w] = 1
                push!(stack, w)
            else
                visited[u] = 2
                pop!(stack)
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
For directed graph,  if at most one vertex has (out-degree) − (in-degree) = 1, at most one vertex has (in-degree) − (out-degree) = 1.
Since degree() accounts only once of self loop in directed graph, incremented degree by 1 for the algorithm to work in undirected graphs.
"""
function has_eulerian_trail end
@traitfn function has_eulerian_trail(
    graph::AG::(!IsDirected),
    ) where {T, AG <: AbstractGraph{T}}

    single_nonzero_degree_component(graph) || return false
    odd = 0
    for v in vertices(graph)
        if (has_edge(graph, v, v) && iseven(outdegree(graph, v))) 
            odd += 1
        elseif (!has_edge(graph, v, v) && isodd(outdegree(graph, v)))
            odd += 1
        end
    end

    return (odd <= 2)
end

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

    return !(out_more > 1 || in_more > 1)
end

"""
    has_eulerian_circuit(g)

Return `true` if graph `g` contains [Eulerian circuit](https://en.wikipedia.org/wiki/Eulerian_path).

### Implementation Notes
Uses single call to iterative version of DFS to check for the existence of a single component with non-zero degree in single_nonzero_degree_component().
Condition for Eulerian circuit :
For undirected graph, if all nodes have even degree.
For directed graph,  if all nodes have (out-degree) = (in-degree).
Since degree() accounts only once of self loop in directed graph, incremented degree by 1 for the algorithm to work in undirected graphs.
"""
function has_eulerian_circuit end
@traitfn function has_eulerian_circuit(
    graph::AG::(!IsDirected),
    ) where {T, AG <: AbstractGraph{T}}

    single_nonzero_degree_component(graph) || return false
    odd = 0
    for v in vertices(graph)
        if (has_edge(graph, v, v) && iseven(outdegree(graph, v))) 
            odd += 1
        elseif (!has_edge(graph, v, v) && isodd(outdegree(graph, v)))
            odd += 1
        end
    end

    return (odd == 0)
end

@traitfn function has_eulerian_circuit(
    graph::AG::(IsDirected),
    ) where {T, AG <: AbstractGraph{T}}

    single_nonzero_degree_component(graph) || return false
    for v in vertices(graph)
        (outdegree(graph, v) != indegree(graph, v)) && return false
    end

    return true
end

"""
    eulerian_circuit(g)

Return array for vertices representing Eulerian circuit if graph `g` contains [Eulerian circuit](https://en.wikipedia.org/wiki/Eulerian_path) otherwise throws error.

### Implementation Notes
Implemented Hierholzer's algorithm to find Eulerian circuit.
The idea is to keep following unused edges and removing them until we get stuck.
Once we get stuck, we back-track to the nearest vertex in our current path that has unused edges, and we repeat the process until all the edges have been used.
For undirected graph, made a copy of adjacency list and deleted edges from it while iterating.
For directed graph, since each edge is in one vertex's adjacency, it can be virtually removed it by decrementing the edge_count.
Since degree() accounts only once of self loop in directed graph, incremented degree by 1 for the algorithm to work in undirected graphs.
"""
function eulerian_circuit end
@traitfn function eulerian_circuit(
    graph::AG::(IsDirected)
    ) where {T, AG <: AbstractGraph{T}}
    
    has_eulerian_circuit(graph) || throw(ArgumentError("Graph do not have Eulerian circuit."))
    circuit = Vector{T}()
    iszero(nv(graph)) && return circuit
    iszero(ne(graph)) && return [vertices(graph)[1]]

    edge_count = collect(outdegree(graph))
    current_path = Vector{T}([1])
    current_vertex = 1

    while !isempty(current_path)
        if !iszero(edge_count[current_vertex])
            push!(current_path, current_vertex)
            next_vertex = neighbors(graph, current_vertex)[edge_count[current_vertex]]
            edge_count[current_vertex] -= 1
            current_vertex = next_vertex
        else
            push!(circuit, current_vertex)
            current_vertex = current_path[end]
            pop!(current_path)
        end
    end
    
    return reverse!(circuit)
end

@traitfn function eulerian_circuit(
    graph::AG::(!IsDirected)
    ) where {T, AG <: AbstractGraph{T}}

    has_eulerian_circuit(graph) || throw(ArgumentError("Graph do not have Eulerian circuit."))
    circuit = Vector{T}()
    iszero(nv(graph)) && return circuit
    iszero(ne(graph)) && return [vertices(graph)[1]]

    edge_count = collect(outdegree(graph))
    for v in vertices(graph)
        has_edge(graph, v, v) && (edge_count[v] += 1)
    end
    out_neighbor = Dict()
    for v in vertices(graph)
        out_neighbor[v] = collect(neighbors(graph,v))
    end
    current_path = Vector{T}([1])
    current_vertex = 1

    while !isempty(current_path)
        if !iszero(edge_count[current_vertex])
            push!(current_path, current_vertex)
            next_vertex = out_neighbor[current_vertex][end]
            pop!(out_neighbor[current_vertex])
            !iszero(length(out_neighbor[next_vertex])) && deleteat!(out_neighbor[next_vertex], findfirst(x -> x == current_vertex, out_neighbor[next_vertex]))            
            edge_count[current_vertex] -= 1
            edge_count[next_vertex] -= 1
            current_vertex = next_vertex
        else
            push!(circuit, current_vertex)
            current_vertex = current_path[end]
            pop!(current_path)
        end
    end

    return reverse!(circuit)
end

"""
    eulerian_trail(g)

Return array for vertices representing Eulerian trail if graph `g` contains [Eulerian trail](https://en.wikipedia.org/wiki/Eulerian_path) otherwise throws error.

### Implementation Notes
Implemented Hierholzer's algorithm to find Eulerian trail.
The idea is to keep following unused edges and removing them until we get stuck.
Once we get stuck, we back-track to the nearest vertex in our current path that has unused edges, and we repeat the process until all the edges have been used.
For undirected graph, made a copy of adjacency list and deleted edges from it while iterating.
For directed graph, since each edge is in one vertex's adjacency, it can be virtually removed it by decrementing the edge_count.
For Eulerian trail we start tracking the path from vertices with odd degree in case of undirected graph and for directed graph from a vertex having outdegree - indegree = 1, if exists.
Since degree() accounts only once of self loop in directed graph, incremented degree by 1 for the algorithm to work in undirected graphs.
"""
function eulerian_trail end
@traitfn function eulerian_trail(
    graph::AG::(IsDirected)
    ) where {T, AG <: AbstractGraph{T}}
    
    has_eulerian_trail(graph) || throw(ArgumentError("Graph do not have Eulerian trail."))
    trail = Vector{T}()
    iszero(nv(graph)) && return trail
    iszero(ne(graph)) && return [vertices(graph)[1]]

    edge_count = collect(outdegree(graph))
    current_vertex = 1
    for v in vertices(graph)
        if outdegree(graph, v) - indegree(graph, v) == 1
            current_vertex = v
            break
        end
    end
    current_path = Vector{T}([current_vertex])

    while !isempty(current_path)
        if !iszero(edge_count[current_vertex])
            push!(current_path, current_vertex)
            next_vertex = neighbors(graph, current_vertex)[edge_count[current_vertex]]
            edge_count[current_vertex] -= 1
            current_vertex = next_vertex
        else
            push!(trail, current_vertex)
            current_vertex = current_path[end]
            pop!(current_path)
        end
    end
    
    return reverse!(trail)
end

@traitfn function eulerian_trail(
    graph::AG::(!IsDirected)
    ) where {T, AG <: AbstractGraph{T}}

    has_eulerian_trail(graph) || throw(ArgumentError("Graph do not have Eulerian trail."))
    trail = Vector{T}()
    iszero(nv(graph)) && return trail
    iszero(ne(graph)) && return [vertices(graph)[1]]

    current_vertex = 1
    edge_count = collect(outdegree(graph))
    for v in vertices(graph)
        has_edge(graph, v, v) && (edge_count[v] += 1)
    end
    for v in vertices(graph)
        if isodd(edge_count[v])
            current_vertex = v
            break
        end
    end
    out_neighbor = Dict()
    for v in vertices(graph)
        out_neighbor[v] = collect(neighbors(graph,v))
    end
    current_path = Vector{T}([current_vertex])

    while !isempty(current_path)
        if !iszero(edge_count[current_vertex])
            push!(current_path, current_vertex)
            next_vertex = out_neighbor[current_vertex][end]
            pop!(out_neighbor[current_vertex])
            !iszero(length(out_neighbor[next_vertex])) && deleteat!(out_neighbor[next_vertex], findfirst(x -> x == current_vertex, out_neighbor[next_vertex]))            
            edge_count[current_vertex] -= 1
            edge_count[next_vertex] -= 1
            current_vertex = next_vertex
        else
            push!(trail, current_vertex)
            current_vertex = current_path[end]
            pop!(current_path)
        end
    end

    return reverse!(trail)
end