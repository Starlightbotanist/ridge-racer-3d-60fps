#include "matrix.h"

typedef unsigned int u32;

enum { CAPACITY = 1024, BUCKETS = 256, AMBIGUOUS = 1, OUTPUT_VALID = 2 };

typedef struct Entry {
    volatile u32 source;
    u32 owner;
    u32 owner_resource;
    u32 render_context;
    struct Entry* next;
    Matrix previous;
    Matrix current;
    Matrix output;
} __attribute__((aligned(64))) Entry;

typedef struct {
    u32 owner;
    u32 render_context;
    u32 thread_tls;
    u32 generation;
    u32 count;
    u32 reserved[11];
    Entry* buckets[BUCKETS];
    Entry entries[CAPACITY];
} Cache;

#define CACHE ((Cache*)0x47e000)
#define PHASE (*(volatile u32*)0x47cfc4)
#define GENERATION (*(volatile u32*)0x47cfc0)
#define SKIP (*(volatile u32*)0x47cfbc)

int render_half(Matrix* out, const Matrix* current, const Matrix* previous);

__attribute__((noinline)) u32 owner_resource(void) {
    /* Point owners use their vtable as the identity. */
    u32 owner = CACHE->owner;
    return owner & 1 ? *(const u32*)(owner & ~1u) : *(const u32*)(owner + 8);
}

__attribute__((noinline)) u32 render_phase(void) {
    u32 tls;
    __asm__ volatile("mrc p15, 0, %0, c13, c0, 3" : "=r"(tls));
    return tls == CACHE->thread_tls ? PHASE : 0;
}

_Static_assert(sizeof(Entry) == 192, "Entry stride");
_Static_assert(__builtin_offsetof(Entry, owner_resource) == 8, "Owner resource offset");
_Static_assert(__builtin_offsetof(Entry, previous) == 20 &&
               __builtin_offsetof(Entry, current) == 68 &&
               __builtin_offsetof(Entry, output) == 116, "Matrix offsets");
_Static_assert(__builtin_offsetof(Cache, owner) == 0 &&
               __builtin_offsetof(Cache, render_context) == 4 &&
               __builtin_offsetof(Cache, thread_tls) == 8, "Hook state offsets");
_Static_assert(__builtin_offsetof(Cache, buckets) == 64, "Bucket offset");
_Static_assert(__builtin_offsetof(Cache, entries) == 1088, "Entry offset");
_Static_assert(0x47e000 + sizeof(Cache) <= 0x47cfb0 + 0x32000,
               "Expanded BSS capacity");

void copy_matrix(Matrix* out, const Matrix* input);

int equal_matrix(const Matrix* a, const Matrix* b);

__attribute__((noinline)) unsigned bucket(u32 source) {
    return ((source >> 4) ^ (source >> 12) ^ (CACHE->owner >> 4) ^
            (CACHE->render_context >> 4)) & (BUCKETS - 1);
}

__attribute__((noinline)) Entry* find_entry(u32 source, Entry* entry) {
    for (; entry; entry = entry->next)
        if ((entry->source & ~3u) == source && entry->owner == CACHE->owner &&
            entry->render_context == CACHE->render_context &&
            entry->owner_resource == owner_resource())
            return entry;
    return 0;
}

__attribute__((noinline)) void begin_frame(u32 generation) {
    if (CACHE->generation != generation) {
        CACHE->count = 0;
        for (unsigned i = 0; i < BUCKETS; ++i)
            CACHE->buckets[i] = 0;
        CACHE->generation = generation;
    }
}

__attribute__((noinline)) void store_matrix(u32 key, const Matrix* source, unsigned index) {
    Entry* entry = find_entry(key, CACHE->buckets[index]);
    if (!entry) {
        if (CACHE->count == CAPACITY)
            return;
        entry = &CACHE->entries[CACHE->count];
        entry->source = 0;
        entry->owner = CACHE->owner;
        entry->render_context = CACHE->render_context;
        entry->owner_resource = owner_resource();
        entry->next = CACHE->buckets[index];
        copy_matrix(&entry->previous, source);
        CACHE->buckets[index] = entry;
        ++CACHE->count;
        __asm__ volatile("mcr p15, 0, %0, c7, c10, 5" : : "r"(0) : "memory");
        entry->source = key;
    } else if (!equal_matrix(&entry->previous, source)) {
        entry->source |= AMBIGUOUS;
        copy_matrix(&entry->previous, source);
    }
}

__attribute__((noinline)) const Matrix* interpolate(Entry* entry, const Matrix* source) {
    if (entry->source & AMBIGUOUS)
        return source;
    if (entry->source & OUTPUT_VALID) {
        if (equal_matrix(&entry->current, source))
            return &entry->output;
        entry->source |= AMBIGUOUS;
        return source;
    }
    copy_matrix(&entry->current, source);
    if (equal_matrix(&entry->previous, source) ||
        !render_half(&entry->output, source, &entry->previous))
        copy_matrix(&entry->output, source);
    entry->source |= OUTPUT_VALID;
    return &entry->output;
}

__attribute__((noinline)) const Matrix* choose_value_matrix(u32 key, const Matrix* source, u32 phase) {
    unsigned index = bucket(key);
    u32 generation = GENERATION;
    if (phase == 2 || SKIP) {
        begin_frame(generation);
        store_matrix(key, source, index);
        return source;
    }
    if (CACHE->generation + 1 != generation)
        return source;
    Entry* entry = find_entry(key, CACHE->buckets[index]);
    return entry ? interpolate(entry, source) : source;
}

