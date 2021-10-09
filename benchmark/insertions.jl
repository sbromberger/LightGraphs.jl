suite["insertions"] = BenchmarkGroup(["ER Generation"])

n = 10000
suite["insertions"]["ER Generation"] = @benchmarkable SimpleGraph($n, 16 * $n)
