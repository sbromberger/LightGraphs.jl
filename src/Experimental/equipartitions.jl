
#=Example:
We have one user-supplied distinuished vertex in an odd wheel-graph.
We can then distinguish 3 vertices: the user-supplied base point, the center, and the
antipodal point of the base point. All other vertices come in pairs of two.
This is optimal: There exists a reflection automorphism.
The hashes depend on the isomorphism type and the init, only.
They should be reproducible (needs test: do big endian machines produce identical hashes?).

julia> g=LightGraphs.SimpleGraphs.WheelGraph(11);
julia> ih = iso_hash(g; init=i->i==7); iso_hash_show(ih)
Iso_Hash 1269515442897797583694403328243932638 of {11, 20}-graph:
	3 / 11 vertices are distinguished.
	8 lie in 4 classes ranging in size from 2 to 2
	Class 1, length 2. Hash 232334094274328048357343354678148208301, vertices: [3, 11]
	Class 2, length 2. Hash 252812222206699830198718529957671714753, vertices: [4, 10]
	Class 3, length 2. Hash 265171865225977565521634104032551704230, vertices: [5, 9]
	Class 4, length 2. Hash 293755718401458989130032242925838110265, vertices: [6, 8]
	Remaining canonical permutation of 3 vertices: [2, 7, 1]

julia> iso_partition(g; init=i->(i==7))
(0x00f47ff19fa5ba7a8a9174e89cb01dde, Array{Int64,1}[[3, 11], [4, 10], [5, 9], [6, 8], [2], [7], [1]])

Within each class of the partition, the vertices are ordered lexicographically. The global hash 
(0x00f47f...) can be used to quickly test whether two graphs can be isomorphic, at all. 

In the hypotherical case of hash collisions (astronomically unlikely, 128 bit long), the result 
is still isomorphism invariant. It is, however, potentially suboptimal, the algorithm can fail to 
converge alltogether, and two graphs with identical hashes and complete canonical permutation can still
fail to be isomorphic. 

It is best not to worry about this: This should only happen if either AES is broken, ~2^60 operations
were performed in the computation, or the graph is an adversarial example built using _AES_DEFAULT_KEY. 
=#

const _AES_DEFAULT_KEY = 0xfc969d39fd4ba27a97ae525b1c8d982f

struct Iso_hash 
    contents::UInt128 
end 

@inline Base.hash(color::Iso_hash) = color.contents % UInt64
#Define an abelian group operation. Structure-less would be best, but UInt128 + is good enough
@inline Base.:+(h1::Iso_hash, h2::Iso_hash) = Iso_hash(h1.contents + h2.contents)

mutable struct Iso_hash_state{HF, G<:AbstractGraph}
    done_vertices::BitSet #todo: update
    color_map::Vector{Iso_hash}
    color_count::Dict{Iso_hash, Int}
    update_cols::Dict{Int64, Iso_hash}
    update_counter::Dict{Iso_hash, Int}
    mod_last::Vector{Int}
    mod_persistent::BitSet
    global_color::Iso_hash
    use_triangles::Bool #todo: generalized 
    graph::G
    _hash_fun::HF
end


#hf needs to be an approximately random function UInt128->UInt128. AES encryption fits the bill.
function Iso_hash_state(g::AbstractGraph, hf = AESmbed.Aes_wrap(_AES_DEFAULT_KEY); init = i->0, use_triangles = false)
    done_vertices = BitSet()
    color_map = Vector{Iso_hash}(undef, nv(g))
    color_count = Dict{Iso_hash, Int}()

    done_vertices =  BitSet()
    color_map = Vector{Iso_hash}(undef, nv(g))
    color_count = Dict{Iso_hash, Int}()
    update_cols = Dict{Int64, Iso_hash}()
    update_counter = Dict{Iso_hash, Int}()
    mod_last = collect(1:nv(g))
    mod_persistent = BitSet(1:nv(g))
    global_color = Iso_hash(hf( UInt128(nv(g))<<64 + ne(g)) )

    
    for v = 1:nv(g)
        col_ = (degree(g, v)<<1 | has_edge(g, v, v)) | UInt128(UInt64(init(v))) << 64 
        col = Iso_hash(hf(col_))
        increment!(color_count, col, 1)

        color_map[v] = col
        global_color += col
    end
    for v=1:nv(g)
        if color_count[color_map[v]] == 1
            push!(done_vertices, v)
        end
    end
    return Iso_hash_state(done_vertices, color_map, color_count, update_cols, 
        update_counter, mod_last, mod_persistent, global_color, use_triangles, g, hf)
end

function iso_hash(g::AbstractGraph, hf =  AESmbed.Aes_wrap(0xfc969d39fd4ba27a97ae525b1c8d982f); use_triangles = false, init = i->0)
    s = Iso_hash_state(g, hf; use_triangles=use_triangles, init=init)

    while true

        while length(s.mod_last)>0
            apply_kernel(s, edge_kernel)
        end
        if use_triangles && length(s.mod_persistent) > 0 && length(s.done_vertices) < nv(s.graph)
            clear_done(s)
            for i in s.mod_persistent
                push!(s.mod_last, i)
            end
            empty!(s.mod_persistent)
            apply_kernel(s, triangle_kernel)
        else
            break
        end
    end
    return s 
end

#return: global hash as UInt128, and canonical partition. 
iso_partition(g::AbstractGraph;  kwargs... ) = iso_partition(iso_hash(g; kwargs...))

