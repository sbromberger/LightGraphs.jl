bg = BenchmarkGroup()
SUITE["connectivity"] = bg


for (name, g) in DIGRAPHS
    bg["connectivity","connected_components","digraph","$name"] = @benchmarkable LightGraphs.connected_components($g)
    bg["connectivity","strongly_connected_components","digraph","$name"] = @benchmarkable LightGraphs.strongly_connected_components($g)

end

for (name, g) in GRAPHS
    bg["connectivity","connected_components","graph","$name"] = @benchmarkable LightGraphs.connected_components($g)
end
