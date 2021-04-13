# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.
"""
    connected_components!(label, g)

Fill `label` with the `id` of the connected component in the undirected graph
`g` to which it belongs. Return a vector representing the component assigned
to each vertex. The component value is the smallest vertex ID in the component.

### Performance
This algorithm is linear in the number of edges of the graph.
"""
function connected_components!(label::AbstractVector, g::AbstractGraph{T}) where T
    nvg = nv(g)

    for u in vertices(g)
        label[u] != zero(T) && continue
        label[u] = u
        Q = Vector{T}()
        push!(Q, u)
        while !isempty(Q)
            src = popfirst!(Q)
            for vertex in all_neighbors(g, src)
                if label[vertex] == zero(T)
                    push!(Q, vertex)
                    label[vertex] = u
                end
            end
        end
    end
    return label
end


"""
    components_dict(labels)

Convert an array of labels to a map of component id to vertices, and return
a map with each key corresponding to a given component id
and each value containing the vertices associated with that component.
"""
function components_dict(labels::Vector{T}) where T <: Integer
    d = Dict{T,Vector{T}}()
    for (v, l) in enumerate(labels)
        vec = get(d, l, Vector{T}())
        push!(vec, v)
        d[l] = vec
    end
    return d
end

"""
    components(labels)

Given a vector of component labels, return a vector of vectors representing the vertices associated
with a given component id.
"""
function components(labels::Vector{T}) where T <: Integer
    d = Dict{T,T}()
    c = Vector{Vector{T}}()
    i = one(T)
    for (v, l) in enumerate(labels)
        index = get!(d, l, i)
        if length(c) >= index
            push!(c[index], v)
        else
            push!(c, [v])
            i += 1
        end
    end
    return c, d
end

"""
    connected_components(g)

Return the [connected components](https://en.wikipedia.org/wiki/Connectivity_(graph_theory))
of an undirected graph `g` as a vector of components, with each element a vector of vertices
belonging to the component.

For directed graphs, see [`strongly_connected_components`](@ref) and
[`weakly_connected_components`](@ref).

# Examples
```jldoctest
julia> g = SimpleGraph([0 1 0; 1 0 1; 0 1 0]);

julia> connected_components(g)
1-element Array{Array{Int64,1},1}:
 [1, 2, 3]

julia> g = SimpleGraph([0 1 0 0 0; 1 0 1 0 0; 0 1 0 0 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> connected_components(g)
2-element Array{Array{Int64,1},1}:
 [1, 2, 3]
 [4, 5]
```
"""
function connected_components(g::AbstractGraph{T}) where T
    label = zeros(T, nv(g))
    connected_components!(label, g)
    c, d = components(label)
    return c
end

"""
    is_connected(g)

Return `true` if graph `g` is connected. For directed graphs, return `true`
if graph `g` is weakly connected.

# Examples
```jldoctest
julia> g = SimpleGraph([0 1 0; 1 0 1; 0 1 0]);

julia> is_connected(g)
true

julia> g = SimpleGraph([0 1 0 0 0; 1 0 1 0 0; 0 1 0 0 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> is_connected(g)
false

julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_connected(g)
true
```
"""
function is_connected(g::AbstractGraph)
    mult = is_directed(g) ? 2 : 1
    return mult * ne(g) + 1 >= nv(g) && length(connected_components(g)) == 1
end

"""
    weakly_connected_components(g)

Return the weakly connected components of the graph `g`. This
is equivalent to the connected components of the undirected equivalent of `g`.
For undirected graphs this is equivalent to the [`connected_components`](@ref) of `g`.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> weakly_connected_components(g)
1-element Array{Array{Int64,1},1}:
 [1, 2, 3]
```
"""
weakly_connected_components(g) = connected_components(g)