__attribute__((noinline)) const Matrix* choose_owned_matrix(const Matrix* source, u32 phase) {
    return choose_value_matrix((u32)source, source, phase);
}

__attribute__((noinline)) const Matrix* choose_matrix(const Matrix* source, u32 caller) {
    u32 phase = PHASE;
    if (!phase || (u32)source - 0x08000000 >= 0x06000000 || ((u32)source & 3))
        return source;
    if (caller == 0x21d2ac || caller == 0x21d2fc) {
        u32 camera = (u32)source - 0x148;
        if (camera < 0x08000000)
            return source;
        /* Camera history is independent of the bound model. */
        u32 model_owner = CACHE->owner;
        u32 render_context = CACHE->render_context;
        CACHE->owner = camera;
        CACHE->render_context = 0;
        const Matrix* result = choose_owned_matrix(source, phase);
        CACHE->owner = model_owner;
        CACHE->render_context = render_context;
        return result;
    }
    if (!CACHE->owner || (caller != 0x2191f4 && caller != 0x3547b8 &&
                         caller != 0x35d3a4 && caller != 0x3547cc &&
                         caller != 0x34bf54 && caller != 0x34bf60))
        return source;
    return choose_owned_matrix(source, phase);
}

__attribute__((noinline)) void effect_multiply(Matrix* out, const Matrix* a,
                                              const Matrix* b, u32 view_world) {
    u32 phase = render_phase();
    if (phase && CACHE->owner) {
        if (view_world) {
            a = choose_matrix(a, 0x21d2ac);
            b = choose_owned_matrix(b, phase);
        } else {
            a = choose_owned_matrix(a, phase);
        }
    }
    ((void (*)(Matrix*, const Matrix*, const Matrix*))0x28e1c8)(out, a, b);
}

__attribute__((noinline)) void badge_point(float* out, u32 owner, const float* point, u32 context) {
    u32 fpscr;
    __asm__ volatile("vmrs %0, FPSCR" : "=r"(fpscr));
    Matrix value = {{1, 0, 0, point[0], 0, 1, 0, point[1], 0, 0, 1, point[2]}};
    const Matrix* result = &value;
    u32 phase = render_phase();
    if (phase) {
        u32 saved_owner = CACHE->owner, saved_context = CACHE->render_context;
        CACHE->owner = owner | 1;
        CACHE->render_context = context;
        result = choose_value_matrix((u32)point, &value, phase);
        CACHE->owner = saved_owner;
        CACHE->render_context = saved_context;
    }
    out[0] = result->v[3];
    out[1] = result->v[7];
    out[2] = result->v[11];
    __asm__ volatile("vmsr FPSCR, %0" : : "r"(fpscr) : "memory");
}

__attribute__((noinline)) void badge_car_position(u32 car, float* out) {
    badge_point(out, car, (const float*)(car + 0x44), 0x1bf538);
}

__attribute__((noinline)) void badge_camera_copy(void* out, const Matrix* source, u32 copy) {
    u32 fpscr;
    __asm__ volatile("vmrs %0, FPSCR" : "=r"(fpscr));
    if (render_phase())
        source = choose_matrix(source, 0x21d2ac);
    __asm__ volatile("vmsr FPSCR, %0" : : "r"(fpscr) : "memory");
    ((void (*)(void*, const Matrix*))copy)(out, source);
}

__attribute__((noinline)) void badge_back_render(u32 canvas) {
    u32 fpscr;
    __asm__ volatile("vmrs %0, FPSCR" : "=r"(fpscr));
    struct { u32 node; float position[3]; } saved[16];
    unsigned count = 0;
    u32 phase = render_phase();
    if (phase) {
        for (u32 node = *(u32*)(canvas + 0x1dcac); node && count < 16;
             node = *(u32*)(node + 0x154)) {
            if (*(unsigned char*)(node + 0x15c) || !*(unsigned char*)(node + 0x16f))
                continue;
            float point[3];
            badge_point(point, node, (const float*)(node + 4), canvas);
            if (phase != 1 || SKIP)
                continue;
            const float* current = (const float*)(node + 4);
            if (point[0] == current[0] && point[1] == current[1] && point[2] == current[2])
                continue;
            saved[count].node = node;
            for (unsigned i = 0; i < 3; ++i)
                saved[count].position[i] = ((const float*)(node + 4))[i];
            ++count;
            ((void (*)(float,float,float,u32))0x2772b0)(point[0], point[1], point[2], node);
        }
    }
    __asm__ volatile("vmsr FPSCR, %0" : : "r"(fpscr) : "memory");
    ((void (*)(u32))0x282040)(canvas);
    __asm__ volatile("vmrs %0, FPSCR" : "=r"(fpscr));
    for (unsigned i = 0; i < count; ++i)
        ((void (*)(float,float,float,u32))0x2772b0)(saved[i].position[0], saved[i].position[1],
                                                 saved[i].position[2], saved[i].node);
    __asm__ volatile("vmsr FPSCR, %0" : : "r"(fpscr) : "memory");
}

/* Keys are cleared without changing chains, including allocations on workers. */
__attribute__((noinline)) void invalidate_range(u32 address, u32 size) {
    if (!address || !size)
        return;
    u32 count = CACHE->count;
    for (u32 i = 0; i < count; ++i) {
        Entry* entry = &CACHE->entries[i];
        u32 source = entry->source & ~3u;
        if (source && (source - address < size || entry->owner - address < size))
            entry->source = 0;
    }
    __asm__ volatile("mcr p15, 0, %0, c7, c10, 5" : : "r"(0) : "memory");
}
