// Preserve legacy text if a retained lexer coordinate does not name its token.
import fs from'node:fs';import path from'node:path';import assert from'node:assert/strict';import{createHash}from'node:crypto';
const file=path.resolve(process.argv[2]),report=path.resolve(process.argv[3]),hash=x=>createHash('sha256').update(x).digest('hex');const before=fs.readFileSync(file,'utf8');let after=before;
const changes=[
 ['[kt("ParseExpected", expected, 0, 0, Nil{})]), Nil{}}','[kt("ParseExpected", expected, 0, 0, Nil{}), kt("ParseToken", f_tx(ts), 0, 0, Nil{})]), Nil{}}'],
 ['String.eq(tg(kid(error, 0)), "ParseExpected") && U32.is_gt(ix(error), 0)','String.eq(tg(kid(error, 0)), "ParseExpected") && String.eq(tg(kid(error, 1)), "ParseToken") && U32.is_gt(ix(error), 0)'],
 ['u => fpe_message(source, error, "end of input"), u => f_choose(String,','u => f_choose(String, String.eq(nm(kid(error, 1)), "<eof>"), u => fpe_message(source, error, "end of input"), u => nm(error)), u => f_choose(String,'],
 ['U32.is_gt(Char.to_u32(f_head(rest)), 65535) || (','Bool.not(U32.is_eq(Char.to_u32(f_head(rest)), Char.to_u32(f_head(nm(kid(error, 1)))))) || U32.is_gt(Char.to_u32(f_head(rest)), 65535) || (']
];for(const[a,b]of changes){assert.equal(after.split(a).length,2,a);after=after.replace(a,b);}
fs.writeFileSync(report+'.before.bend',before,{flag:'wx'});fs.writeFileSync(report,JSON.stringify({kind:'phase5-parser-coordinate-guard',before:{file:report+'.before.bend',sha256:hash(before)},after:{file,sha256:hash(after)},tool:{file:import.meta.filename,sha256:hash(fs.readFileSync(import.meta.filename))},changes},null,2)+'\n',{flag:'wx'});fs.writeFileSync(file,after);
