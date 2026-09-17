# Adapted from the course's Week 3 MyQueue interface. A moving front index
# avoids removing or shifting stored entries as a search consumes the queue.

"""
    MyQueue{T}()

Construct an empty first-in, first-out queue with items of type `T`. Use
`push!`, `popfirst!`, `peek`, `isempty`, and `length` to operate the queue.
Its fields are private by convention; client code must use those operations.

### Type Parameters

- `T`: The element type stored in the queue, such as `Position` or `EscapeState`.

### Fields

- `items::Vector{T}`: Backing storage in insertion order. Consumed entries are
  retained until the queue is discarded.
- `front::Int`: One-based index of the oldest unconsumed item. A value greater
  than `length(items)` identifies an empty queue.

### Returns

- `MyQueue{T}`: An empty queue with `front = 1`. Create a fresh queue for each
  search so its stored entries belong to that search only.
"""
mutable struct MyQueue{T}
    # Data fields -
    items::Vector{T}
    front::Int

    # Empty constructor -
    MyQueue{T}() where {T} = new{T}(T[], 1)
end

"""
    push!(queue::MyQueue, value) -> MyQueue

Append an item to the back of the queue, after all items already waiting.

### Arguments

- `queue::MyQueue`: The queue to modify.
- `value`: The item to append. It must be convertible to the queue's element
  type, following the conversion rules of `push!` on the backing vector.

### Returns

- `MyQueue`: The same queue, now containing the appended item.
"""
Base.push!(queue::MyQueue, value) = (push!(queue.items, value); queue);

"""
    isempty(queue::MyQueue) -> Bool

Check whether the queue has any unconsumed items.

### Arguments

- `queue::MyQueue`: The queue to inspect. It is not modified.

### Returns

- `Bool`: `true` when no items are waiting, even if consumed entries remain in
  the backing vector; `false` otherwise.
"""
Base.isempty(queue::MyQueue) = queue.front > length(queue.items);

"""
    length(queue::MyQueue) -> Int

Count the items waiting to be removed from the queue.

### Arguments

- `queue::MyQueue`: The queue to inspect. It is not modified.

### Returns

- `Int`: The number of unconsumed items. Previously removed items are excluded.
"""
Base.length(queue::MyQueue) = length(queue.items) - queue.front + 1;

"""
    popfirst!(queue::MyQueue{T}) -> T

Remove and return the oldest unconsumed item. Advancing the front index leaves
the backing vector in insertion order.

### Arguments

- `queue::MyQueue`: The queue to modify. It must contain at least one waiting item.

### Returns

- `T`: The item at the front of the queue before removal.

### Errors

- `ArgumentError`: The queue is empty.
"""
function Base.popfirst!(queue::MyQueue)

    # Check that an item is waiting -
    isempty(queue) && throw(ArgumentError("cannot remove an item from an empty queue"));

    # Consume the front item -
    value = queue.items[queue.front];
    queue.front += 1; # the consumed entry remains in storage but is no longer in the queue
    return value;
end

"""
    peek(queue::MyQueue{T}) -> T

Read the oldest unconsumed item without removing it.

### Arguments

- `queue::MyQueue`: The queue to inspect. It is not modified.

### Returns

- `T`: The item that the next call to `popfirst!(queue)` would remove.

### Errors

- `ArgumentError`: The queue is empty.
"""
function Base.peek(queue::MyQueue)
    isempty(queue) && throw(ArgumentError("cannot inspect an empty queue"));
    return queue.items[queue.front];
end
