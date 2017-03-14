@testset "Operators" begin
    g3 = PathGraph(5)
    g4 = PathDiGraph(5)

    c3 = complement(g3)
    c4 = complement(g4)

    re1 = Edge(2, 1)

    @test nv(c3) == 5
    @test ne(c3) == 6
    @test nv(c4) == 5
    @test ne(c4) == 16

    g = reverse(g4)
    @test re1 in edges(g)
    reverse!(g)
    @test g == g4

    g = blkdiag(g3, g3)
    @test nv(g) == 10
    @test ne(g) == 8

    h = PathGraph(2)
    @test intersect(g3, h) == h

    h = PathGraph(4)
    z = difference(g3, h)
    @test nv(z) == 5
    @test ne(z) == 1
    z = difference(h, g3)
    @test nv(z) == 4
    @test ne(z) == 0

    z = symmetric_difference(h,g3)
    @test z == symmetric_difference(g3,h)
    @test nv(z) == 5
    @test ne(z) == 1

    h = Graph(6)
    add_edge!(h, 5, 6)
    e = SimpleEdge(5, 6)
    z = union(g3, h)
    @test has_edge(z, e)
    @test z == PathGraph(6)

    h = DiGraph(6)
    add_edge!(h, 5, 6)
    e = SimpleEdge(5, 6)
    z = union(g4, h)
    @test has_edge(z, e)
    @test z == PathDiGraph(6)

    g = CompleteGraph(2)
    h = CompleteGraph(2)
    z = blkdiag(g, h)
    @test nv(z) == nv(g) + nv(h)
    @test ne(z) == ne(g) + ne(h)
    @test has_edge(z, 1, 2)
    @test has_edge(z, 3, 4)
    @test !has_edge(z, 1, 3)
    @test !has_edge(z, 1, 4)
    @test !has_edge(z, 2, 3)
    @test !has_edge(z, 2, 4)

    g = Graph(2)
    h = Graph(2)
    z = join(g, h)
    @test nv(z) == nv(g) + nv(h)
    @test ne(z) == 4
    @test !has_edge(z, 1, 2)
    @test !has_edge(z, 3, 4)
    @test has_edge(z, 1, 3)
    @test has_edge(z, 1, 4)
    @test has_edge(z, 2, 3)
    @test has_edge(z, 2, 4)

    p = PathGraph(10)
    x = p*ones(10)
    @test  x[1]==1.0 && all(x[2:end-1].==2.0) && x[end]==1.0

    @test size(p) == (10,10)
    @test size(p, 1) == size(p, 2) == 10
    @test size(p, 3) == 1


    g = DiGraph(4)
    add_edge!(g,1,2); add_edge!(g,2,3); add_edge!(g,1,3); add_edge!(g,3,4)
    @test g * ones(nv(g)) == [2.0, 1.0, 1.0, 0.0]
    @test sum(g, 1) ==  [0, 1, 2, 1]
    @test sum(g, 2) ==  [2, 1, 1, 0]
    @test sum(g) == 4
    @test sum(p,1) == sum(p,2)
    @test_throws ErrorException sum(p,3)

    @test sparse(p) == adjacency_matrix(p)
    @test eltype(p) == Int
    @test length(p) == 100
    @test ndims(p) == 2
    @test issymmetric(p)
    @test !issymmetric(g)

    nx = 20; ny = 21
    G = PathGraph(ny); H = PathGraph(nx)
    c = cartesian_product(G, H)
    g = crosspath(ny, PathGraph(nx));
    @test g == c

    function crosspath_slow(len, h)
        g = h
        m = nv(h)
        for i in 1:len-1
            k = nv(g)
            g = blkdiag(g,h)
            for v in 1:m
                add_edge!(g, v+(k-m), v+k)
            end
        end
        return g
    end

    g = CompleteGraph(2)
    h = cartesian_product(g, g)
    @test nv(h) == 4
    @test ne(h)== 4

    h = tensor_product(g, g)
    @test nv(h) == 4
    @test ne(h) == 1

    g2 = CompleteGraph(2)
    @test crosspath_slow(2, g2) == crosspath(2, g2)


    ## test subgraphs ##

    g = smallgraph(:bull)
    n = 3
    h = g[1:n]
    @test nv(h) == n
    @test ne(h) == 3

    h = g[[1,2,4]]
    @test nv(h) == n
    @test ne(h) == 2

    h = g[[1,5]]
    @test nv(h) == 2
    @test ne(h) == 0
    @test typeof(h) == typeof(g)

    g = DiGraph(100,200)
    h = g[5:26]
    @test nv(h) == 22
    @test typeof(h) == typeof(g)
    @test_throws ErrorException g[[1,1]]

    r = 5:26
    h2, vm = induced_subgraph(g, r)
    @test h2 == h
    @test vm == collect(r)
    @test h2 == g[r]

    sg, vm = induced_subgraph(CompleteGraph(10), 5:8)
    @test nv(sg) == 4
    @test ne(sg) == 6

    sg2, vm = induced_subgraph(CompleteGraph(10), [5,6,7,8])
    @test sg2 == sg
    @test vm[4] == 8

    gg = CompleteGraph(10)
    elist = [
      SimpleEdge(1, 2), SimpleEdge(2, 3), SimpleEdge(3, 4),
      SimpleEdge(4, 5),SimpleEdge(5, 1)
    ]
    sg, vm = induced_subgraph(gg, elist)
    @test sg == CycleGraph(5)
    @test sort(vm) == [1:5;]


    g = StarGraph(10)
    @test egonet(g, 1, 0) == Graph(1,0)
    @test egonet(g, 1, 1) == g

    @test eltype(g) == Int
    @test ndims(g) == 2
end
