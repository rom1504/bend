import * as fs from "node:fs";
import * as Bend from "/home/ai/bend2_agy/bend2/bend.ts";
import * as Comp from "./comp_mod.ts";

const [srcFile, rootsFile, skipFlatFile, noEmitFile, outFile] = process.argv.slice(2);
const roots = fs.readFileSync(rootsFile, "utf8").split("\n").map((s) => s.trim()).filter(Boolean);
const skipFlat = new Set(fs.readFileSync(skipFlatFile, "utf8").split("\n").map((s) => s.trim()).filter(Boolean));
const noEmit = new Set(fs.readFileSync(noEmitFile, "utf8").split("\n").map((s) => s.trim()).filter(Boolean));
const t0 = performance.now();
const book = Bend.book_nil();
try {
  await Bend.book_load(book, srcFile, "", new Map());
} catch (e: any) {
  console.error("LOAD_ERR:", e?.msg ?? e?.message ?? String(e));
  process.exit(1);
}
const t1 = performance.now();
try {
  Bend.book_valid(book, 0);
} catch (e: any) {
  console.error("VALID_ERR:", e?.msg ?? e?.message ?? String(e), "def:", e?.def ?? "");
  process.exit(1);
}
const t2 = performance.now();
const c = Comp.compile_module(book, roots, skipFlat, noEmit);
const t3 = performance.now();
fs.writeFileSync(outFile, c);
const rss = (process.memoryUsage().rss / 1048576).toFixed(0);
console.error(`emit_mod_c ${srcFile}: load=${((t1-t0)/1000).toFixed(2)}s valid=${((t2-t1)/1000).toFixed(2)}s emit=${((t3-t2)/1000).toFixed(2)}s total=${((t3-t0)/1000).toFixed(2)}s rss=${rss}MiB bytes=${c.length}`);
