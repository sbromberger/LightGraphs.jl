@benchgroup "insertions" begin
  n = 10000
  @bench "ER Generation" g = SimpleGraph($n, 16 * $n)
end
