# Portions of the smallgraphs.jl package are derived from NetworkX, which
# is licensed under the BSD License as follows:
#
# > NetworkX Python library and are BSD Licensed as follows:
# >
# > Copyright (C) 2004-2012, NetworkX Developers
# > Aric Hagberg <hagberg@lanl.gov>
# > Dan Schult <dschult@colgate.edu>
# > Pieter Swart <swart@lanl.gov>
# > All rights reserved.
# >
# > Redistribution and use in source and binary forms, with or without
# > modification, are permitted provided that the following conditions are
# > met:
# >
# >   * Redistributions of source code must retain the above copyright
# >     notice, this list of conditions and the following disclaimer.
# >
# >   * Redistributions in binary form must reproduce the above
# >     copyright notice, this list of conditions and the following
# >     disclaimer in the documentation and/or other materials provided
# >     with the distribution.
# >
# >   * Neither the name of the NetworkX Developers nor the names of its
# >     contributors may be used to endorse or promote products derived
# >     from this software without specific prior written permission.
# >
# >
# > THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# > "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# > LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# > A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# > OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# > SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# > LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# > DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# > THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# > (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# > OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function CompleteGraph(n::Integer; is_directed=true)
    g = Graph(n)
    for i = 1:n, j=1:n
        if i < j
            add_edge!(g,i,j)
        end
    end
    return g
end

function CompleteDiGraph(n::Integer)
    g = DiGraph(n)
    for i = 1:n, j=1:n
        if i != j
            add_edge!(g,i,j)
        end
    end
    return g
end


function StarGraph(n::Integer)
    g = Graph(n)
    for i = 2:n
        add_edge!(g,1,i)
    end
    return g
end

function StarDiGraph(n::Integer)
    g = DiGraph(n)
    for i = 2:n
        add_edge!(g,1,i)
    end
    return g
end


function PathGraph(n::Integer)
    g = Graph(n)
    for i = 2:n
        add_edge!(g, i-1, i)
    end
    return g
end


function PathDiGraph(n::Integer)
    g = DiGraph(n)
    for i = 2:n
        add_edge!(g, i-1, i)
    end
    return g
end


function WheelGraph(n::Integer)
    g = StarGraph(n)
    for i = 3:n
        add_edge!(g, i-1, i)
    end
    if n != 2
        add_edge!(g, n,2)
    end
    return g
end

function WheelDiGraph(n::Integer)
    g = StarDiGraph(n)
    for i = 3:n
        add_edge!(g, i-1, i)
    end
    if n != 2
        add_edge!(g, n,2)
    end
    return g
end


function _make_simple_undirected_graph{T<:Integer}(n::T, edgelist::Vector{(T,T)})
    g = Graph(n)
    for (s,d) in edgelist
        add_edge!(g,s,d)
    end
    return g
end

DiamondGraph() =
    _make_simple_undirected_graph(4, [(1,2), (1,3), (2,3), (2,4), (3,4)])

BullGraph() =
    _make_simple_undirected_graph(5, [(1,2), (1,3), (2,3), (2,4), (3,5)])

function ChvatalGraph()
    e = [
        (1, 2), (1, 5), (1, 7), (1, 10),
        (2, 3), (2, 6), (2, 8),
        (3, 4), (3, 7), (3, 9),
        (4, 5), (4, 8), (4, 10),
        (5, 6), (5, 9),
        (6, 11), (6, 12),
        (7, 11), (7, 12),
        (8, 9), (8, 12),
        (9, 11),
        (10, 11), (10, 12)
    ]
    return _make_simple_undirected_graph(12,e)
end

function CubicalGraph()
    e = [
        (1, 2), (1, 4), (1, 5),
        (2, 3), (2, 8),
        (3, 4), (3, 7),
        (4, 6), (5, 6), (5, 8),
        (6, 7),
        (7, 8)
    ]
    return _make_simple_undirected_graph(8,e)
end

