# Phase106 Cranelift consumer

This is an isolated research adapter, not an installed Bend compiler/backend.
The compiler/IR producer stays in Bend. This Rust executable consumes its
version1 structured native IR and emits an ELF object through pinned
Cranelift0.121.2. No Rust runtime is linked into the generated executable.

The same IR is consumed by the companion C emitter. This comparison isolates
machine-code generation from Bend parsing/checking and general native lowering.
Extracted workloads cannot establish full-compiler portability or speed.

## Build and run

Root schedules builds serially under the experiment resource guard. With the
manifest directory as current directory:

```sh
CARGO_INCREMENTAL=0 cargo build --release --jobs 1
path/to/bend-native-ir-cranelift input.json output.o speed
cc -O2 runner.c output.o -o output
./output 1000 7
./output --repeat 10000 1000 7
```

`none`, `speed` and `speed_and_size` select Cranelift optimization effort.
Record adapter/toolchain construction separately from per-input object
generation and native link time. The adapter JSON receipt measures its own
input-to-object operation; it excludes process startup, linking and execution.
The authoritative benchmark harness must measure those stages independently.
Dependency acquisition and the first adapter build are not free warmup costs.

## Version1 contract

Top level: `{version:1,entry:"main",functions:[...]}`. A function has `name`,
`params:[{name,type}]`, `result`, `locals:[{name,type}]`, and `body:[...]`.
Types are `u32`, `u64`, `ptr`. All locals start at typed zero. Arithmetic wraps
at its declared width; right shift is unsigned and shift counts are masked
by width minus one. Comparisons return `u32` zero or one. Arguments and local
variables may be assigned. Control flow is structured `if` and `while`.

Expressions use a `kind` discriminator:

- `const`: `value`, `type` (only zero is permitted as a pointer literal).
- `var`: `name`.
- `bin`: `op`, `lhs`, `rhs`; supported operations are `add`, `sub`, `mul`,
  `and`, `or`, `xor`, `shl`, `lshr`, `eq`, `ne`, `ult`, `ule`, `ugt`, `uge`.
  Pointers support only equality/inequality, not ordering or integer operators.
- `ptradd`: `ptr`, `bytes`; byte count is `u32`.
- `call`: `name`, `args`.
- `func`: `name` returns the address of a declared private function.
- `icall`: `callee`, `args`, `params:[type]`, `result`.
- `alloc`: `bytes` (`u32`); zeroed allocation, minimum one byte, abort on failure.
- `load`: `ptr`, `offset` (nonnegative constant byte offset), `type`.

Statements: `set(name,value)`, `if(cond,then,else)`, `while(cond,body)`,
`return(value)`, `store(ptr,offset,value,type)`, `free(ptr)`. Calls, allocation,
and loads are permitted only at an expression root; operands and call arguments
must be pure. This prevents C's unspecified argument evaluation order from
creating a backend difference. Function result types and call arities are
checked. Functions must return on all paths; post-return statements are refused.
Unknown fields/kinds are refused, not silently ignored.

All private direct/indirect calls use the host C ABI. A return of a call is
**not** a guaranteed tail call. Self-tail recursion is explicitly represented
as a `while` loop. Mandatory/mutual tail transfers, GPU, parallel tasks,
production Bend ownership, FFI capabilities and fail-stop semantics are outside
v1 and require a future explicit contract.

Memory operations concern trusted extracted fixtures. Type checks do not prove
pointer bounds, alignment, function-pointer signature validity, lifetime or
alias ownership. The common allocation ABI is libc `calloc`, `free`, `abort`.
These are not the production Bend runtime or its ownership representation.
Cranelift's verifier checks its own IR; it is not a proof of source semantics.

## Executable boundary

The object exports `uint32_t phase106_entry(const uint64_t *args)` and constant
`uint32_t phase106_arity`. Entry parameters are scalar and its result is `u32`.
The common runner parses one unsigned decimal argument per entry parameter and
prints the result. Optional `--repeat N` invokes the entry N times with identical
arguments and prints the wrapping `u32` sum, forcing consumption of every call.
`--expect U32` independently checks every returned value and exits nonzero on
the first mismatch. The two options can appear in either order before entry
arguments; duplicates are refused. Timing runs must supply the independent
expected value: a checksum alone is insufficient, because repeated incorrect
values can collide modulo2^32. Zero repetitions make no execution claim.
Both generated backends link this identical runner; no timing occurs inside it.
A `u32` entry parameter takes the low32 bits of its argument.
`u64` parameters retain all64 bits. Workload sizes remain ordinary IR arguments;
the caller controls repetitions with the same loop/checksum for each backend.

Use an external timeout/RSS guard for every generated executable. JSON input
is limited to16MiB and1024 functions; this is an experimental resource bound,
not an untrusted-code sandbox. Always run type/rejection controls, independently
computed semantic oracles and paired C/Cranelift executions before interpreting
performance. See the Phase106 report for actual completed evidence.
