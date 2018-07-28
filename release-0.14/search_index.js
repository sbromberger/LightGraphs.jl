var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#LightGraphs-1",
    "page": "Getting Started",
    "title": "LightGraphs",
    "category": "section",
    "text": "The goal of LightGraphs.jl is to offer a performant platform for network and graph analysis in Julia. To this end, LightGraphs offers both (a) a set of simple, concrete graph implementations – SimpleGraph (for undirected graphs) and SimpleDiGraph (for directed graphs), and (b) an API for the development of more sophisticated graph implementations under the AbstractGraph type.As such, LightGraphs.jl is the central package of the JuliaGraphs ecosystem. Additional functionality like advanced IO and file formats, weighted graphs, property graphs, and optimization related functions can be found in the following packages:LightGraphsExtras.jl: extra functions for graph analysis.\nMetaGraphs.jl: graphs with associated meta-data.\nSimpleWeightedGraphs.jl: weighted graphs.\nGraphIO.jl: tools for importing and exporting graph objects using common file types like edgelists, GraphML, Pajek NET, and more.\nGraphDataFrameBridge.jl: Tools forconverting edgelists stored in DataFrames into graphs (MetaGraphs, MetaDiGraphs)."
},

{
    "location": "index.html#Basic-library-examples-1",
    "page": "Getting Started",
    "title": "Basic library examples",
    "category": "section",
    "text": "The LightGraphs.jl libraries includes numerous convenience functions for generating functions detailed in Making and Modifying Graphs, such as PathGraph, which makes a simple undirected path graph of a given length. Once created, these graphs can be easily interrogated and modified.julia> g = PathGraph(6)\n\n# Number of vertices\njulia> nv(g)\n\n# Number of edges\njulia> ne(g)\n\n# Add an edge to make the path a loop\njulia> add_edge!(g, 1, 6)For an overview of basic functions for interacting with graphs, check out Accessing Graph Properties and Making and Modifying Graphs. Detailed tutorials may be found in the JuliaGraphs Tutorial Notebooks repository."
},

{
    "location": "graphtypes.html#",
    "page": "Choosing A Graph Type",
    "title": "Choosing A Graph Type",
    "category": "page",
    "text": ""
},

{
    "location": "graphtypes.html#Graph-Types-1",
    "page": "Choosing A Graph Type",
    "title": "Graph Types",
    "category": "section",
    "text": "In addition to providing SimpleGraph and SimpleDiGraph implementations, LightGraphs also serves as a framework for other graph types. Currently, there are several alternative graph types, each with its own package:SimpleWeightedGraphs provides a structure for (un)directed graphs with the ability to specify weights on edges.\nMetaGraphs provides a structure (un)directed graphs that supports user-defined properties on the graph, vertices, and edges.\nStaticGraphs supports very large graph structures in a space- and time-efficient manner, but as the name implies, does not allow modification of the graph once created."
},

{
    "location": "graphtypes.html#Which-Graph-Type-Should-I-Use?-1",
    "page": "Choosing A Graph Type",
    "title": "Which Graph Type Should I Use?",
    "category": "section",
    "text": "These are general guidelines to help you select the proper graph type.In general, prefer the native SimpleGraphs/SimpleDiGraphs structures in LightGraphs.jl.\nIf you need edge weights and don\'t require large numbers of graph modifications, use SimpleWeightedGraphs.\nIf you need labeling of vertices or edges, use MetaGraphs.\nIf you work with very large graphs (billons to tens of billions of edges) and don\'t need mutability, use StaticGraphs."
},

{
    "location": "types.html#",
    "page": "LightGraphs Types",
    "title": "LightGraphs Types",
    "category": "page",
    "text": "#LightGraphs TypesLightGraphs.jl supports both the AbstractGraph type and two concrete simple graph types- - SimpleGraph for undirected graphs and SimpleDiGraph for directed graphs – that are subtypes of AbstractGraph."
},

{
    "location": "types.html#Concrete-Types-1",
    "page": "LightGraphs Types",
    "title": "Concrete Types",
    "category": "section",
    "text": "LightGraphs.jl provides two concrete graph types: SimpleGraph is an undirected graph, and SimpleDiGraph is its directed counterpart. Both of these types can be parameterized to specifying how vertices are identified (by default, SimpleGraph and SimpleDiGraph use the system default integer type, usually Int64).A graph G is described by a set of vertices V and edges E: G = {V, E}. V is an integer range 1:n; E is represented as forward (and, for directed graphs, backward) adjacency lists indexed by vertices. Edges may also be accessed via an iterator that yields Edge types containing (src<:Integer, dst<:Integer) values. Both vertices and edges may be integers of any type, and the smallest type that fits the data is recommended in order to save memory.Graphs are created using SimpleGraph() or SimpleDiGraph(); there are several options (see the tutorials for examples).Multiple edges between two given vertices are not allowed: an attempt to add an edge that already exists in a graph will not raise an error. This event can be detected using the return value of add_edge!."
},

{
    "location": "types.html#AbstractGraph-Type-1",
    "page": "LightGraphs Types",
    "title": "AbstractGraph Type",
    "category": "section",
    "text": "To encourage experimentation and development within the JuliaGraphs ecosystem, LightGraphs.jl defines the AbstractGraph type, which is used by libraries like MetaGraphs.jl (for graphs with associated meta-data) and SimpleWeightedGraphs.jl (for weighted graphs). All types that are a subset of AbstractGraph must implement the following functions (most of which are described in more detail in Accessing Graph Properties and Making and Modifying Graphs):Order = [:type, :function]\nPages   = [\"types.md\"]"
},

{
    "location": "types.html#LightGraphs.AbstractEdge",
    "page": "LightGraphs Types",
    "title": "LightGraphs.AbstractEdge",
    "category": "type",
    "text": "AbstractEdge\n\nAn abstract type representing a single edge between two vertices of a graph.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.AbstractEdgeIter",
    "page": "LightGraphs Types",
    "title": "LightGraphs.AbstractEdgeIter",
    "category": "type",
    "text": "AbstractEdgeIter\n\nAn abstract type representing an edge iterator.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.AbstractGraph",
    "page": "LightGraphs Types",
    "title": "LightGraphs.AbstractGraph",
    "category": "type",
    "text": "AbstractGraph\n\nAn abstract type representing a graph.\n\n\n\n\n\n"
},

{
    "location": "types.html#Base.reverse-Tuple{AbstractEdge}",
    "page": "LightGraphs Types",
    "title": "Base.reverse",
    "category": "method",
    "text": "reverse(e)\n\nCreate a new edge from e with source and destination vertices reversed.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.dst-Tuple{AbstractEdge}",
    "page": "LightGraphs Types",
    "title": "LightGraphs.dst",
    "category": "method",
    "text": "dst(e)\n\nReturn the destination vertex of edge e.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.edges-Tuple{Any}",
    "page": "LightGraphs Types",
    "title": "LightGraphs.edges",
    "category": "method",
    "text": "edges(g)\n\nReturn (an iterator to or collection of) the edges of a graph. For AbstractSimpleGraphs it returns a SimpleEdgeIter. The expressions e in edges(g) and e ∈ edges(ga) evaluate as calls to has_edge.\n\nImplementation Notes\n\nA returned iterator is valid for one pass over the edges, and is invalidated by changes to g.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.edgetype-Tuple{AbstractGraph}",
    "page": "LightGraphs Types",
    "title": "LightGraphs.edgetype",
    "category": "method",
    "text": "edgetype(g)\n\nReturn the type of graph g\'s edge\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.has_edge-Tuple{Any,Any,Any}",
    "page": "LightGraphs Types",
    "title": "LightGraphs.has_edge",
    "category": "method",
    "text": "has_edge(g, s, d)\n\nReturn true if the graph g has an edge from node s to node d.\n\nAn optional has_edge(g, e) can be implemented to check if an edge belongs to a graph, including any data other than source and destination node.\n\ne ∈ edges(g) or e ∈ edges(g) evaluate as calls to has_edge, c.f. edges.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.has_vertex-Tuple{Any,Any}",
    "page": "LightGraphs Types",
    "title": "LightGraphs.has_vertex",
    "category": "method",
    "text": "has_vertex(g, v)\n\nReturn true if v is a vertex of g.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.inneighbors-Tuple{Any,Any}",
    "page": "LightGraphs Types",
    "title": "LightGraphs.inneighbors",
    "category": "method",
    "text": "inneighbors(g, v)\n\nReturn a list of all neighbors connected to vertex v by an incoming edge.\n\nImplementation Notes\n\nReturns a reference, not a copy. Do not modify result.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.is_directed-Tuple{Any}",
    "page": "LightGraphs Types",
    "title": "LightGraphs.is_directed",
    "category": "method",
    "text": "is_directed(g)\n\nReturn true if the graph is a directed graph; false otherwise.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.ne-Tuple{AbstractGraph}",
    "page": "LightGraphs Types",
    "title": "LightGraphs.ne",
    "category": "method",
    "text": "ne(g)\n\nReturn the number of edges in g.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.nv-Tuple{AbstractGraph}",
    "page": "LightGraphs Types",
    "title": "LightGraphs.nv",
    "category": "method",
    "text": "nv(g)\n\nReturn the number of vertices in g.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.outneighbors-Tuple{Any,Any}",
    "page": "LightGraphs Types",
    "title": "LightGraphs.outneighbors",
    "category": "method",
    "text": "outneighbors(g, v)\n\nReturn a list of all neighbors connected to vertex v by an outgoing edge.\n\nImplementation Notes\n\nReturns a reference, not a copy. Do not modify result.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.src-Tuple{AbstractEdge}",
    "page": "LightGraphs Types",
    "title": "LightGraphs.src",
    "category": "method",
    "text": "src(e)\n\nReturn the source vertex of edge e.\n\n\n\n\n\n"
},

{
    "location": "types.html#LightGraphs.vertices-Tuple{AbstractGraph}",
    "page": "LightGraphs Types",
    "title": "LightGraphs.vertices",
    "category": "method",
    "text": "vertices(g)\n\nReturn (an iterator to or collection of) the vertices of a graph.\n\nImplementation Notes\n\nA returned iterator is valid for one pass over the edges, and is invalidated by changes to g.\n\n\n\n\n\n"
},

{
    "location": "types.html#Full-Docs-for-AbstractGraph-Functions-1",
    "page": "LightGraphs Types",
    "title": "Full Docs for AbstractGraph Functions",
    "category": "section",
    "text": "Modules = [LightGraphs]\nPages   = [\"interface.jl\"]\nPrivate = false"
},

{
    "location": "basicproperties.html#",
    "page": "Accessing Properties",
    "title": "Accessing Properties",
    "category": "page",
    "text": ""
},

{
    "location": "basicproperties.html#Accessing-Graph-Properties-1",
    "page": "Accessing Properties",
    "title": "Accessing Graph Properties",
    "category": "section",
    "text": "The following is an overview of functions for accessing graph properties. For functions that modify graphs, see Making and Modifying Graphs."
},

{
    "location": "basicproperties.html#Graph-Properties:-1",
    "page": "Accessing Properties",
    "title": "Graph Properties:",
    "category": "section",
    "text": "nv: Returns number of vertices in graph.\nne: Returns number of edges in graph.\nvertices: Iterable object of all graph vertices.\nedges: Iterable object of all graph edges.\nhas_vertex: Checks for whether graph includes a vertex.\nhas_edge(g, s, d): Checks for whether graph includes an edge from a given source s to a given destination d.\nhas_edge(g, e) will return true if there is an edge in g that satisfies e == f for any f ∈ edges(g). This is a strict equality test that may require all properties of e are the same. This definition of equality depends on the implementation. For testing whether an edge exists between two vertices s,d use has_edge(g, s, d).Note: to use the has_edge(g, e) method safely, it is important to understand the conditions under which edges are equal to each other. These conditions are defined by the has_edge(g::G,e) method as defined by the graph type G. The default behavior is to check has_edge(g,src(e),dst(e)). This distinction exists to allow new graph types such as MetaGraphs or MultiGraphs to distinguish between edges with the same source and destination but potentially different properties.has_self_loops Checks for self-loops.\nis_directed Checks if graph is directed.\neltype Returns element type of graphs."
},

{
    "location": "basicproperties.html#Vertex-Properties-1",
    "page": "Accessing Properties",
    "title": "Vertex Properties",
    "category": "section",
    "text": "neighbors: Return array of neighbors of a vertex. If graph is directed, output is equivalent of outneighbors.\nall_neighbors:  Returns array of all neighbors (both inneighbors and outneighbors). For undirected graphs, equivalent to neighbors.\ninneighbors: Return array of in-neighbors. Equivalent to neighbors for undirected graphs.\noutneighbors: Return array of out-neighbors. Equivalent to neighbors for undirected graphs."
},

{
    "location": "basicproperties.html#Edge-Properties-1",
    "page": "Accessing Properties",
    "title": "Edge Properties",
    "category": "section",
    "text": "src: Give source vertex of an edge.\ndst: Give destination vertex of an edge.\nreverse: Creates a new edge running in opposite direction of passed edge."
},

{
    "location": "generators.html#",
    "page": "Making and Modifying Graphs",
    "title": "Making and Modifying Graphs",
    "category": "page",
    "text": ""
},

{
    "location": "generators.html#Making-and-Modifying-Graphs-1",
    "page": "Making and Modifying Graphs",
    "title": "Making and Modifying Graphs",
    "category": "section",
    "text": "LightGraphs.jl provides a number of methods for creating a graph object, including tools for building and modifying graph objects, a wide array of graph generator functions, and the ability to read and write graphs from files (using GraphIO.jl)."
},

