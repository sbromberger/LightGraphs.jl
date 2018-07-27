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
function SimpleGraph{T}(n::Integer=0) where T <: Integer
    fadjlist = [Vector{T}() for _ = one(T):n]
    return SimpleGraph{T}(0, fadjlist)
end

# SimpleGraph()
SimpleGraph() = SimpleGraph{Int}()

# SimpleGraph(6), SimpleGraph(0x5)
SimpleGraph(n::T) where T <: Integer = SimpleGraph{T}(n)

# SimpleGraph(UInt8)
SimpleGraph(::Type{T}) where T <: Integer = SimpleGraph{T}(zero(T))

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

# converts Graph{Int} to Graph{Int32}
function SimpleGraph{T}(g::SimpleGraph) where T <: Integer
    h_fadj = [Vector{T}(x) for x in fadj(g)]
    return SimpleGraph(ne(g), h_fadj)
end


# SimpleGraph(adjmx)
SimpleGraph(adjmx::AbstractMatrix) = SimpleGraph{Int}(adjmx)

# SimpleGraph(digraph)
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

Creates a SimpleGraph from an iterator iter. The elements in iter must
be of type <: SimpleEdge.
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
"""
function add_vertex!(g::SimpleGraph{T}) where T
    (nv(g) + one(T) <= nv(g)) && return false       # test for overflow
    push!(g.fadjlist, Vector{T}())
    return true
end
