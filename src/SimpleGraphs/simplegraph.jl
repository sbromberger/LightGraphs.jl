const SimpleGraphEdge = SimpleEdge

"""
    SimpleGraph{T}

A type representing an undirected graph.
"""
mutable struct SimpleGraph{T <: Integer} <: AbstractSimpleGraph{T}
    ne::Int
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)
end

eltype(x::SimpleGraph{T}) where T = T

# Graph{UInt8}(6), Graph{Int16}(7), Graph{UInt8}()
"""
    SimpleGraph{T}(n=0)

Construct a `SimpleGraph{T}` with `n` vertices and 0 edges.
If not specified, the element type `T` is the type of `n`.

## Examples
```jldoctest
julia> SimpleGraph(UInt8(10))
{10, 0} undirected simple UInt8 graph
```
"""
function SimpleGraph{T}(n::Integer=0) where T <: Integer
    fadjlist = [Vector{T}() for _ = one(T):n]
    return SimpleGraph{T}(0, fadjlist)
end

# SimpleGraph(6), SimpleGraph(0x5)
SimpleGraph(n::T) where T <: Integer = SimpleGraph{T}(n)

# SimpleGraph()
SimpleGraph() = SimpleGraph{Int}()

# SimpleGraph(UInt8)
"""
    SimpleGraph(::Type{T})

Construct an empty `SimpleGraph{T}` with 0 vertices and 0 edges.

## Examples
```jldoctest
julia> SimpleGraph(UInt8)
{0, 0} undirected simple UInt8 graph
```
"""
SimpleGraph(::Type{T}) where T <: Integer = SimpleGraph{T}(zero(T))

# SimpleGraph(adjmx)
"""
    SimpleGraph{T}(adjm::AbstractMatrix)

Construct a `SimpleGraph{T}` from the adjacency matrix `adjm`.
If `adjm[i][j] != 0`, an edge `(i, j)` is inserted. `adjm` must be a square and symmetric matrix.
The element type `T` can be omitted.

## Examples
```jldoctest
julia> A1 = [false true; true false]
julia> SimpleGraph(A1)
{2, 1} undirected simple Int64 graph

julia> A2 = [2 7; 7 0]
julia> SimpleGraph{Int16}(A2)
{2, 2} undirected simple Int16 graph
```
"""
SimpleGraph(adjmx::AbstractMatrix) = SimpleGraph{Int}(adjmx)

# Graph{UInt8}(adjmx)
function SimpleGraph{T}(adjmx::AbstractMatrix) where T <: Integer
    dima, dimb = size(adjmx)
    isequal(dima, dimb) || throw(ArgumentError("Adjacency / distance matrices must be square"))
    issymmetric(adjmx) || throw(ArgumentError("Adjacency / distance matrices must be symmetric"))

    g = SimpleGraph(T(dima))
    @inbounds for i in findall(triu(adjmx) .!= 0)
        add_edge!(g, i[1], i[2])
    end
    return g
end

# SimpleGraph of a SimpleGraph
"""
    SimpleGraph{T}(g::SimpleGraph)

Construct a copy of g.
If the element type `T` is specified, the vertices of `g` are converted to this type.
Otherwise the element type is the same as for `g`.

## Examples
```jldoctest
julia> g = CompleteGraph(5)
julia> SimpleGraph{UInt8}(g)
{5, 10} undirected simple UInt8 graph
```
"""
SimpleGraph(g::SimpleGraph) = copy(g)

# converts Graph{Int} to Graph{Int32}
function SimpleGraph{T}(g::SimpleGraph) where T <: Integer
    h_fadj = [Vector{T}(x) for x in fadj(g)]
    return SimpleGraph(ne(g), h_fadj)
end



# SimpleGraph(digraph)
"""
    SimpleGraph(g::SimpleDiGraph)

Construct an undirected `SimpleGraph` from a directed `SimpleDiGraph`.
Every directed edge in `g` is added as an undirected edge.
The element type is the same as for `g`.

## Examples
```jldoctest
julia> g = PathDiGraph(Int8(5))
julia> SimpleGraph(g)
{5, 4} undirected simple Int8 graph
```
"""
function SimpleGraph(g::SimpleDiGraph)
    gnv = nv(g)
    edgect = 0
    newfadj = deepcopy(g.fadjlist)
    @inbounds for i in vertices(g)
        for j in badj(g, i)
            index = searchsortedfirst(newfadj[i], j)
            if index <= length(newfadj[i]) && newfadj[i][index] == j
                edgect += 1     # this is an existing edge - we already have it
                if i == j
                    edgect += 1 # need to count self loops
                end
            else
                insert!(newfadj[i], index, j)
                edgect += 2      # this is a new edge only in badjlist
            end
        end
    end
    iseven(edgect) || throw(AssertionError("invalid edgect in graph creation - please file bug report"))
    return SimpleGraph(edgect ÷ 2, newfadj)
