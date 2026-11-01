.syntax unified
.arm
.section .text.wait,"ax"
.global wait_for_vblank
wait_for_vblank:
    push {r4, lr}
again:
    ldr ip, =0x47d000
    ldr r4, [ip, #-0x3c]
    cmp r4, #0
    beq complete
    ldr r4, =0x4674dc
    ldr r4, [r4]
    ldr r2, [ip, #-0x48]
    @ Use the sign of snapshot - now; signed-comparison overflow is irrelevant.
    subs r2, r2, r4
    bmi complete
    strne r4, [ip, #-0x48]
    mov r0, #0x400
    bl 0x3414ac
    b again
complete:
    pop {r4, lr}
    b 0x28dcd8
.ltorg
