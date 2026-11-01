SECTIONS {
 _text_badge_back_render 0x138870 : { *(.text.badge_back_render) }
 _text_choose_value_matrix 0x1389d4 : { *(.text.choose_value_matrix) }
 _text_choose_owned_matrix 0x138a64 : { *(.text.choose_owned_matrix) }
 _text_choose_matrix 0x138ac0 : { *(.text.choose_matrix) }
 _text_render_phase 0x138bbc : { *(.text.render_phase) }
 _text_equal_matrix 0x138be4 : { *(.text.equal_matrix) }
 _text_render_half 0x138c0c : { *(.text.render_half) }
 _text_badge_camera44 0x138c34 : { *(.text.badge_camera44) }
 _text_quat_diagonal 0x15febc : { *(.text.quat_diagonal) }
 _text_effect_first 0x160000 : { *(.text.effect_first) }
 _text_badge_car_position 0x16000c : { *(.text.badge_car_position) }
 _text_decompose 0x16bba4 : { *(.text.decompose) }
 _text_bind_view 0x16be40 : { *(.text.bind_view) }
 _text_matrix_hook 0x16beb0 : { *(.text.matrix_hook) }
 _text_bind_world 0x16bf08 : { *(.text.bind_world) }
 _text_effect_multiply 0x16bf28 : { *(.text.effect_multiply) }
 _text_copy_matrix 0x16bfb8 : { *(.text.copy_matrix) }
 _text_destroy_hook 0x16bfc4 : { *(.text.destroy_hook) }
 _text_badge_point 0x16bfe4 : { *(.text.badge_point) }
 _text_owner_resource 0x16c0a0 : { *(.text.owner_resource) }
 _text_quat_matrix 0x16c0c4 : { *(.text.quat_matrix) }
 _text_quat_from 0x16c17c : { *(.text.quat_from) }
 _text_scene_hook 0x1701b4 : { *(.text.scene_hook) }
 _text_affine_half 0x1701d0 : { *(.text.affine_half) }
 _text_matrix_second 0x170318 : { *(.text.matrix_second) }
 _text_compose 0x170330 : { *(.text.compose) }
 _text_quat_trace 0x17b698 : { *(.text.quat_trace) }
 _text_find_entry 0x17b718 : { *(.text.find_entry) }
 _text_interpolate 0x17c0ac : { *(.text.interpolate) }
 _text_allocate_hook 0x17c14c : { *(.text.allocate_hook) }
 _text_effect_bind 0x17c174 : { *(.text.effect_bind) }
 _text_badge_camera34 0x17c180 : { *(.text.badge_camera34) }
 _text_effect_second 0x17c18c : { *(.text.effect_second) }
 _text_invalidate_range 0x18a618 : { *(.text.invalidate_range) }
 _text_begin_frame 0x18a6a4 : { *(.text.begin_frame) }
 _text_camera_destroy_hook 0x18a6e0 : { *(.text.camera_destroy_hook) }
 _text_view_half 0x1ac788 : { *(.text.view_half) }
 _text_badge_camera_copy 0x1ac7e8 : { *(.text.badge_camera_copy) }
 _text_finite_matrix 0x1ac834 : { *(.text.finite_matrix) }
 _text_store_matrix 0x1b5a1c : { *(.text.store_matrix) }
 _text_matrix_first 0x1b5aec : { *(.text.matrix_first) }
 _text_bind_model 0x33375c : { *(.text.bind_model) }
 _text_frame_hook 0x333788 : { *(.text.frame_hook) }
 _text_bucket 0x37aeac : { *(.text.bucket) }
 _text_wait 0x37aed0 : { *(.text.wait) }
 _text_quat_half 0x37af18 : { *(.text.quat_half) }
 _text_allocate_finish 0x37afb8 : { *(.text.allocate_finish) }
 _text_effect_multiply_saved 0x37afd4 : { *(.text.effect_multiply_saved) }
 /DISCARD/ : { *(.ARM.attributes) *(.comment) }
}
ASSERT(SIZEOF(_text_bind_view)==12,".text.bind_view changed size")
ASSERT(SIZEOF(_text_matrix_hook)==88,".text.matrix_hook changed size")
ASSERT(SIZEOF(_text_bind_world)==12,".text.bind_world changed size")
ASSERT(SIZEOF(_text_destroy_hook)==24,".text.destroy_hook changed size")
ASSERT(SIZEOF(_text_scene_hook)==28,".text.scene_hook changed size")
ASSERT(SIZEOF(_text_matrix_second)==16,".text.matrix_second changed size")
ASSERT(SIZEOF(_text_allocate_hook)==32,".text.allocate_hook changed size")
ASSERT(SIZEOF(_text_invalidate_range)==140,".text.invalidate_range changed size")
ASSERT(SIZEOF(_text_camera_destroy_hook)==24,".text.camera_destroy_hook changed size")
ASSERT(SIZEOF(_text_matrix_first)==16,".text.matrix_first changed size")
ASSERT(SIZEOF(_text_bind_model)==44,".text.bind_model changed size")
ASSERT(SIZEOF(_text_frame_hook)==28,".text.frame_hook changed size")
ASSERT(SIZEOF(_text_wait)==72,".text.wait changed size")
ASSERT(SIZEOF(_text_allocate_finish)==28,".text.allocate_finish changed size")
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
ASSERT(SIZEOF(_text_quat_trace)==128,".text.quat_trace changed size")
ASSERT(SIZEOF(_text_compose)==108,".text.compose changed size")
ASSERT(SIZEOF(_text_quat_half)==108,".text.quat_half changed size")
ASSERT(SIZEOF(_text_find_entry)==104,".text.find_entry changed size")
ASSERT(SIZEOF(_text_view_half)==96,".text.view_half changed size")
ASSERT(SIZEOF(_text_badge_camera_copy)==76,".text.badge_camera_copy changed size")
ASSERT(SIZEOF(_text_begin_frame)==60,".text.begin_frame changed size")
ASSERT(SIZEOF(_text_finite_matrix)==52,".text.finite_matrix changed size")
ASSERT(SIZEOF(_text_quat_from)==40,".text.quat_from changed size")
ASSERT(SIZEOF(_text_render_phase)==40,".text.render_phase changed size")
ASSERT(SIZEOF(_text_equal_matrix)==40,".text.equal_matrix changed size")
ASSERT(SIZEOF(_text_render_half)==40,".text.render_half changed size")
ASSERT(SIZEOF(_text_bucket)==36,".text.bucket changed size")
ASSERT(SIZEOF(_text_owner_resource)==32,".text.owner_resource changed size")
ASSERT(SIZEOF(_text_badge_car_position)==28,".text.badge_car_position changed size")
ASSERT(SIZEOF(_text_effect_multiply_saved)==20,".text.effect_multiply_saved changed size")
ASSERT(SIZEOF(_text_choose_owned_matrix)==12,".text.choose_owned_matrix changed size")
ASSERT(SIZEOF(_text_copy_matrix)==12,".text.copy_matrix changed size")
ASSERT(SIZEOF(_text_effect_bind)==12,".text.effect_bind changed size")
ASSERT(SIZEOF(_text_badge_camera34)==12,".text.badge_camera34 changed size")
ASSERT(SIZEOF(_text_badge_camera44)==12,".text.badge_camera44 changed size")
ASSERT(SIZEOF(_text_effect_first)==8,".text.effect_first changed size")
ASSERT(SIZEOF(_text_effect_second)==8,".text.effect_second changed size")
