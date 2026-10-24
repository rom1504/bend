# P131-007 — prove reflexivity, avoid an owning equality fallback

Status: useful unqualified whole-compiler ceiling; not in selected Bend source.

Exact String/Char reflexivity laws were independently accepted, with a source
bridge. Runtime identity is an additional premise: equal full Term bits must
denote the same live immutable String. The optional pending comparison must be
True. Both original owning root releases remain; alias guards/fallbacks stay.
This is not an arbitrary Term or F32 equality rule.

The private-reader shortcut saves only0.28% on the use-query proxy. The public
owning shortcut saves20.01% on the index proxy. The full frozen N2 QBE ceiling
changes exactly two of63,239 functions and875 bytes. Eighteen rotating clean
compiler requests retain exact independent QBE outputs: lexer6.58% less time,
closures2.21% less, Map0.12% more; geometric time reduction2.93%.

Do not apply the20% proxy result to compiler throughput or multiply this block
into a separately measured upstream ratio. A checked Bend implementation needs
exact source/dependency admission, not a function-name recognizer. No installed
change or complete native qualification is claimed for this ceiling.

The first offline summary used the wrong report-schema field and failed after
all target observations passed. A separate version authenticates the actual
manifest input pin; no target was rerun or frozen preparer modified.

[Research](../../research/phase131/reader-identity.md) ·
[Checked hook proposal](../../research/phase131/identity-hook.md).
