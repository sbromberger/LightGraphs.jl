@benchgroup "max-flow" begin
  for n in 9:5:29
    srand(1)
    p = 8.0 / n
    A = sprand(n,n,p)
    g = DiGraph(A)
    cap = round.(A*100)
    @bench "n = $n" LightGraphs.maximum_flow($g, 1, $n, $cap)
  end
end # max-flow
