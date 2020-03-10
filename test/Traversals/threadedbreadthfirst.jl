import LightGraphs.Traversals:
    preinitfn!, initfn!, previsitfn!, visitfn!, newvisitfn!, postvisitfn!, postlevelfn!

@testset "LT.ThreadedBreadthFirst" begin
    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2)
    add_edge!(g5, 2, 3)
    add_edge!(g5, 1, 3)
    add_edge!(g5, 3, 4)
    g6 = smallgraph(:house)

    for g in testdigraphs(g5)
        T = eltype(g)
        z = @inferred(LT.tree(g, 1, LT.ThreadedBreadthFirst()))
        p = @inferred(LT.parents(g, 1, LT.ThreadedBreadthFirst()))

        @test p == T.([0, 1, 1, 3])
        @test nv(z) == T(4) && ne(z) == T(3) && !has_edge(z, 2, 3)
    end

    function istree(p::Vector{T}, maxdepth, n::T) where {T <: Integer}
        flag = true
        for i in one(T):n
            s = i
            depth = 0
            while p[s] > 0 && p[s] != s
                s = p[s]
                depth += 1
                if depth > maxdepth
                    return false
                end
            end
        end
        return flag
    end

    for g in testgraphs(g6)
        n = nv(g)
        T = eltype(g)
        p = @inferred(LT.parents(g, 1, LT.ThreadedBreadthFirst()))
        @test istree(p, n, n)
        t = LT.tree(p)
        t2 = LT.tree(g, 1, LT.ThreadedBreadthFirst())
        @test is_directed(t)
        @test typeof(t) <: AbstractGraph
        @test ne(t) < nv(t)
        @test t == t2
    end

    g7 = binary_tree(4)
    struct DummyState <: LT.TraversalState end
    LT.preinitfn!(::DummyState, u) = false

    @test !LT.traverse_graph!(g7, 1, LT.ThreadedBreadthFirst(), DummyState())

    LT.preinitfn!(::DummyState, u) = true
    LT.initfn!(::DummyState, u) = false
    @test !LT.traverse_graph!(g7, 1, LT.ThreadedBreadthFirst(), DummyState())

    LT.initfn!(::DummyState, u) = true
    LT.previsitfn!(::DummyState, u, t::Integer) = false
    @test !LT.traverse_graph!(g7, 1, LT.ThreadedBreadthFirst(), DummyState())

    LT.previsitfn!(::DummyState, u, t::Integer) = true
    LT.visitfn!(::DummyState, u, v, t::Integer) = false
    @test !LT.traverse_graph!(g7, 1, LT.ThreadedBreadthFirst(), DummyState())

    LT.visitfn!(::DummyState, u, v, t::Integer) = true
    LT.newvisitfn!(::DummyState, u, v, t::Integer) = false
    @test !LT.traverse_graph!(g7, 1, LT.ThreadedBreadthFirst(), DummyState())

    LT.newvisitfn!(::DummyState, u, v, t::Integer) = true
    LT.postvisitfn!(::DummyState, u, t::Integer) = false
    @test !LT.traverse_graph!(g7, 1, LT.ThreadedBreadthFirst(), DummyState())

    LT.postvisitfn!(::DummyState, u, t::Integer) = true
    LT.postlevelfn!(::DummyState) = false
    @test !LT.traverse_graph!(g7, 1, LT.ThreadedBreadthFirst(), DummyState())
end
