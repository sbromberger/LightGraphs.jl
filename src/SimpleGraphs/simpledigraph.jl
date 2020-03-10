const SimpleDiGraphEdge = SimpleEdge

"""
    SimpleDiGraph{T}

A type representing a directed graph.
"""
mutable struct SimpleDiGraph{T<:Integer} <: AbstractSimpleGraph{T}
    ne::Int
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{T}} # [dst]: (src, src, src)

    function SimpleDiGraph{T}(
        ne::Int,
        fadjlist::Vector{Vector{T}},
        badjlist::Vector{Vector{T}},
    ) where {T}

        throw_if_invalid_eltype(T)
        return new(ne, fadjlist, badjlist)
    end
end

function SimpleDiGraph(
    ne::Int,
    fadjlist::Vector{Vector{T}},
    badjlist::Vector{Vector{T}},
) where {T}

    return SimpleDiGraph{T}(ne, fadjlist, badjlist)
end


eltype(x::SimpleDiGraph{T}) where {T} = T

# DiGraph{UInt8}(6), DiGraph{Int16}(7), DiGraph{Int8}()
"""
    SimpleDiGraph{T}(n=0)

Construct a `SimpleDiGraph{T}` with `n` vertices and 0 edges.
If not specified, the element type `T` is the type of `n`.

## Examples
```jldoctest
julia> SimpleDiGraph(UInt8(10))
{10, 0} directed simple UInt8 graph
```
"""
function SimpleDiGraph{T}(n::Integer = 0) where {T<:Integer}
    fadjlist = [Vector{T}() for _ = one(T):n]
    badjlist = [Vector{T}() for _ = one(T):n]
    return SimpleDiGraph(0, fadjlist, badjlist)
end

# SimpleDiGraph(6), SimpleDiGraph(0x5)
SimpleDiGraph(n::T) where {T<:Integer} = SimpleDiGraph{T}(n)

# SimpleDiGraph()
SimpleDiGraph() = SimpleDiGraph{Int}()

# SimpleDiGraph(UInt8)
"""
    SimpleDiGraph(::Type{T})

Construct an empty `SimpleDiGraph{T}` with 0 vertices and 0 edges.

## Examples
```jldoctest
julia> SimpleDiGraph(UInt8)
{0, 0} directed simple UInt8 graph
```
"""
SimpleDiGraph(::Type{T}) where {T<:Integer} = SimpleDiGraph{T}(zero(T))


# SimpleDiGraph(adjmx)
"""
    SimpleDiGraph{T}(adjm::AbstractMatrix)

Construct a `SimpleDiGraph{T}` from the adjacency matrix `adjm`.
If `adjm[i][j] != 0`, an edge `(i, j)` is inserted. `adjm` must be a square matrix.
The element type `T` can be omitted.

## Examples
```jldoctest
julia> A1 = [false true; false false]
julia> SimpleDiGraph(A1)
{2, 1} directed simple Int64 graph

julia> A2 = [2 7; 5 0]
julia> SimpleDiGraph{Int16}(A2)
{2, 3} directed simple Int16 graph
```
"""
SimpleDiGraph(adjmx::AbstractMatrix) = SimpleDiGraph{Int}(adjmx)

# sparse adjacency matrix constructor: SimpleDiGraph(adjmx)
function SimpleDiGraph{T}(adjmx::SparseMatrixCSC{U}) where {T<:Integer} where {U<:Real}
    dima, dimb = size(adjmx)
    isequal(dima, dimb) ||
    throw(ArgumentError("Adjacency / distance matrices must be square"))

    g = SimpleDiGraph(T(dima))
    maxc = length(adjmx.colptr)
    @inbounds for c = 1:(maxc-1)
        for rind = adjmx.colptr[c]:(adjmx.colptr[c+1]-1)
            isnz = (adjmx.nzval[rind] != zero(U))
            if isnz
                r = adjmx.rowval[rind]
                add_edge!(g, r, c)
            end
        end
    end
    return g
end

# dense adjacency matrix constructor: DiGraph{UInt8}(adjmx)
function SimpleDiGraph{T}(adjmx::AbstractMatrix{U}) where {T<:Integer} where {U<:Real}
    dima, dimb = size(adjmx)
    isequal(dima, dimb) ||
    throw(ArgumentError("Adjacency / distance matrices must be square"))

    g = SimpleDiGraph(T(dima))
    @inbounds for i in findall(adjmx .!= zero(U))
        add_edge!(g, i[1], i[2])
    end
    return g
