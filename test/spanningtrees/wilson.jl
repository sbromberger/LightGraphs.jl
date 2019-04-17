#test that the result of random_spanning_tree is correct
#ie. it should be a spanning forest, oriented towards the roots 
function check_correctness(F,roots)
    @test !is_cyclic(F)
    @test all(outdegree(F,roots) .== 0)
    #test that all nodes lead to a root
    for cc in connected_components(F)
        if length(cc)==1
            @test cc[1] in roots
        else
            rc = intersect(cc,roots)
            #there should be a single root per connected component
            @test length(rc)==1
            rc = rc[1]
            bf=bfs_parents(F,rc;dir=-1)[cc]
            @test all(bf .> 0)
        end
    end
end
#rather than import from StatsBase
function relcounts(values :: Array{Int,1},k :: Int)
    cc=zeros(k)
    for v in values
        cc[v] += 1
    end
    cc ./ length(values)
end

@testset "Wilson" begin
    gg = Grid([4,4])
    for g in testgraphs(gg)
        rt = @inferred(random_spanning_tree(g))
        check_correctness(rt.tree,rt.roots)
    end

    #Try some small graphs
    gs = [CycleGraph(5), CycleDiGraph(4), WheelDiGraph(9),
          smallgraph(:bull), smallgraph(:tutte)]
    map((g) -> (rt=random_spanning_tree(g);check_correctness(rt.tree,rt.roots)),gs)

    #The next graph is not connected, a forest with three roots should be returned
    G=reduce(blockdiag,[CycleDiGraph(5),CycleDiGraph(3),CycleDiGraph(2)])
    rt=random_spanning_tree(G)
    check_correctness(rt.tree,rt.roots)
    @test length(rt.roots)==3

    # What follows is a probabilistic test that checks that the algorithm samples from the correct distribution
    # We use a result by Pemantle & Wilson that states that
    # Uniform Spanning Trees are actually a Determinantal Point Process over the edges of the graph
    # The kernel of the DPP can be computed explictly from the edge-incidence matrix
    IM = Matrix(incidence_matrix(gg;oriented=true));
    eg = eigen(IM'*IM);
    valid = abs.(eg.values) .> 1e-12
    U = eg.vectors[:,valid];
    K = U*U';
    # The kernel of the DPP gives the inclusion probabilities: for instance K_ii is the probability that edge i is included in a UST
    # We compare theoretical to observed incl. probabilities 
    AA = [adjacency_matrix(SimpleGraph(random_spanning_tree(gg).tree)) for i in 1:100000];
    prob_incl = reduce(+,AA)./length(AA);
    pr = map((e) -> prob_incl[src(e),dst(e)],edges(gg));
    #Check that observed probabilities don't deviate too much 
    @test sum(abs.(diag(K)-pr)./pr)./length(pr) < 1e-2

    #Check that the root samples from the stationary distribution of
    #the (degree-corrected) random walk on G
    #See Wilson (1996) for details
    G=join(StarDiGraph(5),CycleDiGraph(5))
    deltadeg = Δout(G) .- outdegree(G)
    p_loop = deltadeg ./ (outdegree(G) .+ deltadeg)
    A = Float64.(adjacency_matrix(G))
    A[diagind(A)] .= p_loop
    #Markov transition matrix
    M=Matrix(A'./sum(A,dims=(2)))
    eg = eigen(M)
    #Stationary distribution
    pr = abs.(real(eg.vectors[:,abs.(eg.values) .≈ 1]))
    pr = pr./sum(pr)
    zz = [random_spanning_tree(G).roots[1] for i in 1:10000];
    pr_est = relcounts(zz,length(pr))
    @test (sum(abs.(pr-pr_est))./length(pr)) < .02
end

