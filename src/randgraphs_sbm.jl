using LightGraphs
import StatsBase: sample
"""StochasticBlockModel(n,nodemap,affinities)
A type capturing the parameters of the SBM.
Each vertex is assigned to a block and the probability of edge (i,j)
depends only on the block labels of vertex i and vertex j.

The assignement is stored in nodemap and the block affinities a k by k
matrix is stored in affinities.

affinities[k,l] is the probability of an edge between any vertex in
block k and any vertex in block k.

We are generating the graphs by taking random `i,j in vertices(g)` and
flipping a coin with probability `affinities[nodemap[i],nodemap[j]]`.
"""
type StochasticBlockModel{T<:Integer,P<:Real}
    n::T
    nodemap::Array{T}
    affinities::Matrix{P}
end

""" a constructor for StochasticBlockModel that uses the sizes of the blocks
and the affinity matrix. This construction implies that consecutive
vertices will be in the same blocks, except for the block boundaries.
"""
function StochasticBlockModel{T,P}(sizes::Vector{T}, affinities::Matrix{P})
    csum = cumsum(sizes)
    j = 1
    nodemap = zeros(Int, csum[end])
    for i in 1:csum[end]
        if i > csum[j]
            j+=1
        end               
        nodemap[i] = j
    end
    return StochasticBlockModel(csum[end], nodemap, affinities)
end

"""produce the sbm affinity matrix where the internal and external probabilities are
the same
"""
function sbmaffinity(internalp::Float64, externalp::Float64, size::Int, numblocks::Int)
    B = eye(numblocks)*(internalp) + externalp*(ones(numblocks,numblocks)-I)
    return B
end

"""produce the sbm affinity matrix where the external probabilities are the same
the internal probabilities and sizes differ by blocks.
"""
function sbmaffinity(internalp::Vector{Float64}, externalp::Float64, sizes::Vector{Int})
    numblocks = length(sizes)
    numblocks == length(internalp) || error("Inconsistent input dimensions: internalp, sizes")
    B = diagm(internalp) + externalp*(ones(numblocks, numblocks)-I)
    return B
end

function StochasticBlockModel(internalp::Float64,
                              externalp::Float64,
                              size::Int,
                              numblocks::Int)
    sizes = [size for i in 1:numblocks]
    B = sbmaffinity([internalp for i in 1:numblocks], externalp, sizes)
    StochasticBlockModel(sizes, B)
end

function StochasticBlockModel(internalp::Vector{Float64}, externalp::Float64, sizes::Vector{Int})
    B = sbmaffinity(internalp, externalp, sizes)
    return StochasticBlockModel(sizes, B)
end


biclique = ones(2,2) - eye(2)

"""construct the affinity matrix for a near bipartite SBM.
between is the affinity between the two parts of each bipartite community
intra is the probability of an edge within the parts of the partitions.

This is a specific type of SBM with k/2 blocks each with two halves.
Each half is connected as a random bipartite graph with probability `intra`
The blocks are connected with probability `between`.
"""
function nearbipartiteaffinity(sizes::Vector{Int}, between::Float64, intra::Float64)
    numblocks = round(Int, length(sizes)/2)
    return kron(between*eye(numblocks), biclique) + eye(2numblocks)*intra
end

"""Return a generator for edges from a stochastic block model near bipartite graph."""
function nearbipartiteaffinity(sizes::Vector{Int}, between::Float64, inter::Float64, noise)
    B = nearbipartiteaffinity(sizes, between, inter) + noise
    #= info("Affinities are:\n$B")#, file=stderr) =#
    return B
end

function nearbipartiteSBM(sizes, between, inter, noise)
    return StochasticBlockModel(sizes, nearbipartiteaffinity(sizes, between, inter, noise))
end


"""random_pair: generates a stream of random pairs in 1:n"""
function random_pair(n::Int)
    while true
        produce( rand(1:n), rand(1:n) )
    end
end

"""take the first n elements produced by t"""
function take(n::Int, t::Task) 
    for i in 1:n
        produce(consume(t))
    end
end

""" Draw an edgestream
Affinity::(Node, Node) -> Probability
pairs::generator of (Node, Node)
"""
function sample(affinity, pairs)
    for (i, j) in pairs
        aff = affinity(i,j)
        #print(STDERR, "affinity $i,$j = $aff\n")
        if rand() < aff
            produce((i,j))
        #else try again
        end        
    end
end

"""Take an infinite sample from the sbm. Use take() to take only the first n edges
or pass to graph(edgestream, numedges).
"""
function sample(sbm::StochasticBlockModel)
    pairs = @task random_pair(sbm.n)
    for (i,j) in pairs
    	if i == j
	    continue
	end
        p = sbm.affinities[sbm.nodemap[i], sbm.nodemap[j]]
        if rand() < p
            produce(i, j)
        end
    end
end

"""convert a stream of edges produced by sample into a graph"""
function graph(edgestream, sizes, numedges::Int)
    g = Graph(sum(sizes))
    #= println(g) =#
    count = 1
    for (i,j) in edgestream
        #print("$count, $i,$j\n")
        count += 1
        if !has_edge(g,i,j)
            add_edge!(g,Edge(i,j))
        end
        if count >= numedges
            break
        end
    end
    #= println(g) =#
    return g
end

"""counts the number of edges that go between each block"""
function blockcounts(sbm::StochasticBlockModel, A::AbstractMatrix)
    #= info("making Q") =#
    I = collect(1:sbm.n)
    J =  [sbm.nodemap[i] for i in 1:sbm.n]
    V =  ones(sbm.n)
    Q = sparse(I,J,V)
    #Q = Q / Q'Q
    #@show Q'Q# < 1e-6
    return (Q'A)*(Q)
end


function blockcounts(sbm::StochasticBlockModel, g::SimpleGraph)
    return blockcounts(sbm, adjacency_matrix(g))
end

function blockfractions(sbm::StochasticBlockModel, g)
    bc = blockcounts(sbm, g)
    bp = bc ./ sum(bc)
    return bp
end