"""
    is_weakly_connected(g)

Return `true` if the graph `g` is weakly connected. If `g` is undirected,
this function is equivalent to [`is_connected(g)`](@ref).

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_weakly_connected(g)
true

julia> g = SimpleDiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> is_connected(g)
true

julia> is_strongly_connected(g)
false

julia> is_weakly_connected(g)
true
```
"""
is_weakly_connected(g) = is_connected(g)


"""
    strongly_connected_components(g)

Compute the strongly connected components of a directed graph `g`.

Return an array of arrays, each of which is the entire connected component.

### Implementation Notes
The order of the components is not part of the API contract.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> strongly_connected_components(g)
2-element Array{Array{Int64,1},1}:
 [3]
 [1, 2]


julia> g=SimpleDiGraph(11)
{11, 0} directed simple Int64 graph

julia> edge_list=[(1,2),(2,3),(3,4),(4,1),(3,5),(5,6),(6,7),(7,5),(5,8),(8,9),(9,8),(10,11),(11,10)];

julia> g = SimpleDiGraph(Edge.(edge_list))
{11, 13} directed simple Int64 graph

julia> strongly_connected_components(g)
4-element Array{Array{Int64,1},1}:
 [8, 9]      
 [5, 6, 7]   
 [1, 2, 3, 4]
 [10, 11]    


This currently uses a modern variation on Tarjan's algorithm, largely derived from algorithm 3 in David J. Pearce's 
preprint: https://homepages.ecs.vuw.ac.nz/~djp/files/IPL15-preprint.pdf   , with some changes & tradeoffs when unrolling it to an
imperative algorithm.
```
"""

function strongly_connected_components end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax


# Required to prevent quadratic time in star graphs without causing type instability. Returns the type of the state object returned by iterate that may be saved to a stack.
neighbor_iter_statetype(::Type{AG}) where {AG <: AbstractGraph} = Any   # Analogous to eltype, but for the state of the iterator rather than the elements.
neighbor_iter_statetype(::Type{AG}) where {AG <: LightGraphs.SimpleGraphs.AbstractSimpleGraph} = Int # Since outneighbours is an array.

# Threshold below which it isn't worth keeping the DFS iteration state.
is_large_vertex(g,v) = length(outneighbors(g,v)) >= 16 
is_unvisited(data::AbstractVector,v::Integer) = iszero(data[v])


