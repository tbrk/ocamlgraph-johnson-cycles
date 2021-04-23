Finding all the Elementary Circuits of a Directed Graph in OCaml
================================================================

A path is a cycle if the first and last vertices are the same, it is 
elementary if no vertex appears twice.

Implements the algorithm from Johnson, “Finding all the Elementary Circuits 
of a Directed Graph”, SIAM Journal on Computing 4(1), March 1975 but handles 
loops loops (they are counted as elementary cycles of length 1). Multiple 
edges between two vertices are treated as a single edge.

In the basic algorithm time is bounded by [O((|V| + |E|)(c + 1))], where [c] 
is the number of cycles which may be more than exponential in the size of 
the graph, and space is bounded by [O(|V| + |E|)]. Where the original 
algorithm treats the vertices in order and constructs an adjacency structure 
in each iteration, this implementation tracks visited nodes using a hash 
table. A hash table is also used to track “blocked” vertices.

Requires the [ocamlgraph](http://ocamlgraph.lri.fr) library.

**Not very useful in practice since the number of elementary circuits is 
easily often exponential in the size of the graph!**