{
    "location": "generators.html#LightGraphs.SimpleGraphs.SimpleGraph",
    "page": "Making and Modifying Graphs",
    "title": "LightGraphs.SimpleGraphs.SimpleGraph",
    "category": "type",
    "text": "SimpleGraph{T}\n\nA type representing an undirected graph.\n\n\n\n\n\n"
},

{
    "location": "generators.html#LightGraphs.SimpleGraphs.SimpleDiGraph",
    "page": "Making and Modifying Graphs",
    "title": "LightGraphs.SimpleGraphs.SimpleDiGraph",
    "category": "type",
    "text": "SimpleDiGraph{T}\n\nA type representing a directed graph.\n\n\n\n\n\n"
},

{
    "location": "generators.html#LightGraphs.Edge",
    "page": "Making and Modifying Graphs",
    "title": "LightGraphs.Edge",
    "category": "type",
    "text": "Edge\n\nA datastruture representing an edge between two vertices in a Graph or DiGraph.\n\n\n\n\n\n"
},

{
    "location": "generators.html#LightGraphs.SimpleGraphs.add_edge!",
    "page": "Making and Modifying Graphs",
    "title": "LightGraphs.SimpleGraphs.add_edge!",
    "category": "function",
    "text": "add_edge!(g, e)\n\nAdd an edge e to graph g. Return true if edge was added successfully, otherwise return false.\n\n\n\n\n\n"
},

{
    "location": "generators.html#LightGraphs.SimpleGraphs.rem_edge!",
    "page": "Making and Modifying Graphs",
    "title": "LightGraphs.SimpleGraphs.rem_edge!",
    "category": "function",
    "text": "rem_edge!(g, e)\n\nRemove an edge e from graph g. Return true if edge was removed successfully, otherwise return false.\n\nImplementation Notes\n\nIf rem_edge! returns false, the graph may be in an indeterminate state, as there are multiple points where the function can exit with false.\n\n\n\n\n\n"
},

{
    "location": "generators.html#LightGraphs.SimpleGraphs.add_vertex!",
    "page": "Making and Modifying Graphs",
    "title": "LightGraphs.SimpleGraphs.add_vertex!",
    "category": "function",
    "text": "add_vertex!(g)\n\nAdd a new vertex to the graph g. Return true if addition was successful.\n\n\n\n\n\n"
},

{
    "location": "generators.html#LightGraphs.add_vertices!",
    "page": "Making and Modifying Graphs",
    "title": "LightGraphs.add_vertices!",
    "category": "function",
    "text": "add_vertices!(g, n)\n\nAdd n new vertices to the graph g. Return the number of vertices that were added successfully.\n\n\n\n\n\n"
},

{
    "location": "generators.html#LightGraphs.SimpleGraphs.rem_vertex!",
    "page": "Making and Modifying Graphs",
    "title": "LightGraphs.SimpleGraphs.rem_vertex!",
    "category": "function",
    "text": "rem_vertex!(g, v)\n\nRemove the vertex v from graph g. Return false if removal fails (e.g., if vertex is not in the graph); true otherwise.\n\nPerformance\n\nTime complexity is mathcalO(k^2), where k is the max of the degrees of vertex v and vertex V.\n\nImplementation Notes\n\nThis operation has to be performed carefully if one keeps external data structures indexed by edges or vertices in the graph, since internally the removal is performed swapping the vertices v  and V, and removing the last vertex V from the graph. After removal the vertices in g will be indexed by 1V-1.\n\n\n\n\n\n"
},

{
    "location": "generators.html#Base.zero",
    "page": "Making and Modifying Graphs",
    "title": "Base.zero",
    "category": "function",
    "text": "zero(g)\n\nReturn a zero-vertex, zero-edge version of the same type of graph as g.\n\n\n\n\n\n"
},

{
    "location": "generators.html#Modifying-graphs-1",
    "page": "Making and Modifying Graphs",
    "title": "Modifying graphs",
    "category": "section",
    "text": "LightGraphs.jl offers a range of tools for modifying graphs, including:SimpleGraph\nSimpleDiGraph\nEdge\nadd_edge!\nrem_edge!\nadd_vertex!\nadd_vertices!\nrem_vertex!\nzeroIn addition to these core functions, more advanced operators can be found in Operators."
},

{
    "location": "generators.html#Graph-Generators-1",
    "page": "Making and Modifying Graphs",
    "title": "Graph Generators",
    "category": "section",
    "text": "LightGraphs.jl implements numerous graph generators, including random graph generators, constructors for classic graphs, numerous small graphs with familiar topologies, and random and static graphs embedded in Euclidean space.Modules = [LightGraphs]\nPages   = [\"generators.md\"]"
},

{
    "location": "generators.html#Datasets-1",
    "page": "Making and Modifying Graphs",
    "title": "Datasets",
    "category": "section",
    "text": "Other notorious graphs and integration with the MatrixDepot.jl package are available in the Datasets submodule of the companion package LightGraphsExtras.jl. Selected graphs from the Stanford Large Network Dataset Collection may be found in the SNAPDatasets.jl package."
},

{
    "location": "generators.html#All-Generators-1",
    "page": "Making and Modifying Graphs",
    "title": "All Generators",
    "category": "section",
    "text": "Modules = [LightGraphs]\nPages   = [\n    \"generators/randgraphs.jl\",\n    \"generators/staticgraphs.jl\",\n    \"generators/smallgraphs.jl\",\n    \"generators/euclideangraphs.jl\"]\nPrivate = false"
},

{
    "location": "persistence.html#",
    "page": "Reading / Writing Graphs",
    "title": "Reading / Writing Graphs",
    "category": "page",
    "text": ""
},

{
    "location": "persistence.html#Reading-and-writing-Graphs-1",
    "page": "Reading / Writing Graphs",
    "title": "Reading and writing Graphs",
    "category": "section",
    "text": "Pages   = [\"persistence.md\"]"
},

{
    "location": "persistence.html#Saving-using-*LightGraphs.jl*-lg-format.-1",
    "page": "Reading / Writing Graphs",
    "title": "Saving using LightGraphs.jl lg format.",
    "category": "section",
    "text": "Graphs may be written to I/O streams and files using the savegraph function and read with the loadgraph function. The default graph format is a bespoke compressed LightGraphs.jl format LG."
},

{
    "location": "persistence.html#Example-1",
    "page": "Reading / Writing Graphs",
    "title": "Example",
    "category": "section",
    "text": "\ng = erdos_renyi(5, 0.2)\n\nsavegraph(\"mygraph.lgz\", g)\nreloaded_g = loadgraph(\"mygraph.lgz\")In addition, graphs can also be saved in an uncompressed format using the compress=false option.\nsavegraph(\"mygraph.lg\", g, compress=false)\n\nreloaded_g = loadgraph(\"mygraph.lg\")Finally, dictionaries of graphs can also be saved and subsequently re-loaded one by one.graph_dict = {\"g1\" => erdos_renyi(5, 0.1),\n              \"g2\" => erdos_renyi(10, 0.2),\n              \"g3\" => erdos_renyi(2, 0.9)}\n\nsavegraph(\"mygraph_dict.lg\", graph_dict)\n\n# Re-load only graph g1\nreloaded_g1 = loadgraph(\"mygraph_dict.lg\", \"g1\")"
},

{
    "location": "persistence.html#LightGraphs.loadgraph-Tuple{AbstractString,AbstractString,LightGraphs.AbstractGraphFormat}",
    "page": "Reading / Writing Graphs",
    "title": "LightGraphs.loadgraph",
    "category": "method",
    "text": "loadgraph(file, gname=\"graph\", format=LGFormat())\n\nRead a graph named gname from file in the format format.\n\nImplementation Notes\n\ngname is graph-format dependent and is only used if the file contains multiple graphs; if the file format does not support multiple graphs, this value is ignored. The default value may change in the future.\n\n\n\n\n\n"
},

{
    "location": "persistence.html#LightGraphs.loadgraphs-Tuple{AbstractString,LightGraphs.AbstractGraphFormat}",
    "page": "Reading / Writing Graphs",
    "title": "LightGraphs.loadgraphs",
    "category": "method",
    "text": "loadgraphs(file, format=LGFormat())\n\nLoad multiple graphs from file in the format format. Return a dictionary mapping graph name to graph.\n\nImplementation Notes\n\nFor unnamed graphs the default name \"graph\" will be used. This default may change in the future.\n\n\n\n\n\n"
},

{
    "location": "persistence.html#LightGraphs.savegraph-Tuple{AbstractString,AbstractGraph,AbstractString,LightGraphs.AbstractGraphFormat}",
    "page": "Reading / Writing Graphs",
    "title": "LightGraphs.savegraph",
    "category": "method",
    "text": "savegraph(file, g, gname=\"graph\", format=LGFormat; compress=true)\n\nSaves a graph g with name gname to file in the format format. If compress = true, use GZip compression when writing the file. Return the number of graphs written.\n\nImplementation Notes\n\nThe default graph name assigned to gname may change in the future.\n\n\n\n\n\n"
},

{
    "location": "persistence.html#LightGraphs.savegraph-Union{Tuple{T}, Tuple{U}, Tuple{AbstractString,Dict{T,U},AbstractGraphFormat}} where T<:AbstractString where U<:AbstractGraph",
    "page": "Reading / Writing Graphs",
    "title": "LightGraphs.savegraph",
    "category": "method",
    "text": "savegraph(file, g, d, format=LGFormat; compress=true)\n\nSave a dictionary of graphname => graph to file in the format format. If compress = true, use GZip compression when writing the file. Return the number of graphs written.\n\nImplementation Notes\n\nWill only work if the file format supports multiple graph types.\n\n\n\n\n\n"
},

{
    "location": "persistence.html#Full-docs-1",
    "page": "Reading / Writing Graphs",
    "title": "Full docs",
    "category": "section",
    "text": "Modules = [LightGraphs]\nPages   = [\"persistence/common.jl\"]\nPrivate = false"
},

{
    "location": "persistence.html#Reading-and-Writing-using-other-formats-using-GraphIO-1",
    "page": "Reading / Writing Graphs",
    "title": "Reading and Writing using other formats using GraphIO",
    "category": "section",
    "text": "The GraphIO.jl library provides tools for importing and exporting graph objects using common file types like edgelists, GraphML, Pajek NET, and more."
},

{
    "location": "operators.html#",
    "page": "Operators",
    "title": "Operators",
    "category": "page",
    "text": ""
},

{
    "location": "operators.html#Operators-1",
    "page": "Operators",
    "title": "Operators",
    "category": "section",
    "text": "LightGraphs.jl implements the following graph operators. In general, functions with two graph arguments will require them to be of the same type (either both SimpleGraph or both SimpleDiGraph).Order = [:type, :function]\nPages   = [\"operators.md\"]"
},

{
    "location": "operators.html#Base.intersect-Union{Tuple{T}, Tuple{T,T}} where T<:AbstractGraph",
    "page": "Operators",
    "title": "Base.intersect",
    "category": "method",
    "text": "intersect(g, h)\n\nReturn a graph with edges that are only in both graph g and graph h.\n\nImplementation Notes\n\nThis function may produce a graph with 0-degree vertices. Preserves the eltype of the input graph.\n\n\n\n\n\n"
},

{
    "location": "operators.html#Base.join-Union{Tuple{T}, Tuple{T,T}} where T<:AbstractGraph",
    "page": "Operators",
    "title": "Base.join",
    "category": "method",
    "text": "join(g, h)\n\nReturn a graph that combines graphs g and h using blockdiag and then adds all the edges between the vertices in g and those in h.\n\nImplementation Notes\n\nPreserves the eltype of the input graph. Will error if the number of vertices in the generated graph exceeds the eltype.\n\n\n\n\n\n"
},

{
    "location": "operators.html#Base.reverse",
    "page": "Operators",
    "title": "Base.reverse",
    "category": "function",
    "text": "reverse(g)\n\nReturn a directed graph where all edges are reversed from the original directed graph.\n\nImplementation Notes\n\nPreserves the eltype of the input graph.\n\n\n\n\n\n"
},

{
    "location": "operators.html#Base.reverse!",
    "page": "Operators",
    "title": "Base.reverse!",
    "category": "function",
    "text": "reverse!(g)\n\nIn-place reverse of a directed graph (modifies the original graph).\n\n\n\n\n\n"
},

{
    "location": "operators.html#Base.union-Union{Tuple{T}, Tuple{T,T}} where T<:AbstractGraph",
    "page": "Operators",
    "title": "Base.union",
    "category": "method",
    "text": "union(g, h)\n\nReturn a graph that combines graphs g and h by taking the set union of all vertices and edges.\n\nImplementation Notes\n\nPreserves the eltype of the input graph. Will error if the number of vertices in the generated graph exceeds the eltype.\n\n\n\n\n\n"
},

{
    "location": "operators.html#LightGraphs.cartesian_product-Union{Tuple{G}, Tuple{G,G}} where G<:AbstractGraph",
    "page": "Operators",
    "title": "LightGraphs.cartesian_product",
    "category": "method",
    "text": "cartesian_product(g, h)\n\nReturn the (cartesian product)[https://en.wikipedia.org/wiki/Cartesianproductof_graphs] of g and h.\n\nImplementation Notes\n\nPreserves the eltype of the input graph. Will error if the number of vertices in the generated graph exceeds the eltype.\n\n\n\n\n\n"
},

{
    "location": "operators.html#LightGraphs.complement-Tuple{SimpleGraph}",
    "page": "Operators",
    "title": "LightGraphs.complement",
    "category": "method",
    "text": "complement(g)\n\nReturn the graph complement of a graph\n\nImplementation Notes\n\nPreserves the eltype of the input graph.\n\n\n\n\n\n"
},

{
    "location": "operators.html#LightGraphs.crosspath",
    "page": "Operators",
    "title": "LightGraphs.crosspath",
    "category": "function",
    "text": "crosspath(len::Integer, g::Graph)\n\nReturn a graph that duplicates g len times and connects each vertex with its copies in a path.\n\nImplementation Notes\n\nPreserves the eltype of the input graph. Will error if the number of vertices in the generated graph exceeds the eltype.\n\n\n\n\n\n"
},

