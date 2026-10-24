package leaf
type Record struct { Value int }
const K = 3
//go:noinline
func Value() int { return hidden() }
//go:noinline
func hidden() int { return 1 }
func Tiny() int { return 2 }
func Read(r Record) int { return r.Value }
