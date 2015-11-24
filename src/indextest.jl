function gi(g::Graph,i::Int)
    s = 1
    di = 1
    origi = i       # remove post-test
    while i > 0
        newrow=false
        s > length(g.fadjlist) && throw(BoundsError())
        println("i = $i, s = $s, di = $di")
        if s <= get(g.fadjlist[s], di, -1)
            i -= 1
        end
        while di >= length(g.fadjlist[s])
            s += 1
            di = 1
            # info("setting newrow = true")
            newrow = true
        end
        if !newrow
            di += 1
            # info("setting newrow = false")
            newrow = false
        end

    end

    if di == 1
        s -= 1
        di = length(g.fadjlist[s])
    else
        di -= 1
    end
    println("END: orig i = $origi, i = $i, s = $s, di = $di, g.fadjlist[s][di] = $(g.fadjlist[s][di])")
    return Edge(s,g.fadjlist[s][di])
end

function gi2(g::Graph, i::Int)
    gi = LightGraphs.EdgeIter(g)
    st = start(gi)
    e = Edge(0,0)
    while i > 0
        e, st = next(gi,st)
        i -= 1
    end
    return e
end
