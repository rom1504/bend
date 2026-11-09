// Diagnostic observer only; exact upstream checker, no alternative semantics.
import * as B from '../../.bootstrap/upstream-phase182/bend2/bend.ts';
try {
  const book=B.book_nil();
  await B.book_load(book,process.argv[2],'',new Map());
  B.book_valid(book);
  console.log(JSON.stringify({valid:true,holes:book.hols}));
} catch(e) {
  console.log(JSON.stringify({valid:false,definition:e.def,expected:e.exp,observed:e.obs,
    around:e.spn?.file?.str?.slice(Math.max(0,e.spn.beg-250),e.spn.beg+250)}));
  process.exitCode=1;
}
