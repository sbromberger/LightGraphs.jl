@testset "Cycles" begin
    completedg = CompleteDiGraph(4)
    pathdg = PathDiGraph(5)
    triangle = random_regular_graph(3,2)
    quadrangle = random_regular_graph(4,2)
    pentagon = random_regular_graph(5,2)

    @test maxsimplecycles(pathdg) == 0
    @test maxsimplecycles(completedg) == 20
    @test maxsimplecycles(4) == 20
    @test maxsimplecycles(pathdg, false) == 84

    @test length(simplecycles(completedg)) == 20
    @test simplecycles(completedg) == @inferred(simplecycles_iter(completedg))
    @test simplecyclescount(completedg) == 20
    @test simplecycleslength(completedg) == ([0,6,8,6], 20)

    @test simplecyclescount(pathdg) == 0
    @test length(simplecycles(pathdg)) == 0
    @test isempty(simplecycles(pathdg)) == true
    @test isempty(simplecycles_iter(pathdg)) == true
    @test simplecycleslength(pathdg) == (zeros(5), 0)

    @test simplecyclescount(completedg, 10) == 10
    @test simplecycleslength(completedg, 10)[2] == 10

    @test simplecyclescount(pathdg, 10) == 0
    @test isempty(simplecycles_iter(pathdg, 10)) == true
    @test simplecycleslength(pathdg, 10) == (zeros(5), 0)

    trianglelengths, triangletotal = simplecycleslength(DiGraph(triangle))
    @test sum(trianglelengths) == triangletotal

    quadranglelengths, quadrangletotal = simplecycleslength(DiGraph(quadrangle))
    @test sum(quadranglelengths) == quadrangletotal
    @test simplecycles(DiGraph(quadrangle)) == @inferred(simplecycles_iter(DiGraph(quadrangle)))

    pentagonlengths, pentagontotal = simplecycleslength(DiGraph(pentagon))
    @test sum(pentagonlengths) == pentagontotal

end

