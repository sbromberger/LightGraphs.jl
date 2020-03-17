"""
    dominator_Tree(g, source)

 Create a [Parent Dominator tree array](https://en.wikipedia.org/wiki/Dominator_(graph_theory)).

 u is the dominator of v, if all paths from source to v must include u,
 we can observe that
   - if both w1, and w2 are dominators of v, then after w1 is a dominator
     of w2, or w2 is a dominator of w1
   - dominator_of is a transitive relation
 so the whole dominance relation in a graph can be represented by a tree
 the parent of a node in this tree, is called the immediate dominator.


### Implementation Notes
dominator[source] = source, the dominator of the nodes that aren’t reachable from the source is 0

### References
- Lengauer-Tarjan, "A Fast Algorithm for Finding Dominators in a Flowgraph".
- TARJAN, "Applications of path compression on balanced trees".

## Examples
```jldoctest
julia> using LightGraphs

julia> g = cycle_digraph(4);

julia> g
{4, 4} directed simple Int32 graph

julia> dominator_tree(g, 1)
4-element Array{Int32,1}:
 1
 1
 2
 3

julia> add_edge!(g, 2, 4);

julia> dominator_tree(g, 1)
4-element Array{Int32,1}:
 1
 1
 2
 2
```
"""
function dominator_tree end
@traitfn function dominator_tree(g::AG::IsDirected, source::T) where {T, AG<:DiGraph{T}}
    parent, semi, ord_verts, cnt = Traversals.parent_order(g, source)
    eval, link = produce_eval_link(nv(g), semi)
    bucktes = [Vector{T}() for i in 1:nv(g)]
    dom = zeros(T, nv(g))

    # the goal of this step  is to decide for every node the semi dominator of it
    x = cnt
    while x >= 2
        w = ord_verts[x]
        for u in inneighbors(g, w)
            z = eval(u)
            if semi[z] < semi[w]
              semi[w] = semi[z]
            end
        end

        # we store w in the bucket of its smei dominator,
        # until we know all the semi domintor of all the nodes between w  and its semi dominator

        push!(bucktes[ord_verts[semi[w]]], w)
        p = parent[w]
        # when we know all the semi dominators of w and its descendants,it is the time to 'link' it to its parent
        link(p, w)

        while !isempty(bucktes[p])
            z = pop!(bucktes[p])
            y = eval(z)
            if semi[y] >= semi[p]
              # if there is no node between z and its semi dominator that has semi dominator smaller that z’s ,
              # then 'dom[z] = semi_dominator[z]',
              # note that 'semi[p] = preorder' of p, because p havn’t been processed yet
              dom[z] = p
            else
              # else we will declare implicitly that z has the same dominator as y
              dom[z] = y
            end
        end

        x -= 1
    end

    # the goal of this step is to declare the immidate dominator for the nodes
    # that their semi domintor havn’t been declared in the first step
    for i in 2:cnt
      v = ord_verts[i]
      if ord_verts[semi[v]] != dom[v]
        dom[v] = dom[dom[v]]
      end
    end

    dom[source] = source
    return dom
end

#=
one important step to know the immediate dominator for v, is to know the vertex
u for which semi_dominator(u) is minimum in the path between u and its semi
dominator, it is the jop of 'link' and 'eval',
at first we connsider each node to be a tree by its own, and in each 'link' step
we merge two trees by 'link' operation,
for a node u and its semi_dominator v, it is easy to know the the node with
smallest semi_dominator in the path between u and v by 'eval' operation, when v
is the root of u in the forest,

for the details look
"TARJAN, R.E. Applications of path compression on balanced trees. " section 5
=#



