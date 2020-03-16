"""
    biconnected_components(g) -> Vector{Vector{Edge{eltype(g)}}}

Compute the [biconnected components](https://en.wikipedia.org/wiki/Biconnected_component)
of an undirected graph `g`and return a vector of vectors containing each
biconnected component.

Performance:
Time complexity is ``\\mathcal{O}(|V|)``.

# Examples
```jldoctest
julia> using LightGraphs

julia> biconnected_components(star_graph(5))
4-element Array{Array{LightGraphs.SimpleGraphs.SimpleEdge,1},1}:
 [Edge 1 => 3]
 [Edge 1 => 4]
 [Edge 1 => 5]
 [Edge 1 => 2]

julia> biconnected_components(cycle_graph(5))
1-element Array{Array{LightGraphs.SimpleGraphs.SimpleEdge,1},1}:
 [Edge 1 => 5, Edge 4 => 5, Edge 3 => 4, Edge 2 => 3, Edge 1 => 2]
```
"""
function biconnected_components end
@traitfn function biconnected_components(g::::(!IsDirected))
    nvg = nv(g)
    T = eltype(g)
    S = Vector{Tuple{T, T}}()
    E = Edge{eltype(g)}
    edge_st = Vector{E}()
    components = Vector{Vector{E}}()
    idx = zero(T)      # preorder counter
    low = zeros(T, nvg)
    pre = zeros(T, nvg)
    #stack pointer to emulate what happens in function call,
    #that will make us avoid the reallocation of push and pop vector
    stack_ptr = zero(T) #stack pointer to emulate what happens in function  call, that will make us avoid the reallocation of push and pop vector
    @inbounds for us in vertices(g)
        pre[us] == 0 || continue # don’t go to visited nodes again
        #stack_ptr += 1
        #S[stack_ptr] = (us, 1)
        push!(S, (us, 1))
        ptr = one(T)    
        while length(S) > 0
            v, _ = S[end]
            if ptr == 1  # if ptr == 1 then we all in this node for the first time
                idx += 1
                low[v] = pre[v] = idx
            end
            neighs = outneighbors(g, v)
            while ptr <= length(neighs)
                i = neighs[ptr]            
                if pre[i] ==  0
                    e = i < v ? E(i, v) : E(v, i)
                    push!(edge_st, e)
                    #stack_ptr += 1
                    #S[stack_ptr] = (i, ptr+1)
                    push!(S, (i, ptr + 1))
                    break
                elseif (!(length(S) > 1 && i == S[end-1][1])) && pre[i] < low[v]
                    low[v] = pre[i]
                    e = i < v ? E(i, v) : E(v, i)
                    push!(edge_st, e)
                end
        
                ptr += 1
            end
            #if ptr > length(neighs) then i finished my processing
            # and will return to my parent, else i will go to new node
            if ptr > length(neighs)
                _, ptr = S[end]
                #stack_ptr -= 1
                pop!(S)
                if length(S) >= 1
                    p, _ = S[end]   #  my parent
                    if low[v] < low[p]
                        low[p] = low[v]
                    elseif low[v] >= pre[p] # find if my parent is an articulation point
                        e = E(0, 0) #Invalid Edge, used for comparison only
                        st = Vector{E}()
                        e2 = p < v ? E(p, v) : E(v, p)
                        while e != e2
                            e = pop!(edge_st)
                            push!(st, e)
                        end
                        push!(components, st)                    
                    end                   
                end
            else
                ptr = 1                
            end           
        end   
    end       
    return components
end
