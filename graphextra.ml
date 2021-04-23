
module Cycles (G : Graph.Sig.G) :
sig
  (** Returns the list of elementary cycles in a graph.

      A path is a cycle if the first and last vertices are the same, it is
      elementary if no vertex appears twice.

      Implements the algorithm from Johnson, “Finding all the Elementary
      Circuits of a Directed Graph”, SIAM Journal on Computing 4(1),
      March 1975 but handles loops loops (they are counted as elementary
      cycles of length 1). Multiple edges between two vertices are treated as
      a single edge.

      In the basic algorithm time is bounded by [O((|V| + |E|)(c + 1))], where
      [c] is the number of cycles which may be more than exponential in the
      size of the graph, and space is bounded by [O(|V| + |E|)]. Where the
      original algorithm treats the vertices in order and constructs an
      adjacency structure in each iteration, this implementation tracks
      visited nodes using a hash table. A hash table is also used to track
      “blocked” vertices. *)
  val cycles_list : G.t -> G.V.t list list
end
  =
struct

  module VHash = Hashtbl.Make (G.V)

  type blocked_info = {
    blist : unit VHash.t;
    mutable blocked : bool;
  }

  let cycles_list g =
    let nv = G.nb_vertex g in
    let blist_init_size = G.nb_edges g / nv + 5 in
    let visited = VHash.create nv in

    (* data structures for blocking *)
    let blocked = VHash.create nv in
    let get_blocked_info v =
      try VHash.find blocked v
      with Not_found ->
        let r = { blist = VHash.create blist_init_size; blocked = false }
        in VHash.add blocked v r; r
    in
    let rec unblock' binfo =
      binfo.blocked <- false;
      VHash.iter test_and_unblock binfo.blist;
      VHash.reset binfo.blist
    and test_and_unblock w () =
      let binfo = get_blocked_info w in
      if binfo.blocked then unblock' binfo
    in
    let reset_blocked () = VHash.clear blocked in
    let unblock v = unblock' (get_blocked_info v) in
    let set_blocked v vv = (get_blocked_info v).blocked <- vv in
    let blocked_for v w = VHash.replace (get_blocked_info w).blist v () in
    let blocked v = (get_blocked_info v).blocked in

    (* graph exploration *)
    let visit_vertex s cycles =
      VHash.add visited s ();
      reset_blocked ();
      let rec circuit path v (f', cycles) =
        set_blocked v true;
        let f, cycles' =
          G.fold_succ (circuit_succ (v :: path)) g v (false, cycles)
        in
        if f then unblock v else G.iter_succ (blocked_for v) g v;
        (f' || f, cycles')

      and circuit_succ path w (f, cycles) =
        if G.V.equal w s then (true, path :: cycles)
        else if VHash.mem visited w || blocked w then (f, cycles)
        else circuit path w (f, cycles)
      in
      snd (circuit [] s (false, cycles))
    in
    G.fold_vertex visit_vertex g []

end

