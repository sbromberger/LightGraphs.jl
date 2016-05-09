function MDGraph(a::AbstractString, x...)
    a in matrixdepot("symmetric") || error("Valid matrix not found in collection")
    external = a in matrixdepot("data")
    m = external? matrixdepot(a, x..., :read) : matrixdepot(a, x...)
    m == nothing && error("Invalid matrix parameters specified")

    return Graph(m)
end

function MDDiGraph(a::AbstractString, x...)
    a in matrixdepot("all") || error("Valid matrix not found in collection")
    external = a in matrixdepot("data")
    m = external? matrixdepot(a, x..., :read) : matrixdepot(a, x...)
    m == nothing && error("Invalid matrix parameters specified")

    return DiGraph(m)
end
