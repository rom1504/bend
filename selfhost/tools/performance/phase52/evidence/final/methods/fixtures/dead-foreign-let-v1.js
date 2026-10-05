// This source must never be initialized when its only request expression is dead.
console.log('phase52-unexpected-dead-initializer');
io_eff(CID(Ghost.request), () => 123);
