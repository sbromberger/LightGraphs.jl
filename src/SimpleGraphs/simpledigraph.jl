const SimpleDiGraphEdge = SimpleEdge

"""
    SimpleDiGraph{T}

A type representing a directed graph.
"""
mutable struct SimpleDiGraph{T <: Integer} <: AbstractSimpleGraph{T}
    ne::Int
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{T}} # [dst]: (src, src, src)
end


eltype(x::SimpleDiGraph{T}) where T = T

# DiGraph{UInt8}(6), DiGraph{Int16}(7), DiGraph{Int8}()
function SimpleDiGraph{T}(n::Integer=0) where T <: Integer
    fadjlist = [Vector{T}() for _ = one(T):n]
    badjlist = [Vector{T}() for _ = one(T):n]
    return SimpleDiGraph(0, fadjlist, badjlist)
end

# SimpleDiGraph()
SimpleDiGraph() = SimpleDiGraph{Int}()

# SimpleDiGraph(6), SimpleDiGraph(0x5)
SimpleDiGraph(n::T) where T <: Integer = SimpleDiGraph{T}(n)

# SimpleDiGraph(UInt8)
SimpleDiGraph(::Type{T}) where T <: Integer = SimpleDiGraph{T}(zero(T))

# sparse adjacency matrix constructor: SimpleDiGraph(adjmx)
function SimpleDiGraph{T}(adjmx::SparseMatrixCSC{U}) where T <: Integer where U <: Real
    dima, dimb = size(adjmx)
    isequal(dima, dimb) || throw(ArgumentError("Adjacency / distance matrices must be square"))

    g = SimpleDiGraph(T(dima))
    maxc = length(adjmx.colptr)
    @inbounds for c = 1:(maxc - 1)
        for rind = adjmx.colptr[c]:(adjmx.colptr[c + 1] - 1)
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
function SimpleDiGraph{T}(adjmx::AbstractMatrix{U}) where T <: Integer where U <: Real
    dima, dimb = size(adjmx)
    isequal(dima, dimb) || throw(ArgumentError("Adjacency / distance matrices must be square"))

    g = SimpleDiGraph(T(dima))
    @inbounds for i in findall(adjmx .!= zero(U))
        add_edge!(g, i[1], i[2])    
    end
    return g
end

# SimpleDiGraph(adjmx)
SimpleDiGraph(adjmx::AbstractMatrix) = SimpleDiGraph{Int}(adjmx)

# converts DiGraph{Int} to DiGraph{Int32}
function SimpleDiGraph{T}(g::SimpleDiGraph) where T <: Integer
    h_fadj = [Vector{T}(x) for x in fadj(g)]
    h_badj = [Vector{T}(x) for x in badj(g)]
    return SimpleDiGraph(ne(g), h_fadj, h_badj)
end

SimpleDiGraph(g::SimpleDiGraph) = copy(g)

# constructor from abstract graph: SimpleDiGraph(graph)
function SimpleDiGraph(g::AbstractSimpleGraph)
    h = SimpleDiGraph(nv(g))
    h.ne = ne(g) * 2 - num_self_loops(g)
    h.fadjlist = deepcopy(fadj(g))
    h.badjlist = deepcopy(badj(g))
    return h
end


@inbounds function cleanupedges!(fadjlist::Vector{Vector{T}},
                                 badjlist::Vector{Vector{T}}) where T <: Integer
    neg = 0
    for v in 1:length(fadjlist)
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

