# Source index

A small Bend command-line tool that reads a source file at runtime and prints
a deterministic tab-separated inventory. It lists column-one `def`, `type`,
and `import` declarations in source order, including duplicate names and their
one-based line numbers. The summary counts UTF-8 bytes, Unicode characters,
physical lines, comment-bearing lines, and declarations. An unfinished quoted
string or character literal is reported explicitly.

After compiling `main.bend` to an application executable, run:

```sh
./source-index --file path/to/source.bend
```

For a native executable with runtime options, place application arguments after
the runtime separator:

```sh
./source-index --threads 1 --gpu off -- --file path/to/source.bend
```

The app finds the explicit `--file` marker so it works whether `IO.args` includes
the executable name or starts with application arguments. The following argument
is the filename; later arguments are ignored. Missing arguments print usage.

`fixtures/sample.bend` demonstrates comments, quoted false positives, an import,
a type, and functions. The first output line is `format\tbend-source-index-v1`;
summary rows precede a `kind\tline\tname` table. Table names escape backslashes,
tabs, and carriage returns. Output ends in one newline and never includes the
input path, making comparisons across copied files straightforward.

## Independent oracle and fixtures

The Python implementation uses line splitting and regular-expression token
recognition independently of the Bend character-state implementation. It requires
only the Python standard library:

```sh
python3 oracle.py fixtures/sample.bend
python3 oracle.py --self-check
python3 oracle.py --generate /tmp/source-index-input.bend --definitions 512
```

The shared runner imports `oracle.py` and calls
`cases(out_dir, depth='smoke'|'survey')`. It creates input files and returns a list
of dictionaries with `id`, `argv`, full newline-exact `expected` stdout, and
`input_files`. Smoke covers the sample, UTF-8 with a BOM and CRLF, empty input, and
missing CLI arguments. Survey adds multiline/escaped quotes, an unfinished quote,
generated modules with 512, 4,096, and 10,000 definitions, real repository Base
and tool source files, the selected native compiler's Bend source, and a missing
file. Base and tool copies remain bounded to 1 MiB each; the compiler copy uses
the application's 8 MiB limit. The compiler source is discovered through
`selfhost/tools/native/selection.json`, its admission, and the admission's source
descriptor. The oracle verifies the admission and source byte counts and SHA-256
hashes before copying; the case records the original path and those identities.

## Scope and limitations

This is a lexical inventory, not a Bend parser or type checker. Only declarations
starting in column one are indexed; an initial UTF-8 BOM is permitted. Names
contain ASCII letters, digits, `_`, `.`, or non-ASCII characters. A quoted first
operand is retained with its quotes and escapes. Syntax validity, nested
declarations, import resolution, and duplicate-name validity are not checked.
Lines inside single- or double-quoted text are skipped; backslash escapes are
recognized and `#` starts a comment outside quotes. Other comment syntaxes are
not supported. Only LF ends a physical line; CR remains part of the character
count. Empty input has zero lines and a final LF does not add an empty line.

Inputs must be ordinary, stable UTF-8 text files no larger than 8 MiB. The app
uses `File.size`, performs one read of that size plus one byte, closes the file,
and compares the decoded characters' UTF-8 widths with the byte size. It does
not compare character count with byte count. This catches a short read and many
file changes but does not provide a filesystem snapshot; same-size edits can
escape detection. Malformed UTF-8 behavior depends on the runtime decoder and
is outside this tool's supported input contract. The whole decoded file and
output are held in memory.

Open, size, read, oversize, and read-size failures print `error` followed by a tab
and a stable reason. The supported IO surface does not provide an exit-status
operation here, so callers should check the output rather than rely on a nonzero
process status. The only effects used are `IO.args`, `IO.print`, and
`File.open/read/size/close`.
