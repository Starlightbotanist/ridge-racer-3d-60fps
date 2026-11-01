.syntax unified
.arm
.fpu vfpv2

.equ CACHE, 0x47e000

.section .text.copy_matrix,"ax"
.global copy_matrix
copy_matrix:
    vldmia r1, {s0-s11}
    vstmia r0, {s0-s11}
    bx lr

.section .text.equal_matrix,"ax"
.global equal_matrix
equal_matrix:
    mov r2, #12
1:  ldr r3, [r0], #4
    ldr ip, [r1], #4
    cmp r3, ip
    bne 2f
    subs r2, r2, #1
    bne 1b
2:  moveq r0, #1
    movne r0, #0
    bx lr

.section .text.view_half,"ax"
.global view_half
view_half:
    push {r4,r5,r6,lr}
    sub sp, sp, #144
    mov r4, r0
    mov r5, r2
    mov r0, sp
    bl 0x293168
    cmp r0, #0
    beq 1f
    add r0, sp, #48
    mov r1, r5
    bl 0x293168
    cmp r0, #0
    beq 1f
    add r0, sp, #96
    mov r1, sp
    add r2, sp, #48
    bl affine_half
    cmp r0, #0
    beq 1f
    mov r0, r4
    add r1, sp, #96
    bl 0x293168
1:  add sp, sp, #144
    pop {r4,r5,r6,pc}

.section .text.render_half,"ax"
.global render_half
render_half:
    ldr ip, =CACHE
    ldm ip, {r3,ip}
    add r3, r3, #0x1bc
    cmp r1, r3
    subne r3, r3, #0xc0
    cmpne r1, r3
    cmpne ip, #0
    beq view_half
    b affine_half
.ltorg

.section .text.effect_bind,"ax"
.global effect_bind
effect_bind:
    push {r0-r11,lr}
    bl bind_model
    b 0x34bd54

.section .text.effect_first,"ax"
.global effect_first, effect_second
effect_first:
    mov r3, #1
    b effect_multiply_saved
.section .text.effect_second,"ax"
effect_second:
    mov r3, #0
    b effect_multiply_saved
.section .text.effect_multiply_saved,"ax"
effect_multiply_saved:
    push {r4,lr}
    vmrs r4, FPSCR
    bl effect_multiply
    vmsr FPSCR, r4
    pop {r4,pc}

.section .text.scene_hook,"ax"
.section .text.badge_camera34,"ax"
.global badge_camera34, badge_camera44
badge_camera34:
    ldr r2, =0x281f30
    b badge_camera_copy
.ltorg
.section .text.badge_camera44,"ax"
badge_camera44:
    ldr r2, =0x25a78c
    b badge_camera_copy
.ltorg

.section .text.scene_hook,"ax"
.global scene_hook
scene_hook:
    ldr ip, =0x47cfc4
    ldr ip, [ip]
    cmp ip, #2
    bxeq lr
    push {r4-r10,lr}
    b 0x1e2024
.ltorg

.section .text.matrix_first,"ax"
.global matrix_first, matrix_second
matrix_first:
    str lr, [sp, #-8]!
    bl matrix_hook
    ldr lr, [sp], #8
    b 0x245e7c
.section .text.matrix_second,"ax"
matrix_second:
    str lr, [sp, #-8]!
    bl matrix_hook
    ldr lr, [sp], #8
    b 0x245e44

.section .text.matrix_hook,"ax"
.global matrix_hook
matrix_hook:
    push {r0-r7,ip,lr}
    vpush {d6,d7}
    mrs r6, CPSR
    vmrs r7, FPSCR
    mrc p15, 0, ip, c13, c0, 3
    ldr r3, =CACHE
    ldr r3, [r3, #8]
    cmp ip, r3
    bne native_matrix
    mov r0, r1
    ldr r1, [sp, #56]
    bl choose_matrix
    vldmia r0, {s0-s11}
    b matrix_done
native_matrix:
    vldmia r1, {s0-s11}
matrix_done:
    vmsr FPSCR, r7
    msr CPSR_f, r6
    vpop {d6,d7}
    pop {r0-r7,ip,lr}
    add r1, r1, #48
    bx lr
.ltorg

.section .text.frame_hook,"ax"
.global frame_hook
frame_hook:
    ldr ip, =CACHE
    mrc p15, 0, r2, c13, c0, 3
    str r2, [ip, #8]
    mov r2, #0
    str r2, [ip]
    b 0x333688
.ltorg

.section .text.bind_world,"ax"
.global bind_world, bind_view
bind_world:
    push {r4-r6,lr}
    bl bind_model
    b 0x354a04
.section .text.bind_view,"ax"
bind_view:
    push {r4-r6,lr}
    bl bind_model
    b 0x354ad0

.section .text.bind_model,"ax"
.global bind_model
bind_model:
    push {r2,r3,ip,lr}
    mrs r3, CPSR
    mrc p15, 0, ip, c13, c0, 3
    ldr r2, =CACHE
    ldr lr, [r2, #8]
    cmp ip, lr
    streq r1, [r2]
    streq r0, [r2, #4]
    msr CPSR_f, r3
    pop {r2,r3,ip,pc}
.ltorg

.section .text.allocate_hook,"ax"
.global allocate_hook
allocate_hook:
    push {r1,lr}
    cmp r1, #0x34
    bl 0x349968
    push {r0-r3,ip,lr}
    mrs r3, CPSR
    push {r3,lr}
    ldr r1, [sp, #32]
    b allocate_finish

.section .text.allocate_finish,"ax"
.global allocate_finish
allocate_finish:
    bl invalidate_range
    pop {r3,lr}
    msr CPSR_f, r3
    pop {r0-r3,ip,lr}
    ldr lr, [sp, #4]
    add sp, sp, #8
    bx lr

.section .text.destroy_hook,"ax"
.global destroy_hook
destroy_hook:
    push {r0-r3,ip,lr}
    mov r1, #1
    bl invalidate_range
    pop {r0-r3,ip,lr}
    push {r4-r11,lr}
    b 0x1e64e4

.section .text.camera_destroy_hook,"ax"
.global camera_destroy_hook
camera_destroy_hook:
    push {r0-r3,ip,lr}
    mov r1, #1
    bl invalidate_range
    pop {r0-r3,ip,lr}
    push {r4-r10,lr}
    b 0x1fd284

.section .text.sync_motion_blur_alpha,"ax"
.global sync_motion_blur_alpha
sync_motion_blur_alpha:
    @ Keep both blur quads synchronized on endpoint frames.
    ldr ip, =0x47cfc4
    ldr ip, [ip]
    cmp ip, #2
    bne 0x287e74
    push {r4,lr}
    add ip, r5, #0xc00
    vldr s0, [ip, #0xb4]
    add ip, r4, #0x1d000
    ldr r0, [ip, #0xe88]
    bl 0x27dd94
    add ip, r5, #0xc00
    vldr s0, [ip, #0xb4]
    add ip, r4, #0x1d000
    ldr r0, [ip, #0xe8c]
    bl 0x27dd94
    pop {r4,lr}
    b 0x287e74
.ltorg