function SimpleDiGraph(edge_list::Vector{SimpleDiGraphEdge{T}}) where T <: Integer
    nvg = zero(T)
    @inbounds(
    for e in edge_list
        nvg = max(nvg, src(e), dst(e)) 
    end)
   
    list_sizes_out = ones(Int, nvg)
    list_sizes_in = ones(Int, nvg)
    degs_out = zeros(Int, nvg)
    degs_in = zeros(Int, nvg)
    @inbounds(
    for e in edge_list
        s, d = src(e), dst(e)
        (s >= 1 && d >= 1) || continue
        degs_out[s] += 1
        degs_in[d] += 1
    end)
    
    fadjlist = Vector{Vector{T}}(undef, nvg)
    badjlist = Vector{Vector{T}}(undef, nvg)
    @inbounds(
    for v in 1:nvg
        fadjlist[v] = Vector{T}(undef, degs_out[v])
        badjlist[v] = Vector{T}(undef, degs_in[v])
    end)

    @inbounds(
    for e in edge_list
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


@inbounds function add_to_lists!(fadjlist::Vector{Vector{T}},
                                 badjlist::Vector{Vector{T}}, s::T, d::T) where T <: Integer
    nvg = length(fadjlist)
    nvg_new = max(nvg, s, d)
    for v = (nvg + 1):nvg_new
        push!(fadjlist, Vector{T}())
        push!(badjlist, Vector{T}())
    end

    push!(fadjlist[s], d)
    push!(badjlist[d], s)
end

function _SimpleDiGraphFromIterator(iter)::SimpleDiGraph
    T = Union{}
    fadjlist = Vector{Vector{T}}() 
    badjlist = Vector{Vector{T}}() 
    @inbounds(
    for e in iter
        typeof(e) <: SimpleDiGraphEdge ||
                        throw(ArgumentError("iter must be an iterator over SimpleEdge"))
        s, d = src(e), dst(e)
        (s >= 1 && d >= 1) || continue
        if T != eltype(e)
            T = typejoin(T, eltype(e)) 
            fadjlist = convert(Vector{Vector{T}}, fadjlist)
            badjlist = convert(Vector{Vector{T}}, badjlist)
        end
        add_to_lists!(fadjlist, badjlist, s, d)
    end)

    T == Union{} && return SimpleDiGraph(0)
    neg  = cleanupedges!(fadjlist, badjlist)
    g = SimpleDiGraph{T}()
    g.fadjlist = fadjlist
    g.badjlist = badjlist
    g.ne = neg

    return g
end

function _SimpleDiGraphFromIterator(iter, ::Type{SimpleDiGraphEdge{T}}) where T <: Integer
    fadjlist = Vector{Vector{T}}() 
    badjlist = Vector{Vector{T}}() 
    @inbounds(
    for e in iter
        s, d = src(e), dst(e)
        (s >= 1 && d >= 1) || continue
        add_to_lists!(fadjlist, badjlist, s, d)
    end)

    g = SimpleDiGraph{T}()
    neg  = cleanupedges!(fadjlist, badjlist)
    g.fadjlist = fadjlist
    g.badjlist = badjlist
    g.ne = neg

    return g
end

"""
    SimpleDiGraphFromIterator(iter)

Creates a SimpleDiGraph from an iterator iter. The elements in iter must
be of type <: SimpleEdge.
"""
function SimpleDiGraphFromIterator(iter)::SimpleDiGraph
    if Base.IteratorEltype(iter) == Base.EltypeUnknown()
        return _SimpleDiGraphFromIterator(iter)
    end
    # if the eltype of iter is known but is a proper supertype of SimpleDiGraphEdge
    if !(eltype(iter) <: SimpleDiGraphEdge) && SimpleDiGraphEdge <: eltype(iter)
        return _SimpleDiGraphFromIterator(iter)
    end
    return _SimpleDiGraphFromIterator(iter, eltype(iter))
end


edgetype(::SimpleDiGraph{T}) where T <: Integer = SimpleGraphEdge{T}


badj(g::SimpleDiGraph) = g.badjlist
badj(g::SimpleDiGraph, v::Integer) = badj(g)[v]


copy(g::SimpleDiGraph{T}) where T <: Integer =
SimpleDiGraph{T}(g.ne, deepcopy(g.fadjlist), deepcopy(g.badjlist))


==(g::SimpleDiGraph, h::SimpleDiGraph) =
vertices(g) == vertices(h) &&
ne(g) == ne(h) &&
fadj(g) == fadj(h) &&
badj(g) == badj(h)

is_directed(g::SimpleDiGraph) = true
is_directed(::Type{SimpleDiGraph}) = true
is_directed(::Type{SimpleDiGraph{T}}) where T = true


function has_edge(g::SimpleDiGraph{T}, e::SimpleDiGraphEdge{T}) where T
    s, d = T.(Tuple(e))
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

function add_edge!(g::SimpleDiGraph{T}, e::SimpleDiGraphEdge{T}) where T
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


function rem_edge!(g::SimpleDiGraph{T}, e::SimpleDiGraphEdge{T}) where T
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

function add_vertex!(g::SimpleDiGraph{T}) where T
    (nv(g) + one(T) <= nv(g)) && return false       # test for overflow
    push!(g.badjlist, Vector{T}())
    push!(g.fadjlist, Vector{T}())

    return true
end
