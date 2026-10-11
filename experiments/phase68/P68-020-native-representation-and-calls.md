# P68-020: extend native representation and call facts

Prospective design: [native facts and calls](../../design/phase68/native-facts-and-calls.md).
Compiler20 tree/lexer/Map/closure runtime ratios are3.35/2.57/1.85/1.78 versus
upstream. Inspect actual generated code before selecting a mechanism. Hypotheses:
private product transport can remove residual temporary boxes, and known closure
flows can use ordinary workers with explicit captures. No gain is assumed from
old compiler06 coverage counts. Preserve finite oracles, ownership and bounded
stack; refuse speculative changes without an active path and measured benefit.