end


@inbounds function cleanupedges!(fadjlist::Vector{Vector{T}}) where T <: Integer
    neg = 0
    for v in 1:length(fadjlist)
        if !issorted(fadjlist[v])
            sort!(fadjlist[v])
        end
        unique!(fadjlist[v])
        neg += length(fadjlist[v])
        # self-loops should count as one edge
        for w in fadjlist[v]
            if w == v
                neg += 1
                break
            end
        end
    end
    return neg ÷ 2
end

"""
    SimpleGraph(edge_list::Vector)

Construct a `SimpleGraph` from a vector of edges.
The element type is taken from the edges in `edge_list`.
The number of vertices is the highest that is used in an edge in `edge_list`.

### Implementation Notes
This constructor works the fastest when `edge_list` is sorted
by the lexical ordering and does not contain any duplicates.

### See also
[`SimpleGraphFromIterator`](@ref)

## Examples
```jldoctest

julia> el = Edge.([ (1, 2), (1, 5) ])
julia> SimpleGraph(el)
{5, 2} undirected simple Int64 graph
```
"""
function SimpleGraph(edge_list::Vector{SimpleGraphEdge{T}}) where T <: Integer
    nvg = zero(T)
    @inbounds(
    for e in edge_list
        nvg = max(nvg, src(e), dst(e)) 
    end)
   
    list_sizes = ones(Int, nvg)
    degs = zeros(Int, nvg)
    @inbounds(
    for e in edge_list
        s, d = src(e), dst(e)
        (s >= 1 && d >= 1) || continue
        degs[s] += 1
        if s != d
            degs[d] += 1
        end
    end)
    
    fadjlist = Vector{Vector{T}}(undef, nvg)
    @inbounds(
    for v in 1:nvg
        fadjlist[v] = Vector{T}(undef, degs[v])
    end)

    @inbounds(
    for e in edge_list
        s, d = src(e), dst(e)
        (s >= 1 && d >= 1) || continue
        fadjlist[s][list_sizes[s]] = d 
        list_sizes[s] += 1
        if s != d 
            fadjlist[d][list_sizes[d]] = s 
            list_sizes[d] += 1
        end
    end)

    neg = cleanupedges!(fadjlist)
    g = SimpleGraph{T}()
    g.fadjlist = fadjlist
    g.ne = neg

    return g
end


@inbounds function add_to_fadjlist!(fadjlist::Vector{Vector{T}}, s::T, d::T) where T <: Integer
    nvg = length(fadjlist)
    nvg_new = max(nvg, s, d)
    for v = (nvg + 1):nvg_new
        push!(fadjlist, Vector{T}())
    end

    push!(fadjlist[s], d)
    if s != d
        push!(fadjlist[d], s)
    end
end

function _SimpleGraphFromIterator(iter)::SimpleGraph
    T = Union{}
    fadjlist = Vector{Vector{T}}() 
    @inbounds(
    for e in iter
        typeof(e) <: SimpleGraphEdge ||
                        throw(ArgumentError("iter must be an iterator over SimpleEdge"))
        s, d = src(e), dst(e)
        (s >= 1 && d >= 1) || continue
        if T != eltype(e)
            T = typejoin(T, eltype(e)) 
            fadjlist = convert(Vector{Vector{T}}, fadjlist)
        end
        add_to_fadjlist!(fadjlist, s, d)
    end)

    T == Union{} && return SimpleGraph(0)
    neg  = cleanupedges!(fadjlist)
    g = SimpleGraph{T}()
    g.fadjlist = fadjlist
    g.ne = neg
    
    return g
end

function _SimpleGraphFromIterator(iter, ::Type{SimpleGraphEdge{T}}) where T <: Integer
    fadjlist = Vector{Vector{T}}() 
    @inbounds(
    for e in iter
        s, d = src(e), dst(e)
        (s >= 1 && d >= 1) || continue
        add_to_fadjlist!(fadjlist, s, d)
    end)

    neg  = cleanupedges!(fadjlist)
    g = SimpleGraph{T}()
    g.fadjlist = fadjlist
    g.ne = neg

    return g
