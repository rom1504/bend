# P73-009: reuse native prepared bodies

The new sharing certificate was re-erasing every reachable definition before
the existing static/native preparation already did the same work. Move the
certificate to ns_compile after validation/preparation and read its cached
compact body. Retain original annotated definitions for the type of each
occurrence. Literal/static compaction cannot introduce or hide variable uses;
closed static terms contain no free variables. Foreign/raw fallbacks retain
permission rules. This removes duplicated analysis without a new cache or IR.
Measure B1/B2 requests separately; verify emitted macro facts and all generated
bodies match the prior candidate modulo the relocated header block.
