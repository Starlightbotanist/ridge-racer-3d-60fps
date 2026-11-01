#pragma once

/* Row-major 3x4 affine transform. */
typedef struct {
    float v[12];
} Matrix;

_Static_assert(sizeof(float) == 4 && sizeof(Matrix) == 48, "Native matrix layout");

int affine_half(Matrix* out, const Matrix* current, const Matrix* previous);