{
    "location": "operators.html#LightGraphs.difference-Union{Tuple{T}, Tuple{T,T}} where T<:AbstractGraph",
    "page": "Operators",
    "title": "LightGraphs.difference",
    "category": "method",
    "text": "difference(g, h)\n\nReturn a graph with edges in graph g that are not in graph h.\n\nImplementation Notes\n\nNote that this function may produce a graph with 0-degree vertices. Preserves the eltype of the input graph.\n\n\n\n\n\n"
},

{
    "location": "operators.html#LightGraphs.egonet-Union{Tuple{T}, Tuple{U}, Tuple{AbstractGraph{T},Integer,Integer}, Tuple{AbstractGraph{T},Integer,Integer,AbstractArray{U,2}}} where T<:Integer where U<:Real",
    "page": "Operators",
    "title": "LightGraphs.egonet",
    "category": "method",
    "text": "egonet(g, v, d, distmx=weights(g))\n\nReturn the subgraph of g induced by the neighbors of v up to distance d, using weights (optionally) provided by distmx. This is equivalent to induced_subgraph(g, neighborhood(g, v, d, dir=dir))[1].\n\nOptional Arguments\n\ndir=:out: if g is directed, this argument specifies the edge direction\n\nwith respect to v (i.e. :in or :out).\n\n\n\n\n\n"
},

{
    "location": "operators.html#LightGraphs.induced_subgraph-Union{Tuple{T}, Tuple{U}, Tuple{T,AbstractArray{U,1}}} where T<:AbstractGraph where U<:Integer",
    "page": "Operators",
    "title": "LightGraphs.induced_subgraph",
    "category": "method",
    "text": "induced_subgraph(g, vlist)\ninduced_subgraph(g, elist)\n\nReturn the subgraph of g induced by the vertices in  vlist or edges in elist along with a vector mapping the new vertices to the old ones (the  vertex i in the subgraph corresponds to the vertex vmap[i] in g.)\n\nThe returned graph has length(vlist) vertices, with the new vertex i corresponding to the vertex of the original graph in the i-th position of vlist.\n\nUsage Examples\n\njulia> g = CompleteGraph(10)\n\njulia> sg, vmap = induced_subgraph(g, 5:8)\n\njulia> @assert g[5:8] == sg\n\njulia> @assert nv(sg) == 4\n\njulia> @assert ne(sg) == 6\n\njulia> @assert vm[4] == 8\n\njulia> sg, vmap = induced_subgraph(g, [2,8,3,4])\n\njulia> @assert sg == g[[2,8,3,4]]\n\njulia> elist = [Edge(1,2), Edge(3,4), Edge(4,8)]\n\njulia> sg, vmap = induced_subgraph(g, elist)\n\njulia> @assert sg == g[elist]\n\n\n\n\n\n"
},

{
    "location": "operators.html#LightGraphs.merge_vertices!-Union{Tuple{T}, Tuple{SimpleGraph{T},Array{U,1} where U<:Integer}} where T",
    "page": "Operators",
    "title": "LightGraphs.merge_vertices!",
    "category": "method",
    "text": "merge_vertices!(g, vs)\n\nCombine vertices specified in vs into single vertex whose index will be the lowest value in vs. All edges connected to vertices in vs connect to the new merged vertex.\n\nReturn a vector with new vertex values are indexed by the original vertex indices.\n\nImplementation Notes\n\nSupports SimpleGraph only.\n\n\n\n\n\n"
},

{
    "location": "operators.html#LightGraphs.merge_vertices-Tuple{AbstractGraph,Any}",
    "page": "Operators",
    "title": "LightGraphs.merge_vertices",
    "category": "method",
    "text": "merge_vertices(g::AbstractGraph, vs)\n\nCreate a new graph where all vertices in vs have been aliased to the same vertex minimum(vs).\n\n\n\n\n\n"
},

{
    "location": "operators.html#LightGraphs.symmetric_difference-Union{Tuple{T}, Tuple{T,T}} where T<:AbstractGraph",
    "page": "Operators",
    "title": "LightGraphs.symmetric_difference",
    "category": "method",
    "text": "symmetric_difference(g, h)\n\nReturn a graph with edges from graph g that do not exist in graph h, and vice versa.\n\nImplementation Notes\n\nNote that this function may produce a graph with 0-degree vertices. Preserves the eltype of the input graph. Will error if the number of vertices in the generated graph exceeds the eltype.\n\n\n\n\n\n"
},

{
    "location": "operators.html#LightGraphs.tensor_product-Union{Tuple{G}, Tuple{G,G}} where G<:AbstractGraph",
    "page": "Operators",
    "title": "LightGraphs.tensor_product",
    "category": "method",
    "text": "tensor_product(g, h)\n\nReturn the (tensor product)[https://en.wikipedia.org/wiki/Tensorproductof_graphs] of g and h.\n\nImplementation Notes\n\nPreserves the eltype of the input graph. Will error if the number of vertices in the generated graph exceeds the eltype.\n\n\n\n\n\n"
},

{
    "location": "operators.html#SparseArrays.blockdiag-Union{Tuple{T}, Tuple{T,T}} where T<:AbstractGraph",
    "page": "Operators",
    "title": "SparseArrays.blockdiag",
    "category": "method",
    "text": "blockdiag(g, h)\n\nReturn a graph with V(g) + V(h) vertices and E(g) + E(h) edges where the vertices an edges from graph h are appended to graph g.\n\nImplementation Notes\n\nPreserves the eltype of the input graph. Will error if the number of vertices in the generated graph exceeds the eltype.\n\n\n\n\n\n"
},

{
    "location": "operators.html#Full-Docs-1",
    "page": "Operators",
    "title": "Full Docs",
    "category": "section",
    "text": "Modules = [LightGraphs]\nPages   = [\"operators.jl\"]\nPrivate = false"
},

{
    "location": "plotting.html#",
    "page": "Plotting Graphs",
    "title": "Plotting Graphs",
    "category": "page",
    "text": ""
},

{
    "location": "plotting.html#Plotting-Graphs-1",
    "page": "Plotting Graphs",
    "title": "Plotting Graphs",
    "category": "section",
    "text": "LightGraphs.jl integrates with several other Julia packages for plotting. Here are a few examples."
},

{
    "location": "plotting.html#[GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl)-1",
    "page": "Plotting Graphs",
    "title": "GraphLayout.jl",
    "category": "section",
    "text": "This excellent graph visualization package can be used with LightGraphs.jl as follows:julia> g = WheelGraph(10); am = Matrix(adjacency_matrix(g))\njulia> loc_x, loc_y = layout_spring_adj(am)\njulia> draw_layout_adj(am, loc_x, loc_y, filename=\"wheel10.svg\")producing a graph like this:(Image: Wheel Graph)"
},

{
    "location": "plotting.html#[TikzGraphs.jl](https://github.com/sisl/TikzGraphs.jl)-1",
    "page": "Plotting Graphs",
    "title": "TikzGraphs.jl",
    "category": "section",
    "text": "Another nice graph visualization package. (TikzPictures.jl required to render/save):julia> g = WheelGraph(10); t = plot(g)\n\njulia> save(SVG(\"wheel10.svg\"), t)producing a graph like this:(Image: Wheel Graph)"
},

{
    "location": "plotting.html#[GraphPlot.jl](https://github.com/afternone/GraphPlot.jl)-1",
    "page": "Plotting Graphs",
    "title": "GraphPlot.jl",
    "category": "section",
    "text": "Another graph visualization package that is very simple to use. Compose.jl is required for most rendering functionality:julia> using GraphPlot, Compose\n\njulia> g = WheelGraph(10)\n\njulia> draw(PNG(\"/tmp/wheel10.png\", 16cm, 16cm), gplot(g))"
},

{
    "location": "plotting.html#[NetworkViz.jl](https://github.com/abhijithanilkumar/NetworkViz.jl)-1",
    "page": "Plotting Graphs",
    "title": "NetworkViz.jl",
    "category": "section",
    "text": "NetworkViz.jl is tightly coupled with LightGraphs.jl. Graphs can be visualized in 2D as well as 3D using ThreeJS.jl and Escher.jl.#Run this code in Escher\n\nusing NetworkViz\nusing LightGraphs\n\nmain(window) = begin\n  push!(window.assets, \"widgets\")\n  push!(window.assets,(\"ThreeJS\",\"threejs\"))\n  g = CompleteGraph(10)\n  drawGraph(g)\nendThe above code produces the following output:(Image: alt tag)"
},

{
    "location": "pathing.html#",
    "page": "Path and Traversal",
    "title": "Path and Traversal",
    "category": "page",
    "text": ""
},

{
    "location": "pathing.html#LightGraphs.DefaultDistance",
    "page": "Path and Traversal",
    "title": "LightGraphs.DefaultDistance",
    "category": "type",
    "text": "DefaultDistance\n\nAn array-like structure that provides distance values of 1 for any src, dst combination.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#Path-and-Traversal-1",
    "page": "Path and Traversal",
    "title": "Path and Traversal",
    "category": "section",
    "text": "LightGraphs.jl provides several traversal and shortest-path algorithms, along with various utility functions. Where appropriate, edge distances may be passed in as a matrix of real number values.Edge distances for most traversals may be passed in as a sparse or dense matrix of  values, indexed by [src,dst] vertices. That is, distmx[2,4] = 2.5 assigns the distance 2.5 to the (directed) edge connecting vertex 2 and vertex 4. Note that also for undirected graphs distmx[4,2] has to be set.Default edge distances may be passed in via theLightGraphs.DefaultDistancestructure.Any graph traversal  will traverse an edge only if it is present in the graph. When a distance matrix is passed in,distance values for undefined edges will be ignored, and\nany unassigned values (in sparse distance matrices), for edges that are present in the graph, will be assumed to take the default value of 1.0.\nany zero values (in sparse/dense distance matrices), for edges that are present in the graph, will instead have an implicit edge cost of 1.0."
},

{
    "location": "pathing.html#LightGraphs.bfs_tree",
    "page": "Path and Traversal",
    "title": "LightGraphs.bfs_tree",
    "category": "function",
    "text": "bfs_tree(g, s[; dir=:out])\n\nProvide a breadth-first traversal of the graph g starting with source vertex s, and return a directed acyclic graph of vertices in the order they were discovered. If dir is specified, use the corresponding edge direction (:in and :out are acceptable values).\n\n\n\n\n\nbfs_tree(LevelSynchronousBFS(), g, s, nv)\n\nProvide a parallel breadth-first traversal of the graph g starting with source vertex s, and return a directed acyclic graph of vertices in the order they were discovered using a frontier based parallel approach.\n\nImplementation Notes\n\nThis function uses @threads for parallelism which depends on the JULIA_NUM_THREADS environment variable to decide the number of threads to use. Refer @threads documentation for more details. This function is a high level wrapper around LightGraphs.bfs_tree!; use that function for more performance.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.bfs_tree!",
    "page": "Path and Traversal",
    "title": "LightGraphs.bfs_tree!",
    "category": "function",
    "text": "bfs_tree!(LevelSynchronousBFS(), g, src, parents)\n\nProvide a parallel breadth-first traversal of the graph g starting with source vertex s, and return a parents array. The returned array is an Array of Atomic integers.\n\nImplementation Notes\n\nThis function uses @threads for parallelism which depends on the JULIA_NUM_THREADS environment variable to decide the number of threads to use. Refer @threads documentation for more details.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.dfs_tree",
    "page": "Path and Traversal",
    "title": "LightGraphs.dfs_tree",
    "category": "function",
    "text": "dfs_tree(g, s)\n\nReturn an ordered vector of vertices representing a directed acylic graph based on depth-first traversal of the graph g starting with source vertex s.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.maximum_adjacency_visit",
    "page": "Path and Traversal",
    "title": "LightGraphs.maximum_adjacency_visit",
    "category": "function",
    "text": "maximum_adjacency_visit(g[, distmx][, log][, io])\n\nReturn the vertices in g traversed by maximum adjacency search. An optional distmx matrix may be specified; if omitted, edge distances are assumed to be 1. If log (default false) is true, visitor events will be printed to io, which defaults to STDOUT; otherwise, no event information will be displayed.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.bfs_parents",
    "page": "Path and Traversal",
    "title": "LightGraphs.bfs_parents",
    "category": "function",
    "text": "bfs_parents(g, s[; dir=:out])\n\nPerform a breadth-first search of graph g starting from vertex s. Return a vector of parent vertices indexed by vertex. If dir is specified, use the corresponding edge direction (:in and :out are acceptable values).\n\nPerformance\n\nThis implementation is designed to perform well on large graphs. There are implementations which are marginally faster in practice for smaller graphs, but the performance improvements using this implementation on large graphs can be significant.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.has_path",
    "page": "Path and Traversal",
    "title": "LightGraphs.has_path",
    "category": "function",
    "text": "has_path(g::AbstractGraph, u, v; exclude_vertices=Vector())\n\nReturn true if there is a path from u to v in g (while avoiding vertices in exclude_vertices) or u == v. Return false if there is no such path or if u or v is in excluded_vertices. \n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.diffusion",
    "page": "Path and Traversal",
    "title": "LightGraphs.diffusion",
    "category": "function",
    "text": "diffusion(g, p, n)\n\nRun diffusion simulation on g for n steps with spread probabilities based on p. Return a vector with the set of new vertices reached at each step of the simulation.\n\nOptional Arguments\n\ninitial_infections=sample(vertices(g), 1): A list of vertices that\n\nare infected at the start of the simulation.\n\nwatch=Vector(): While simulation is always run on the full graph,\n\nspecifying watch limits reporting to a specific set of vertices reached during the simulation. If left empty, all vertices will be watched.\n\nnormalize=false: if false, set the probability of spread from a vertex i to\n\neach of the outneighbors of i to p. If true, set the probability of spread from a vertex i to each of the outneighbors of i to fracpoutdegreee(g i).\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.diffusion_rate",
    "page": "Path and Traversal",
    "title": "LightGraphs.diffusion_rate",
    "category": "function",
    "text": "diffusion_rate(results)\ndiffusion_rate(g, p, n; ...)\n\nGiven the results of a diffusion output or the parameters to the diffusion simulation itself, (run and) return the rate of diffusion as a vector representing the cumulative number of vertices infected at each simulation step, restricted to vertices included in watch, if specified.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.mincut",
    "page": "Path and Traversal",
    "title": "LightGraphs.mincut",
    "category": "function",
    "text": "mincut(g, distmx=weights(g))\n\nReturn a tuple (parity, bestcut), where parity is a vector of integer values that determines the partition in g (1 or 2) and bestcut is the weight of the cut that makes this partition. An optional distmx matrix may be specified; if omitted, edge distances are assumed to be 1.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#Graph-Traversal-1",
    "page": "Path and Traversal",
    "title": "Graph Traversal",
    "category": "section",
    "text": "Graph traversal refers to a process that traverses vertices of a graph following certain order (starting from user-input sources). This package implements three traversal schemes:BreadthFirst,\nDepthFirst, and\nMaximumAdjacency.bfs_tree\nLightGraphs.bfs_tree!\ndfs_tree\nmaximum_adjacency_visit\nbfs_parents\nhas_path\ndiffusion\ndiffusion_rate\nmincut"
},

