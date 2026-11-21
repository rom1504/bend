# Fusing a character split followed by a join

The two native45 Unicode text workloads construct a string by repeating a dynamic block, split at a character, then join the pieces with a separator string. A split preserves leading, consecutive and trailing empty pieces. Joining those pieces is equivalent to emitting the separator on each matching character and the original character on each other step. This identity holds for empty, multi-character and delimiter-containing separators as well as arbitrary Unicode strings.

The first Bend implementation fuses the split and join into one traversal of the input. The second exploits the fact that replacement distributes over concatenation, applying the replacement to the dynamic block **once** before repeating it. Both preserve the dynamic size and seed, full resulting string, and the benchmark's existing validation. The replacement body is general. The source adapter is a diagnostic instantiation of the law at two known sites. Automatic admission by the native compiler is a further step.

The screen source-checks both variants, compiles them with the real Phase199 N1 and links its normal runtime. It compares five full returned strings to an independent Python calculation for each variant and both baseline compilers, then measures four roles in balanced positions. Run from the repository root on the assigned lane.

```sh
python3 -B research/phase200/measure/job.py text01 52 12 \
  python3 -B research/phase200/text/screen.py --out selfhost/build/phase200/text01
```

[Sequence theorem and finite controls](../text-laws/README.md)
