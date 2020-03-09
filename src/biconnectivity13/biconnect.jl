
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
        n = nv(g)
        S = Array{Tuple{Int, Int}, 1}(undef,n)
        E = Edge{eltype(g)}
        edge_st = Vector{E}()
        components = Vector{Vector{E}}()
        idx = zero(Int)      # preorder counter
        low = zeros(Int, nv(g))
        pre = zeros(Int, nv(g))
        #stack pointer to emulate what happens in function call,
        #that will make us avoid the reallocation of push and pop vector
        stack_ptr = zero(Int) #stack pointer to emulate what happens in function  call, that will make us avoid the reallocation of push and pop vector

    @inbounds for us in vertices(g)
        pre[us] == 0 || continue # don’t go to visited nodes again
        stack_ptr += 1
        S[stack_ptr] = (us, 1)
        ptr = one(Int)

        while stack_ptr > 0
            v, _ = S[stack_ptr]
            if ptr == 1  # if ptr == 1 then we all in this node for the first time
                idx+=1
                low[v] = pre[v] = idx
            end

            neighs = outneighbors(g, v)
             while ptr <= length(neighs)
                i = neighs[ptr]

                if pre[i] ==  0
                    push!(edge_st, E(min(i, v), max(i, v)))
                    stack_ptr += 1
                    S[stack_ptr] = (i, ptr+1)
                    break
                elseif (!(stack_ptr > 1 && i == S[stack_ptr-1][1])) && pre[i] < low[v]
                    low[v] = pre[i]
                    push!(edge_st, E(min(v, i), max(v, i)))
                end

                ptr += 1
            end

            #if ptr > length(neighs) then i finished my processing
            # and will return to my parent, else i will go to new node

            if ptr > length(neighs)
                _, ptr = S[stack_ptr]
                stack_ptr -= 1
                if stack_ptr >= 1
                    p, _ = S[stack_ptr]   #  my parent
                   if low[v] < low[p]
                        low[p] = low[v]
                    elseif low[v] >= pre[p] # find if my parent is an articulation point
                    e = E(0, 0) #Invalid Edge, used for comparison only
                    st = Vector{E}()
                    while e != E(min(p, v), max(p, v))
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
