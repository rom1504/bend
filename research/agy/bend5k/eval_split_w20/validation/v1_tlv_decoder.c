#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    TLV_HDR = 0,
    TLV_U32 = 1,
    TLV_PAIR = 2,
    TLV_XOR = 3,
    TLV_SHIFT = 4,
    TLV_CRC = 5,
    TLV_SKIP = 6,
    TLV_END = 7
} TlvTag;

typedef struct Packet {
    TlvTag tag;
    uint32_t a;
    uint32_t b;
    struct Packet *next;
} Packet;

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static Packet *build_packets(uint32_t n, uint32_t seed, int skew) {
    Packet *acc = NULL;
    for (uint32_t i = 0; i < n; i++) {
        uint32_t s1 = prng(seed);
        uint32_t s2 = prng(s1);
        uint32_t s3 = prng(s2);
        seed = s3;
        uint32_t raw_tag;
        if (skew) {
            uint32_t m = s1 & 15u;
            if (m < 4u) raw_tag = 1u;
            else if (m < 8u) raw_tag = 2u;
            else if (m < 12u) raw_tag = 3u;
            else raw_tag = (m - 12u) * 2u; /* 0, 2, 4, 6 -> wait, let's match Bend exactly */
        } else {
            raw_tag = s1 & 7u;
        }
        /* Match Bend's exact skew mapping */
        if (skew) {
            uint32_t m = s1 & 15u;
            if (m < 4u) raw_tag = 1u;
            else if (m < 8u) raw_tag = 2u;
            else if (m < 12u) raw_tag = 3u;
            else if (m == 12u) raw_tag = 0u;
            else if (m == 13u) raw_tag = 4u;
            else if (m == 14u) raw_tag = 5u;
            else raw_tag = 7u;
        }
        Packet *p = (Packet *)malloc(sizeof(Packet));
        p->tag = (TlvTag)raw_tag;
        if (raw_tag == 0u) {
            p->a = (s2 & 15u) + 1u;
            p->b = s3 & 255u;
        } else if (raw_tag == 4u) {
            p->a = (s2 & 7u) + 1u;
            p->b = s3;
        } else {
            p->a = s2;
            p->b = s3;
        }
        p->next = acc;
        acc = p;
    }
    return acc;
}

static uint32_t run_decode(uint32_t iters, const Packet *head) {
    uint32_t crc = 2166136261u;
    uint32_t seq = 1u;
    uint32_t acc = 7u;
    uint32_t err = 0u;
    for (uint32_t r = 0; r < iters; r++) {
        for (const Packet *p = head; p != NULL; p = p->next) {
            switch (p->tag) {
                case TLV_HDR:
                    crc = (crc ^ p->a) * 16777619u;
                    seq = seq + p->b + 1u;
                    break;
                case TLV_U32:
                    acc = acc + (p->a ^ p->b);
                    crc = crc ^ (acc * 2654435761u);
                    break;
                case TLV_PAIR:
                    acc = (acc ^ p->a) + p->b;
                    seq = seq + 1u;
                    break;
                case TLV_XOR:
                    crc = crc ^ (p->a & p->b);
                    acc = acc ^ p->b;
                    break;
                case TLV_SHIFT:
                    acc = acc ^ (p->b >> p->a) ^ (p->b << p->a);
                    break;
                case TLV_CRC:
                    crc = ((crc ^ p->a) * 2654435761u) ^ p->b;
                    break;
                case TLV_SKIP:
                    err = err + (p->a & 3u);
                    break;
                case TLV_END:
                    crc = crc ^ p->a ^ seq ^ err;
                    seq = seq + 7u;
                    break;
            }
        }
    }
    return (crc ^ acc) ^ (seq + err);
}

int main(int argc, char **argv) {
    int skew = (argc > 1 && strcmp(argv[1], "skew") == 0);
    uint32_t n = skew ? 512u : 320u;
    uint32_t iters = skew ? 12000u : 18000u;
    uint32_t seed = skew ? 987654321u : 123456789u;
    Packet *pkts = build_packets(n, seed, skew);
    uint32_t res = run_decode(iters, pkts);
    printf("%u\n", res);
    while (pkts) {
        Packet *nxt = pkts->next;
        free(pkts);
        pkts = nxt;
    }
    return 0;
}