function DesarguesGraph()
    e = [
        (1, 2), (1, 6), (1, 20),
        (2, 3), (2, 17),
        (3, 4), (3, 12),
        (4, 5), (4, 15),
        (5, 6), (5, 10),
        (6, 7),
        (7, 8), (7, 16),
        (8, 9), (8, 19),
        (9, 10), (9, 14),
        (10, 11),
        (11, 12), (11, 20),
        (12, 13),
        (13, 14), (13, 18),
        (14, 15),
        (15, 16),
        (16, 17),
        (17, 18),
        (18, 19),
        (19, 20)
    ]
    return _make_simple_undirected_graph(20,e)
end

function DodecahedralGraph()
    e = [
        (1, 2), (1, 11), (1, 20),
        (2, 3), (2, 9),
        (3, 4), (3, 7),
        (4, 5), (4, 20),
        (5, 6), (5, 18),
        (6, 7), (6, 16),
        (7, 8),
        (8, 9), (8, 15),
        (9, 10),
        (10, 11), (10, 14),
        (11, 12),
        (12, 13), (12, 19),
        (13, 14), (13, 17),
        (14, 15),
        (15, 16),
        (16, 17),
        (17, 18),
        (18, 19),
        (19, 20)
    ]
    return _make_simple_undirected_graph(20,e)
end

function FruchtGraph()
    e = [
        (1, 2), (1, 7), (1, 8),
        (2, 3), (2, 8),
        (3, 4), (3, 9),
        (4, 5), (4, 10),
        (5, 6), (5, 10),
        (6, 7), (6, 11),
        (7, 11),
        (8, 12),
        (9, 10), (9, 12),
        (11, 12)
    ]
    return _make_simple_undirected_graph(20,e)
end

function HeawoodGraph()
    e = [
    (1, 2), (1, 6), (1, 14),
    (2, 3), (2, 11),
    (3, 4), (3, 8),
    (4, 5), (4, 13),
    (5, 6), (5, 10),
    (6, 7),
    (7, 8), (7, 12),
    (8, 9),
    (9, 10), (9, 14),
    (10, 11),
    (11, 12),
    (12, 13),
    (13, 14)
    ]
    return _make_simple_undirected_graph(14,e)
end

function HouseGraph()
    e = [ (1, 2), (1, 3), (2, 4), (3, 4), (3, 5), (4, 5) ]
    return _make_simple_undirected_graph(5,e)
end

function HouseXGraph()
    g = HouseGraph()
    add_edge!(g, 1, 4)
    add_edge!(g, 2, 3)
    return g
end

function IcosahedralGraph()
    e = [
        (1, 2), (1, 6), (1, 8), (1, 9), (1, 12),
        (2, 3), (2, 6), (2, 7), (2, 9),
        (3, 4), (3, 7), (3, 9), (3, 10),
        (4, 5), (4, 7), (4, 10), (4, 11),
        (5, 6), (5, 7), (5, 11), (5, 12),
        (6, 7), (6, 12),
        (8, 9), (8, 10), (8, 11), (8, 12),
        (9, 10),
        (10, 11), (11, 12)
    ]
    return _make_simple_undirected_graph(12, e)
end

function KrackhardtKiteGraph()
    e = [
        (1, 2), (1, 3), (1, 4), (1, 6),
        (2, 4), (2, 5), (2, 7),
        (3, 4), (3, 6),
        (4, 5), (4, 6), (4, 7),
        (5, 7),
        (6, 7), (6, 8),
        (7, 8),
        (8, 9),
        (9, 10)
    ]
    return _make_simple_undirected_graph(10,e)
end

function MoebiusKantorGraph()
    e = [
        (1, 2), (1, 6), (1, 16),
        (2, 3), (2, 13),
        (3, 4), (3, 8),
        (4, 5), (4, 15),
        (5, 6), (5, 10),
        (6, 7),
        (7, 8), (7, 12),
        (8, 9),
        (9, 10), (9, 14),
        (10, 11),
        (11, 12), (11, 16),
        (12, 13),
        (13, 14),
        (14, 15),
        (15, 16)
    ]
    return _make_simple_undirected_graph(16,e)
end

function OctahedralGraph()
    e = [
        (1, 2), (1, 3), (1, 4), (1, 5),
        (2, 3), (2, 4), (2, 6),
        (3, 5), (3, 6),
        (4, 5), (4, 6),
        (5, 6)
    ]
    return _make_simple_undirected_graph(6,e)
