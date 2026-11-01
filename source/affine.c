#include "matrix.h"

typedef struct {
    Matrix rotation;
    float stretch[6];
} Decomposition;

static float square_root(float value) {
    float result;
    __asm__("vsqrt.f32 %0, %1" : "=t"(result) : "t"(value));
    return result;
}

__attribute__((noinline)) int finite_matrix(const Matrix* matrix) {
    for (unsigned i = 0; i < 12; ++i)
        if ((((const unsigned*)matrix)[i] & 0x7f800000) == 0x7f800000)
            return 0;
    return 1;
}

/* QR decomposition retains nonuniform scale, shear and reflections. */
__attribute__((noinline)) int decompose(const Matrix* matrix, Decomposition* out) {
    float length[2];
    for (unsigned column = 0; column < 2; ++column) {
        float norm = 0;
        for (unsigned row = 0; row < 3; ++row) {
            float value = matrix->v[4 * row + column];
            if (column)
                value -= out->rotation.v[4 * row] * out->stretch[1];
            out->rotation.v[4 * row + column] = value;
            norm += value * value;
        }
        if (!(norm > 1.0e-20f && norm < 1.0e20f))
            return 0;
        length[column] = square_root(norm);
        for (unsigned row = 0; row < 3; ++row)
            out->rotation.v[4 * row + column] /= length[column];
        if (!column) {
            float projection = 0;
            for (unsigned row = 0; row < 3; ++row)
                projection += out->rotation.v[4 * row] * matrix->v[4 * row + 1];
            out->stretch[1] = projection;
        }
    }
    out->stretch[0] = length[0];
    out->stretch[3] = length[1];
    float orthogonality = 0;
    for (unsigned row = 0; row < 3; ++row)
        orthogonality += out->rotation.v[4 * row] * out->rotation.v[4 * row + 1];
    if (!(orthogonality > -.0001f && orthogonality < .0001f))
        return 0;
    for (unsigned row = 0; row < 3; ++row) {
        unsigned next = row == 2 ? 0 : row + 1;
        unsigned last = next == 2 ? 0 : next + 1;
        out->rotation.v[4 * row + 2] =
            out->rotation.v[4 * next] * out->rotation.v[4 * last + 1] -
            out->rotation.v[4 * last] * out->rotation.v[4 * next + 1];
    }
    for (unsigned column = 0; column < 3; ++column) {
        float projection = 0;
        for (unsigned row = 0; row < 3; ++row)
            projection += out->rotation.v[4 * row + column] * matrix->v[4 * row + 2];
        if (!(projection > -1.0e10f && projection < 1.0e10f))
            return 0;
        out->stretch[column == 2 ? 5 : 2 + 2 * column] = projection;
    }
    return out->stretch[5] > 1.0e-10f || out->stretch[5] < -1.0e-10f;
}

__attribute__((noinline)) void quat_trace(const Matrix* matrix, float* quaternion) {
    float w = square_root(1 + matrix->v[0] + matrix->v[5] + matrix->v[10]) * .5f;
    float factor = .25f / w;
    quaternion[0] = (matrix->v[9] - matrix->v[6]) * factor;
    quaternion[1] = (matrix->v[2] - matrix->v[8]) * factor;
    quaternion[2] = (matrix->v[4] - matrix->v[1]) * factor;
    quaternion[3] = w;
}

__attribute__((noinline)) void quat_diagonal(const Matrix* matrix, float* quaternion) {
    unsigned i = 0;
    if (matrix->v[5] > matrix->v[0])
        i = 1;
    if (matrix->v[10] > matrix->v[5 * i])
        i = 2;
    unsigned j = i == 2 ? 0 : i + 1;
    unsigned k = j == 2 ? 0 : j + 1;
    float value = square_root(1 + matrix->v[5 * i] - matrix->v[5 * j] -
                             matrix->v[5 * k]) * .5f;
    float factor = .25f / value;
    quaternion[i] = value;
    quaternion[j] = (matrix->v[4 * i + j] + matrix->v[4 * j + i]) * factor;
    quaternion[k] = (matrix->v[4 * i + k] + matrix->v[4 * k + i]) * factor;
    quaternion[3] = (matrix->v[4 * k + j] - matrix->v[4 * j + k]) * factor;
}

__attribute__((noinline)) void quat_from(const Matrix* matrix, float* quaternion) {
    if (matrix->v[0] + matrix->v[5] + matrix->v[10] > 0)
        quat_trace(matrix, quaternion);
    else
        quat_diagonal(matrix, quaternion);
}

void quat_half(float* quaternion, const float* other);

__attribute__((noinline)) void quat_matrix(Matrix* matrix, const float* quaternion) {
    float x = quaternion[0], y = quaternion[1], z = quaternion[2], w = quaternion[3];
    matrix->v[0] = 1 - 2 * (y * y + z * z);
    matrix->v[1] = 2 * (x * y - z * w);
    matrix->v[2] = 2 * (x * z + y * w);
    matrix->v[4] = 2 * (x * y + z * w);
    matrix->v[5] = 1 - 2 * (x * x + z * z);
    matrix->v[6] = 2 * (y * z - x * w);
    matrix->v[8] = 2 * (x * z - y * w);
    matrix->v[9] = 2 * (y * z + x * w);
    matrix->v[10] = 1 - 2 * (x * x + y * y);
}

__attribute__((noinline)) void compose(Matrix* out, const Matrix* rotation,
                                     const float* stretch) {
    for (unsigned row = 0; row < 3; ++row) {
        out->v[4 * row] = rotation->v[4 * row] * stretch[0];
        out->v[4 * row + 1] = rotation->v[4 * row] * stretch[1] +
                             rotation->v[4 * row + 1] * stretch[3];
        out->v[4 * row + 2] = rotation->v[4 * row] * stretch[2] +
                             rotation->v[4 * row + 1] * stretch[4] +
                             rotation->v[4 * row + 2] * stretch[5];
    }
}

__attribute__((noinline)) int affine_half(Matrix* out, const Matrix* current,
                                        const Matrix* previous) {
    Decomposition a, b;
    Matrix rotation;
    float q[4], r[4];
    if (!finite_matrix(current) || !finite_matrix(previous) ||
        !decompose(current, &a) || !decompose(previous, &b) ||
        (a.stretch[5] < 0) != (b.stretch[5] < 0))
        return 0;
    quat_from(&a.rotation, q);
    quat_from(&b.rotation, r);
    quat_half(q, r);
    quat_matrix(&rotation, q);
    for (unsigned i = 0; i < 6; ++i)
        a.stretch[i] = a.stretch[i] * .5f + b.stretch[i] * .5f;
    compose(out, &rotation, a.stretch);
    for (unsigned i = 3; i < 12; i += 4)
        out->v[i] = current->v[i] * .5f + previous->v[i] * .5f;
    return 1;
}
