- The source vertices passed to bfs shortest paths now get a parent of 0 and a distance of 0. Previously, the
parent was the vertex id and the distance was 0. This is consistent with the other shortest path algorithms.
