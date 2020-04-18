module Generators

import Base: ==

using Random: shuffle!, randperm, AbstractRNG, GLOBAL_RNG
using SparseArrays: sparse
using Statistics: mean

using LightGraphs
using LightGraphs: sample!, randbn
using LightGraphs.SimpleGraphs
using LightGraphs.SimpleGraphs: AbstractSimpleGraph, SimpleEdge
import LightGraphs.SimpleGraphs: SimpleGraph, SimpleDiGraph, SimpleGraphFromIterator, SimpleDiGraphFromIterator
using LightGraphs.Generators
using LightGraphs.Generators:
    Euclidean,
    ErdosRenyi,
    ApproxErdosRenyi,
    ExpectedDegree,
    WattsStrogatz,
    BarabasiAlbert,
    StaticFitnessModel,
    StaticScaleFree,
    RandomRegular,
    RandomConfigurationModel,
    Tournament,
    Kronecker,
    DorogovtsevMendes,
    RandomOrientationDAG,
    Bull,
    Chvatal,
    Cubical,
    Desargues,
    Diamond,
    Dodecahedral,
    Frucht,
    Heawood,
    House,
    HouseX,
    Icosahedral,
    Karate,
    KrackhardtKite,
    MoebiusKantor,
    Octahedral,
    Pappus,
    Petersen,
    SedgewickMaze,
    Tetrahedral,
    TruncatedCube,
    TruncatedTetrahedron,
    Tutte,
    Complete,
    CompleteBipartite,
    CompleteMultipartite,
    Turan,
    Star,
    Path,
    Cycle,
    Wheel,
    Grid,
    BinaryTree,
    DoubleBinaryTree,
    Roach,
    Clique,
    Ladder,
    CircularLadder,
    Barbell,
    Lollipop,
    Circulant,
    Friendship

import LightGraphs.Generators: BarabasiAlbert    

include("euclideangraphs.jl")
include("randgraphs.jl")
include("sbm.jl")
include("smallgraphs.jl")
include("staticgraphs.jl")


include("deprecations/euclidean.jl")
include("deprecations/randgraphs.jl")
include("deprecations/smallgraphs.jl")
include("deprecations/staticgraphs.jl")
end # module
