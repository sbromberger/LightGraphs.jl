
using Base.Threads

function parallel_cross_edge_find(
    edge_list::Vector{Edge{U}},
    connected_vs::Vector{U},
    n_threads::Integer
    current_ind::Vector{R}
    ) where U <: Integer where R <: Integer

    best_ind = Atomic{R}(typemax(R))

    @threads for i in 1:n_threads

        id = threadid()
        for ind in Iterators.countfrom(current_ind[id], n_threads)


        end
    end

end
