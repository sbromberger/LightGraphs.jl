@benchgroup "insertions" begin
  n = 10000
  @bench "ER Generation" g = Graph($n, 16*$n)
end
