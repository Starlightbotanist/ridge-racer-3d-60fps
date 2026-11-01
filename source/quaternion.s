.syntax unified
.arm
.fpu vfpv2
.section .text.quat_half,"ax"
.global quat_half
quat_half:
    vldmia r0, {s0-s3}
    vldmia r1, {s4-s7}
    vmul.f32 s8, s0, s4
    vmla.f32 s8, s1, s5
    vmla.f32 s8, s2, s6
    vmla.f32 s8, s3, s7
    vcmp.f32 s8, #0
    vmrs APSR_nzcv, fpscr
    vneglt.f32 s4, s4
    vneglt.f32 s5, s5
    vneglt.f32 s6, s6
    vneglt.f32 s7, s7
    vadd.f32 s0, s0, s4
    vadd.f32 s1, s1, s5
    vadd.f32 s2, s2, s6
    vadd.f32 s3, s3, s7
    vmul.f32 s8, s0, s0
    vmla.f32 s8, s1, s1
    vmla.f32 s8, s2, s2
    vmla.f32 s8, s3, s3
    vsqrt.f32 s8, s8
    vdiv.f32 s0, s0, s8
    vdiv.f32 s1, s1, s8
    vdiv.f32 s2, s2, s8
    vdiv.f32 s3, s3, s8
    vstmia r0, {s0-s3}
    bx lr
