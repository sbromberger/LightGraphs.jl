function maximum_weigth_maximal_matching(g::Graph, w, n1, n2)
    # bpmap = bipartite_map(g)
    # length(bpmap) != nv(g) && error("Graph is not bipartite")
    # v1 = findin(bpmap, 1)
    # v2 = findin(bpmap, 2)
    v1 = [1:n1;]
    v2 = [n1+1:n1+n2;]
    assert(length(v1) + length(v2) == nv(g))
    if length(v1) > length(v2)
        v1, v2 = v2, v1
    end
    nedg = 0
    edgemap = Dict{Edge,Int}([e => nedg+=1 for (e,w) in w])

    m = Model()
    @defVar(m, x[1:length(w)] >= 0)

    for i in v1
        idx = Int64[]
        for j in neighbors(g, i)
            if haskey(w, Edge(i,j))
                push!(idx, edgemap[Edge(i,j)])
            else
                println(i," ", j)
                assert(false)
            end
        end
        @addConstraint(m, sum{x[id], id=idx} == 1)
    end

    for j in v2
        idx = Int64[]
        for i in neighbors(g, j)
            if haskey(w, Edge(i,j))
                push!(idx, edgemap[Edge(i,j)])
            else
                assert(false)
            end

        end

        @addConstraint(m, sum{x[id], id=idx} <= 1)
    end

    @setObjective(m, Max, sum{c * x[edgemap[e]], (e,c)=w})

    status = solve(m)
    status != :Optimal && error("Failure")
    sol = getValue(x)

    #check solution
    all(Bool[s == 1 || s == 0 for s in sol])
    # return m
    matchmap = Dict([e => convert(Bool,sol[edgemap[e]]) for e in keys(w)])
    return getObjectiveValue(m), matchmap
end


# m = bipartite_matching(g, w)
#
# getObjectiveValue(m)