{
    "location": "pathing.html#LightGraphs.randomwalk",
    "page": "Path and Traversal",
    "title": "LightGraphs.randomwalk",
    "category": "function",
    "text": "randomwalk(g, s, niter)\n\nPerform a random walk on graph g starting at vertex s and continuing for a maximum of niter steps. Return a vector of vertices visited in order.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.non_backtracking_randomwalk",
    "page": "Path and Traversal",
    "title": "LightGraphs.non_backtracking_randomwalk",
    "category": "function",
    "text": "non_backtracking_randomwalk(g, s, niter)\n\nPerform a non-backtracking random walk on directed graph g starting at vertex s and continuing for a maximum of niter steps. Return a vector of vertices visited in order.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.saw",
    "page": "Path and Traversal",
    "title": "LightGraphs.saw",
    "category": "function",
    "text": "saw(g, s, niter)\n\nPerform a self-avoiding walk on graph g starting at vertex s and continuing for a maximum of niter steps. Return a vector of vertices visited in order.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#Random-walks-1",
    "page": "Path and Traversal",
    "title": "Random walks",
    "category": "section",
    "text": "LightGraphs includes uniform random walks and self avoiding walks:randomwalk\nnon_backtracking_randomwalk\nsaw"
},

{
    "location": "pathing.html#LightGraphs.is_connected",
    "page": "Path and Traversal",
    "title": "LightGraphs.is_connected",
    "category": "function",
    "text": "is_connected(g)\n\nReturn true if graph g is connected. For directed graphs, return true if graph g is weakly connected.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.is_strongly_connected",
    "page": "Path and Traversal",
    "title": "LightGraphs.is_strongly_connected",
    "category": "function",
    "text": "is_strongly_connected(g)\n\nReturn true if directed graph g is strongly connected.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.is_weakly_connected",
    "page": "Path and Traversal",
    "title": "LightGraphs.is_weakly_connected",
    "category": "function",
    "text": "is_weakly_connected(g)\n\nReturn true if the graph g is weakly connected. If g is undirected, this function is equivalent to is_connected(g).\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.connected_components",
    "page": "Path and Traversal",
    "title": "LightGraphs.connected_components",
    "category": "function",
    "text": "connected_components(g)\n\nReturn the connected components of an undirected graph g as a vector of components, with each element a vector of vertices belonging to the component.\n\nFor directed graphs, see strongly_connected_components and weakly_connected_components.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.strongly_connected_components",
    "page": "Path and Traversal",
    "title": "LightGraphs.strongly_connected_components",
    "category": "function",
    "text": "strongly_connected_components(g)\n\nCompute the strongly connected components of a directed graph g.\n\nReturn an array of arrays, each of which is the entire connected component.\n\nImplementation Notes\n\nThe order of the components is not part of the API contract.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.weakly_connected_components",
    "page": "Path and Traversal",
    "title": "LightGraphs.weakly_connected_components",
    "category": "function",
    "text": "weakly_connected_components(g)\n\nReturn the weakly connected components of the graph g. This is equivalent to the connected components of the undirected equivalent of g. For undirected graphs this is equivalent to the connected components of g.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.has_self_loops",
    "page": "Path and Traversal",
    "title": "LightGraphs.has_self_loops",
    "category": "function",
    "text": "has_self_loops(g)\n\nReturn true if g has any self loops.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.attracting_components",
    "page": "Path and Traversal",
    "title": "LightGraphs.attracting_components",
    "category": "function",
    "text": "attracting_components(g)\n\nReturn a vector of vectors of integers representing lists of attracting components in the directed graph g.\n\nThe attracting components are a subset of the strongly connected components in which the components do not have any leaving edges.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.is_bipartite",
    "page": "Path and Traversal",
    "title": "LightGraphs.is_bipartite",
    "category": "function",
    "text": "is_bipartite(g)\n\nReturn true if graph g is bipartite.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.bipartite_map",
    "page": "Path and Traversal",
    "title": "LightGraphs.bipartite_map",
    "category": "function",
    "text": "bipartite_map(g)\n\nFor a bipartite graph g, return a vector c of size V containing the assignment of each vertex to one of the two sets (c_i == 1 or c_i == 2`). Ifg` is not bipartite, return an empty vector.\n\nImplementation Notes\n\nNote that an empty vector does not necessarily indicate non-bipartiteness. An empty graph will return an empty vector but is bipartite.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.biconnected_components",
    "page": "Path and Traversal",
    "title": "LightGraphs.biconnected_components",
    "category": "function",
    "text": "biconnected_components(g)\n\nCompute the biconnected components of an undirected graph gand return a vector of vectors containing each biconnected component.\n\nPerformance: Time complexity is mathcalO(V).\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.condensation",
    "page": "Path and Traversal",
    "title": "LightGraphs.condensation",
    "category": "function",
    "text": "condensation(g[, scc])\n\nReturn the condensation graph of the strongly connected components scc in the directed graph g. If scc is missing, generate the strongly connected components first.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.neighborhood",
    "page": "Path and Traversal",
    "title": "LightGraphs.neighborhood",
    "category": "function",
    "text": "neighborhood(g, v, d, distmx=weights(g))\n\nReturn a vector of each vertex in g at a geodesic distance less than or equal to d, where distances may be specified by distmx. \n\nOptional Arguments\n\ndir=:out: If g is directed, this argument specifies the edge direction\n\nwith respect to v of the edges to be considered. Possible values: :in or :out.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.neighborhood_dists",
    "page": "Path and Traversal",
    "title": "LightGraphs.neighborhood_dists",
    "category": "function",
    "text": "neighborhood_dists(g, v, d, distmx=weights(g))\n\nReturn a tuple of each vertex at a geodesic distance less than or equal to d, where distances may be specified by distmx, along with its distance from v.\n\nOptional Arguments\n\ndir=:out: If g is directed, this argument specifies the edge direction\n\nwith respect to v of the edges to be considered. Possible values: :in or :out.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.articulation",
    "page": "Path and Traversal",
    "title": "LightGraphs.articulation",
    "category": "function",
    "text": "articulation(g)\n\nCompute the articulation points of a connected graph g and return an array containing all cut vertices.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.period",
    "page": "Path and Traversal",
    "title": "LightGraphs.period",
    "category": "function",
    "text": "period(g)\n\nReturn the (common) period for all vertices in a strongly connected directed graph. Will throw an error if the graph is not strongly connected.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.isgraphical",
    "page": "Path and Traversal",
    "title": "LightGraphs.isgraphical",
    "category": "function",
    "text": "isgraphical(degs)\n\nReturn true if the degree sequence degs is graphical, according to Erdös-Gallai condition.\n\nPerformance\n\nTime complexity: ``\\mathcal{O}(|degs|^2)``\n\n\n\n\n\n"
},

{
    "location": "pathing.html#Connectivity-/-Bipartiteness-1",
    "page": "Path and Traversal",
    "title": "Connectivity / Bipartiteness",
    "category": "section",
    "text": "Graph connectivity functions are defined on both undirected and directed graphs:is_connected\nis_strongly_connected\nis_weakly_connected\nconnected_components\nstrongly_connected_components\nweakly_connected_components\nhas_self_loops\nattracting_components\nis_bipartite\nbipartite_map\nbiconnected_components\ncondensation\nneighborhood\nneighborhood_dists\narticulation\nperiod\nisgraphical"
},

{
    "location": "pathing.html#LightGraphs.is_cyclic",
    "page": "Path and Traversal",
    "title": "LightGraphs.is_cyclic",
    "category": "function",
    "text": "is_cyclic(g)\n\nReturn true if graph g contains a cycle.\n\nImplementation Notes\n\nUses DFS.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.maxsimplecycles",
    "page": "Path and Traversal",
    "title": "LightGraphs.maxsimplecycles",
    "category": "function",
    "text": "maxsimplecycles(dg::::IsDirected, byscc::Bool = true)\n\nCompute the theoretical maximum number of cycles in the directed graph dg.\n\nThe computation can be performed assuming the graph is complete or taking into account the decomposition in strongly connected components (byscc parameter).\n\nPerformance\n\nA more efficient version is possible.\n\nReferences\n\nJohnson\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.simplecycles",
    "page": "Path and Traversal",
    "title": "LightGraphs.simplecycles",
    "category": "function",
    "text": "simplecycles(dg::::IsDirected)\n\nCompute and return all cycles of the given directed graph using Johnson\'s algorithm.\n\nPerformance\n\nThe number of cycles grows more than exponentially with the number of vertices, you might want to use the algorithm with a ceiling – getcycles – on large directed graphs (slightly slower). If you want to have an idea of the possible number of cycles, look at function maxsimplecycles(dg::DiGraph, byscc::Bool = true).\n\nReferences\n\nJohnson\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.simplecycles_iter",
    "page": "Path and Traversal",
    "title": "LightGraphs.simplecycles_iter",
    "category": "function",
    "text": "simplecycles_iter(dg::DiGraph, ceiling = 10^6)\n\nSearch all cycles of the given directed graph, using Johnson\'s algorithm, up to the ceiling (to avoid memory overload).\n\nImplementation Notes\n\nIf the graph is small, the ceiling will not be reached and simplecycles(dg::DiGraph) is more efficient. It avoids the overhead of the counting and testing if the ceiling is reached. It returns all the cycles of the directed graph if the ceiling is not reached, a subset of them otherwise.\n\nTo get an idea of the possible number of cycles, use function `maxsimplecycles(dg::DiGraph, byscc::Bool = true) on the directed graph.\n\nReferences\n\nJohnson\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.simplecycles_hadwick_james",
    "page": "Path and Traversal",
    "title": "LightGraphs.simplecycles_hadwick_james",
    "category": "function",
    "text": "simplecycles_hadwick_james(g)\n\nFind circuits (including self-loops) in g using the algorithm of Hadwick & James.\n\nReferences\n\nHadwick & James, \"Enumerating Circuits and Loops in Graphs with Self-Arcs and Multiple-Arcs\", 2008\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.simplecyclescount",
    "page": "Path and Traversal",
    "title": "LightGraphs.simplecyclescount",
    "category": "function",
    "text": "simplecyclescount(dg::DiGraph, ceiling = 10^6)\n\nCount the number of cycles in a directed graph, using Johnson\'s algorithm. Return the minimum of the ceiling and the number of cycles.\n\nImplementation Notes\n\nThe ceiling is here to avoid memory overload if there are a lot of cycles in the graph. Default value is 10^6, but it can be higher or lower. You can use the function maxsimplecycles(dg::DiGraph, byscc::Bool = true) to get an idea of the theoretical maximum number or cycles.\n\nReferences\n\nJohnson\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.simplecycleslength",
    "page": "Path and Traversal",
    "title": "LightGraphs.simplecycleslength",
    "category": "function",
    "text": "simplecycleslength(dg::DiGraph, ceiling = 10^6)\n\nSearch all cycles of the given directed graph, using Johnson\'s algorithm,  and return a tuple representing the cycle length and the number of cycles.\n\nImplementation Notes\n\nTo get an idea of the possible number of cycles, using function maxsimplecycles(dg::DiGraph, byscc::Bool = true) on the directed graph.\n\nIf the ceiling is reached (ncycles = ceiling), the output is only a subset of the cycles lengths.\n\nReferences\n\nJohnson\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.karp_minimum_cycle_mean",
    "page": "Path and Traversal",
    "title": "LightGraphs.karp_minimum_cycle_mean",
    "category": "function",
    "text": "karp_minimum_cycle_mean(g[, distmx])\n\nReturn minimum cycle mean of the directed graph g with optional edge weights contained in distmx.\n\nReferences\n\nKarp.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#Cycle-Detection-1",
    "page": "Path and Traversal",
    "title": "Cycle Detection",
    "category": "section",
    "text": "In graph theory, a cycle is defined to be a path that starts from some vertex v and ends up at v.is_cyclic\nmaxsimplecycles\nsimplecycles\nsimplecycles_iter\nsimplecycles_hadwick_james\nsimplecyclescount\nsimplecycleslength\nkarp_minimum_cycle_mean"
},

