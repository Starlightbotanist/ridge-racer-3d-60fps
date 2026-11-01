/* Interpolation routines occupy retired diagnostic overlays. */
SECTIONS {
 _text_affine_half 0x15febc : { *(.text.affine_half) }
 _text_badge_car_position 0x16000c : { *(.text.badge_car_position) }
 _text_badge_back_render 0x1701b4 : { *(.text.badge_back_render) }
 _text_quat_trace 0x170318 : { *(.text.quat_trace) }
 _text_quat_matrix 0x17b698 : { *(.text.quat_matrix) }
 _text_bind_model 0x17b750 : { *(.text.bind_model) }
 _text_interpolate 0x17c0ac : { *(.text.interpolate) }
 _text_sync_motion_blur_alpha 0x17c14c : { *(.text.sync_motion_blur_alpha) }
 _text_badge_point 0x18a618 : { *(.text.badge_point) }
 _text_quat_from 0x18a6d4 : { *(.text.quat_from) }
 _text_choose_value_matrix 0x1ac788 : { *(.text.choose_value_matrix) }
 _text_matrix_hook 0x1ac818 : { *(.text.matrix_hook) }
 _text_effect_multiply 0x1b5a1c : { *(.text.effect_multiply) }
 _text_badge_camera_copy 0x1b5aac : { *(.text.badge_camera_copy) }
 _text_matrix_first 0x1b5af8 : { *(.text.matrix_first) }
 _text_render_phase 0x2993e4 : { *(.text.render_phase) }
 _text_equal_matrix 0x29940c : { *(.text.equal_matrix) }
 _text_render_half 0x299434 : { *(.text.render_half) }
 _text_bucket 0x29945c : { *(.text.bucket) }
 _text_allocate_hook 0x299480 : { *(.text.allocate_hook) }
 _text_scene_hook 0x2994a0 : { *(.text.scene_hook) }
 _text_frame_hook 0x2994bc : { *(.text.frame_hook) }
 _text_allocate_finish 0x2994d8 : { *(.text.allocate_finish) }
 _text_destroy_hook 0x2994f4 : { *(.text.destroy_hook) }
 _text_camera_destroy_hook 0x29950c : { *(.text.camera_destroy_hook) }
 _text_matrix_second 0x299524 : { *(.text.matrix_second) }
 _text_effect_bind 0x299534 : { *(.text.effect_bind) }
 _text_badge_camera34 0x299540 : { *(.text.badge_camera34) }
 _text_badge_camera44 0x29954c : { *(.text.badge_camera44) }
 _text_bind_world 0x299558 : { *(.text.bind_world) }
 _text_bind_view 0x299564 : { *(.text.bind_view) }
 _text_effect_first 0x299570 : { *(.text.effect_first) }
 _text_effect_second 0x299578 : { *(.text.effect_second) }
 _text_quat_diagonal 0x2996c8 : { *(.text.quat_diagonal) }
 _text_choose_matrix 0x29980c : { *(.text.choose_matrix) }
 _text_owner_resource 0x299908 : { *(.text.owner_resource) }
 _text_decompose 0x299930 : { *(.text.decompose) }
 _text_effect_multiply_saved 0x299bcc : { *(.text.effect_multiply_saved) }
 _text_invalidate_range 0x299be8 : { *(.text.invalidate_range) }
 _text_compose 0x299c74 : { *(.text.compose) }
 _text_quat_half 0x299ce0 : { *(.text.quat_half) }
 _text_find_entry 0x299d4c : { *(.text.find_entry) }
 _text_view_half 0x299db4 : { *(.text.view_half) }
 _text_wait 0x299e14 : { *(.text.wait) }
 _text_begin_frame 0x33375c : { *(.text.begin_frame) }
 _text_choose_owned_matrix 0x333798 : { *(.text.choose_owned_matrix) }
 _text_store_matrix 0x37aeac : { *(.text.store_matrix) }
 _text_copy_matrix 0x37af7c : { *(.text.copy_matrix) }
 _text_finite_matrix 0x37afb8 : { *(.text.finite_matrix) }
 /DISCARD/ : { *(.ARM.attributes) *(.comment) }
}
ASSERT(SIZEOF(_text_decompose)==668,".text.decompose changed size")
ASSERT(SIZEOF(_text_badge_back_render)==356,".text.badge_back_render changed size")
ASSERT(SIZEOF(_text_affine_half)==328,".text.affine_half changed size")
ASSERT(SIZEOF(_text_quat_diagonal)==324,".text.quat_diagonal changed size")
ASSERT(SIZEOF(_text_choose_matrix)==252,".text.choose_matrix changed size")
ASSERT(SIZEOF(_text_store_matrix)==208,".text.store_matrix changed size")
ASSERT(SIZEOF(_text_badge_point)==188,".text.badge_point changed size")
ASSERT(SIZEOF(_text_quat_matrix)==184,".text.quat_matrix changed size")
ASSERT(SIZEOF(_text_interpolate)==160,".text.interpolate changed size")
ASSERT(SIZEOF(_text_choose_value_matrix)==144,".text.choose_value_matrix changed size")
ASSERT(SIZEOF(_text_effect_multiply)==144,".text.effect_multiply changed size")
ASSERT(SIZEOF(_text_invalidate_range)==140,".text.invalidate_range changed size")
ASSERT(SIZEOF(_text_quat_trace)==128,".text.quat_trace changed size")
ASSERT(SIZEOF(_text_compose)==108,".text.compose changed size")
ASSERT(SIZEOF(_text_quat_half)==108,".text.quat_half changed size")
ASSERT(SIZEOF(_text_find_entry)==104,".text.find_entry changed size")
ASSERT(SIZEOF(_text_view_half)==96,".text.view_half changed size")
ASSERT(SIZEOF(_text_matrix_hook)==88,".text.matrix_hook changed size")
ASSERT(SIZEOF(_text_badge_camera_copy)==76,".text.badge_camera_copy changed size")
ASSERT(SIZEOF(_text_sync_motion_blur_alpha)==72,".text.sync_motion_blur_alpha changed size")
ASSERT(SIZEOF(_text_wait)==72,".text.wait changed size")
ASSERT(SIZEOF(_text_begin_frame)==60,".text.begin_frame changed size")
ASSERT(SIZEOF(_text_finite_matrix)==52,".text.finite_matrix changed size")
ASSERT(SIZEOF(_text_bind_model)==44,".text.bind_model changed size")
ASSERT(SIZEOF(_text_quat_from)==40,".text.quat_from changed size")
ASSERT(SIZEOF(_text_render_phase)==40,".text.render_phase changed size")
ASSERT(SIZEOF(_text_equal_matrix)==40,".text.equal_matrix changed size")
ASSERT(SIZEOF(_text_render_half)==40,".text.render_half changed size")
ASSERT(SIZEOF(_text_bucket)==36,".text.bucket changed size")
ASSERT(SIZEOF(_text_owner_resource)==32,".text.owner_resource changed size")
ASSERT(SIZEOF(_text_allocate_hook)==32,".text.allocate_hook changed size")
ASSERT(SIZEOF(_text_badge_car_position)==28,".text.badge_car_position changed size")
ASSERT(SIZEOF(_text_scene_hook)==28,".text.scene_hook changed size")
ASSERT(SIZEOF(_text_frame_hook)==28,".text.frame_hook changed size")
ASSERT(SIZEOF(_text_allocate_finish)==28,".text.allocate_finish changed size")
ASSERT(SIZEOF(_text_destroy_hook)==24,".text.destroy_hook changed size")
ASSERT(SIZEOF(_text_camera_destroy_hook)==24,".text.camera_destroy_hook changed size")
ASSERT(SIZEOF(_text_effect_multiply_saved)==20,".text.effect_multiply_saved changed size")
ASSERT(SIZEOF(_text_matrix_first)==16,".text.matrix_first changed size")
ASSERT(SIZEOF(_text_matrix_second)==16,".text.matrix_second changed size")
ASSERT(SIZEOF(_text_choose_owned_matrix)==12,".text.choose_owned_matrix changed size")
ASSERT(SIZEOF(_text_copy_matrix)==12,".text.copy_matrix changed size")
ASSERT(SIZEOF(_text_effect_bind)==12,".text.effect_bind changed size")
ASSERT(SIZEOF(_text_badge_camera34)==12,".text.badge_camera34 changed size")
ASSERT(SIZEOF(_text_badge_camera44)==12,".text.badge_camera44 changed size")
ASSERT(SIZEOF(_text_bind_world)==12,".text.bind_world changed size")
ASSERT(SIZEOF(_text_bind_view)==12,".text.bind_view changed size")
ASSERT(SIZEOF(_text_effect_first)==8,".text.effect_first changed size")
ASSERT(SIZEOF(_text_effect_second)==8,".text.effect_second changed size")