end

function PappusGraph()
    e = [
        (1, 2), (1, 6), (1, 18),
        (2, 3), (2, 9),
        (3, 4), (3, 14),
        (4, 5), (4, 11),
        (5, 6), (5, 16),
        (6, 7),
        (7, 8), (7, 12),
        (8, 9), (8, 15),
        (9, 10),
        (10, 11), (10, 17),
        (11, 12),
        (12, 13),
        (13, 14), (13, 18),
        (14, 15),
        (15, 16),
        (16, 17),
        (17, 18)
    ]
    return _make_simple_undirected_graph(18,e)
end

function PetersenGraph()
    e = [
        (1, 2), (1, 5), (1, 6),
        (2, 3), (2, 7),
        (3, 4), (3, 8),
        (4, 5), (4, 9),
        (5, 10),
        (6, 8), (6, 9),
        (7, 9), (7, 10),
        (8, 10)
    ]
    return _make_simple_undirected_graph(10,e)
end

function SedgewickMazeGraph()
    e = [
        (1, 3),
        (1, 6), (1, 8),
        (2, 8),
        (3, 7),
        (4, 5), (4, 6),
        (5, 6), (5, 7), (5, 8)
    ]
    return _make_simple_undirected_graph(8,e)
end

TetrahedralGraph() =
    _make_simple_undirected_graph(4, [(1, 2), (1, 3), (1, 4), (2, 3), (2, 4), (3, 4)])

function TruncatedCubeGraph()
    e = [
        (1, 2), (1, 3), (1, 5),
        (2, 12), (2, 15),
        (3, 4), (3, 5),
        (4, 7), (4, 9),
        (5, 6),
        (6, 17), (6, 19),
        (7, 8), (7, 9),
        (8, 11), (8, 13),
        (9, 10),
        (10, 18), (10, 21),
        (11, 12), (11, 13),
        (12, 15), (13, 14),
        (14, 22), (14, 23),
        (15, 16),
        (16, 20), (16, 24),
        (17, 18), (17, 19),
        (18, 21),
        (19, 20),
        (20, 24),
        (21, 22),
        (22, 23),
        (23, 24)
    ]
    return _make_simple_undirected_graph(24,e)
end

function TruncatedTetrahedronGraph()
    e = [
        (1, 2),(1, 3),(1, 10),
        (2, 3),(2, 7),
        (3, 4),
        (4, 5),(4, 12),
        (5, 6),(5, 12),
        (6, 7),(6, 8),
        (7, 8),
        (8, 9),
        (9, 10),(9, 11),
        (10, 11),
        (11, 12)
    ]
    return _make_simple_undirected_graph(12,e)
end

function TutteGraph()
    e = [
    (1, 2),(1, 3),(1, 4),
    (2, 5),(2, 27),
    (3, 11),(3, 12),
    (4, 19),(4, 20),
    (5, 6),(5, 34),
    (6, 7),(6, 30),
    (7, 8),(7, 28),
    (8, 9),(8, 15),
    (9, 10),(9, 39),
    (10, 11),(10, 38),
    (11, 40),
    (12, 13),(12, 40),
    (13, 14),(13, 36),
    (14, 15),(14, 16),
    (15, 35),
    (16, 17),(16, 23),
    (17, 18),(17, 45),
    (18, 19),(18, 44),
    (19, 46),
    (20, 21),(20, 46),
    (21, 22),(21, 42),
    (22, 23),(22, 24),
    (23, 41),
    (24, 25),(24, 28),
    (25, 26),(25, 33),
    (26, 27),(26, 32),
    (27, 34),
    (28, 29),
    (29, 30),(29, 33),
    (30, 31),
    (31, 32),(31, 34),
    (32, 33),
    (35, 36),(35, 39),
    (36, 37),
    (37, 38),(37, 40),
    (38, 39),
    (41, 42),(41, 45),
    (42, 43),
    (43, 44),(43, 46),
    (44, 45)
    ]
    return _make_simple_undirected_graph(46,e)
end