{
    "location": "pathing.html#LightGraphs.kruskal_mst",
    "page": "Path and Traversal",
    "title": "LightGraphs.kruskal_mst",
    "category": "function",
    "text": "kruskal_mst(g, distmx=weights(g))\n\nReturn a vector of edges representing the minimum spanning tree of a connected, undirected graph g with optional distance matrix distmx using Kruskal\'s algorithm.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.prim_mst",
    "page": "Path and Traversal",
    "title": "LightGraphs.prim_mst",
    "category": "function",
    "text": "prim_mst(g, distmx=weights(g))\n\nReturn a vector of edges representing the minimum spanning tree of a connected, undirected graph g with optional distance matrix distmx using Prim\'s algorithm. Return a vector of edges.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#Minimum-Spanning-Trees-(MST)-Algorithms-1",
    "page": "Path and Traversal",
    "title": "Minimum Spanning Trees (MST) Algorithms",
    "category": "section",
    "text": "A Minimum Spanning Tree (MST) is a subset of the edges of a connected, edge-weighted (un)directed graph that connects all the vertices together, without any cycles and with the minimum possible total edge weight.kruskal_mst\nprim_mst"
},

{
    "location": "pathing.html#Shortest-Path-Algorithms-1",
    "page": "Path and Traversal",
    "title": "Shortest-Path Algorithms",
    "category": "section",
    "text": ""
},

{
    "location": "pathing.html#LightGraphs.a_star",
    "page": "Path and Traversal",
    "title": "LightGraphs.a_star",
    "category": "function",
    "text": "a_star(g, s, t[, distmx][, heuristic])\n\nReturn a vector of edges comprising the shortest path between vertices s and t using the A* search algorithm. An optional heuristic function and edge distance matrix may be supplied. If missing, the distance matrix is set to LightGraphs.DefaultDistance and the heuristic is set to n -> 0.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.dijkstra_shortest_paths",
    "page": "Path and Traversal",
    "title": "LightGraphs.dijkstra_shortest_paths",
    "category": "function",
    "text": "dijkstra_shortest_paths(g, srcs, distmx=weights(g));\n\nPerform Dijkstra\'s algorithm on a graph, computing shortest distances between srcs and all other vertices. Return a LightGraphs.DijkstraState that contains various traversal information.\n\nOptional Arguments\n\nallpaths=false: If true, returns a LightGraphs.DijkstraState that keeps track of all\n\npredecessors of a given vertex.\n\nPerformance\n\nUse a matrix type for distmx that is implemented in row-major matrix format  for better run-time. Eg. Set the type of distmx to Transpose{Int64, SparseMatrixCSC{Int64,Int64}}  instead of SparseMatrixCSC{Int64,Int64}.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.bellman_ford_shortest_paths",
    "page": "Path and Traversal",
    "title": "LightGraphs.bellman_ford_shortest_paths",
    "category": "function",
    "text": "bellman_ford_shortest_paths(g, s, distmx=weights(g))\nbellman_ford_shortest_paths(g, ss, distmx=weights(g))\n\nCompute shortest paths between a source s (or list of sources ss) and all other nodes in graph g using the Bellman-Ford algorithm. Return a LightGraphs.BellmanFordState with relevant traversal information.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.floyd_warshall_shortest_paths",
    "page": "Path and Traversal",
    "title": "LightGraphs.floyd_warshall_shortest_paths",
    "category": "function",
    "text": "floyd_warshall_shortest_paths(g, distmx=weights(g); parallel=false)\n\nUse the Floyd-Warshall algorithm to compute the shortest paths between all pairs of vertices in graph g using an optional distance matrix distmx. Return a LightGraphs.FloydWarshallState with relevant traversal information.\n\nPerformance\n\nSpace complexity is on the order of mathcalO(V^2).\n\nOptional Arguments\n\nparallel=false: If true, the algorithm runs in parallel.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.yen_k_shortest_paths",
    "page": "Path and Traversal",
    "title": "LightGraphs.yen_k_shortest_paths",
    "category": "function",
    "text": "yen_k_shortest_paths(g, source, target, distmx=weights(g), K=1; maxdist=Inf);\n\nPerform Yen\'s algorithm on a graph, computing k-shortest distances between source and target other vertices. Return a YenState that contains distances and paths.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.parallel_multisource_dijkstra_shortest_paths",
    "page": "Path and Traversal",
    "title": "LightGraphs.parallel_multisource_dijkstra_shortest_paths",
    "category": "function",
    "text": "parallel_multisource_dijkstra_shortest_paths(g, sources=vertices(g), distmx=weights(g))\n\nCompute the shortest paths between all pairs of vertices in graph g by running [dijkstra_shortest_paths] for every vertex and using an optional list of source vertex sources and an optional distance matrix distmx. Return a MultipleDijkstraState with relevant traversal information.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#General-properties-of-shortest-path-algorithms-1",
    "page": "Path and Traversal",
    "title": "General properties of shortest path algorithms",
    "category": "section",
    "text": "The distance from a vertex to itself is always 0.\nThe distance between two vertices with no connecting edge is always Inf.a_star\ndijkstra_shortest_paths\nbellman_ford_shortest_paths\nfloyd_warshall_shortest_paths\nyen_k_shortest_paths\nparallel_multisource_dijkstra_shortest_paths"
},

{
    "location": "pathing.html#LightGraphs.gdistances",
    "page": "Path and Traversal",
    "title": "LightGraphs.gdistances",
    "category": "function",
    "text": "gdistances(g, source; sort_alg=QuickSort)\n\nReturn a vector filled with the geodesic distances of vertices in  g from source. If source is a collection of vertices each element should be unique. For vertices in disconnected components the default distance is typemax(T).\n\nAn optional sorting algorithm may be specified (see Performance section).\n\nPerformance\n\ngdistances uses QuickSort internally for its default sorting algorithm, since it performs the best of the algorithms built into Julia Base. However, passing a RadixSort (available via SortingAlgorithms.jl) will provide significant performance improvements on larger graphs.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.gdistances!",
    "page": "Path and Traversal",
    "title": "LightGraphs.gdistances!",
    "category": "function",
    "text": "gdistances!(g, source, dists; sort_alg=QuickSort)\n\nFill dists with the geodesic distances of vertices in g from source vertex (or collection of vertices) source. dists should be a vector of length nv(g)  filled with typemax(T). Return dists.\n\nFor vertices in disconnected components the default distance is typemax(T).\n\nAn optional sorting algorithm may be specified (see Performance section).\n\nPerformance\n\ngdistances uses QuickSort internally for its default sorting algorithm, since it performs the best of the algorithms built into Julia Base. However, passing a RadixSort (available via SortingAlgorithms.jl) will provide significant performance improvements on larger graphs.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.enumerate_paths",
    "page": "Path and Traversal",
    "title": "LightGraphs.enumerate_paths",
    "category": "function",
    "text": "enumerate_paths(state[, vs])\n\nGiven a path state state of type AbstractPathState, return a vector (indexed by vertex) of the paths between the source vertex used to compute the path state and a single destination vertex, a list of destination vertices, or the entire graph. For multiple destination vertices, each path is represented by a vector of vertices on the path between the source and the destination. Nonexistent paths will be indicated by an empty vector. For single destinations, the path is represented by a single vector of vertices, and will be length 0 if the path does not exist.\n\nImplementation Notes\n\nFor Floyd-Warshall path states, please note that the output is a bit different, since this algorithm calculates all shortest paths for all pairs of vertices: enumerate_paths(state) will return a vector (indexed by source vertex) of vectors (indexed by destination vertex) of paths. enumerate_paths(state, v) will return a vector (indexed by destination vertex) of paths from source v to all other vertices. In addition, enumerate_paths(state, v, d) will return a vector representing the path from vertex v to vertex d.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#Path-discovery-/-enumeration-1",
    "page": "Path and Traversal",
    "title": "Path discovery / enumeration",
    "category": "section",
    "text": "gdistances\ngdistances!\nenumerate_paths"
},

{
    "location": "pathing.html#LightGraphs.AbstractPathState",
    "page": "Path and Traversal",
    "title": "LightGraphs.AbstractPathState",
    "category": "type",
    "text": "AbstractPathState\n\nAn abstract type that provides information from shortest paths calculations.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.DijkstraState",
    "page": "Path and Traversal",
    "title": "LightGraphs.DijkstraState",
    "category": "type",
    "text": "struct DijkstraState{T, U}\n\nAn AbstractPathState designed for Dijkstra shortest-paths calculations.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.BellmanFordState",
    "page": "Path and Traversal",
    "title": "LightGraphs.BellmanFordState",
    "category": "type",
    "text": "BellmanFordState{T, U}\n\nAn AbstractPathState designed for Bellman-Ford shortest-paths calculations.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.FloydWarshallState",
    "page": "Path and Traversal",
    "title": "LightGraphs.FloydWarshallState",
    "category": "type",
    "text": "struct FloydWarshallState{T, U}\n\nAn AbstractPathState designed for Floyd-Warshall shortest-paths calculations.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#LightGraphs.YenState",
    "page": "Path and Traversal",
    "title": "LightGraphs.YenState",
    "category": "type",
    "text": "struct YenState{T, U}\n\nDesigned for yen k-shortest-paths calculations.\n\n\n\n\n\n"
},

{
    "location": "pathing.html#Path-States-1",
    "page": "Path and Traversal",
    "title": "Path States",
    "category": "section",
    "text": "All path states derive fromLightGraphs.AbstractPathStateThe dijkstra_shortest_paths, floyd_warshall_shortest_paths, bellman_ford_shortest_paths, and yen_shortest_paths functions  return states that contain various  information about the graph learned during traversal. \nLightGraphs.DijkstraState\nLightGraphs.BellmanFordState\nLightGraphs.FloydWarshallState\nLightGraphs.YenStateThe above state types (with the exception of YenState) have the following common information, accessible via the type:.dists Holds a vector of distances computed, indexed by source vertex..parents Holds a vector of parents of each source vertex. The parent of a source vertex is always 0.(YenState substitutes .paths for .parents.)In addition, the following information may be populated with the appropriate arguments to dijkstra_shortest_paths:.predecessors Holds a vector, indexed by vertex, of all the predecessors discovered during shortest-path calculations. This keeps track of all parents when there are multiple shortest paths available from the source..pathcounts Holds a vector, indexed by vertex, of the path counts discovered during traversal. This equals the length of each subvector in the .predecessors output above."
},

{
    "location": "distance.html#",
    "page": "Distance",
    "title": "Distance",
    "category": "page",
    "text": ""
},

{
    "location": "distance.html#Distance-1",
    "page": "Distance",
    "title": "Distance",
    "category": "section",
    "text": "LightGraphs.jl includes the following distance measurements:Order = [:type, :function]\nPages   = [\"distance.md\"]"
},

{
    "location": "distance.html#LightGraphs.BoundedMinkowskiCost-Tuple{AbstractArray{T,1} where T,AbstractArray{T,1} where T}",
    "page": "Distance",
    "title": "LightGraphs.BoundedMinkowskiCost",
    "category": "method",
    "text": "BoundedMinkowskiCost(μ₁, μ₂)\n\nReturn value similar to MinkowskiCost, but ensure costs smaller than 2τ.\n\nOptional Arguments\n\np=1: the p value for p-norm calculation. τ=1: value specifying half of the upper limit of the Minkowski cost.\n\n\n\n\n\n"
},

{
    "location": "distance.html#LightGraphs.MinkowskiCost-Tuple{AbstractArray{T,1} where T,AbstractArray{T,1} where T}",
    "page": "Distance",
    "title": "LightGraphs.MinkowskiCost",
    "category": "method",
    "text": "MinkowskiCost(μ₁, μ₂; p::Real=1)\n\nFor labels μ₁ on the vertices of graph G₁ and labels μ₂ on the vertices of graph G₂, compute the p-norm cost of substituting vertex u ∈ G₁ by vertex v ∈ G₂.\n\nOptional Arguments\n\np=1: the p value for p-norm calculation.\n\n\n\n\n\n"
},

{
    "location": "distance.html#LightGraphs.center-Tuple{Array{T,1} where T}",
    "page": "Distance",
    "title": "LightGraphs.center",
    "category": "method",
    "text": "center(eccentricities)\ncenter(g, distmx=weights(g))\nparallel_center(g, distmx=weights(g))\n\nGiven a graph and optional distance matrix, or a vector of precomputed eccentricities, return the set of all vertices whose eccentricity is equal to the graph\'s radius (that is, the set of vertices with the smallest eccentricity).\n\n\n\n\n\n"
},

{
    "location": "distance.html#LightGraphs.diameter-Tuple{Array{T,1} where T}",
    "page": "Distance",
    "title": "LightGraphs.diameter",
    "category": "method",
    "text": "diameter(eccentricities)\ndiameter(g, distmx=weights(g))\nparallel_diameter(g, distmx=weights(g))\n\nGiven a graph and optional distance matrix, or a vector of precomputed eccentricities, return the maximum eccentricity of the graph.\n\n\n\n\n\n"
},

{
    "location": "distance.html#LightGraphs.eccentricity-Union{Tuple{T}, Tuple{AbstractGraph,Integer}, Tuple{AbstractGraph,Integer,AbstractArray{T,2}}} where T<:Real",
    "page": "Distance",
    "title": "LightGraphs.eccentricity",
    "category": "method",
    "text": "eccentricity(g[, v][, distmx])\neccentricity(g[, vs][, distmx])\nparallel_eccentricity(g[, vs][, distmx])\n\nReturn the eccentricity[ies] of a vertex / vertex list v or a set of vertices  vs defaulting to the entire graph. An optional matrix of edge distances may be supplied; if missing, edge distances default to 1.\n\nThe eccentricity of a vertex is the maximum shortest-path distance between it and all other vertices in the graph.\n\nThe output is either a single float (when a single vertex is provided) or a vector of floats corresponding to the vertex vector. If no vertex vector is provided, the vector returned corresponds to each vertex in the graph.\n\nPerformance\n\nBecause this function must calculate shortest paths for all vertices supplied in the argument list, it may take a long time.\n\nImplementation Notes\n\nThe eccentricity vector returned by eccentricity() may be used as input for the rest of the distance measures below. If an eccentricity vector is provided, it will be used. Otherwise, an eccentricity vector will be calculated for each call to the function. It may therefore be more efficient to calculate, store, and pass the eccentricities if multiple distance measures are desired.\n\nAn infinite path length is represented by the typemax of the distance matrix.\n\n\n\n\n\n"
},