# The key idea behind any variation on Tarjan's algorithm is to use DFS and pop off found components.
# Whenever we are forced to backtrack, we are in a bottom cycle of the remaining graph, 
# which we accumulate in a stack while backtracking, until we reach a local root.
# A local root is a vertex from which we cannot reach any node that was visited earlier by DFS.
# As such, when we have backtracked to it, we may pop off the contents the stack as a strongly connected component.
@traitfn function strongly_connected_components_4(g::AG::IsDirected) where {T <: Integer, AG <: AbstractGraph{T}}
    nvg = nv(g)
    count = Int(nvg)  # (Counting downwards) Visitation order for the branch being explored. Backtracks when we pop an scc.
    component_count = 1  # Index of the current component being discovered.
    # Invariant 1: count is always smaller than component_count.
    # Invariant 2: if rindex[v] < component_count, then v is in components[rindex[v]].
    # This trivially lets us tell if a vertex belongs to a previously discovered scc without any extra bits, 
    # just inequalities that combine naturally with other checks.

    is_component_root = Vector{Bool}(undef,nvg) # Fields are set when tracing and read when backtracking, so can be initialized undef.
    rindex = zeros(Int,nvg)
    components = Vector{Vector{T}}()    # maintains a list of scc (order is not guaranteed in API)

    stack = Vector{T}()     # while backtracking, stores vertices which have been discovered and not yet assigned to any component
    dfs_stack = Vector{T}()
    largev_iterstate_stack = Vector{Tuple{T,neighbor_iter_statetype(AG)}}()  # For large vertexes we push the iteration state into a stack so we may resume it.
    # adding this last stack fixes the O(|E|^2) performance bug that could previously be seen in large star graphs.

    @inbounds for s in vertices(g)
        if is_unvisited(rindex, s)
            rindex[s] = count
            is_component_root[s] = true
            count -= 1

            # start dfs from 's'
            push!(dfs_stack, s)
            if is_large_vertex(g, s)
                push!(largev_iterstate_stack, iterate(outneighbors(g, s)))
            end 
            
            @inbounds while !isempty(dfs_stack)
                v = dfs_stack[end] #end is the most recently added item
                outn = outneighbors(g, v)
                v_is_large = is_large_vertex(g, v)
                next = v_is_large ? pop!(largev_iterstate_stack) : iterate(outn)
                while next !== nothing
                    (v_neighbor, state) = next
                    if is_unvisited(rindex, v_neighbor)
                        break
                        #GOTO A push v_neighbor onto DFS stack and continue DFS
                        # Note: This is no longer quadratic for (very large) tournament graphs or star graphs, 
                        # as we save the iteration state in largev_iterstate_stack for large vertices.
                        # The loop is tight so not saving the state still benchmarks well unless the vertex orders are large enough to make quadratic growth kick in.
                    elseif (rindex[v_neighbor] > rindex[v])
                        rindex[v] = rindex[v_neighbor]
                        is_component_root[v] = false
                    end
                    next = iterate(outn, state)
                end
                if isnothing(next) # Natural loop end.
                    # All out neighbors already visited or no out neighbors
                    # we have fully explored the DFS tree from v.
                    # time to start popping.
                    popped = pop!(dfs_stack)
                    if is_component_root[popped]  # Found an SCC rooted at popped which is a bottom cycle in remaining graph.
                        component = T[popped]
                        count += 1   # We also backtrack the count to reset it to what it would be if the component were never in the graph.
                        while !isempty(stack) && (rindex[popped] >= rindex[stack[end]])  # Keep popping its children from the backtracking stack.
                            newpopped = pop!(stack)
                            rindex[newpopped] = component_count # Bigger than the value of anything unexplored.
                            push!(component, newpopped) # popped has been assigned a component, so we will never see it again.
                            count +=1
                        end
                        rindex[popped] = component_count
                        component_count += 1
                        push!(components, component)                    
                    else  # Invariant: the DFS stack can never be empty in this second branch where popped is not a root.
                        if (rindex[popped] > rindex[dfs_stack[end]])
                            rindex[dfs_stack[end]] = rindex[popped]
                            is_component_root[dfs_stack[end]] = false
                        end
                        # Because we only push to stack when backtracking, it gets filled up less than in Tarjan's original algorithm.
                        push!(stack, popped)  # For DAG inputs, the stack variable never gets touched at all.
                    end
                    
                else #LABEL A
                    # add unvisited neighbor to dfs
                    (u, state) = next
                    push!(dfs_stack, u)
                    if v_is_large
                        push!(largev_iterstate_stack, next)
                    end
                    if is_large_vertex(g, u)
                        push!(largev_iterstate_stack, iterate(outneighbors(g, u)))
                    end
                    is_component_root[u] = true
                    rindex[u] = count
                    count -= 1
                    # next iteration of while loop will expand the DFS tree from u.
                end
            end
        end
    end

    #Unlike in the original Tarjans, rindex are potentially also worth returning here. 
    # For any v, v is in components[rindex[v]], s it acts as a lookup table for components.
    # Scipy's graph library returns only that and lets the user sort by its values.
    return components # ,rindex
end
                            
