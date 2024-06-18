shader_type spatial;

render_mode diffuse_toon, specular_disabled, cull_disabled, depth_prepass_alpha;

uniform vec3 face_color : source_color = vec3(0.125, 0.154, 0.19); 


group_uniforms eyes;
uniform sampler2D eye_sampler : repeat_disable, filter_linear;
uniform vec2 eye_scale_left = vec2(1.0);
uniform vec2 eye_scale_right = vec2(1.0);
uniform vec2 eye_seperation = vec2(8.0, 0.0);
uniform vec2 eye_offset = vec2(0.0, 0.0);
uniform float eye_rotation_right : hint_range(-180.0, 180.0, 0.1) = -5.0;
uniform float eye_rotation_left : hint_range(-180.0, 180.0, 0.1) = -5.0;

group_uniforms mouth;
uniform sampler2D mouth_sampler : repeat_disable, filter_linear;
uniform float mouth_rotation : hint_range(-180.0, 180.0, 0.1) = 0.0;
uniform vec2 mouth_scale = vec2(1.0);
uniform vec2 mouth_offset = vec2(0.0, -7);

vec2 rotate_uv(vec2 uv, float angle_degrees, vec2 pivot) {
	float rotation_to_radians = radians(angle_degrees);
	mat2 rotation_matrix = mat2(vec2(cos(rotation_to_radians), -sin(rotation_to_radians)), vec2(sin(rotation_to_radians), cos(rotation_to_radians)));
	
	return ((uv - vec2(pivot)) * rotation_matrix) + vec2(pivot);
}

void fragment() {
	ROUGHNESS = 0.1;
	METALLIC = 0.35;
	ALBEDO = face_color;
	float face_mask;
	vec2 uv_scale_right = (1.0 / (eye_scale_right * 0.25));
	vec2 uv_scale_left = (1.0 / (eye_scale_left * 0.25));
	vec2 uv_scale_mouth = (1.0 / (mouth_scale * 0.25));
	
	vec2 uv_transform_right = (((UV + ((1.0 / uv_scale_right) * 0.5)) - 0.5) * uv_scale_right);
	vec2 uv_transform_left = ((vec2(1.0 - UV.x, UV.y) + ((1.0 / uv_scale_left) * 0.5)) - 0.5) * uv_scale_left;
	vec2 uv_transform_mouth = (((UV + ((1.0 / uv_scale_mouth) * 0.5)) - 0.5) * uv_scale_mouth);
	
	
	vec2 seperation_uv_right = uv_transform_right + ((eye_seperation * 0.1) * (1.0 / eye_scale_right));
	vec2 seperation_uv_left = uv_transform_left + (vec2((eye_seperation.x * 0.1), -(eye_seperation.y * 0.1)) * (1.0 / eye_scale_left));
	vec2 uv_mouth_offset = uv_transform_mouth + ((mouth_offset * 0.1) * (1.0 / mouth_scale));
	
	face_mask = texture(eye_sampler, rotate_uv(seperation_uv_right, eye_rotation_right, vec2(0.5, 0.5)) + (eye_offset * 0.1)).a;
	face_mask += texture(eye_sampler, rotate_uv(seperation_uv_left, eye_rotation_left, vec2(0.5, 0.5)) + (vec2(-0.1, 0.1) * eye_offset)).a;
	
	
	face_mask += texture(mouth_sampler, rotate_uv(uv_mouth_offset, mouth_rotation, vec2(0.5, 0.5))).a;
	face_mask = clamp(face_mask, 0.0, 1.0);
	ALPHA = face_mask;
}
