const std = @import("std");
const time = std.time;
const Timer = time.Timer;
const hash_map = std.hash_map;

var timer: Timer = undefined;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    timer = try Timer.start();

    var allocator = std.heap.c_allocator;
    const buf_size = 256;
    var buf: [buf_size]u8 = undefined;

    var numInsertions: usize = 1;
    var maxInsertions: usize = 10 * 1000 * 1000;
    try stdout.print("num_elements,nanoseconds_per_element\n", .{});
    while (numInsertions < maxInsertions) {
        var fastest: u64 = std.math.maxInt(u64);

        var i: usize = 0;
        const numAttempts = 5;
        while (i < numAttempts) : (i += 1) {
            var map = hash_map.StringHashMap(i32).init(allocator);
            defer map.deinit();
            var r = std.rand.DefaultPrng.init(213);
            const rand = r.random();

            // Allocate all the strings upfront so the allocation doesn't get included in the benchmark
            var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
            defer arena_state.deinit();
            const arena = arena_state.allocator();
            var strings: [][]const u8 = try arena.alloc([]const u8, numInsertions);
            var n: usize = 0;
            while (n < numInsertions) : (n += 1) {
                rand.bytes(&buf);
                const end_i = rand.intRangeLessThan(usize, 1, buf_size);
                const str = try arena.dupe(u8, buf[0..end_i]);
                strings[n] = str;
            }

            beginMeasure();
            n = 0;
            while (n < numInsertions) : (n += 1) {
                _ = try map.put(strings[n], undefined);
            }
            const ns_per_element = endMeasure(numInsertions);

            if (ns_per_element < fastest) {
                fastest = ns_per_element;
            }
        }

        try stdout.print("{},{}\n", .{ numInsertions, fastest });
        numInsertions = nextInterval(numInsertions);
    }
}

fn beginMeasure() void {
    timer.reset();
}

fn endMeasure(iterations: usize) u64 {
    const elapsed_ns = timer.read();
    return elapsed_ns / iterations;
}

fn nextInterval(x: usize) usize {
    return @as(usize, @intFromFloat(@as(f64, @floatFromInt(x + 1)) * 1.25));
}