end

# converts DiGraph{Int} to DiGraph{Int32}
"""
    SimpleDiGraph{T}(g::SimpleDiGraph)

Construct a copy of g.
If the element type `T` is specified, the vertices of `g` are converted to this type.
Otherwise the element type is the same as for `g`.

## Examples
```jldoctest
julia> g = complete_digraph(5)
julia> SimpleDiGraph{UInt8}(g)
{5, 20} directed simple UInt8 graph
```
"""
function SimpleDiGraph{T}(g::SimpleDiGraph) where {T<:Integer}
    h_fadj = [Vector{T}(x) for x in fadj(g)]
    h_badj = [Vector{T}(x) for x in badj(g)]
    return SimpleDiGraph(ne(g), h_fadj, h_badj)
end

SimpleDiGraph(g::SimpleDiGraph) = copy(g)

# constructor from abstract graph: SimpleDiGraph(graph)
"""
    SimpleDiGraph(g::AbstractSimpleGraph)

Construct an directed `SimpleDiGraph` from a graph `g`.
The element type is the same as for `g`.

## Examples
```jldoctest
julia> g = path_graph(Int8(5))
julia> SimpleDiGraph(g)
{5, 8} directed simple Int8 graph
```
"""
function SimpleDiGraph(g::AbstractSimpleGraph)
    h = SimpleDiGraph(nv(g))
    h.ne = ne(g) * 2 - num_self_loops(g)
    h.fadjlist = deepcopy_adjlist(fadj(g))
    h.badjlist = deepcopy_adjlist(badj(g))
    return h
end


@inbounds function cleanupedges!(
    fadjlist::Vector{Vector{T}},
    badjlist::Vector{Vector{T}},
) where {T<:Integer}
    neg = 0
    for v = 1:length(fadjlist)
        if !issorted(fadjlist[v])
            sort!(fadjlist[v])
        end
        if !issorted(badjlist[v])
            sort!(badjlist[v])
        end
        unique!(fadjlist[v])
        unique!(badjlist[v])
        neg += length(fadjlist[v])
    end
    return neg
end

"""
    SimpleDiGraph(edge_list::Vector)

Construct a `SimpleDiGraph` from a vector of edges.
The element type is taken from the edges in `edge_list`.
The number of vertices is the highest that is used in an edge in `edge_list`.

### Implementation Notes
This constructor works the fastest when `edge_list` is sorted
by the lexical ordering and does not contain any duplicates.

### See also
[`SimpleDiGraphFromIterator`](@ref)

## Examples
```jldoctest

julia> el = Edge.([ (1, 3), (1, 5), (3, 1) ])
julia> SimpleDiGraph(el)
{5, 3} directed simple Int64 graph
```
"""
function SimpleDiGraph(edge_list::Vector{SimpleDiGraphEdge{T}}) where {T<:Integer}
    nvg = zero(T)
    @inbounds(for e in edge_list
        nvg = max(nvg, src(e), dst(e))
    end)

    list_sizes_out = ones(Int, nvg)
    list_sizes_in = ones(Int, nvg)
    degs_out = zeros(Int, nvg)
    degs_in = zeros(Int, nvg)
    @inbounds(for e in edge_list
        s, d = src(e), dst(e)
        (s >= 1 && d >= 1) || continue
        degs_out[s] += 1
        degs_in[d] += 1
    end)

    fadjlist = Vector{Vector{T}}(undef, nvg)
    badjlist = Vector{Vector{T}}(undef, nvg)
    @inbounds(for v = 1:nvg
        fadjlist[v] = Vector{T}(undef, degs_out[v])
        badjlist[v] = Vector{T}(undef, degs_in[v])
    end)

    @inbounds(for e in edge_list
        s, d = src(e), dst(e)
        (s >= 1 && d >= 1) || continue
        fadjlist[s][list_sizes_out[s]] = d
        list_sizes_out[s] += 1
        badjlist[d][list_sizes_in[d]] = s
        list_sizes_in[d] += 1
    end)

    neg = cleanupedges!(fadjlist, badjlist)
    g = SimpleDiGraph{T}()
    g.fadjlist = fadjlist
    g.badjlist = badjlist
    g.ne = neg

    return g
