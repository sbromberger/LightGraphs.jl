function dominator_Tree(g::AG, source) where {T, AG<:DiGraph{T}}



  parent=zeros(T,nv(g)) #the parents of every node in the dfs teree


  #= the semi dominator is the first node on the path between the root and the node of interest,
  such that  there is at least two disjoint paths between it and the node of interest ,
  if there is not such a node we will consider the parent of the node of interst to be the semi dominator of it
   there is a duality between the semi dominator and the  immediate dominator
   min(preorderof(semi_dominator(v)))>=max(preorder(dominator(v))
   for more details see the paper
   the key theorm is
   Let w != the source, and let u be a vertex for which semi_dominator(u) is minimum
   among vertices between w and its semi dominator.
   Then the immediate dominator is
   semi_dominator(w) if semi_dominator(w) = semi_dominator(u),
   immidiate_dominator(w) =  immidiate_dominator(u) otherwise.
  =#
  semi=zeros(T,nv(g))
  #==#


  function accumfunc(a1,a2)
    if semi[a1]<=semi[a2]
      return true
    else
      return false
    end
  end
      eval,link=produce_eval_link(nv(g),accumfunc,T)

  #=
   we will store each node in the bucket of its semi dominator,
   until we we figure out all the semi dominator of the nodes between them
  =#

  bucktes=Array{Vector,1}(undef,nv(g))

  verticesar=zeros(T,nv(g)) #map between each preorder of a node and its real name
  dom=zeros(T,nv(g))        #the immediate dominator of the the node
  #=
  one important step in the algorithm is to know a  vertex u for which semi_dominator(u) is minimum
  among vertices between every node and its semi dominator,
  after we order the vertices by preorder, we will scan them backwards,
  then we can imagine the graph as a forest of trees, in each step we merge two trees by making the root of one tree the
  child of the root of the other tree, now we discovered  another child of the later root,let it be w
  then we will see if there is node u that consider w to be its semi dominator, and look for the smallest smei dominator in the path between w and u
  we can leverage some facts
  - we donot need to travel all the path each time, we can do path decompsion
  - each time we do a merge one of the two trees will not be affected at all,
  in the other tree if there is a node that has semi dominator smaller than the new root its descendants will not be affected

  =#



  parent[source]=1

  counter=Int(0)


  #=function dfs(v)
    counter=counter+1
    semi[v]=counter
    verticesar[Int(counter)]=v
    bucktes[v]=Array{T}([])
    for w in outneighbors(g,v)
      if parent[w]==0
        parent[w]=v
        dfs(w)
      end
    end

    end
    dfs(source)=#
    s=Vector{}([])
    ptr=1
    counter=1
    semi[source]=1
    verticesar[1]=source
    bucktes[source]=Vector{}([])
    push!(s,(source,0))
    while !isempty(s)
        v,_=s[end]
      
        vneighbors=outneighbors(g,v)
        while ptr <= length(vneighbors)
            u=vneighbors[ptr]
            if semi[u]==0
                bucktes[u]=Vector{T}([])
                push!(s,(u,ptr+1))
                counter+=1
                semi[u]=counter
                parent[u]=v
                verticesar[counter]=u
                break
            end
            ptr+=1
        end
        if ptr>length(vneighbors)
            _,ptr=pop!(s)
          else
            ptr=1
        end

    end




    #=the semi dominator of node w ,is the first node in the path between the root and w
    that has at least two disjoint paths to w, 
    let the semi dominator be u then u has two childern v1,v2 one of them is an ancesstor of w in the dfs tree,
    the other is either 
    1-w itself 
    2- has a descendant c that has a croos edge to w 
    -in the first case w will have an in_edge to u, because we scan backwards semi[u] will have the intial vaule preorder of u
    -in the second case v2 would have a preorder numper grater than w , so by the time we reach w,
     v2 and its all descendants would have been processed, we know that if u is the semi dominator of w,
     then the eval(j) for any j in the path between w and c will be w,
     the proof of the last claim
      let z be smei[eval(j)] to some j
      is that it is impossibe for z to be greater than w because semi[v2] is at most w,
      and if semi[eval(j)] is smaller than w then there is two disjoint paths from z to u,
      one passes by w and the other passes by eval(j), which contradicts that w is the semi domintor of u    
      =#

      
    x=counter
    while x >= 2
      w=verticesar[x]

      for u in inneighbors(g,w)
          z=eval(u)
          z==0 && continue
          if semi[z]<semi[w]
            semi[w]=semi[z]
          end
        end
      

        #=
         we store w in the bucket of its smei dominator,
         until we know all the semi domintor of the nodes between w  and its dominator
      
        =#
        push!(bucktes[verticesar[semi[w]]],w)
        
        
        p=parent[w]

        #=
        when we know all the semi dominators of w and descendants it is the time to link it to its parent
        =#
        link(p,w)

        while !isempty(bucktes[p])
          z=pop!(bucktes[p])
          y=eval(z)
          if semi[y]>=semi[p]
            #=
            if there is no node that has semi dominator smaller that z’s ,
            then dom[z]=semi dominator[z],
            note that semi[p]=preorder of p, because p havn’t been processed yet
            =#
            dom[z]=p
            
          else
            # else we will declare implicitly that z has the same domina as y  
           dom[z]=y

          end
        end

      x-=1
    end


    for i in 2:counter
      # we look for the nodes that their dominator havn’t been declared emplictly, but now we know whert to look   
      v=verticesar[i]
      if verticesar[semi[v]]!=dom[v]
        dom[v]=dom[dom[v]]
      end
    end
    dom[source]=0
    return dom
  end


function produce_eval_link(n,accumfun::Function,T::DataType)



  size=ones(T,n)          # size(v) is the numper of nodes that in v’s subtree in the forest
  childs=zeros(T,n)       # the  child u of a node w of the the node that its suntree has a big size and has semi_dominator snaller than w
  ancesstor=zeros(T,n)    # the  ancesstor u of node w is the cuurent parent of w in the forest
  labels=zeros(T,n)       # the label u of node w is the result of accumalteing ancesstors to last known root in the operation of path decompostion

  #initially the forset conseisit of every node by its own so its label will be itself

  for i in 1:n
    labels[i]=i
  end



  #=eval(v) is the fuction which will tell us the the node which has the samllest semi dominator
  between v and the root of its currret tree,
  we want two things
  1-make all nodes int the bath between v and and the root of its currret tree direct childern to the parent in order not to travel this path again
  2-every node in this path gets the result of accumalteing all its ancesstors between it and the root to maintain the correctness of the algorithm


  =#
  function eval(v)

    #=
    s will travel Through all v’s ancesstors until we know the root of its cureent tree,
    we distinguish the root by having its ancesstor equals 0
    =#

    s = v
    # parents of s is always one step over s
    parents = ancesstor[s]
    vstack = Vector{T}([])
    # if parents equals 0 then v is a root and we don’t need to go further
    parents == 0 && return labels[s]

    # after the will exit we will have parents as the root of the tree
    while ancesstor[parents]!=0
          #= we will store all the ancesstors in between in a stack to accumalte them and
          redirect their ancesstor to be the current root of the tree=#
          push!(vstack,s)
          s=parents
          parents=ancesstor[parents]
        end

        #now boss is the root  of the tree

        boss=parents
        parents=s

        while !isempty(vstack)

          s=pop!(vstack)
          # simply accumalte[i]=accumalte_func(val[i],accumalte[i-1])
          if accumfun(labels[parents],labels[s])
             labels[s]=labels[parents]
          end
          #redirect ancesstor of s to be the current root of the tree
          ancesstor[s]=boss
          parents=s
        end

        # now v is direct child to the root all we nedd to know is its value and its root’s value
        if accumfun(labels[v],labels[ancesstor[v]])
          return labels[v]
        else
          return labels[ancesstor[v]]
        end
  end



  #=
  link(v,w) will put w under v in the forst, there is two ways that could happen,
  we will choose the one that makes the tree most balnced
  1-we declare that ancesstor of w is v
  2-we declare that childs[v]=w
  note that childs is just an array it maps every node to at most one of its descendants ,
  lut u be  childs[v], as far as u concerns ,he is the root whenever an eval query occurs
  to one of u’s descendants, it will not consider any ancesstor of u, because ancesstor[u] still equals to zero,
  so we must ensure always that whenever eval occurs to one of u’s descendants  all the nodes between v and u have
  semi dominator greater than v, or we don’t care about v or its ancesstors, to maintain the correctness of the algorithm .
  for maore details look at "TARJAN, R.E. Applications of path compression on balanced trees. " section 5
  =#

  function link(v,w)
   #=
    now we know the semi dominator of w and
    want all its descendants that have semi dominator greater than w’s, to cosider w
    
   =#
      s = w
      newlabel = labels[w]
      while childs[s]!=0 && accumfun(labels[newlabel],labels[childs[s]])
        s2 = childs[childs[s]]
        s2 = s2==0 ? 0 : size[s2]
        
        if size[s]+s2>=2*size[childs[s]]
          #=
          now child[s] will refer to s as its ancesstor
          =#
          ancesstor[childs[s]] = s
          childs[s] = childs[childs[s]]
       else
         #=to ensure the balance we might swap some edges but the algorithm still correct
         becasue at the end label[s] will be equal to label w=# 
         size[childs[s]] = size[s]
         s=ancesstor[s] = childs[s]
       end
     end
     

     
     labels[s] = labels[w]

     #=
     at this point of the algorithm [s child[s] child[child[s]] ...] is a sorted linked list accroding to thier semi dominator
     

     =#


      #=
      finnaly make w implicitly descendant of v
      =#
     size[v]+= size[w]
     if size[v] < 2*size[w]
       s,childs[v] = childs[v],s
     end
     
     while s!=0
       ancesstor[s] = v
       s = childs[s]
     end

     #=
     for maore details look at "TARJAN, R.E. Applications of path compression on balanced trees. " section 5
     althought that algorithm is modified because we don’t know the semi dominator of v untill we process all of its descendants,
     plus as far as any eval operation occurs before reaching v in the backwards loop above semi[v] is not important 

     =#
   end


  return eval,link
end
