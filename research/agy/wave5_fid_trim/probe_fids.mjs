import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";

const apiPath = path.resolve(process.argv[2]);
const srcPath = path.resolve(process.argv[3]);
const basePath = "/home/ai/bend2_agy/selfhost/dist/base.bend";
const carrierPath = "/home/ai/bend2_agy/selfhost/build/agy/bootstrap/base.p130";
const baseStampPath = "/home/ai/bend2/build/publish/bend/selfhost/.bootstrap/upstream-phase182/bend2/base.bend";
const stamp = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212";

const t0 = performance.now();
const mod = await import(pathToFileURL(apiPath).href);
const api = mod.default || mod;
const baseText = fs.readFileSync(basePath, "utf8");
const carrierText = fs.readFileSync(carrierPath, "utf8");
const srcText = fs.readFileSync(srcPath, "utf8");

const prep = api.p88_cache_prepare(baseStampPath, baseText, carrierText, stamp);
if (prep.$ !== "P86PreparationReady") {
  console.error("prep failed:", prep);
  process.exit(1);
}
const t1 = performance.now();
const plan = api.p86_plan(prep.seed, srcPath, srcText);
const t2 = performance.now();
if (plan.$ !== "P86PlanReady") {
  console.error("plan failed:", plan);
  process.exit(1);
}
const lowered = api.p168_request_mode(1, plan.request);
const t3 = performance.now();

function listToArr(xs) {
  const out = [];
  while (xs && xs.$ === "Con") { out.push(xs.head); xs = xs.tail; }
  return out;
}

const stats = listToArr(lowered.stats);
console.log(`Source: ${srcPath} (${srcText.length} B)`);
console.log(`Timing: prep=${(t1-t0).toFixed(0)}ms  plan=${(t2-t1).toFixed(0)}ms  lower=${(t3-t2).toFixed(0)}ms  total=${(t3-t0).toFixed(0)}ms`);
console.log(`Error: ${JSON.stringify(lowered.error)}`);
console.log(`Stats [names, directFns, families, factories, wrappers, segments, demands]:`, stats);
console.log(`EXACT N111Segment count: ${stats[5]} / 65531  (delta = ${stats[5] - 65531})`);
process.exit(0);

// Categorize segments
const cats = new Map();
const byPref = new Map();
for (const s of segs) {
  const nm = s.name;
  let cat = "named_def";
  if (nm.startsWith("$p111.k.")) cat = "$p111.k";
  else if (nm.startsWith("$direct.")) cat = "$direct";
  else if (nm.startsWith("$")) cat = nm.split(".")[0];
  cats.set(cat, (cats.get(cat) || 0) + 1);
  if (cat === "$direct" || cat === "named_def") {
    const clean = nm.startsWith("$direct.") ? nm.slice(8) : nm;
    const pref = clean.includes("_") ? clean.split("_")[0] : clean.slice(0, 6);
    byPref.set(pref, (byPref.get(pref) || 0) + 1);
  }
}
console.log("Segment categories:");
for (const [k, v] of [...cats.entries()].sort((a, b) => b[1] - a[1])) {
  console.log(`  ${k.padEnd(20)}: ${v}`);
}
console.log("Top 15 named+$direct prefixes:");
for (const [k, v] of [...byPref.entries()].sort((a, b) => b[1] - a[1]).slice(0, 15)) {
  console.log(`  ${k.padEnd(20)}: ${v}`);
}