{
    "location": "distance.html#LightGraphs.edit_distance-Tuple{AbstractGraph,AbstractGraph}",
    "page": "Distance",
    "title": "LightGraphs.edit_distance",
    "category": "method",
    "text": "edit_distance(G₁::AbstractGraph, G₂::AbstractGraph)\n\nCompute the edit distance between graphs G₁ and G₂. Return the minimum edit cost and edit path to transform graph G₁ into graph G₂. An edit path consists of a sequence of pairs of vertices(u,v) ∈ [0,|G₁|] × [0,|G₂|]` representing vertex operations:\n\n(0v): insertion of vertex v  G₂\n(u0): deletion of vertex u  G₁\n(u0v0): substitution of vertex u  G₁ by vertex v  G₂\n\nOptional Arguments\n\ninsert_cost::Function=v->1.0\ndelete_cost::Function=u->1.0\nsubst_cost::Function=(u,v)->0.5\n\nBy default, the algorithm uses constant operation costs. The user can provide classical Minkowski costs computed from vertex labels μ₁ (for G₁) and μ₂ (for G₂) in order to further guide the search, for example:\n\nedit_distance(G₁, G₂, subst_cost=MinkowskiCost(μ₁, μ₂))\n\nheuristic::Function=DefaultEditHeuristic: a custom heuristic provided to the A*\n\nsearch in case the default heuristic is not satisfactory.\n\nPerformance\n\nGiven two graphs G₁  G₂, edit_distance(G₁, G₂) is faster to\n\ncompute than edit_distance(G₂, G₁). Consider swapping the arguments if involved costs are equivalent.\n\nThe use of simple Minkowski costs can improve performance considerably.\nExploit vertex attributes when designing operation costs.\n\nReferences\n\nRIESEN, K., 2015. Structural Pattern Recognition with Graph Edit Distance: Approximation Algorithms and Applications. (Chapter 2)\n\nAuthor\n\nJúlio Hoffimann Mendes (juliohm@stanford.edu)\n\n\n\n\n\n"
},

{
    "location": "distance.html#LightGraphs.periphery-Tuple{Array{T,1} where T}",
    "page": "Distance",
    "title": "LightGraphs.periphery",
    "category": "method",
    "text": "periphery(eccentricities)\nperiphery(g, distmx=weights(g))\nparallel_periphery(g, distmx=weights(g))\n\nGiven a graph and optional distance matrix, or a vector of precomputed eccentricities, return the set of all vertices whose eccentricity is equal to the graph\'s diameter (that is, the set of vertices with the largest eccentricity).\n\n\n\n\n\n"
},

{
    "location": "distance.html#LightGraphs.radius-Tuple{Array{T,1} where T}",
    "page": "Distance",
    "title": "LightGraphs.radius",
    "category": "method",
    "text": "radius(eccentricities)\nradius(g, distmx=weights(g))\nparallel_radius(g, distmx=weights(g))\n\nGiven a graph and optional distance matrix, or a vector of precomputed eccentricities, return the minimum eccentricity of the graph.\n\n\n\n\n\n"
},

{
    "location": "distance.html#LightGraphs.transitiveclosure",
    "page": "Distance",
    "title": "LightGraphs.transitiveclosure",
    "category": "function",
    "text": "transitiveclosure(g, selflooped=false)\n\nCompute the transitive closure of a directed graph, using the Floyd-Warshall algorithm. Return a graph representing the transitive closure. If selflooped is true, add self loops to the graph.\n\nPerformance\n\nTime complexity is \\mathcal{O}(|V|^3).\n\n\n\n\n\n"
},

{
    "location": "distance.html#LightGraphs.transitiveclosure!",
    "page": "Distance",
    "title": "LightGraphs.transitiveclosure!",
    "category": "function",
    "text": "transitiveclosure!(g, selflooped=false)\n\nCompute the transitive closure of a directed graph, using the Floyd-Warshall algorithm. If selflooped is true, add self loops to the graph.\n\nPerformance\n\nTime complexity is \\mathcal{O}(|V|^3).\n\nImplementation Notes\n\nThis version of the function modifies the original graph.\n\n\n\n\n\n"
},

{
    "location": "distance.html#Full-Docs-1",
    "page": "Distance",
    "title": "Full Docs",
    "category": "section",
    "text": "Modules = [LightGraphs]\nPages   = [\n    \"distance.jl\",\n    \"transitivity.jl\"\n]\nPrivate = false"
},

{
    "location": "centrality.html#",
    "page": "Centrality Measures",
    "title": "Centrality Measures",
    "category": "page",
    "text": ""
},

{
    "location": "centrality.html#Centrality-Measures-1",
    "page": "Centrality Measures",
    "title": "Centrality Measures",
    "category": "section",
    "text": "Centrality measures describe the importance of a vertex to the rest of the graph using some set of criteria. Centrality measures implemented in LightGraphs.jl include the following:Pages   = [\"centrality.md\"]"
},

{
    "location": "centrality.html#LightGraphs.betweenness_centrality",
    "page": "Centrality Measures",
    "title": "LightGraphs.betweenness_centrality",
    "category": "function",
    "text": "betweenness_centrality(g[, vs])\nbetweenness_centrality(g, k)\nparallel_betweenness_centrality(g[, vs])\nparallel_betweenness_centrality(g, k)\n\nCalculate the betweenness centrality of a graph g across all vertices, a specified subset of vertices vs, or a random subset of k vertices. Return a vector representing the centrality calculated for each node in g.\n\nOptional Arguments\n\nnormalize=true: If true, normalize the betweenness values by the\n\ntotal number of possible distinct paths between all pairs in the graphs. For an undirected graph, this number is frac(V-1)(V-2)2 and for a directed graph, (V-1)(V-2).\n\nendpoints=false: If true, include endpoints in the shortest path count.\n\nBetweenness centrality is defined as: bc(v) = frac1mathcalN sum_s neq t neq v fracsigma_st(v)sigma_st.\n\nReferences\n\nBrandes 2001 & Brandes 2008\n\n\n\n\n\n"
},

{
    "location": "centrality.html#LightGraphs.closeness_centrality",
    "page": "Centrality Measures",
    "title": "LightGraphs.closeness_centrality",
    "category": "function",
    "text": "closeness_centrality(g)\n\nCalculate the closeness centrality of the graph g. Return a vector representing the centrality calculated for each node in g.\n\nOptional Arguments\n\nnormalize=true: If true, normalize the centrality value of each\n\nnode n by fracδ_nV-1, where δ_n is the set of vertices reachable from node n.\n\n\n\n\n\n"
},

{
    "location": "centrality.html#LightGraphs.degree_centrality-Tuple{AbstractGraph}",
    "page": "Centrality Measures",
    "title": "LightGraphs.degree_centrality",
    "category": "method",
    "text": "degree_centrality(g)\nindegree_centrality(g)\noutdegree_centrality(g)\n\nCalculate the degree centrality of graph g. Return a vector representing the centrality calculated for each node in g.\n\nOptional Arguments\n\nnormalize=true: If true, normalize each centrality measure by frac1V-1.\n\n\n\n\n\n"
},

{
    "location": "centrality.html#LightGraphs.eigenvector_centrality-Tuple{AbstractGraph}",
    "page": "Centrality Measures",
    "title": "LightGraphs.eigenvector_centrality",
    "category": "method",
    "text": "eigenvector_centrality(g)\n\nCompute the eigenvector centrality for the graph g.\n\nEigenvector centrality computes the centrality for a node based on the centrality of its neighbors. The eigenvector centrality for node i is the i^th element of mathbfx in the equation mathbfAx = λ mathbfx where mathbfA is the adjacency matrix of the graph g  with eigenvalue λ.\n\nBy virtue of the Perron–Frobenius theorem, there is a unique and positive solution if λ is the largest eigenvalue associated with the eigenvector of the adjacency matrix mathbfA.\n\nReferences\n\nPhillip Bonacich: Power and Centrality: A Family of Measures.   American Journal of Sociology 92(5):1170–1182, 1986   http://www.leonidzhukov.net/hse/2014/socialnetworks/papers/Bonacich-Centrality.pdf\nMark E. J. Newman: Networks: An Introduction.      Oxford University Press, USA, 2010, pp. 169.\n\n\n\n\n\n"
},

{
    "location": "centrality.html#LightGraphs.katz_centrality",
    "page": "Centrality Measures",
    "title": "LightGraphs.katz_centrality",
    "category": "function",
    "text": "katz_centrality(g, α=0.3)\n\nCalculate the Katz centrality of the graph g optionally parameterized by α. Return a vector representing the centrality calculated for each node in g.\n\n\n\n\n\n"
},

{
    "location": "centrality.html#LightGraphs.pagerank-Union{Tuple{AbstractGraph{U}}, Tuple{U}, Tuple{AbstractGraph{U},Any}, Tuple{AbstractGraph{U},Any,Any}, Tuple{AbstractGraph{U},Any,Any,Any}} where U<:Integer",
    "page": "Centrality Measures",
    "title": "LightGraphs.pagerank",
    "category": "method",
    "text": "pagerank(g, α=0.85, n=100, ϵ=1.0e-6)\nparallel_pagerank(g, α=0.85, n=100, ϵ=1.0e-6)\n\nCalculate the PageRank of the graph g parameterized by damping factor α, number of iterations  n, and convergence threshold ϵ. Return a vector representing the centrality calculated for each node in g, or an error if convergence is not reached within n iterations.\n\n\n\n\n\n"
},

{
    "location": "centrality.html#LightGraphs.stress_centrality",
    "page": "Centrality Measures",
    "title": "LightGraphs.stress_centrality",
    "category": "function",
    "text": "stress_centrality(g[, vs])\nstress_centrality(g, k)\nparallel_stress_centrality(g[, vs])\nparallel_stress_centrality(g, k)\n\nCalculate the stress centrality of a graph g across all vertices, a specified subset of vertices vs, or a random subset of k vertices. Return a vector representing the centrality calculated for each node in g.\n\nThe stress centrality of a vertex n is defined as the number of shortest paths passing through n.\n\nReferences\n\nBarabási, A.L., Oltvai, Z.N.: Network biology: understanding the cell\'s functional organization. Nat Rev Genet 5 (2004) 101-113\nShimbel, A.: Structural parameters of communication networks. Bull Math Biophys 15 (1953) 501-507.\n\n\n\n\n\n"
},

{
    "location": "centrality.html#LightGraphs.radiality_centrality-Tuple{AbstractGraph}",
    "page": "Centrality Measures",
    "title": "LightGraphs.radiality_centrality",
    "category": "method",
    "text": "radiality_centrality(g)\nparallel_radiality_centrality(g)\n\nCalculate the radiality centrality of a graph g across all vertices. Return a vector representing the centrality calculated for each node in g.\n\nThe radiality centrality R_u of a vertex u is defined as R_u = fracD_g + 1 - fracsum_vVd_uvV-1D_g\n\nwhere D_g is the diameter of the graph and d_uv is the  length of the shortest path from u to v.\n\nReferences\n\nBrandes, U.: A faster algorithm for betweenness centrality. J Math Sociol 25 (2001) 163-177\n\n\n\n\n\n"
},

{
    "location": "centrality.html#Full-docs-1",
    "page": "Centrality Measures",
    "title": "Full docs",
    "category": "section",
    "text": "Modules = [LightGraphs]\nPages   = [\n    \"centrality/betweenness.jl\",\n    \"centrality/closeness.jl\",\n    \"centrality/degree.jl\",\n    \"centrality/eigenvector.jl\",\n    \"centrality/katz.jl\",\n    \"centrality/pagerank.jl\",\n    \"centrality/stress.jl\",\n    \"centrality/radiality.jl\"\n]\nPrivate = false"
},

{
    "location": "linalg.html#",
    "page": "Linear Algebra",
    "title": "Linear Algebra",
    "category": "page",
    "text": ""
},

{
    "location": "linalg.html#Linear-Algebra-1",
    "page": "Linear Algebra",
    "title": "Linear Algebra",
    "category": "section",
    "text": "LightGraphs.jl provides the following matrix operations on both directed and undirected graphs in the LinAlg submodule:Order = [:type, :function]\nPages   = [\"linalg.md\"]"
},

