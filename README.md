# zig-hash-map-bench

Benchmarks for [Zig](https://ziglang.org)'s `std.HashMap`. Will be expanded on in the future.

Based loosely on some of the benchmarking of C++ hash map implementations here:
- https://probablydance.com/2017/02/26/i-wrote-the-fastest-hashtable/
- https://tessil.github.io/2016/08/29/benchmark-hopscotch-map.html
- https://martin.ankerl.com/2019/04/01/hashmap-benchmarks-01-overview/
- https://github.com/ktprime/emhash#other-benchmark

## Running

Insertion without ensureCapacity:

```
zig run insert.zig --release-fast --library c
```

Output will be in the format:

```
num_elements,nanoseconds_per_element
1,68
2,40
3,32
5,25
7,21
10,19
...
```
