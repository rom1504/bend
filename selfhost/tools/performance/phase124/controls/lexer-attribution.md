# Lexer workload: generation, not a changed lexing core

Root's static exact-body comparison is recorded in `lexer-attribution.json`.
Only three existing public QBE bodies change: String.order, String.cmp.fin, gen.
Each gains a private local-table worker. The complete private lex/expand QBE
bodies are byte-identical between Phase123 and ready-resume source01.

The frozen source's timed path is p93.loop → p93.value → bench → batch → line.
`line(i) = lex(gen(tpl(),seed(i),0),(Gap{},0))`; generation is deliberately inside
each timed iteration. `gen` recurses over the template, then calls gen.at/expand
to prepend the expanded character/identifier/number to the generated suffix.
The new verified-complete callable view allows that helper inside a local region.
This is a distinct ordering from RLE's helper-before-recursion/resume shape.

Thus the measured32.9% focused improvement is valid for the frozen combined
**generate-and-lex workload**. It does not demonstrate32.9% faster tokenization
on prebuilt input, nor that the new ResumeReady variant alone causes the gain.
The callable-catalogue bridge and local continuation selection are both part of
this experiment. No new sampling profile or isolated generator ablation was run;
machine-layout effects and the precise contribution of other changed routines
have not been independently quantified.