"""
    strongly_connected_components_kosaraju(g)

Compute the strongly connected components of a directed graph `g` using Kosaraju's Algorithm. 
(https://en.wikipedia.org/wiki/Kosaraju%27s_algorithm).

Return an array of arrays, each of which is the entire connected component.

### Performance
Time Complexity : O(|E|+|V|)
Space Complexity : O(|V|) {Excluding the memory required for storing graph}

|V| = Number of vertices
|E| = Number of edges

### Examples
```jldoctest

julia> g=SimpleDiGraph(3)
{3, 0} directed simple Int64 graph

julia> g = SimpleDiGraph([0 1 0 ; 0 0 1; 0 0 0])
{3, 2} directed simple Int64 graph

julia> strongly_connected_components_kosaraju(g)
3-element Array{Array{Int64,1},1}:
 [1]
 [2]
 [3]


julia> g=SimpleDiGraph(11)
{11, 0} directed simple Int64 graph

julia> edge_list=[(1,2),(2,3),(3,4),(4,1),(3,5),(5,6),(6,7),(7,5),(5,8),(8,9),(9,8),(10,11),(11,10)]
13-element Array{Tuple{Int64,Int64},1}:
 (1, 2)  
 (2, 3)  
 (3, 4)  
 (4, 1)  
 (3, 5)  
 (5, 6)  
 (6, 7)  
 (7, 5)  
 (5, 8)  
 (8, 9)  
 (9, 8)  
 (10, 11)
 (11, 10)

julia> g = SimpleDiGraph(Edge.(edge_list))
{11, 13} directed simple Int64 graph

julia> strongly_connected_components_kosaraju(g)
4-element Array{Array{Int64,1},1}:
 [11, 10]    
 [2, 3, 4, 1]
 [6, 7, 5]   
 [9, 8]      

```
"""

function strongly_connected_components_kosaraju end
@traitfn function strongly_connected_components_kosaraju(g::AG::IsDirected) where {T<:Integer, AG <: AbstractGraph{T}}
       
   nvg = nv(g)    

   components = Vector{Vector{T}}()    # Maintains a list of strongly connected components
   
   order = Vector{T}()         # Vector which will store the order in which vertices are visited
   sizehint!(order, nvg)    
   
   color = zeros(UInt8, nvg)       # Vector used as for marking the colors during dfs
   
   dfs_stack = Vector{T}()   # Stack used for dfs
    
   # dfs1
   @inbounds for v in vertices(g)
       
       color[v] != 0  && continue  
       color[v] = 1
       
       # Start dfs from v
       push!(dfs_stack, v)   # Push v to the stack
       
       while !isempty(dfs_stack)
           u = dfs_stack[end]
           w = zero(T)
       
           for u_neighbor in outneighbors(g, u)
               if  color[u_neighbor] == 0
                   w = u_neighbor
                   break
               end
           end
           
           if w != 0
               push!(dfs_stack, w)
               color[w] = 1
           else
               push!(order, u)  #Push back in vector to store the order in which the traversal finishes(Reverse Topological Sort)
               color[u] = 2
               pop!(dfs_stack)    
           end
       end
   end
    
   @inbounds for i in vertices(g)
        color[i] = 0    # Marking all the vertices from 1 to n as unvisited for dfs2
   end
   
   # dfs2
   @inbounds for i in 1:nvg
    
       v = order[end-i+1]   # Reading the order vector in the decreasing order of finish time
       color[v] != 0  && continue  
       color[v] = 1
       
       component=Vector{T}()   # Vector used to store the vertices of one component temporarily
       
       # Start dfs from v
       push!(dfs_stack, v)   # Push v to the stack
      
       while !isempty(dfs_stack)
           u = dfs_stack[end]
           w = zero(T)
       
           for u_neighbor in inneighbors(g, u)
               if  color[u_neighbor] == 0
                   w = u_neighbor
                   break
               end
           end
           
           if w != 0
               push!(dfs_stack, w)
               color[w] = 1
           else
               color[u] = 2
               push!(component, u)   # Push u to the vector component
               pop!(dfs_stack)    
           end
       end
       
       push!(components, component)
   end
 
   return components
end


