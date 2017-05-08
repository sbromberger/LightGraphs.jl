

# Function to compute all simple paths between source-sink pairs

# Usage: pathSet = []
#        visited = [source]
#        RecDFS(graph, visited, sink, pathSet)

function recdfs(graph, visited, sink, pathSet)
  nodes = LightGraphs.neighbors(graph, visited[length(visited)])

  for i in nodes

    if in(i, visited)
      continue
    end

    if i == sink
      push!(visited, i)
      push!(pathSet, visited)
      pop!(visited)
    elseif !in(i, visited)
      push!(visited, i)
      recdfs(graph, visited, sink, pathSet) # Recursion starts here
      pop!(visited)
    end

  end

end
