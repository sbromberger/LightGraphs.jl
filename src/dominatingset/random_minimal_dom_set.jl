"""
    random_minimal_dominating_set_it(g)

### Implementation Notes
Initially, every vertex is in the dominating set.
In some random order, we check if the removal of a vertex from the dominating set will no longer make the
vertex a dominating set. If no, the vertex is removed from the dominating set,
### Performance
O(|V|+|E|)
"""    
function random_minimal_dominating_set_it(
    g::AbstractGraph{T}
    ) where T <: Integer 

    nvg::T = nv(g)  
    is_dom = ones(Bool, nvg)  
    dom_degree = degree(g)
    perm_v = Random.shuffle(collect(vertices(g)))
    dom_size = nvg

    for v in perm_v
    	(dom_degree[v] == 0) && continue
    	safe = true
    	for u in neighbors(g, v)
        	if !is_dom[u] && dom_degree[u] <= 1
        		safe = false
        		break
        	end
        end
        safe || continue
        is_dom[v] = false
        dom_size -= 1
        for u in neighbors(g, v)
        	dom_degree[u] -= 1
        end
    end

    dom_set = Vector{T}()
    sizehint!(dom_set, dom_size)
    for i in 1:nvg
    	is_dom[i] && push!(dom_set, i)
    end

    return dom_set
end

best_dom_set(ds1::Vector{T}, ds2::Vector{T}) where T <: Integer = size(ds1)[1] < size(ds2)[1] ? ds1 : ds2

"""
    seq_random_minimal_dominating_set(g, reps)

### Implementation Notes
Initially, every vertex is in the dominating set.
In some random order, we check if the removal of a vertex from the dominating set will no longer make the
vertex a dominating set. If no, the vertex is removed from the dominating set,
It repreats the algorithm `reps` times and returns the set with the least vertices.
### Performance
O((|V|+|E|)*reps)
"""
function seq_random_minimal_dominating_set(
    g::AbstractGraph{T},
    reps::Integer
    ) where T <: Integer 

    dom_set = random_minimal_dominating_set_it(g)
    for i in 2:reps
        dom_set = best_dom_set(random_minimal_dominating_set_it(g), dom_set)
    end
    return dom_set
end

"""
    parallel_random_minimal_dominating_set(g, reps)

### Implementation Notes
Initially, every vertex is in the dominating set.
In some random order, we check if the removal of a vertex from the dominating set will no longer make the
vertex a dominating set. If no, the vertex is removed from the dominating set,
It repreats the algorithm `reps` times in parallel and returns the set with the least vertices
### Performance
O((|V|+|E|)*reps)
"""
function parallel_random_minimal_dominating_set(
    g::AbstractGraph{T},
    reps::Integer
    ) where T <: Integer 

    type_instable_dom_set = @distributed (best_dom_set) for i in 1:max(1, reps)
        random_minimal_dominating_set_it(g)
    end
    
    dom_set = Vector{T}() #Makes the code type stable
    sizehint!(dom_set, size(type_instable_dom_set)[1])
    for i in type_instable_dom_set
        push!(dom_set, i)
    end
    return dom_set
end

"""
    random_minimal_dominating_set(g, reps=1; parallel=true)

### Implementation Notes
Initially, every vertex is in the dominating set.
In some random order, we check if the removal of a vertex from the dominating set will no longer make the
vertex a dominating set. If no, the vertex is removed from the dominating set,
It repreats the algorithm `reps` times and returns the set with the least vertices.
If arguement `parallel` is set true then the repetitions are done in parallel on different processes.
### Performance
O(reps*(|V|+|E|))
"""
random_minimal_dominating_set(g::AbstractGraph{T},reps::Integer=1; parallel::Bool=false) where {T<:Integer} =
parallel ? parallel_random_minimal_dominating_set(g, reps) : seq_random_minimal_dominating_set(g, reps)
