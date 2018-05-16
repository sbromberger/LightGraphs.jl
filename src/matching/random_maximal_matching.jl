"""
    random_maximal_matching_it(g)

### Implementation Notes
Performs [Approximate Maximum Matching](https://en.wikipedia.org/wiki/Vertex_matching#Approximate_evaluation) once.
Returns a vector of edges representing the edges in the Matching.
### Performance
O(|V|+|E|)
"""
function random_maximal_matching_it(
    g::AbstractGraph{T}
    ) where T <: Integer 

    nvg::T = nv(g)  
    matching = Vector{Edge{T}}()  
    seen = zeros(Bool, nvg)
    edge_list = Random.shuffle(collect(edges(g)))

    for e in edge_list
        if !(seen[e.src] || seen[e.dst])
            seen[e.src] = seen[e.dst] = true
            push!(matching, e)
        end
    end
    return matching
end

best_matching(m1::Vector{Edge{T}}, m2::Vector{Edge{T}}) where T <: Integer = size(m1)[1] > size(m2)[1] ? m1 : m2

"""
    seq_random_maximal_matching(g, reps)

### Implementation Notes
Performs [Approximate Maximum Matching](https://en.wikipedia.org/wiki/Vertex_matching#Approximate_evaluation)
`reps` times and returns the matching with the most edges.
### Performance
O((|V|+|E|)*reps)
"""
function seq_random_maximal_matching(
    g::AbstractGraph{T},
    reps::Integer
    ) where T <: Integer 

    matching = random_maximal_matching_it(g)
    for i in 2:reps
        matching = best_matching(random_maximal_matching_it(g), matching)
    end

    return matching
end

"""
    parallel_random_maximal_matching(g, reps)

### Implementation Notes
Performs [Approximate Maximum Matching](https://en.wikipedia.org/wiki/Vertex_matching#Approximate_evaluation)
`reps` times in parallel and returns the matching with the most edges.
### Performance
O((|V|+|E|)*reps)
"""
function parallel_random_maximal_matching(
    g::AbstractGraph{T},
    reps::Integer
    ) where T <: Integer 

    type_instable_matching = @distributed (best_matching) for i in 1:max(1, reps)
        random_maximal_matching_it(g)
    end
    matching = Vector{Edge{T}}() #Makes the code type stable
    sizehint!(matching, size(type_instable_matching)[1])
    for i in type_instable_matching
        push!(matching, i)
    end
    return matching
end

"""
    random_maximal_matching(g, reps=1; parallel=true)

### Implementation Notes
Performs [Approximate Maximum Matching](https://en.wikipedia.org/wiki/Vertex_matching#Approximate_evaluation)
Returns a vector of edges representing the edges in the matching.
It repreats the algorithm `reps` times and returns the matching with the most edges.
If arguement `parallel` is set true then the repetitions are done in parallel on different processes.
### Performance
O(reps*(|V|+|E|))
"""
random_maximal_matching(g::AbstractGraph{T},reps::Integer=1; parallel::Bool=false) where {T<:Integer} =
parallel ? parallel_random_maximal_matching(g, reps) : seq_random_maximal_matching(g, reps)