function produce_eval_link(n::T, sem::Vector{T}) where T


      size = ones(T, n)          # 'size[v]' is the numper of nodes that in v’s subtree in the forest
      child = zeros(T, n)        # 'child[v]' is some descendant of v that for performance reasons still think that he is a root
      ancesstor = zeros(T, n)    # the ancesstor u of node w is the cuurent parent of w in the forest
      labels = zeros(T, n)       # the label u of node w is the result of accumalteing ancesstors to last known root in the operation of path decompostion
      semi = sem

      # initially the forset conseisit of every node by its own so its label will be itself
      for i in 1:n
        labels[i] = i
      end

      #=
      'eval(v)' is the fuction which will tell us the the node which has the samllest
      semi dominator between v and the root of its currret tree,
      we want two things
      1- make all nodes in the bath between v and the root of its currret tree direct
         childern to the parent in order not to travel this path again
      2- every node in this path gets the result of accumalteing all its ancesstors
         between it and the root to maintain the correctness of the algorithm
      =#
      function eval(v::T)
          # s will travel Through all v’s ancesstors until we know the root
          # of its cureent tree  we distinguish the root by having its ancesstor
          # equals 0

          s = v
          # parents of s is always one step over s
          parents = ancesstor[s]
          vstack = Vector{T}([])
          # if parents equals 0 then v is a root and we don’t need to go further
          parents == 0 && return labels[s]

          # after the will exit we will have parents as the root of the tree
          while ancesstor[parents] != 0
              # we will store all the ancesstors in between in a stack to
              # accumalte them and redirect their ancesstor to be the current
              # root of the tree
              push!(vstack, s)
              s = parents
              parents = ancesstor[parents]
          end
          # now boss is the root  of the tree
          boss = parents
          parents = s

          while !isempty(vstack)
              s = pop!(vstack)
              # simply 'accumalte[i] = accumalte_func(val[i], accumalte[i-1])'
              if semi[labels[parents]] <= sem[labels[s]]
                 labels[s] = labels[parents]
              end
              # redirect ancesstor of s to be the current root of the tree
              ancesstor[s] = boss
              parents = s
          end

          # now v is direct child to the root all we nedd to know is its value
          # and its root’s value

          if semi[labels[v]] <= semi[labels[ancesstor[v]]]
              return labels[v]
            else
              return labels[ancesstor[v]]
          end
      end



      #=
      'link'(v,w) will put w under v in the forst, there is two ways that could happen,
      we will choose the one that makes the tree most balnced
      1-we declare that ancesstor of w is v
      2-we declare that child[v] = w
      note that child is just an array it maps every node to at most one of
      its descendants ,  lut u be child[v], as far as u concerns ,he is the root
      whenever an 'eval' query occurs to one of u’s descendants, it will not consider
      any ancesstor of u, because ancesstor[u] still equals to zero, so we must
      ensure always that whenever 'eval' occurs to one of u’s descendants  all the nodes
      between v and u have semi dominator greater than v, or we don’t care for now
      about v or its ancesstors, to maintain the correctness of the algorithm .
      for maore details look at "TARJAN, R.E. Applications of path compression
      on balanced trees. " section 5.
      =#

      function link(v, w)
          #now we know the semi dominator of w, we want all
          #its descendants that have semi dominator greater
          #than w’s, to cosider w.
          s = w
          newlabel = labels[w]
          while child[s] != 0 && semi[labels[newlabel]] <= semi[labels[child[s]]]
              s2 = child[child[s]]
              s2 = s2==0 ? 0 : size[s2]

              if size[s] + s2 >= 2 * size[child[s]]

                  # now child[s] will refer to s as its ancesstor.
                  ancesstor[child[s]] = s
                  child[s] = child[child[s]]
              else

                  # to ensure the balance we might swap some edges
                  # but the algorithm still correct becasue at the end
                  # label w.
                  size[child[s]] = size[s]
                  s = ancesstor[s] = child[s]
              end
          end
          labels[s] = labels[w]

         # at this point of the algorithm [s child[s] child[child[s]] ...]
         # is a sorted linked list accroding to thier semi dominator.


         # finnaly make w a descendant of v.

         size[v] += size[w]
         if size[v] < 2 * size[w]
           s, child[v] = child[v], s
         end

         while s != 0
           ancesstor[s] = v
           s = child[s]
         end


         # for mare details look at "TARJAN, R.E. Applications
         # of path compression on balanced trees. " section 5
         # that algorithm is modified because we don’t know the semi dominator
         # of v untill we process all of its descendants,
         # plus as far as any eval operation occurs before reaching v in
         # the backwards loop  semi[v] is not important .
      end

      return eval, link
end
