# PS2: Written responses

Name:

NetID:

Write a short paragraph for each question. Use your implementation and the
supplied maps to make the explanation concrete.

1. **What does a vertex represent?** In the small Part 2 map, explain why the
   search must distinguish `(2, 4, false)` from `(2, 4, true)`. What can go wrong
   if the discovered set stores only `(row, column)`? Why is revisiting this
   physical junction consistent with finding a shortest path in the state graph?

   TODO: Write your response.

2. **Why use a queue?** Explain why first-in, first-out exploration finds a
   route with the fewest moves in these maps. Would returning the first escape
   found by depth-first search provide the same guarantee? If some moves took
   longer than others, with all travel times positive, which Week 4 algorithm
   would you use to minimize total travel time, and why?

   TODO: Write your response.

3. **How much can the search discover?** Let `P` denote the number of non-wall
   cells in a map, including marked cells. Give an upper bound in terms of `P`
   for the number of distinct states in each part. Explain why some counted
   states may be invalid or unreachable and why marking states when they enter
   the queue prevents duplicate queue entries for the same state.

   TODO: Write your response.
