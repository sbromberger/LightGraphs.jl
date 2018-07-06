"""
    random_vertex_cover_it(g)

### Implementation Notes
Performs [Approximate Minimum Vertex Cover](https://en.wikipedia.org/wiki/Vertex_cover#Approximate_evaluation) once.
Returns a vector of vertices representing the vertices in the Vertex Cover.
### Performance
O(|V|+|E|)
### Approximation Factor
2
"""
function random_vertex_cover_it(
    g::AbstractGraph{T}
    ) where T <: Integer 

    nvg::T = nv(g)  
    cover = Vector{T}()  
    seen = zeros(Bool, nvg)
    edge_list = Random.shuffle(collect(edges(g)))

    for e in edge_list
        if !(seen[e.src] || seen[e.dst])
            seen[e.src] = seen[e.dst] = true
            push!(cover, e.src)
            push!(cover, e.dst)
        end
    end

    return cover
end

best_cover(c1::Vector{T}, c2::Vector{T}) where T <: Integer = size(c1)[1] < size(c2)[1] ? c1 : c2

"""
    seq_random_vertex_cover(g, reps)

### Implementation Notes
Performs [Approximate Minimum Vertex Cover](https://en.wikipedia.org/wiki/Vertex_cover#Approximate_evaluation)
`reps` times and returns the cover with the least vertices.
### Performance
O((|V|+|E|)*reps)
### Approximation Factor
2
"""
function seq_random_vertex_cover(
    g::AbstractGraph{T},
    reps::Integer
    ) where T <: Integer 

    cover = random_vertex_cover_it(g)
    for i in 2:reps
        cover = best_cover(random_vertex_cover_it(g), cover)
    end
    return cover
end

"""
    parallel_random_vertex_cover(g, reps)

### Implementation Notes
Performs [Approximate Minimum Vertex Cover](https://en.wikipedia.org/wiki/Vertex_cover#Approximate_evaluation).
`reps` times in parallel and returns the cover with the least vertices.
### Performance
O((|V|+|E|)*reps)
### Approximation Factor
2
"""
function parallel_random_vertex_cover(
    g::AbstractGraph{T},
    reps::Integer
    ) where T <: Integer 

    type_instable_cover = @distributed (best_cover) for i in 1:max(1, reps)
        random_vertex_cover_it(g)
    end
    cover = Vector{T}() #Makes the code type stable
    sizehint!(cover, size(type_instable_cover)[1])
    for i in type_instable_cover
        push!(cover, i)
    end
    return cover
end

"""
    random_vertex_cover(g, reps=1; parallel=true)

### Implementation Notes
Performs [Approximate Minimum Vertex Cover](https://en.wikipedia.org/wiki/Vertex_cover#Approximate_evaluation).
which randomly chooses both end points of an uncovered edge iteratively in some random order.
It repreats the algorithm `reps` times and returns the cover with the least vertices.
If arguement `parallel` is set true then the repetitions are done in parallel on different processes.
### Performance
O(reps*(|V|+|E|))
### Approximation Factor
2
"""
random_vertex_cover(g::AbstractGraph{T}, reps::Integer=1; parallel::Bool=false) where {T<:Integer} =
parallel ? parallel_random_vertex_cover(g, reps) : seq_random_vertex_cover(g, reps)