end


@inbounds function add_to_lists!(
    fadjlist::Vector{Vector{T}},
    badjlist::Vector{Vector{T}},
    s::T,
    d::T,
) where {T<:Integer}
    nvg = length(fadjlist)
    nvg_new = max(nvg, s, d)
    for v = (nvg+1):nvg_new
        push!(fadjlist, Vector{T}())
        push!(badjlist, Vector{T}())
    end

    push!(fadjlist[s], d)
    push!(badjlist[d], s)
end

# Try to get the eltype from the first element
function _SimpleDiGraphFromIterator(iter)::SimpleDiGraph

    next = iterate(iter)
    if (next === nothing)
        return SimpleDiGraph(0)
    end

    e = first(next)
    E = typeof(e)
    if !(E <: SimpleGraphEdge{<:Integer})
        throw(DomainError(iter, "Edges must be of type SimpleEdge{T <: Integer}"))
    end

    T = eltype(e)
    g = SimpleDiGraph{T}()
    fadjlist = Vector{Vector{T}}()
    badjlist = Vector{Vector{T}}()

    while next != nothing
        (e, state) = next

        if !(e isa E)
            throw(DomainError(iter, "Edges must all have the same type."))
        end
        s, d = src(e), dst(e)
        if ((s >= 1) & (d >= 1))
            add_to_lists!(fadjlist, badjlist, s, d)
        end

        next = iterate(iter, state)
    end

    neg = cleanupedges!(fadjlist, badjlist)
    g.fadjlist = fadjlist
    g.badjlist = badjlist
    g.ne = neg

    return g
end

function _SimpleDiGraphFromIterator(iter, ::Type{T}) where {T<:Integer}

    g = SimpleDiGraph{T}()
    fadjlist = Vector{Vector{T}}()
    badjlist = Vector{Vector{T}}()

    @inbounds(for e in iter
        s, d = src(e), dst(e)
        (s >= 1 && d >= 1) || continue
        add_to_lists!(fadjlist, badjlist, s, d)

    end)

    neg = cleanupedges!(fadjlist, badjlist)
    g.fadjlist = fadjlist
    g.badjlist = badjlist
    g.ne = neg

    return g
end

"""
    SimpleDiGraphFromIterator(iter)

Create a `SimpleDiGraph` from an iterator `iter`. The elements in `iter` must
be of `type <: SimpleEdge`.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = SimpleDiGraph(2);

julia> add_edge!(g, 1, 2);

julia> add_edge!(g, 2, 1);

julia> h = SimpleDiGraphFromIterator(edges(g))
{2, 2} directed simple Int64 graph

julia> collect(edges(h))
2-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 1
```
"""
function SimpleDiGraphFromIterator(iter)::SimpleDiGraph

    if Base.IteratorEltype(iter) == Base.HasEltype()
        E = eltype(iter)
        if (E <: SimpleGraphEdge{<:Integer} && isconcretetype(E))
            T = eltype(E)
            if isconcretetype(T)
                return _SimpleDiGraphFromIterator(iter, T)
            end
        end
    end

    return _SimpleDiGraphFromIterator(iter)
end



edgetype(::SimpleDiGraph{T}) where {T<:Integer} = SimpleGraphEdge{T}


badj(g::SimpleDiGraph) = g.badjlist
badj(g::SimpleDiGraph, v::Integer) = badj(g)[v]


copy(g::SimpleDiGraph{T}) where {T<:Integer} =
    SimpleDiGraph{T}(g.ne, deepcopy_adjlist(g.fadjlist), deepcopy_adjlist(g.badjlist))


==(g::SimpleDiGraph, h::SimpleDiGraph) =
    vertices(g) == vertices(h) && ne(g) == ne(h) && fadj(g) == fadj(h) && badj(g) == badj(h)

is_directed(::Type{<:SimpleDiGraph}) = true

function has_edge(g::SimpleDiGraph{T}, s, d) where {T}
    verts = vertices(g)
    (s in verts && d in verts) || return false  # edge out of bounds
    @inbounds list = g.fadjlist[s]
    @inbounds list_backedge = g.badjlist[d]
    if length(list) > length(list_backedge)
        d = s
        list = list_backedge
    end
    return insorted(d, list)
end

function has_edge(g::SimpleDiGraph{T}, e::SimpleDiGraphEdge{T}) where {T}
    s, d = T.(Tuple(e))
    return has_edge(g, s, d)
