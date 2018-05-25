""" HITS algorithm
HITS(g, mx=100, tol=1e-6, h0=nothing)

Calculates Hyperlink-Induced Topic Search (HITS; also known as hubs and authorities)
of a graph `g`, using a maximum of `mx` iterations, subject to a tolerance `tol`. 
Returns hubs and authorities vectors for nodes in g.

HITS is a link analysis algorithm that rates Web pages, 
developed by Jon Kleinberg.
https://en.wikipedia.org/wiki/HITS_algorithm """

function HITS(g::AbstractGraph, mx=100, tol=1e-6, h0=nothing)
    N = Int(nv(g))
    if (h0 == nothing) # if no starting hub score
        h0 = fill(1. / N, N)
    else # normalized ensures convergence
        h0 = normalize(h0)
    end

    ag = adjacency_matrix(g)
    agT = is_directed(g) ? ag' : ag
    for _ in 1:mx
        auth = normalize(agT * h0)
        hubs = normalize(ag * auth)
        # check for threshold
        sum(abs.(hubs - h0)) <= tol && return (hubs, auth)
        h0 = hubs # update hubs
    end
    warn("Did not converge")
    return (hubs, auth)
end