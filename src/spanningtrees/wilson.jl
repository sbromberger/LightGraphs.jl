"""
Generate a (uniform) random spanning tree using Wilson's algorithm

A spanning tree of G is a connected subgraph of G that's cycle-free, i.e. a tree that includes only edges from G and connects every node. 

If you specify the root of the tree, the function produces a spanning tree that is picked uniformly among all trees rooted at r. 

If you do not specify a root, the function produces a random tree from G, picking *uniformly* among all spanning trees of G (overall all possible roots). 

It has two implementations, depending on whether G is directed or not. For undirected graphs, we pick a random root uniformly and call random_spanning_tree_with_root. For directed graphs, we use Alg. 2 from Wilson (1996), which generates random forests iteratively until a forest with a single tree is found. 

In a directed graph, it is important to note that all branches in the tree need to point *towards* the root, so that there may not be a spanning tree with root r even if the graph is connected. 

As an example, consider the graph 1 -> 2 -> 3. There is a spanning tree rooted at 3 (the graph itself), but no spanning tree rooted at 2 or 1. 

In an undirected graph that is connected, a spanning tree always exists, wherever one roots it. 1 <-> 2 <-> 3, rooted at 2, for instance, has spanning tree 1->2<-3.


# Arguments

- G: a graph
- optional: r, index of a node to serve as root
- maxiter: interrupt the algorithm for directed graphs after maxiter attempts. Default 50. Ignored for undirected graphs.

# Output 

If the root is specified, returns the set of edges in the tree. If it isn't, returns a named tuple with 'edges': the set of edges and 'root': the root. 

Interestingly, the root is a perfect sample from the stationary distribution of the random walk on the graph, see Wilson (1996). 


# Examples

The graph 1->2->3 has only one spanning tree (i.e. the graph itself)

```jldoctest
julia> G = PathDiGraph(3)
{3, 2} directed simple Int64 graph

julia> random_spanning_tree(G)
(edges = LightGraphs.SimpleGraphs.SimpleEdge{Int64}[Edge 1 => 2, Edge 2 => 3], root = 3)
```

Other graphs have several:

```@example
julia> G = CycleDiGraph(4)
{4, 4} directed simple Int64 graph

julia> random_spanning_tree(G)
(edges = LightGraphs.SimpleGraphs.SimpleEdge{Int64}[Edge 1 => 2, Edge 2 => 3, Edge 3 => 4], root = 4)

julia> random_spanning_tree(G)
(edges = LightGraphs.SimpleGraphs.SimpleEdge{Int64}[Edge 1 => 2, Edge 2 => 3, Edge 3 => 4, Edge 4 => 1], root = 1)

julia> random_spanning_tree(G,2)
3-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 3 => 4
 Edge 4 => 1
```

# See also 

prim_mst, kruskal_mst

# References 

Wilson, D. B. (1996). [Generating random spanning trees more quickly than the cover time](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.47.8598&rep=rep1&type=pdf). In STOC (Vol. 96, pp. 296-303).

"""
function random_spanning_tree end


function random_spanning_tree(G :: AG ,r :: Integer) where AG <: AbstractGraph{T} where T
    r in vertices(G) || throw(BoundsError())
    is_connected(G) || error("G must be connected")
    n = nv(G)
    in_tree = falses(n)
    next = zeros(T,n)
    in_tree[r] = true
    # we follow closely Wilson's extremely elegant pseudo-code
    for i in 1:n
        u = i
        while !in_tree[u] #run a loop-erased random walk
            nn = outneighbors(G, u)
            length(nn) == 0 && error("No spanning tree with this root exists")
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
    return [Edge{T}(v,next[v]) for v in vertices(G) if next[v] != 0]
end


""" 
Corresponds to 'attempt' in Wilson's paper. The idea is to construct a random forest in an augmented graph. If the forest is actually a tree, then we have generated a spanning tree. See paper for details. 
"""
function attempt_tree(G :: AG ,eps :: Real) where AG <: AbstractGraph{T} where T
    roots = Set{T}()
    root = zeros(T,nv(G))
    nroots = Int(0)
    n = nv(G)
    in_tree = falses(n)
    next = zeros(Int64,n)

    
    # We will run the Markov chain on a graph augmented with self-loops
    # such that the total degree of each node is equal
    deltadeg = Δout(G) .- outdegree(G)
    p_loop = deltadeg ./ outdegree(G)
    p_stop = eps./ (1 .- (1-eps).*p_loop) #probability that the Markov chain is interrupted
    
    
    for i in 1:n
        u = i
        while !in_tree[u]
            if (outdegree(G,u) == 0 || rand() < p_stop[u])
                in_tree[u] = true
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
    (edges =[Edge{T}(v,next[v]) for v in vertices(G) if next[v] != 0],nroots=1,
     root=pop!(roots))
end


#maxiter is required by traitfn but pointless for undirected graphs
@traitfn function random_spanning_tree(G::::(!IsDirected);maxiter=-1)
    r = rand(vertices(G))
    (edges=random_spanning_tree(G,r),root=r)
end

@traitfn function random_spanning_tree(G::::IsDirected;maxiter=50)
    (sum(outdegree(G).==0) > 1) && error("This graph does not have a spanning tree: there is more than one sink node")
    eps = 1.0
    niter = 1
    while niter < maxiter #nb: maxiter cut-off needed because you might wait a while
        eps = eps/2
        rf=attempt_tree(G,eps)
        if (rf.nroots == 1) #We've found a tree
            return (edges=rf.edges,root=rf.root)
        end
        niter += 1
    end
    error("Failed to find tree, increase maxiter?")
end