"""
    is_strongly_connected(g)

Return `true` if directed graph `g` is strongly connected.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_strongly_connected(g)
true
```
"""
function is_strongly_connected end
@traitfn is_strongly_connected(g::::IsDirected) = length(strongly_connected_components(g)) == 1

"""
    period(g)

Return the (common) period for all vertices in a strongly connected directed graph.
Will throw an error if the graph is not strongly connected.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> period(g)
3
```
"""
function period end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function period(g::AG::IsDirected) where {T, AG <: AbstractGraph{T}}
    !is_strongly_connected(g) && throw(ArgumentError("Graph must be strongly connected"))

    # First check if there's a self loop
    has_self_loops(g) && return 1

    g_bfs_tree  = bfs_tree(g, 1)
    levels      = gdistances(g_bfs_tree, 1)
    tree_diff   = difference(g, g_bfs_tree)
    edge_values = Vector{T}()

    divisor = 0
    for e in edges(tree_diff)
        @inbounds value = levels[src(e)] - levels[dst(e)] + 1
        divisor = gcd(divisor, value)
        isequal(divisor, 1) && return 1
    end

    return divisor
end

"""
    condensation(g[, scc])

Return the condensation graph of the strongly connected components `scc`
in the directed graph `g`. If `scc` is missing, generate the strongly
connected components first.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0])
{5, 6} directed simple Int64 graph

julia> strongly_connected_components(g)
2-element Array{Array{Int64,1},1}:
 [4, 5]
 [1, 2, 3]

julia> foreach(println, edges(condensation(g)))
Edge 2 => 1
```
"""
function condensation end
@traitfn function condensation(g::::IsDirected, scc::Vector{Vector{T}}) where T <: Integer
    h = DiGraph{T}(length(scc))

    component = Vector{T}(undef, nv(g))

    for (i, s) in enumerate(scc)
        @inbounds component[s] .= i
    end

    @inbounds for e in edges(g)
        s, d = component[src(e)], component[dst(e)]
        if (s != d)
            add_edge!(h, s, d)
        end
    end
    return h
end
@traitfn condensation(g::::IsDirected) = condensation(g, strongly_connected_components(g))

"""
    attracting_components(g)

Return a vector of vectors of integers representing lists of attracting
components in the directed graph `g`.

The attracting components are a subset of the strongly
connected components in which the components do not have any leaving edges.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0])
{5, 6} directed simple Int64 graph

julia> strongly_connected_components(g)
2-element Array{Array{Int64,1},1}:
 [4, 5]
 [1, 2, 3]

julia> attracting_components(g)
1-element Array{Array{Int64,1},1}:
 [4, 5]
```
"""
function attracting_components end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function attracting_components(g::AG::IsDirected) where {T, AG <: AbstractGraph{T}}
    scc  = strongly_connected_components(g)
    cond = condensation(g, scc)

    attracting = Vector{T}()

    for v in vertices(cond)
        if outdegree(cond, v) == 0
            push!(attracting, v)
        end
    end
    return scc[attracting]
end

"""
    neighborhood(g, v, d, distmx=weights(g))

Return a vector of each vertex in `g` at a geodesic distance less than or equal to `d`, where distances
may be specified by `distmx`.

### Optional Arguments
- `dir=:out`: If `g` is directed, this argument specifies the edge direction
with respect to `v` of the edges to be considered. Possible values: `:in` or `:out`.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> neighborhood(g, 1, 2)
3-element Array{Int64,1}:
 1
 2
 3

julia> neighborhood(g, 1, 3)
4-element Array{Int64,1}:
 1
 2
 3
 4

julia> neighborhood(g, 1, 3, [0 1 0 0 0; 0 0 1 0 0; 1 0 0 0.25 0; 0 0 0 0 0.25; 0 0 0 0.25 0])
5-element Array{Int64,1}:
 1
 2
 3
 4
 5
```
"""
neighborhood(g::AbstractGraph{T}, v::Integer, d, distmx::AbstractMatrix{U}=weights(g); dir=:out) where T <: Integer where U <: Real =
    first.(neighborhood_dists(g, v, d, distmx; dir=dir))

