/* Adapted from bench/runtime/tree-bitonic/main.c; see NOTES.md.
 * Arena indices are tree edges, not an array sorting representation. */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

typedef uint64_t Tree;
#define TREE_LEAF (UINT64_C(1) << 32u)
#define TREE_NIL UINT32_MAX

typedef struct TreeNode {
  Tree left, right;
} TreeNode;

typedef struct TreeArena {
  TreeNode *items;
  size_t length, capacity;
  uint32_t free_head;
} TreeArena;

static uint32_t tree_push(TreeArena *arena, TreeNode value) {
  if (arena->free_head != TREE_NIL) {
    uint32_t index = arena->free_head;
    arena->free_head = (uint32_t)arena->items[index].left;
    arena->items[index] = value;
    return index;
  }
  if (arena->length >= UINT32_MAX)
    abort();
  if (arena->length == arena->capacity) {
    size_t capacity = arena->capacity ? arena->capacity * 2u : 1024u;
    if (capacity < arena->capacity || capacity > UINT32_MAX)
      capacity = UINT32_MAX;
    if (capacity > SIZE_MAX / sizeof(*arena->items))
      abort();
    TreeNode *items = realloc(arena->items, capacity * sizeof(*items));
    if (!items)
      abort();
    arena->items = items;
    arena->capacity = capacity;
  }
  uint32_t index = (uint32_t)arena->length++;
  arena->items[index] = value;
  return index;
}

static void tree_drop(TreeArena *arena, uint32_t index) {
  arena->items[index].left = arena->free_head;
  arena->free_head = index;
}

static Tree tree_leaf(uint32_t value) {
  return TREE_LEAF | value;
}

static int tree_is_leaf(Tree tree) {
  return (tree & TREE_LEAF) != 0u;
}

static Tree tree_node(TreeArena *arena, Tree left, Tree right) {
  return tree_push(arena, (TreeNode){left, right});
}

static uint32_t tree_prng(uint32_t x) {
  uint32_t b = x ^ (x << 13u);
  uint32_t d = b ^ (b >> 17u);
  return d ^ (d << 5u);
}

static uint32_t tree_key(uint32_t index) {
  return tree_prng((index + 1u) * UINT32_C(2654435761));
}

static Tree tree_warp_leaf(TreeArena *arena, uint32_t x, uint32_t y,
                           uint32_t descending) {
  if (descending ^ (x > y ? 1u : 0u))
    return tree_node(arena, tree_leaf(y), tree_leaf(x));
  return tree_node(arena, tree_leaf(x), tree_leaf(y));
}

static Tree tree_warp_zip(TreeArena *arena, Tree wa, Tree wb) {
  if (!tree_is_leaf(wa) && !tree_is_leaf(wb)) {
    uint32_t i = (uint32_t)wa, j = (uint32_t)wb;
    Tree a1 = arena->items[i].right;
    arena->items[i].right = arena->items[j].left;
    arena->items[j].left = a1;
    return tree_node(arena, wa, wb);
  }
  return tree_leaf(0u);
}

static Tree tree_warp(TreeArena *arena, Tree x, Tree y, uint32_t descending) {
  if (tree_is_leaf(x) && tree_is_leaf(y))
    return tree_warp_leaf(arena, (uint32_t)x, (uint32_t)y, descending);
  if (tree_is_leaf(x) != tree_is_leaf(y))
    return tree_leaf(0u);
  uint32_t i = (uint32_t)x, j = (uint32_t)y;
  TreeNode a = arena->items[i], b = arena->items[j];
  tree_drop(arena, i);
  tree_drop(arena, j);
  Tree wa = tree_warp(arena, a.left, b.left, descending);
  Tree wb = tree_warp(arena, a.right, b.right, descending);
  return tree_warp_zip(arena, wa, wb);
}

static Tree tree_warp_node(TreeArena *arena, Tree tree, uint32_t descending) {
  if (tree_is_leaf(tree))
    return tree;
  uint32_t index = (uint32_t)tree;
  TreeNode node = arena->items[index];
  tree_drop(arena, index);
  return tree_warp(arena, node.left, node.right, descending);
}

static Tree tree_flow(TreeArena *arena, uint32_t depth, uint32_t descending, Tree warped) {
  if (depth == 0u || tree_is_leaf(warped))
    return warped;
  uint32_t index = (uint32_t)warped;
  TreeNode node = arena->items[index];
  Tree left = tree_flow(arena, depth - 1u, descending,
                        tree_warp_node(arena, node.left, descending));
  Tree right = tree_flow(arena, depth - 1u, descending,
                         tree_warp_node(arena, node.right, descending));
  arena->items[index] = (TreeNode){left, right};
  return warped;
}

static Tree tree_bsort(TreeArena *arena, uint32_t depth, uint32_t descending, uint32_t index) {
  if (depth == 0u)
    return tree_leaf(tree_key(index));
  Tree left = tree_bsort(arena, depth - 1u, 0u, index * 2u + 1u);
  Tree right = tree_bsort(arena, depth - 1u, 1u, index * 2u);
  return tree_flow(arena, depth - 1u, descending, tree_warp(arena, left, right, descending));
}

typedef struct TreeStat {
  uint32_t lo, hi, ok, mix;
} TreeStat;

static TreeStat tree_scan(const TreeArena *arena, Tree tree) {
  if (tree_is_leaf(tree)) {
    uint32_t value = (uint32_t)tree;
    return (TreeStat){value, value, 1u, value};
  }
  TreeNode node = arena->items[(uint32_t)tree];
  TreeStat left = tree_scan(arena, node.left);
  TreeStat right = tree_scan(arena, node.right);
  return (TreeStat){left.lo, right.hi,
    left.hi <= right.lo ? left.ok & right.ok : 0u,
    left.mix * UINT32_C(2654435761) + right.mix};
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
  TreeArena arena = {NULL, 0u, 0u, TREE_NIL};
  Tree tree = tree_bsort(&arena, a, 0u, b);
  TreeStat stat = tree_scan(&arena, tree);
  uint32_t result = ((stat.mix * UINT32_C(2654435761)) ^
                    (stat.hi + stat.lo * UINT32_C(340573321))) +
                   stat.ok * UINT32_C(2246822519);
  /* Owns every live and consumed node; no storage survives an invocation. */
  free(arena.items);
  return result;
}
