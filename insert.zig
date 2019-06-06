const std = @import("std");
const time = std.time;
const Timer = time.Timer;
const hash_map = std.hash_map;

var timer: Timer = undefined;
var stdout: *std.io.OutStream(std.os.WriteError) = undefined;

pub fn main() !void {
    const stdout_file = try std.io.getStdOut();
    stdout = &(stdout_file.outStream().stream);
    timer = try Timer.start();

    var allocator = std.heap.c_allocator;
    var result: u64 = 0;

    var numInsertions: usize = 1;
    var maxInsertions: usize = 10 * 1000 * 1000;
    try stdout.print("num_elements,nanoseconds_per_element\n");
    while (numInsertions < maxInsertions) {

        var fastest: u64 = std.math.maxInt(u64);

        var i: usize = 0;
        const numAttempts = 5;
        while (i < numAttempts) : (i+=1) {
            var map = hash_map.AutoHashMap(i32, i32).init(allocator);
            defer map.deinit();
            var r = std.rand.DefaultPrng.init(213);

            beginMeasure();
            var n: usize = 0;
            while (n < numInsertions) : (n += 1) {
                _ = try map.put(r.random.int(i32), undefined);
            }
            const ns_per_element = endMeasure(numInsertions);

            if (ns_per_element < fastest) {
                fastest = ns_per_element;
            }
        }

        try stdout.print("{},{}\n", numInsertions, fastest);
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
    return @floatToInt(usize, @intToFloat(f64, x+1) * 1.25);
}