"""
    neighborhood_dists(g, v, d, distmx=weights(g))

Return a a vector of tuples representing each vertex which is at a geodesic distance less than or equal to `d`, along with
its distance from `v`. Non-negative distances may be specified by `distmx`.

### Optional Arguments
- `dir=:out`: If `g` is directed, this argument specifies the edge direction
with respect to `v` of the edges to be considered. Possible values: `:in` or `:out`.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> neighborhood_dists(g, 1, 3)
4-element Array{Tuple{Int64,Int64},1}:
 (1, 0)
 (2, 1)
 (3, 2)
 (4, 3)

julia> neighborhood_dists(g, 1, 3, [0 1 0 0 0; 0 0 1 0 0; 1 0 0 0.25 0; 0 0 0 0 0.25; 0 0 0 0.25 0])
5-element Array{Tuple{Int64,Float64},1}:
 (1, 0.0)
 (2, 1.0)
 (3, 2.0)
 (4, 2.25)
 (5, 2.5)

julia> neighborhood_dists(g, 4, 3)
2-element Array{Tuple{Int64,Int64},1}:
 (4, 0)
 (5, 1)

julia> neighborhood_dists(g, 4, 3, dir=:in)
5-element Array{Tuple{Int64,Int64},1}:
 (4, 0)
 (3, 1)
 (5, 1)
 (2, 2)
 (1, 3)
```
"""
neighborhood_dists(g::AbstractGraph{T}, v::Integer, d, distmx::AbstractMatrix{U}=weights(g); dir=:out) where T <: Integer where U <: Real =
    (dir == :out) ? _neighborhood(g, v, d, distmx, outneighbors) : _neighborhood(g, v, d, distmx, inneighbors)


function _neighborhood(g::AbstractGraph{T}, v::Integer, d::Real, distmx::AbstractMatrix{U}, neighborfn::Function) where T <: Integer where U <: Real
    Q = Vector{Tuple{T,U}}()
    d < zero(U) && return Q
    push!(Q, (v,zero(U),) )
    seen = fill(false,nv(g)); seen[v] = true #Bool Vector benchmarks faster than BitArray
    for (src,currdist) in Q
        currdist >= d && continue
        for dst in neighborfn(g,src)
            if !seen[dst]
                seen[dst]=true
                if currdist+distmx[src,dst] <= d
                    push!(Q, (dst , currdist+distmx[src,dst],))
                end
            end
        end
    end
    return Q
end

"""
    isgraphical(degs)

Return true if the degree sequence `degs` is graphical.
A sequence of integers is called graphical, if there exists a graph where the degrees of its vertices form that same sequence.

### Performance
Time complexity: ``\\mathcal{O}(|degs|*\\log(|degs|))``.

### Implementation Notes
According to Erdös-Gallai theorem, a degree sequence ``\\{d_1, ...,d_n\\}`` (sorted in descending order) is graphic iff the sum of vertex degrees is even and the sequence obeys the property -
```math
\\sum_{i=1}^{r} d_i \\leq r(r-1) + \\sum_{i=r+1}^n min(r,d_i)
```
for each integer r <= n-1
"""
function isgraphical(degs::Vector{<:Integer})
    iseven(sum(degs)) || return false
    sorted_degs = sort(degs, rev = true)
    n = length(sorted_degs)
    cur_sum = zero(UInt64)
    mindeg = Vector{UInt64}(undef, n)
    @inbounds for i = 1:n
        mindeg[i] = min(i, sorted_degs[i])
    end
    cum_min = sum(mindeg)
    @inbounds for r = 1:(n - 1)
        cur_sum += sorted_degs[r]
        cum_min -= mindeg[r]
        cond = cur_sum <= (r * (r - 1) + cum_min)
        cond || return false
    end
    return true
end
