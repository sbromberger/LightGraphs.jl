"""
    random_independent_set_it(g)

### Implementation Notes
Performs [Approximate Maximum Independent Set](https://en.wikipedia.org/wiki/Maximal_independent_set#Sequential_algorithm) once.
Returns a vector of vertices representing the vertices in the independent set.
### Performance
O(|V|+|E|)
### Approximation Factor
max(degree(g))+1
"""
function random_independent_set_it(
    g::AbstractGraph{T}
    ) where T <: Integer 
  
    ind_set = Vector{T}()  
    deleted = zeros(Bool, nv(g))
    perm_v = Random.shuffle(collect(vertices(g)))

    for v in perm_v
        deleted[v] && continue
        deleted[v] = true
        push!(ind_set, v)
        for u in neighbors(g, v)
            deleted[u] = true
        end
    end

    return ind_set
end

best_ind_set(is1::Vector{T}, is2::Vector{T}) where T <: Integer = size(is1)[1] > size(is2)[1] ? is1 : is2

"""
    seq_random_independent_set(g, reps)

### Implementation Notes
Performs [Approximate Maximum Independent Set](https://en.wikipedia.org/wiki/Maximal_independent_set#Sequential_algorithm) once.
`reps` times and returns the cover with the least vertices.
### Performance
O((|V|+|E|)*reps)
### Approximation Factor
max(degree(g))+1
"""
function seq_random_independent_set(
    g::AbstractGraph{T},
    reps::Integer
    ) where T <: Integer 

    ind_set = random_independent_set_it(g)
    for i in 2:reps
        ind_set = best_ind_set(random_independent_set_it(g), ind_set)
    end
    return ind_set
end

"""
    parallel_random_independent_set(g, reps)

### Implementation Notes
Performs [Approximate Maximum Independent Set](https://en.wikipedia.org/wiki/Maximal_independent_set#Sequential_algorithm) once.
`reps` times in parallel and returns the cover with the least vertices.
### Performance
O((|V|+|E|)*reps)
### Approximation Factor
max(degree(g))+1
"""
function parallel_random_independent_set(
    g::AbstractGraph{T},
    reps::Integer
    ) where T <: Integer 

    type_instable_ind_set = @distributed (best_ind_set) for i in 1:max(1, reps)
        random_independent_set_it(g)
    end
    ind_set = Vector{T}() #Makes the code type stable
    sizehint!(ind_set, size(type_instable_ind_set)[1])
    for i in type_instable_ind_set
        push!(ind_set, i)
    end

    return ind_set
end

"""
    random_independent_set(g, reps=1; parallel=true)

### Implementation Notes
Performs [Approximate Maximum Independent Set](https://en.wikipedia.org/wiki/Maximal_independent_set#Sequential_algorithm) once.
which iteratively chooses a vertex at random for the set removes the vertex and its neighbors from the graph.
It repreats the algorithm `reps` times and returns the independent set with the most vertices.
Returns a vector of vertices representing the vertices in the independent set.
If arguement `parallel` is set true then the repetitions are done in parallel on different processes.
### Performance
O(reps*(|V|+|E|))
### Approximation Factor
max(degree(g))+1
"""
random_independent_set(g::AbstractGraph{T}, reps::Integer=1; parallel::Bool=false) where {T<:Integer} =
parallel ? parallel_random_independent_set(g, reps) : seq_random_independent_set(g, reps)