{
    "location": "linalg.html#LightGraphs.LinAlg",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg",
    "category": "module",
    "text": "LinAlg\n\nA package for using the type system to check types of graph matrices.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.Adjacency",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.Adjacency",
    "category": "type",
    "text": "Adjacency{T}\n\nThe core Adjacency matrix structure. Keeps the vertex degrees around. Subtypes are used to represent the different normalizations of the adjacency matrix. Laplacian and its subtypes are used for the different Laplacian matrices.\n\nAdjacency(lapl::Laplacian) provides a generic function for getting the adjacency matrix of a Laplacian matrix. If your subtype of Laplacian does not provide an field A for the Adjacency instance, then attach another method to this function to provide an Adjacency{T} representation of the Laplacian. The Adjacency matrix here is the final subtype that corresponds to this type of Laplacian\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.AveragingAdjacency",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.AveragingAdjacency",
    "category": "type",
    "text": "AveragingAdjacency{T}\n\nThe matrix whose action is to average over each neighborhood.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.AveragingLaplacian",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.AveragingLaplacian",
    "category": "type",
    "text": "AveragingLaplacian{T}\n\nLaplacian version of the AveragingAdjacency matrix.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.CombinatorialAdjacency",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.CombinatorialAdjacency",
    "category": "type",
    "text": "CombinatorialAdjacency{T,S,V}\n\nThe standard adjacency matrix.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.GraphMatrix",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.GraphMatrix",
    "category": "type",
    "text": "GraphMatrix{T}\n\nAn abstract type to allow opertions on any type of graph matrix\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.Noop",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.Noop",
    "category": "type",
    "text": "Noop\n\nA type that represents no action.\n\nImplementation Notes\n\nThe purpose of Noop is to help write more general code for the\n\ndifferent scaled GraphMatrix types.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.NormalizedAdjacency",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.NormalizedAdjacency",
    "category": "type",
    "text": "NormalizedAdjacency{T}\n\nThe normalized adjacency matrix is hatA = D^-12 A D^-12. If A is symmetric, then the normalized adjacency is also symmetric with real eigenvalues bounded by [-1, 1].\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.NormalizedLaplacian",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.NormalizedLaplacian",
    "category": "type",
    "text": "NormalizedLaplacian{T}\n\nThe normalized Laplacian is hatL = I - D^-12 A D^-12. If A is symmetric, then the normalized Laplacian is also symmetric with positive eigenvalues bounded by 2.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.StochasticAdjacency",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.StochasticAdjacency",
    "category": "type",
    "text": "StochasticAdjacency{T}\n\nA transition matrix for the random walk.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.StochasticLaplacian",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.StochasticLaplacian",
    "category": "type",
    "text": "StochasticLaplacian{T}\n\nLaplacian version of the StochasticAdjacency matrix.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.degrees-Tuple{LightGraphs.LinAlg.CombinatorialAdjacency}",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.degrees",
    "category": "method",
    "text": "degrees(adjmat)\n\nReturn the degrees of a graph represented by the CombinatorialAdjacency adjmat.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.degrees-Tuple{LightGraphs.LinAlg.GraphMatrix}",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.degrees",
    "category": "method",
    "text": "degrees(graphmx)\n\nReturn the degrees of a graph represented by the graph matrix graphmx.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.symmetrize",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.symmetrize",
    "category": "function",
    "text": "symmetrize(A::SparseMatrix, which=:or)\n\nReturn a symmetric version of graph (represented by sparse matrix A) as a sparse matrix. which may be one of :triu, :tril, :sum, or :or. Use :sum for weighted graphs.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.symmetrize",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.symmetrize",
    "category": "function",
    "text": "symmetrize(adjmat, which=:or)\n\nReturn a symmetric version of graph (represented by CombinatorialAdjacency adjmat) as a CombinatorialAdjacency. which may be one of :triu, :tril, :sum, or :or. Use :sum for weighted graphs.\n\nImplementation Notes\n\nOnly works on Adjacency because the normalizations don\'t commute with symmetrization.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.adjacency_matrix",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.adjacency_matrix",
    "category": "function",
    "text": "adjacency_matrix(g[, T=Int; dir=:out])\n\nReturn a sparse adjacency matrix for a graph, indexed by [u, v] vertices. Non-zero values indicate an edge between u and v. Users may override the default data type (Int) and specify an optional direction.\n\nOptional Arguments\n\ndir=:out: :in, :out, or :both are currently supported.\n\nImplementation Notes\n\nThis function is optimized for speed and directly manipulates CSC sparse matrix fields.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.adjacency_spectrum",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.adjacency_spectrum",
    "category": "function",
    "text": "Return the eigenvalues of the adjacency matrix for a graph g, indexed by vertex. Default values for T are the same as those in adjacency_matrix.\n\nOptional Arguments\n\ndir=:unspec: Options for dir are the same as those in laplacian_matrix.\n\nPerformance\n\nConverts the matrix to dense with nv^2 memory usage.\n\nImplementation Notes\n\nUse eigs(adjacency_matrix(g);  kwargs...) to compute some of the eigenvalues/eigenvectors.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.incidence_matrix",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.incidence_matrix",
    "category": "function",
    "text": "incidence_matrix(g[, T=Int; oriented=false])\n\nReturn a sparse node-arc incidence matrix for a graph, indexed by [v, i], where i is in 1:ne(g), indexing an edge e. For directed graphs, a value of -1 indicates that src(e) == v, while a value of 1 indicates that dst(e) == v. Otherwise, the value is 0. For undirected graphs, both entries are 1 by default (this behavior can be overridden by the oriented optional argument).\n\nIf oriented (default false) is true, for an undirected graph g, the matrix will contain arbitrary non-zero values representing connectivity between v and i.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.laplacian_matrix-Union{Tuple{AbstractGraph{U}}, Tuple{U}, Tuple{AbstractGraph{U},DataType}} where U",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.laplacian_matrix",
    "category": "method",
    "text": "laplacian_matrix(g[, T=Int; dir=:unspec])\n\nReturn a sparse Laplacian matrix for a graph g, indexed by [u, v] vertices. T defaults to Int for both graph types.\n\nOptional Arguments\n\ndir=:unspec: :unspec, :both, :in, and:outare currently supported. For undirected graphs,dirdefaults to:out; for directed graphs,dirdefaults to:both`.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.laplacian_spectrum",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.laplacian_spectrum",
    "category": "function",
    "text": "laplacian_spectrum(g[, T=Int; dir=:unspec])\n\nReturn the eigenvalues of the Laplacian matrix for a graph g, indexed by vertex. Default values for T are the same as those in laplacian_matrix.\n\nOptional Arguments\n\ndir=:unspec: Options for dir are the same as those in laplacian_matrix.\n\nPerformance\n\nConverts the matrix to dense with nv^2 memory usage.\n\nImplementation Notes\n\nUse eigs(laplacian_matrix(g);  kwargs...) to compute some of the eigenvalues/eigenvectors.\n\n\n\n\n\n"
},

{
    "location": "linalg.html#LightGraphs.LinAlg.spectral_distance",
    "page": "Linear Algebra",
    "title": "LightGraphs.LinAlg.spectral_distance",
    "category": "function",
    "text": "spectral_distance(G₁, G₂ [, k])\n\nCompute the spectral distance between undirected n-vertex graphs G₁ and G₂ using the top k greatest eigenvalues. If k is ommitted, uses full spectrum.\n\nReferences\n\nJOVANOVIC, I.; STANIC, Z., 2014. Spectral Distances of Graphs Based on their Different Matrix Representations\n\n\n\n\n\n"
},

{
    "location": "linalg.html#Full-Docs-1",
    "page": "Linear Algebra",
    "title": "Full Docs",
    "category": "section",
    "text": "Modules = [LightGraphs.LinAlg]\nPages   = [\n    \"graphmatrices.jl\",\n    \"Nonbacktracking.jl\",\n    \"spectral.jl\"\n]\nPrivate = false"
},

{
    "location": "matching.html#",
    "page": "Matching",
    "title": "Matching",
    "category": "page",
    "text": ""
},

{
    "location": "matching.html#Matching-1",
    "page": "Matching",
    "title": "Matching",
    "category": "section",
    "text": "Maximum weight matching is supported in the companion package LightGraphsExtras.jl."
},

{
    "location": "community.html#",
    "page": "Community Structures",
    "title": "Community Structures",
    "category": "page",
    "text": ""
},

{
    "location": "community.html#Community-Structures-1",
    "page": "Community Structures",
    "title": "Community Structures",
    "category": "section",
    "text": "LightGraphs.jl contains many algorithm to detect and analyze community structures in graphs. These include:Order = [:type, :function]\nPages   = [\"community.md\"]"
},

{
    "location": "community.html#LightGraphs.maximal_cliques",
    "page": "Community Structures",
    "title": "LightGraphs.maximal_cliques",
    "category": "function",
    "text": "maximal_cliques(g)\n\nReturn a vector of vectors representing the node indices in each of the maximal cliques found in the undirected graph g.\n\njulia> using LightGraphs\njulia> g = SimpleGraph(3)\njulia> add_edge!(g, 1, 2)\njulia> add_edge!(g, 2, 3)\njulia> maximal_cliques(g)\n2-element Array{Array{Int64,N},1}:\n [2,3]\n [2,1]\n\n\n\n\n\n"
},

{
    "location": "community.html#LightGraphs.global_clustering_coefficient-Tuple{AbstractGraph}",
    "page": "Community Structures",
    "title": "LightGraphs.global_clustering_coefficient",
    "category": "method",
    "text": "global_clustering_coefficient(g)\n\nReturn the global clustering coefficient of graph g.\n\n\n\n\n\n"
},

{
    "location": "community.html#LightGraphs.local_clustering-Tuple{AbstractGraph,Integer}",
    "page": "Community Structures",
    "title": "LightGraphs.local_clustering",
    "category": "method",
    "text": "local_clustering(g, v)\nlocal_clustering(g, vs)\n\nReturn a tuple (a, b), where a is the number of triangles in the neighborhood of v and b is the maximum number of possible triangles. If a list of vertices vs is specified, return two vectors representing the number of triangles and the maximum number of possible triangles, respectively, for each node in the list.\n\nThis function is related to the local clustering coefficient r by r=fracab.\n\n\n\n\n\n"
},

{
    "location": "community.html#LightGraphs.local_clustering_coefficient-Tuple{AbstractGraph,Integer}",
    "page": "Community Structures",
    "title": "LightGraphs.local_clustering_coefficient",
    "category": "method",
    "text": "local_clustering_coefficient(g, v)\nlocal_clustering_coefficient(g, vs)\n\nReturn the local clustering coefficient for node v in graph g. If a list of vertices vs is specified, return a vector of coefficients for each node in the list.\n\n\n\n\n\n"
},

{
    "location": "community.html#LightGraphs.triangles-Tuple{AbstractGraph,Integer}",
    "page": "Community Structures",
    "title": "LightGraphs.triangles",
    "category": "method",
    "text": "triangles(g[, v])\ntriangles(g, vs)\n\nReturn the number of triangles in the neighborhood of node v in graph g. If a list of vertices vs is specified, return a vector of number of triangles for each node in the list. If no vertices are specified, return the number of triangles for each node in the graph.\n\n\n\n\n\n"
},

{
    "location": "community.html#LightGraphs.core_periphery_deg",
    "page": "Community Structures",
    "title": "LightGraphs.core_periphery_deg",
    "category": "function",
    "text": "core_periphery_deg(g)\n\nCompute the degree-based core-periphery for graph g. Return the vertex assignments (1 for core and 2 for periphery) for each node in g.\n\nReferences:     Lip)\n\n\n\n\n\n"
},

{
    "location": "community.html#LightGraphs.label_propagation-Union{Tuple{AbstractGraph{T}}, Tuple{T}, Tuple{AbstractGraph{T},Any}} where T",
    "page": "Community Structures",
    "title": "LightGraphs.label_propagation",
    "category": "method",
    "text": "label_propagation(g, maxiter=1000)\n\nCommunity detection using the label propagation algorithm. Return two vectors: the first is the label number assigned to each node, and the second is the convergence history for each node. Will return after maxiter iterations if convergence has not completed.\n\nReferences\n\nRaghavan et al.\n\n\n\n\n\n"
},

{
    "location": "community.html#LightGraphs.modularity",
    "page": "Community Structures",
    "title": "LightGraphs.modularity",
    "category": "function",
    "text": "modularity(g, c)\n\nReturn a value representing Newman\'s modularity Q for the undirected graph g given the partitioning vector c.\n\n\n\n\n\n"
},

{
    "location": "community.html#Full-Docs-1",
    "page": "Community Structures",
    "title": "Full Docs",
    "category": "section",
    "text": "Modules = [LightGraphs]\nPages   = [\n    \"community/cliques.jl\",\n    \"community/clustering.jl\",\n    \"community/core-periphery.jl\",\n    \"community/label_propagation.jl\",\n    \"community/modularity.jl\"\n]\nPrivate = false"
},

{
    "location": "degeneracy.html#",
    "page": "Degeneracy",
    "title": "Degeneracy",
    "category": "page",
    "text": ""
},

{
    "location": "degeneracy.html#Graph-Decomposition-1",
    "page": "Degeneracy",
    "title": "Graph Decomposition",
    "category": "section",
    "text": "LightGraphs.jl provides the following graph degeneracy functions:Order = [:type, :function]\nPages   = [\"degeneracy.md\"]"
},

{
    "location": "degeneracy.html#LightGraphs.core_number-Union{Tuple{AbstractGraph{T}}, Tuple{T}} where T",
    "page": "Degeneracy",
    "title": "LightGraphs.core_number",
    "category": "method",
    "text": "core_number(g)\n\nReturn the core number for each vertex in graph g.\n\nA k-core is a maximal subgraph that contains vertices of degree k or more. The core number of a vertex is the largest value k of a k-core containing that vertex.\n\nImplementation Notes\n\nNot implemented for graphs with self loops.\n\nReferences\n\nAn O(m) Algorithm for Cores Decomposition of Networks,   Vladimir Batagelj and Matjaz Zaversnik, 2003.   http://arxiv.org/abs/cs.DS/0310049\n\n\n\n\n\n"
},

{
    "location": "degeneracy.html#LightGraphs.k_core",
    "page": "Degeneracy",
    "title": "LightGraphs.k_core",
    "category": "function",
    "text": "k_core(g[, k]; corenum=core_number(g))\n\nReturn a vector of vertices in the k-core of graph g. If k is not specified, return the core with the largest degree.\n\nA k-core is a maximal subgraph that contains vertices of degree k or more.\n\nImplementation Notes\n\nNot implemented for graphs with self loops.\n\nReferences\n\nAn O(m) Algorithm for Cores Decomposition of Networks,   Vladimir Batagelj and Matjaz Zaversnik, 2003.   http://arxiv.org/abs/cs.DS/0310049\n\n\n\n\n\n"
},

