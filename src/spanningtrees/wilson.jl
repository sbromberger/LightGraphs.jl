
"""
    random_spanning_tree(G,[r])

Generate a (uniform) random spanning tree using Wilson's algorithm

A spanning tree of G is a connected subgraph of G that's cycle-free, i.e. a tree that includes only edges from G and connects every node. 

If you specify the root of the tree, the function produces a spanning tree that is picked uniformly among all trees rooted at r. 

If you do not specify a root, the function produces a random tree from G, picking *uniformly* among all spanning trees of G (over all possible roots). 

It has two implementations, depending on whether G is directed or not. For undirected graphs, we pick a random root r and call random_spanning_tree(G,r). For directed graphs, we use Alg. 2 from Wilson (1996), which generates random forests iteratively until a forest with a single tree is found. 

In a directed graph, it is important to note that all branches in the tree need to point *towards* the root, so that there may not be a spanning tree with root r even if the graph is connected. 

As an example, consider the graph 1 -> 2 -> 3. There is a spanning tree rooted at 3 (the graph itself), but no spanning tree rooted at 2 or 1. 

In an undirected graph that is connected, a spanning tree always exists, wherever one roots it. 1 <-> 2 <-> 3, rooted at 2, for instance, has spanning tree 1->2<-3.

In the case of graphs that are not connected, a random spanning *forest* is returned, i.e. one tree per connected component. 

### Arguments

- G: a graph
- optional: r, index of a node to serve as root
- maxiter: interrupt the algorithm for directed graphs after maxiter attempts. Default 50. Ignored for undirected graphs.
- skip_test: On directed graphs that are periodic, the algorithm may get stuck into an infinite loop, so by default the algorithm tests that this won't happen. The test is expensive, however, so set skip_test to false if you know this won't happen (or if you want to take the risk). On *directed* graphs, the problem does not occur, and the test is skipped anyways. 

### Output 

If the root is specified, returns a tree, represented as a SimpleDiGraph. If it isn't, returns a named tuple with "tree": the tree and "root": the root. 

### Examples

The graph 1->2->3 has only one spanning tree (i.e. the graph itself)

```jldoctest
julia> G = PathDiGraph(3)
{3, 2} directed simple Int64 graph

julia> random_spanning_tree(G).tree |> edges |> collect
2-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
```

Other graphs have several:

```@example
julia> G = CycleDiGraph(4)
{4, 4} directed simple Int64 graph

julia> random_spanning_tree(G).tree |> edges |> collect
3-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 3 => 4
 Edge 4 => 1

julia> random_spanning_tree(G).tree |> edges |> collect
3-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 3
 Edge 3 => 4
```

On graphs that are not connected, a forest is returned (ie., there will be multiple roots): 

```@example
julia> G=blockdiag(CycleDiGraph(5),CycleDiGraph(3))
{8, 8} directed simple Int64 graph

julia> random_spanning_tree(G).tree |> connected_components
2-element Array{Array{Int64,1},1}:
 [1, 2, 3, 4, 5]
 [6, 7, 8]      
```




### See also 

prim_mst, kruskal_mst

### References 

Wilson, D. B. (1996). [Generating random spanning trees more quickly than the cover time](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.47.8598&rep=rep1&type=pdf). In STOC (Vol. 96, pp. 296-303).

"""
function random_spanning_tree(G :: AG, r :: Integer; skip_test=false) where AG <: AbstractGraph{T} where T
    _random_spanning_tree(G,r;skip_test=skip_test)
end

function _random_spanning_tree(G :: AG, r :: Integer; nodes = vertices(G), force=false, skip_test=false ) where AG <: AbstractGraph{T} where T
    r in vertices(G) || throw(BoundsError("Root r must be one of the vertices"))
    r in nodes || throw(BoundsError("Root r must be one of the vertices in subset"))
    if (!force)
        is_connected(G) || throw(ArgumentError("Graph must be connected"))
    end
    
    #in directed graphs, add an extra test for safety, otherwise we may get into inf. loops
    if (!skip_test && is_directed(G))
        all(bfs_parents(reverse(G),r) .> 0) || throw(ArgumentError("No spanning tree at this root"))
    end
    n = nv(G)
    in_tree = falses(n)
    next = zeros(T,n)
    in_tree[r] = true
    # we follow closely Wilson's extremely elegant pseudo-code
    for i in nodes
        u = i
        while !in_tree[u] #run a loop-erased random walk
            nn = outneighbors(G, u)
            length(nn) == 0 && throw(ArgumentError("No spanning tree with this root exists"))
            next[u]= rand(nn)
            u = next[u]
        end
        #Retrace steps, erasing loops
        u = i
        while !in_tree[u]
            in_tree[u] = true
            u = next[u]
        end
    end
    return tree_from_next(next,nodes)
