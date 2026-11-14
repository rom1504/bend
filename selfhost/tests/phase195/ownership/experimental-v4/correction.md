# V4 correction: unmatched parenthesis in preceding declaration

Preserved API02 failure:
`selfhost/build/phase195/owned-diagnostic-api02/stderr` reports expected ':' at
frozen `owned-diagnostic-api-source02/compiler.bend:52977`, the start of
p195od_rebase_facts. The actual defect is in preceding p195oa_match_fields:
p195oa_match_join was not closed before the outer nt_choose false lambda.
That left one opening parenthesis at declaration end and shifted the parser's
failure location into the next declaration. The source-block origin is
experimental-v3/proof.bend:42; the frozen manifest records that same module.

V4 adds exactly one ')' there. Layout, evaluator and ordinary BST Bend sources
are byte-identical to v3. No function or admission rule was added or broadened.

Per-declaration lexical preflight covers all four Bend files: balanced
parentheses/braces/brackets after stripping strings/comments, def/law header
colons, law binder annotations, and @unsafe-to-def adjacency. The match-site
inventory is rerun unchanged. Both inventories report zero issues. They are
static aids, not compiler acceptance. No compiler/target execution ran here;
all consumed earlier versions and source-check failures remain preserved.