end

"""
    SimpleGraphFromIterator(iter)

Create a [`SimpleGraph`](@ref) from an iterator `iter`. The elements in iter must
be of `type <: SimpleEdge`.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(3);

julia> add_edge!(g, 1, 2);

julia> add_edge!(g, 2, 3);

julia> h = SimpleGraphFromIterator(edges(g));

julia> collect(edges(h))
2-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
```
"""
function SimpleGraphFromIterator(iter)::SimpleGraph
    if Base.IteratorEltype(iter) == Base.EltypeUnknown()
        return _SimpleGraphFromIterator(iter)
    end
    if eltype(iter) <: SimpleGraphEdge && isconcretetype(eltype(iter))
        return _SimpleGraphFromIterator(iter, eltype(iter))
    end
    return _SimpleGraphFromIterator(iter)
end


edgetype(::SimpleGraph{T}) where T <: Integer = SimpleGraphEdge{T}

"""
    badj(g::SimpleGraph[, v::Integer])

Return the backwards adjacency list of a graph. If `v` is specified,
return only the adjacency list for that vertex.

###Implementation Notes
Returns a reference, not a copy. Do not modify result.
"""
badj(g::SimpleGraph) = fadj(g)
badj(g::SimpleGraph, v::Integer) = fadj(g, v)


"""
    adj(g[, v])

Return the adjacency list of a graph. If `v` is specified, return only the
adjacency list for that vertex.

### Implementation Notes
Returns a reference, not a copy. Do not modify result.
"""
adj(g::SimpleGraph) = fadj(g)
adj(g::SimpleGraph, v::Integer) = fadj(g, v)

copy(g::SimpleGraph) =  SimpleGraph(g.ne, deepcopy(g.fadjlist))

==(g::SimpleGraph, h::SimpleGraph) =
vertices(g) == vertices(h) &&
ne(g) == ne(h) &&
fadj(g) == fadj(h)


"""
    is_directed(g)

Return `true` if `g` is a directed graph.
"""
is_directed(::Type{SimpleGraph}) = false
is_directed(::Type{SimpleGraph{T}}) where T = false
is_directed(g::SimpleGraph) = false

function has_edge(g::SimpleGraph{T}, s, d) where T
    verts = vertices(g)
    (s in verts && d in verts) || return false  # edge out of bounds
    @inbounds list_s = g.fadjlist[s]
    @inbounds list_d = g.fadjlist[d]
    if length(list_s) > length(list_d)
        d = s
        list_s = list_d
    end
    return insorted(d, list_s)
end

function has_edge(g::SimpleGraph{T}, e::SimpleGraphEdge{T}) where T
    s, d = T.(Tuple(e))
    return has_edge(g, s, d)
end

"""
    add_edge!(g, e)

Add an edge `e` to graph `g`. Return `true` if edge was added successfully,
otherwise return `false`.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(2);

julia> add_edge!(g, 1, 2)
true

julia> add_edge!(g, 2, 3)
false
```
"""
function add_edge!(g::SimpleGraph{T}, e::SimpleGraphEdge{T}) where T
    s, d = T.(Tuple(e))
    verts = vertices(g)
    (s in verts && d in verts) || return false  # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) && return false  # edge already in graph
    insert!(list, index, d)

    g.ne += 1
    s == d && return true  # selfloop

    @inbounds list = g.fadjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    return true  # edge successfully added
end

"""
    rem_edge!(g, e)

Remove an edge `e` from graph `g`. Return `true` if edge was removed successfully,
otherwise return `false`.

### Implementation Notes
If `rem_edge!` returns `false`, the graph may be in an indeterminate state, as
there are multiple points where the function can exit with `false`.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(2);

julia> add_edge!(g, 1, 2);

julia> rem_edge!(g, 1, 2)
true

julia> rem_edge!(g, 1, 2)
false
```
"""
function rem_edge!(g::SimpleGraph{T}, e::SimpleGraphEdge{T}) where T
    s, d = T.(Tuple(e))
    verts = vertices(g)
    (s in verts && d in verts) || return false  # edge out of bounds
    @inbounds list = g.fadjlist[s] 
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false  # edge not in graph   
    deleteat!(list, index)

    g.ne -= 1
    s == d && return true  # selfloop

    @inbounds list = g.fadjlist[d] 
    index = searchsortedfirst(list, s)
    deleteat!(list, index)
    return true  # edge successfully removed