function iso_partition(s::Iso_hash_state)
    d = Dict{Iso_hash, Vector{Int}}()
    for i in 1:nv(s.graph)
        k = s.color_map[i]
        if haskey(d, k)
            push!(d[k], i)
        else
            d[k]=[i]
        end
    end
    pairs = collect(d)
    sort!(pairs; by=kv->(-length(kv[2]),kv[1].contents))
    part = [v for (k,v) in pairs]::Vector{Vector{Int}}
    return s.global_color.contents, part
end


function iso_hash_show(s::Iso_hash_state; verbose = true)
    gh, part = iso_partition(s)
    nt = count(v->(length(v)>1), part)
    println("Iso_Hash $(gh) of {$(nv(s.graph)), $(ne(s.graph))}-graph:")
    println("\t$(length(s.done_vertices)) / $(nv(s.graph)) vertices are distinguished.")
    if nt > 0
        println("\t$(nv(s.graph)-length(s.done_vertices)) lie in $(nt) classes ranging in size from $(length(part[1])) to $(length(part[nt]))")
        verbose && for (n,v) in enumerate(part)
            length(v)>1 || break
            println("\tClass $(n), length $(length(v)). Hash $(s.color_map[v[1]].contents), vertices: $(v)")
        end
    end
    if verbose
        uniques = Int[]
        for i=nt+1:length(part)
            push!(uniques, part[i][1])
        end
        println("\tRemaining canonical permutation of $(length(uniques)) vertices: $(uniques)")
    end
end




#todo: Pointwise kernels that apply to all vertices.
function apply_kernel(state::Iso_hash_state, kernel::kernelT) where kernelT 
    g = state.graph
    done_vertices = state.done_vertices
    color_map = state.color_map
    color_count = state.color_count
    update_cols = state.update_cols
    update_counter = state.update_counter
    mod_last = state.mod_last
    mod_persistent = state.mod_persistent

    empty!(update_counter)
    empty!(update_cols)
    for v in mod_last
        kernel(state, v)
    end
    for (v, col_up) in update_cols
        if color_count[color_map[v]] == 1
            push!(done_vertices, v)
        end
        increment!(update_counter, col_up, 1)
    end
    
    for (v,col) in update_cols
        if update_counter[col] == color_count[color_map[v]]
            delete!(update_cols, v)
        end
    end
    empty!(mod_last)


    for (vertex, col_up) in update_cols
        #generate new color.
        new_col = Iso_hash(state._hash_fun(col_up.contents))

        #update counters 
        col_old = color_map[vertex]
        r = increment!(color_count, col_old, -1)
        r == 0 && delete!(color_count, col_old)
        if update_counter[col_up] == 1
            push!(done_vertices, vertex)
        end
        increment!(color_count, new_col, 1)
        state.global_color += new_col

        color_map[vertex] = new_col
        push!(mod_persistent, vertex)
        push!(mod_last, vertex)
    end
    return state 
end








#kernels

function edge_kernel(s::Iso_hash_state, v)
    g = s.graph
    for u in neighbors(g, v)
        ((u in s.done_vertices) || u == v) && continue
        increment!(s.update_cols, s.color_map, u, s.color_map[v])
    end
    nothing
end
function triangle_kernel(s::Iso_hash_state, v)
    g = s.graph
    v in s.done_vertices && return nothing
    for u in neighbors(g, v)
        ((u in s.done_vertices) || u == v) && continue
        for x in common_neighbors(g, u, v)
            ((x in s.done_vertices) || u == v || x == u || x == v) && continue
            new_col = Iso_hash(s._hash_fun(s.color_map[u].contents + s.color_map[v].contents + s.color_map[x].contents))
            increment!(s.update_cols, s.color_map, u, new_col)
            increment!(s.update_cols, s.color_map, v, new_col)
            increment!(s.update_cols, s.color_map, x, new_col)
        end
    end
    nothing
end




#misc utils

#sometimes a vertex becomes a single equivalence class without being updated.
#this function clears these vertices (good for expensive kernels)
function clear_done(s::Iso_hash_state)
    for i=1:length(s.color_map)
        if s.color_count[s.color_map[i]] == 1
            push!(s.done_vertices, i)
        end
    end
end


function relabel(g, perm)
    res = LightGraphs.SimpleGraph(nv(g))
    res.ne = g.ne
    for i=1:nv(g)
        res.fadjlist[perm[i]] = sort(perm[g.fadjlist[i]])
    end
    res
end


function increment!(d::Dict, k, v)
    idx = Base.ht_keyindex2!(d, k)
    if idx > 0
        @inbounds d.vals[idx] += v
    else
        @inbounds Base._setindex!(d, v, k, -idx)
    end
    nothing
end

function increment!(d::Dict, default, k, v)
    idx = Base.ht_keyindex2!(d, k)
    if idx > 0
        @inbounds d.vals[idx] += v
    else
        @inbounds Base._setindex!(d, default[k]+v, k, -idx)
    end
    nothing
end


#=
function Base.iterate(c::Iso_hash_state)
    return (c.global_color, nothing)
end

function Base.iterate(s::Iso_hash_state, iter_state)
    if length(s.mod_last)>0
        apply_kernel(s, edge_kernel)
        if length(s.mod_last)>0
            return (s.global_color, nothing)
        end
    end
    if s.use_triangles && length(s.mod_persistent)>0
        clear_done(s)
        for i in s.mod_persistent
            push!(s.mod_last, i)
        end
        empty!(s.mod_persistent)
        apply_kernel(s, triangle_kernel)
        if length(s.mod_last)>0
            return (s.global_color, nothing)
        else 
            return nothing
        end
    end
    return nothing
end 
=#

