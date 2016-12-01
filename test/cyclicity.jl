complete = CompleteDiGraph(4)

@test maxcycles(g4) == 0
@test maxcycles(complete) == 20
@test maxcycles(4) == 20
@test maxcycles(g4, false) == 84

@test length(simplecycles(complete)) == 20
@test simplecycles(complete) == getcycles(complete)
@test countcycles(complete) == 20
@test getcycleslength(complete) == ([0,6,8,6], 20)

@test countcycles(g4) == 0
@test length(simplecycles(g4)) == 0
@test isempty(simplecycles(g4)) == true
@test isempty(getcycles(g4)) == true
@test getcycleslength(g4) == (zeros(5), 0)

@test countcycles(complete, 10) == 10
@test getcycleslength(complete, 10)[2] == 10

@test countcycles(g4, 10) == 0
@test isempty(getcycles(g4, 10)) == true
@test getcycleslength(g4, 10) == (zeros(5), 0)

trianglelengths, triangletotal = getcycleslength(DiGraph(triangle))
@test sum(trianglelengths) == triangletotal

quadranglelengths, quadrangletotal = getcycleslength(DiGraph(quadrangle))
@test sum(quadranglelengths) == quadrangletotal
@test simplecycles(DiGraph(quadrangle)) == getcycles(DiGraph(quadrangle))

pentagonlengths, pentagontotal = getcycleslength(DiGraph(pentagon))
@test sum(pentagonlengths) == pentagontotal

