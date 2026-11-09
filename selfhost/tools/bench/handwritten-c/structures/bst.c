/* Fueled zipper insertion and in-order fold from coverage-bst-32.bend. */
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct Tree Tree;
struct Tree { Tree *left; uint32_t value; Tree *right; };
typedef struct Frame Frame;
struct Frame { uint32_t value; Tree *other; bool left; Frame *rest; };

static Tree *node(Tree *left, uint32_t value, Tree *right) {
    Tree *tree = malloc(sizeof *tree);
    if (tree == NULL) abort();
    tree->left = left;
    tree->value = value;
    tree->right = right;
    return tree;
}

static Frame *push(uint32_t value, Tree *other, bool left, Frame *rest) {
    Frame *frame = malloc(sizeof *frame);
    if (frame == NULL) abort();
    frame->value = value;
    frame->other = other;
    frame->left = left;
    frame->rest = rest;
    return frame;
}

static Tree *insert(uint64_t fuel, uint32_t value, Tree *tree) {
    Frame *path = NULL;
    /* bst.down takes every fuel step, including steps already at BLeaf. */
    while (fuel != 0) {
        --fuel;
        if (tree != NULL) {
            bool left = value < tree->value;
            Tree *child = left ? tree->left : tree->right;
            Tree *other = left ? tree->right : tree->left;
            path = push(tree->value, other, left, path);
            free(tree);
            tree = child;
        }
    }
    if (tree == NULL) {
        tree = node(NULL, value, NULL);
    } else {
        /* insert.fin preserves an occupied subtree when fuel is insufficient. */
        Tree *previous = tree;
        tree = node(previous->left, previous->value, previous->right);
        free(previous);
    }
    while (path != NULL) {
        Frame *frame = path;
        path = frame->rest;
        tree = frame->left ? node(tree, frame->value, frame->other)
                           : node(frame->other, frame->value, tree);
        free(frame);
    }
    return tree;
}

static uint32_t inorder(Tree *tree, uint32_t accumulator) {
    if (tree == NULL) return accumulator;
    Tree *left = tree->left;
    uint32_t value = tree->value;
    Tree *right = tree->right;
    free(tree);
    uint32_t prefix = inorder(left, accumulator);
    uint32_t next = (uint32_t)(prefix * UINT32_C(10) + value);
    return inorder(right, next);
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
    Tree *tree = NULL;
    uint64_t fuel = (uint64_t)a + UINT64_C(1);
    uint32_t stride = (uint32_t)(b * UINT32_C(2) + UINT32_C(1));
    for (uint32_t i = 0; i < a; ++i) {
        uint32_t word = (uint32_t)(i * stride + b);
        tree = insert(fuel, word % UINT32_C(257), tree);
    }
    return inorder(tree, 0);
}
