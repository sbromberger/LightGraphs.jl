    { // Start BFS
      auto wcts = std::chrono::system_clock::now();
      std::vector<uint8_t> vert_level(num_vertices, 255);
      std::vector<bool> vert_visited(num_vertices, false);
      uint8_t n_level = 2;
      std::vector<uint32_t> cur_level, next_level;
      cur_level.reserve(num_vertices); next_level.reserve(num_vertices);
      vert_level[source] = 0;
      vert_visited[source] = 1;
      cur_level.push_back(source);
      while(!cur_level.empty()) {
        for(auto v : cur_level) {
          for(size_t i=vert_offset[v]; i < vert_offset[v+1]; ++i) {
            uint32_t neighbor = edge_targets[i];
            if(!vert_visited[neighbor]) {
              next_level.push_back(neighbor);
              vert_level[neighbor] = n_level;
              vert_visited[neighbor] = true;
            }
          }
        }
        std::cout << "Completed level " << (int) n_level-1 << " size = " << next_level.size() << std::endl;
        ++n_level;
        cur_level.clear();
        next_level.swap(cur_level);
        std::sort(cur_level.begin(), cur_level.end());
      }