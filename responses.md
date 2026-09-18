# PS2: Written responses

Name:

NetID:

Write one short paragraph per question. Use examples from your code and the
supplied maps. Keep the numbered questions and replace each TODO with your answer.

1. **Why track your CornellID?** In the
   [small Part 2 map](data/test_part_2.txt), why must the search treat
   `(2, 4, false)` and `(2, 4, true)` as two states? What can go wrong if the
   set of discovered states stores only `(row, column)`? Why can a shortest
   route visit `(2, 4)` twice?

   TODO: Write your response.

2. **Why use a queue?** Explain why breadth-first search with a first-in,
   first-out queue finds a route with the fewest moves. Would the first route
   found by depth-first search always have the fewest moves? Explain. If some
   moves took longer than others, with all travel times greater than zero,
   which algorithm from Week 4 would find the fastest route? Why?

   TODO: Write your response.

3. **How many states can the search discover?** Let `P` be the number of cells
   that are not walls, including `S`, `E`, `K`, and `D`. Give an upper bound,
   in terms of `P`, on the number of states in each part. Why might the search
   reach fewer states than your bound? Consider walls and the CornellID rules.
   Explain why recording a state in the discovered set when adding it to the
   queue prevents the same state from being added twice.

   TODO: Write your response.
