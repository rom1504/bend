package mid
import "example.invalid/p132/leaf"
func Sum() int { return leaf.Value() + leaf.Tiny() + leaf.Read(leaf.Record{Value: leaf.K}) }
