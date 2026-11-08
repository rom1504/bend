function number(n) {
  if(typeof n!=='number')throw Error('Nat host argument is not Number');
  if(CID(number)!==FID(number)||!FID(number).includes(':'))throw Error('qualified effect identity lost');
  return n+1;
}
function character(c) {
  if(c!=='\ufffd')throw Error('non-scalar Char escaped its host boundary');
  return '\ud800';
}
function scalar() { return 1.00000008; }
function box() {
  if(CID(Box)!=='Box')throw Error('constructor namespace was not removed');
  return {$:CID(Box),value:9};
}
io_eff(CID(number),number);
io_eff(CID(character),character);
io_eff(CID(scalar),scalar);
io_eff(CID(box),box);