{
    "location": "degeneracy.html#LightGraphs.k_corona-Tuple{AbstractGraph,Any}",
    "page": "Degeneracy",
    "title": "LightGraphs.k_corona",
    "category": "method",
    "text": "k_corona(g, k; corenum=core_number(g))\n\nReturn a vector of vertices in the k-corona of g. \n\nThe k-corona is the subgraph of vertices in the k-core which have exactly k neighbors in the k-core.\n\nImplementation Notes\n\nNot implemented for graphs with parallel edges or self loops.\n\nReferences\n\nk-core (bootstrap) percolation on complex networks:  Critical phenomena and nonlocal effects,  A. V. Goltsev, S. N. Dorogovtsev, and J. F. F. Mendes,  Phys. Rev. E 73, 056101 (2006)  http://link.aps.org/doi/10.1103/PhysRevE.73.056101\n\n\n\n\n\n"
},

{
    "location": "degeneracy.html#LightGraphs.k_crust",
    "page": "Degeneracy",
    "title": "LightGraphs.k_crust",
    "category": "function",
    "text": "k_crust(g[, k]; corenum=core_number(g))\n\nReturn a vector of vertices in the k-crust of g.  If k is not specified, return the crust of the core with the largest degree.\n\nThe k-crust is the graph g with the k-core removed.\n\nImplementation Notes\n\nThis definition of k-crust is different than the definition in References. The k-crust in References is equivalent to the k+1 crust of this algorithm.\n\nNot implemented for graphs with self loops.\n\nReferences\n\nA model of Internet topology using k-shell decomposition  Shai Carmi, Shlomo Havlin, Scott Kirkpatrick, Yuval Shavitt,  and Eran Shir, PNAS  July 3, 2007   vol. 104  no. 27  11150-11154  http://www.pnas.org/content/104/27/11150.full\n\n\n\n\n\n"
},

{
    "location": "degeneracy.html#LightGraphs.k_shell",
    "page": "Degeneracy",
    "title": "LightGraphs.k_shell",
    "category": "function",
    "text": "k_shell(g[, k]; corenum=core_number(g))\n\nReturn a vector of vertices in the k-shell of g. If k is not specified, return the shell of the core with the largest degree.\n\nThe k-shell is the subgraph of vertices in the k-core but not in the (k+1)-core. This is similar to k_corona but in that case only neighbors in the k-core are considered.\n\nImplementation Notes\n\nNot implemented for graphs with parallel edges or self loops.\n\nReferences\n\nA model of Internet topology using k-shell decomposition  Shai Carmi, Shlomo Havlin, Scott Kirkpatrick, Yuval Shavitt,  and Eran Shir, PNAS  July 3, 2007   vol. 104  no. 27  11150-11154  http://www.pnas.org/content/104/27/11150.full\n\n\n\n\n\n"
},

{
    "location": "degeneracy.html#Full-Docs-1",
    "page": "Degeneracy",
    "title": "Full Docs",
    "category": "section",
    "text": "Modules = [LightGraphs]\nPages   = [\"degeneracy.jl\"]\nPrivate = false"
},

{
    "location": "integration.html#",
    "page": "Integration with other packages",
    "title": "Integration with other packages",
    "category": "page",
    "text": ""
},

{
    "location": "integration.html#Integration-with-other-packages-1",
    "page": "Integration with other packages",
    "title": "Integration with other packages",
    "category": "section",
    "text": "LightGraphs.jl\'s integration with other Julia packages is designed to be straightforward. Here are a few examples."
},

{
    "location": "integration.html#[Graphs.jl](http://github.com/JuliaLang/Graphs.jl)-1",
    "page": "Integration with other packages",
    "title": "Graphs.jl",
    "category": "section",
    "text": "Creating a Graphs.jl simple_graph is easy:julia> s = simple_graph(nv(g), is_directed=LightGraphs.is_directed(g))\njulia> for e in LightGraphs.edges(g)\n           add_edge!(s,src(e), dst(e))\n       end"
},

{
    "location": "integration.html#[Metis.jl](https://github.com/JuliaSparse/Metis.jl)-1",
    "page": "Integration with other packages",
    "title": "Metis.jl",
    "category": "section",
    "text": "The Metis graph partitioning package can interface with LightGraphs.jl:julia> using LightGraphs\n\njulia> g = SimpleGraph(100,1000)\n{100, 1000} undirected graph\n\njulia> partGraphKway(g, 6)  # 6 partitions"
},

{
    "location": "experimental.html#",
    "page": "Experimental Functionality",
    "title": "Experimental Functionality",
    "category": "page",
    "text": ""
},

{
    "location": "experimental.html#Experimental-Graph-Algorithms-1",
    "page": "Experimental Functionality",
    "title": "Experimental Graph Algorithms",
    "category": "section",
    "text": "LightGraphs.Experimental is a module for graph algorithms that are newer or less stable. We can adopt algorithms before we finalize an interface for using them or if we feel that full support cannot be provided to the current implementation. You can expect new developments to land here before they make it into the main module. This enables the development to keep advancing without being risk averse because of stability guarantees. You can think of this module as a 0.X semantic version space; it is a place where you can play around with new algorithms, perspectives, and interfaces without fear of breaking critical code."
},

{
    "location": "experimental.html#A-Note-To-Users-1",
    "page": "Experimental Functionality",
    "title": "A Note To Users",
    "category": "section",
    "text": "Code in this module is unstable and subject to change. Do not use any code in this module in production environments without understanding the (large) risks involved. However, we welcome bug reports and issues via the normal channels.."
},

{
    "location": "experimental.html#Graph-Isomorphism-1",
    "page": "Experimental Functionality",
    "title": "Graph Isomorphism",
    "category": "section",
    "text": "Here is the documentation for graph isomorphism functions."
},

{
    "location": "contributing.html#",
    "page": "Contributing",
    "title": "Contributing",
    "category": "page",
    "text": ""
},

{
    "location": "contributing.html#Contributor-Guide-1",
    "page": "Contributing",
    "title": "Contributor Guide",
    "category": "section",
    "text": "We welcome all possible contributors and ask that you read these guidelines before starting to work on this project. Following these guidelines will reduce friction and improve the speed at which your code gets merged."
},

{
    "location": "contributing.html#Bug-reports-1",
    "page": "Contributing",
    "title": "Bug reports",
    "category": "section",
    "text": "If you notice code that is incorrect/crashes/too slow please file a bug report. The report should be raised as a github issue with a minimal working example that reproduces the error message. The example should include any data needed. If the problem is incorrectness, then please post the correct result along with an incorrect result.Please include version numbers of all relevant libraries and Julia itself."
},

{
    "location": "contributing.html#Development-guidelines-1",
    "page": "Contributing",
    "title": "Development guidelines",
    "category": "section",
    "text": "PRs should contain one logical enhancement to the codebase.\nSquash commits in a PR.\nOpen an issue to discuss a feature before you start coding (this maximizes the likelihood of patch acceptance).\nMinimize dependencies on external packages, and avoid introducing new dependencies. In general,\nPRs introducing dependencies on Julia Base or the packages in the Julia Standard Library are ok.\nPRs introducing dependencies on third-party non-core \"leaf\" packages (no subdependencies except for Julia Base / Standard Library packages) are less ok.\nPRs introducing dependencies on third-party non-core non-leaf packages (that is, third-party packages that have dependencies on one or more other third-party packages) require strict scrutiny and will likely not be accepted without some compelling reason (urgent bugfix or much-needed functionality).\nPut type assertions on all function arguments where conflict may arise (use abstract types, Union, or Any if necessary).\nIf the algorithm was presented in a paper, include a reference to the paper (i.e. a proper academic citation along with an eprint link).\nTake steps to ensure that code works on graphs with multiple connected components efficiently.\nCorrectness is a necessary requirement; efficiency is desirable. Once you have a correct implementation, make a PR so we can help improve performance.\nWe can accept code that does not work for directed graphs as long as it comes with an explanation of what it would take to make it work for directed graphs.\nStyle point: prefer the short circuiting conditional over if/else when convenient, and where state is not explicitly being mutated (e.g., condition && error(\"message\") is good; condition && i += 1 is not).\nWhen possible write code to reuse memory. For example:function f(g, v)\n    storage = Vector{Int}(undef, nv(g))\n    # some code operating on storage, g, and v.\n    for i in 1:nv(g)\n        storage[i] = v-i\n    end\n    return sum(storage)\nendshould be rewritten as two functionsfunction f(g::AbstractGraph, v::Integer)\n    storage = Vector{Int}(undef, nv(g))\n    return f!(g, v, storage)\nend\n\nfunction f!(g::AbstractGraph, v::Integer, storage::AbstractVector{Int})\n    # some code operating on storage, g, and v.\n    for i in 1:nv(g)\n        storage[i] = v-i\n    end\n    return sum(storage)\nendThis gives users the option of reusing memory and improving performance."
},

{
    "location": "contributing.html#Minimizing-use-of-internal-struct-fields-1",
    "page": "Contributing",
    "title": "Minimizing use of internal struct fields",
    "category": "section",
    "text": "Since LightGraphs supports multiple implementations of the graph datastructure using the AbstractGraph type you should refrain as much as reasonably practicable from using the internal fields of structs such as fadjlist. Instead, you should use the functions provided in the api. Code that is instrumental to defining a concrete graph type can use the internal structure of that type for example graph generators in /src/StaticGraphs/generators/staticgraphs.jl use the fadjlist field in order to construct graphs efficiently."
},

{
    "location": "contributing.html#Git-usage-1",
    "page": "Contributing",
    "title": "Git usage",
    "category": "section",
    "text": "In order to make it easier for you to review Pull Requests (PRs), you can add this to your git config file, which should be located at $HOME/.julia/v0.6/LightGraphs/.git/config. Follow the instructions here.Locate the section for your github remote in the .git/config file. It looks like this:[remote \"origin\"]\n    fetch = +refs/heads/*:refs/remotes/origin/*\n    url = git@github.com:JuliaGraphs/LightGraphs.jl.gitNow add the line fetch = +refs/pull/*/head:refs/remotes/origin/pr/* to this section. Obviously, change the github url to match your project\'s URL. It ends up looking like this:[remote \"origin\"]\n    fetch = +refs/heads/*:refs/remotes/origin/*\n    url = git@github.com:JuliaGraphs/LightGraphs.jl.git\n    fetch = +refs/pull/*/head:refs/remotes/origin/pr/*Now fetch all the pull requests:$ git fetch origin\nFrom github.com:JuliaGraphs/LightGraphs.jl\n * [new ref]         refs/pull/1000/head -> origin/pr/1000\n * [new ref]         refs/pull/1002/head -> origin/pr/1002\n * [new ref]         refs/pull/1004/head -> origin/pr/1004\n * [new ref]         refs/pull/1009/head -> origin/pr/1009\n...To check out a particular pull request:$ git checkout pr/999\nBranch pr/999 set up to track remote branch pr/999 from origin.\nSwitched to a new branch \'pr/999\'Now you can test a PR by running git fetch && git checkout pr/PRNUMBER && julia -e \'Pkg.test(\"LightGraphs\")"
},

{
    "location": "developing.html#",
    "page": "Developer Notes",
    "title": "Developer Notes",
    "category": "page",
    "text": ""
},

{
    "location": "developing.html#Developing-Alternate-Graph-Types-1",
    "page": "Developer Notes",
    "title": "Developing Alternate Graph Types",
    "category": "section",
    "text": "This section is designed to guide developers who wish to write their own graph structures.All LightGraphs functions rely on a standard API to function. As long as your graph structure is a subtype of AbstractGraph and implements the following API functions with the given return values, all functions within the LightGraphs package should just work:edges\neltype\nhas_edge\nhas_vertex\ninneighbors\nis_directed: Note that since we use traits to determine directedness, is_directed for a CustomGraph type should have the following signatures:\nis_directed(::Type{CustomGraph})::Bool\nis_directed(g::CustomGraph)::Bool\nne\nnv\noutneighbors\nverticesIf the graph structure is designed to represent weights on edges, the weights function should also be defined. Note that the output does not necessarily have to be a dense matrix, but it must be indexable via [u, v]."
},

{
    "location": "license.html#",
    "page": "License Information",
    "title": "License Information",
    "category": "page",
    "text": "The LightGraphs.jl package is licensed under the Simplified \"2-clause\" BSD License:Copyright (c) 2015: Seth Bromberger and other contributors.Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\nRedistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.LightGraphs uses code derived from and/or inspired by the following packages:NetworkX:Copyright (C) 2004-2012, NetworkX Developers Aric Hagberg <hagberg@lanl.gov> Dan Schult <dschult@colgate.edu> Pieter Swart <swart@lanl.gov> All rights reserved.Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\nRedistributions in binary form must reproduce the above with the distribution.\nNeither the name of the NetworkX Developers nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.Graphs.jl:Copyright (c) 2012: John Myles White and other contributors.Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
},

{
    "location": "citing.html#",
    "page": "Citing LightGraphs",
    "title": "Citing LightGraphs",
    "category": "page",
    "text": "We encourage you to cite our work if you have used our libraries, tools or datasets. Starring the repository on GitHub is also appreciated.Use the following BibTeX citation for the latest version of LightGraphs.jl:@misc{Bromberger17,\n  author       = {Seth Bromberger, James Fairbanks, and other contributors},\n  title        = {JuliaGraphs/LightGraphs.jl: LightGraphs},\n  year         = 2017,\n  doi          = {10.5281/zenodo.889971},\n  url          = {https://doi.org/10.5281/zenodo.889971}\n}For previous versions, please reference the zenodo site."
},

]}