end

# Given a vector of pointers "next", make a tree of DiGraph type
function tree_from_next(next :: Array{T,1}, nodes :: AbstractArray{T,1}) where T
    tree = SimpleDiGraph{T}(length(next))
    for v in nodes
        next[v] > 0 && add_edge!(tree,v,next[v])
    end
    tree
end

# Corresponds to 'attempt' in Wilson's paper. The idea is to construct a random forest in an augmented graph. If the forest is actually a tree, then we have generated a spanning tree. See paper for details. 
function attempt_tree(G :: AG, eps :: Real; nodes=1:nv(G)) where AG <: AbstractGraph{T} where T
    roots = Set{T}()
    root = zeros(T,nv(G))
    nroots = Int(0)
    n = nv(G)
    in_tree = falses(n)
    next = zeros(T,n)
    
    # We will run the Markov chain on a graph augmented with self-loops
    # such that the total degree of each node is equal
    deltadeg = Δout(G) .- outdegree(G)
    p_loop = deltadeg ./ (outdegree(G) .+ deltadeg)
    p_stop = eps ./ (1 .- (1-eps).*p_loop) #probability that the Markov chain is interrupted
    for i in nodes
        u = i
        while !in_tree[u]
            if (outdegree(G,u) == 0 || rand() < p_stop[u])
                in_tree[u] = true
                next[u] = 0
                push!(roots,u)
                nroots+=1
                (nroots == 2) && return (nroots=2,)
                root[u] = u
            else
                nn = outneighbors(G, u)
                next[u]= rand(nn)
                u = next[u]
            end
        end
        r = root[u]
        #Retrace steps, erasing loops
        u = i
        while !in_tree[u]
            root[u] = r
            in_tree[u] = true
            u = next[u]
        end
    end
    # If we got here it means we have a single tree, just return it

    (tree = tree_from_next(next,nodes),nroots=1,
     root=pop!(roots))
end


#maxiter is required by traitfn but pointless for undirected graphs
@traitfn function random_spanning_tree(G::AG::(!IsDirected); maxiter=-1) where {T,AG <: AbstractGraph{T} }
    ccG = connected_components(G)
    tree = SimpleDiGraph{T}(nv(G))
    edges = Array{SimpleEdge{T},1}()
    roots = zeros(T,length(ccG))
    for i in eachindex(ccG)
        r = rand(ccG[i])
        tree = union(tree,_random_spanning_tree(G,r;nodes=ccG[i],force=true))
        roots[i] = r
    end
    (tree=tree,roots=roots)
end




@traitfn function random_spanning_tree(G::AG::(IsDirected); maxiter=50) where {T,AG <: AbstractGraph{T} }
    ccG = connected_components(G)
    tree = SimpleDiGraph{T}(nv(G))
    roots = zeros(T,length(ccG))
    for i in eachindex(ccG)
        if (length(ccG[i])>1)
            res= _random_spanning_tree_dir(G;nodes=ccG[i],maxiter=maxiter)
            tree = union(tree,res.tree)
            roots[i] = res.root
        else
            roots[i] = ccG[i][1]
        end
    end
    (tree=tree,roots=roots)
end

# implementation of Wilson's second algorithm, for directed graphs (outer loop)
function _random_spanning_tree_dir(G :: AG; nodes=1:nv(G),maxiter=50) where AG <: AbstractGraph{T} where T
    (sum(outdegree(G)[nodes].==0) > 1) && throw(ArgumentError("This component does not have a spanning tree: there is more than one sink node"))
    eps = 1.0
    niter = 1
    while niter < maxiter #nb: maxiter cut-off needed because you might wait a while
        eps = eps/2
        rf=attempt_tree(G,eps;nodes=nodes)
        if (rf.nroots == 1) #We've found a tree
            return (tree=rf.tree,root=rf.root)
        end
        niter += 1
    end
    throw(ErrorException("Failed to find tree, increase maxiter?"))
end