end


"""
    add_vertex!(g)

Add a new vertex to the graph `g`. Return `true` if addition was successful.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleGraph(Int8(typemax(Int8) - 1))
{126, 0} undirected simple Int8 graph

julia> add_vertex!(g)
true

julia> add_vertex!(g)
false
```
"""
function add_vertex!(g::SimpleGraph{T}) where T
    (nv(g) + one(T) <= nv(g)) && return false       # test for overflow
    push!(g.fadjlist, Vector{T}())
    return true
end

"""
    rem_vertices!(g, vs, keep_order=false) -> vmap

Remove all vertices in `vs` from `g`.
Return a vector `vmap` that maps the vertices in the modified graph to the ones in
the unmodified graph.
If `keep_order` is `true`, the vertices in the modified graph appear in the same
order as they did in the unmodified graph. This might be slower.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = CompleteGraph{5}
{5, 10} undirected simple Int64 graph

julia> vmap = rem_vertices!(g, [2, 4], keep_order=true);

julia> vmap
3-element Array{Int64,1}:
 1
 3
 5

julia> g
{3, 3} undirected simple Int64 graph
```
"""
function rem_vertices!(g::SimpleGraph{T},
                       vs::AbstractVector{T};
                       keep_order::Bool=false
                      ) where {T}
    # TODO There might be some room for performance improvements.
    # At the moment, we check for all edges if they stay in the graph.
    # If some vertices keep their position, this might be unnecessary.

    n = nv(g)
    isempty(vs) && return collect(Base.OneTo(n))

    # Sort and filter the vertices that we want to remove
    remove = sort(vs)
    unique!(remove)
    lo, hi = extrema(remove)
    (one(T) <= lo && hi <= n) ||
            throw(ArgumentError("Vertices to be removed must be in the range 1:nv(g)."))

    # Create a vmap that maps vertices to their new position
    # vertices that get removed are mapped to 0
    vmap = Vector{T}(undef, n)

    if keep_order
        # traverse the vertex list and shift if a vertex gets removed
        i = 1
        Δ = 0
        @inbounds for u in vertices(g)
            if i <= length(remove) && u == remove[i]
                vmap[u] = 0
                Δ += 1
                i += 1
            else
                vmap[u] = u - Δ
            end
        end
    else
        # traverse the vertex list and replace vertices that get removed
        # with the furthest one to the back that does not get removed
        i = 1
        j = length(remove)
        v = n
        @inbounds for u in vertices(g)
            u > v && break
            if i <= length(remove) && u == remove[i]
                while v == remove[j] && v > u
                   vmap[v] = 0
                   v -= one(T)
                   j -= 1
                end
                # v > remove[j] || u == v
                vmap[v] = u
                vmap[u] = 0
                v -= one(T)
                i += 1
            else
                vmap[u] = u
            end
        end
    end

    fadjlist = g.fadjlist

    # count the number of edges that will be removed
    # for an edge that gets removed we have to ensure that
    # such an edge does not get counted twice when both endpoints
    # get removed. That's why we relay on the ordering >= on the vertices.
    num_removed_edges = 0
    @inbounds for u in remove
        for v in fadjlist[u]
            if v >= u || vmap[v] != 0
                num_removed_edges += 1
            end
        end
    end
    g.ne -= num_removed_edges

    # move the lists in the adjacency list to their new position
    # The order of traversal is very important here, as otherwise we
    # could overwrite lists, that we want to keep!
    @inbounds for u in (keep_order ? (one(T):1:n) : (n:-1:one(T)))
        if vmap[u] != 0
            fadjlist[vmap[u]] = fadjlist[u]
        end
    end
    resize!(fadjlist, n - length(remove))

    # remove vertices from the lists in fadjlist
    @inbounds for list in fadjlist
        Δ = 0
        for (i, v) in enumerate(list)
            if vmap[v] == 0
                Δ += 1
            else
                list[i - Δ] = vmap[v]
            end
        end
        resize!(list, length(list) - Δ)
        if !keep_order
            sort!(list)
        end
    end

    # we create a reverse vmap, that maps vertices in the result graph
    # to the ones in the original graph. This resembles the output of
    # induced_subgraph
    reverse_vmap = Vector{T}(undef, nv(g))
    @inbounds for (i, u) in enumerate(vmap)
        if u != 0
            reverse_vmap[u] = i
        end
    end

    return reverse_vmap
end