end

function add_edge!(g::SimpleDiGraph{T}, e::SimpleDiGraphEdge{T}) where {T}
    s, d = T.(Tuple(e))
    verts = vertices(g)
    (s in verts && d in verts) || return false  # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) && return false  # edge already in graph
    insert!(list, index, d)

    g.ne += 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    insert!(list, index, s)
    return true  # edge successfully added
end


function rem_edge!(g::SimpleDiGraph{T}, e::SimpleDiGraphEdge{T}) where {T}
    s, d = T.(Tuple(e))
    verts = vertices(g)
    (s in verts && d in verts) || return false  # edge out of bounds
    @inbounds list = g.fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) || return false   # edge not in graph
    deleteat!(list, index)

    g.ne -= 1

    @inbounds list = g.badjlist[d]
    index = searchsortedfirst(list, s)
    deleteat!(list, index)
    return true # edge successfully removed
end

function add_vertex!(g::SimpleDiGraph{T}) where {T}
    (nv(g) + one(T) <= nv(g)) && return false       # test for overflow
    push!(g.badjlist, Vector{T}())
    push!(g.fadjlist, Vector{T}())

    return true
end

function rem_vertices!(
    g::SimpleDiGraph{T},
    vs::AbstractVector{<:Integer};
    keep_order::Bool = false,
) where {T<:Integer}
    # check the implementation in simplegraph.jl for more comments

    n = nv(g)
    isempty(vs) && return collect(Base.OneTo(n))

    # Sort and filter the vertices that we want to remove
    remove = sort(vs)
    unique!(remove)
    (1 <= remove[1] && remove[end] <= n) ||
    throw(ArgumentError("Vertices to be removed must be in the range 1:nv(g)."))

    # Create a vmap that maps vertices to their new position
    # vertices that get removed are mapped to 0
    vmap = Vector{T}(undef, n)
    if keep_order
        # traverse the vertex list and shift if a vertex gets removed
        i = 1
        @inbounds for u in vertices(g)
            if i <= length(remove) && u == remove[i]
                vmap[u] = 0
                i += 1
            else
                vmap[u] = u - (i - 1)
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
    badjlist = g.badjlist

    # count the number of edges that will be removed
    num_removed_edges = 0
    @inbounds for u in remove
        for v in fadjlist[u]
            num_removed_edges += 1
        end
        for v in badjlist[u]
            if vmap[v] != 0
                num_removed_edges += 1
            end
        end
    end
    g.ne -= num_removed_edges

    # move the lists in the adjacency list to their new position
    # order of traversing is important!
    @inbounds for u in (keep_order ? (one(T):1:n) : (n:-1:one(T)))
        if vmap[u] != 0
            fadjlist[vmap[u]] = fadjlist[u]
            badjlist[vmap[u]] = badjlist[u]
        end
    end
    resize!(fadjlist, n - length(remove))
    resize!(badjlist, n - length(remove))

    # remove vertices from the lists in fadjlist and badjlist
    @inbounds for list_of_lists in (fadjlist, badjlist)
        for list in list_of_lists
            Δ = 0
            for (i, v) in enumerate(list)
                if vmap[v] == 0
                    Δ += 1
                else
                    list[i-Δ] = vmap[v]
                end
            end
            resize!(list, length(list) - Δ)
            if !keep_order
                sort!(list)
            end
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

function all_neighbors(g::SimpleDiGraph{T}, u::Integer) where {T}
    union_nbrs = Vector{T}()
    i, j = 1, 1
    in_nbrs, out_nbrs = inneighbors(g, u), outneighbors(g, u)
    in_len, out_len = length(in_nbrs), length(out_nbrs)
    while i <= in_len && j <= out_len
        if in_nbrs[i] < out_nbrs[j]
            push!(union_nbrs, in_nbrs[i])
            i += 1
        elseif in_nbrs[i] > out_nbrs[j]
            push!(union_nbrs, out_nbrs[j])
            j += 1
        else
            push!(union_nbrs, in_nbrs[i])
            i += 1
            j += 1
        end
    end
    while i <= in_len
        push!(union_nbrs, in_nbrs[i])
        i += 1
    end
    while j <= out_len
        push!(union_nbrs, out_nbrs[j])
        j += 1
    end
    return union_nbrs
end
