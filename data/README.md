# Maze data

These are synthetic teaching maps. They do not represent Olin Hall or any other actual building.

The small maps were written by hand. The production maps use fixed seeds in
the instructor map generator in the authoring checkout.
That instructor file is excluded from the student archive; no generator is needed to solve the assignment.

| Map | Rows × columns | Minimum moves |
|---|---:|---:|
| [test_part_1.txt](test_part_1.txt) | 5 × 9 | 10 |
| [production_part_1.txt](production_part_1.txt) | 17 × 25 | 84 |
| [test_part_2.txt](test_part_2.txt) | 5 × 11 | 16 |
| [production_part_2.txt](production_part_2.txt) | 21 × 31 | 178 |

Every move has unit cost. The Part 2 counts include the detour to collect the CornellID and obey
the locked-door rule. Counts were checked with an independent Python search
and the Julia reference implementation. The small maps can also be checked by hand.

## File digests

SHA-256 digests identify the exact map bytes used by
[`testme_part_1.jl`](../testme_part_1.jl) and
[`testme_part_2.jl`](../testme_part_2.jl):

```text
dcea565cc82724d37dac9a232876cdfd3da2a54677610e9aeac5cd781642a230  test_part_1.txt
35c1f3c4bd2549478dd372c9ac5a4c77399e2481f9b01381069c94be7a176b1e  production_part_1.txt
ca64d4fa837999cf54a9506d3fb7885414c5225ab2a34b0db66829e984cd3142  test_part_2.txt
29a61504feae54a0a25f568b8368814a8101e6c0407539eb961f36ff8037fa90  production_part_2.txt
```
