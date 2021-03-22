// Copyright (c) 2021 Gil Barbosa Reis.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
#include <gdnative_api_struct.gen.h>
#include <stdlib.h>

const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_nativescript_api_struct *nativescript_api = NULL;

// called method names
godot_string GET_NAME;
godot_string GET_SIZE_NAME;
godot_string LOCK_NAME;
godot_string SET_NAME;
godot_string SET_PIXEL_NAME;
godot_string UNLOCK_NAME;

// accessed property names
godot_variant HEIGHT_ARRAY_NAME;
godot_variant LUMINANCE_ARRAY_NAME;

///////////////////////////////////////////////////////////////////////////////
// Helpers
///////////////////////////////////////////////////////////////////////////////
#define STR(s) api->godot_string_chars_to_utf8_with_len(s, sizeof(s))

#define MIN(a, b) (a < b ? a : b)
#define MAX(a, b) (a > b ? a : b)
#define CLAMP(x, min, max) (MIN(max, MAX(min, x)))

static inline godot_int posmod(godot_int p_x, godot_int p_y) {
    godot_int value = p_x % p_y;
    if ((value < 0 && p_y > 0) || (value > 0 && p_y < 0)) {
        value += p_y;
    }
    return value;
}

#ifdef NDEBUG
static void print_if_error(godot_variant_call_error *error, const char *method, int line) {}
#else
#include <stdio.h>
static void print_if_error(godot_variant_call_error *error, const char *method, int line) {
    char msg[1024];
    if(error->error != GODOT_CALL_ERROR_CALL_OK) {
        sprintf(msg, "code: %d", error->error);
        api->godot_print_error(msg, method, __FILE__, line);
    }
}
#endif

///////////////////////////////////////////////////////////////////////////////
// Class ctor/dtor
///////////////////////////////////////////////////////////////////////////////
GDCALLINGCONV void *null_constructor(godot_object *p_instance, void *p_method_data) { return NULL; }
GDCALLINGCONV void null_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data) {}

///////////////////////////////////////////////////////////////////////////////
// Methods
///////////////////////////////////////////////////////////////////////////////
GDCALLINGCONV godot_variant apply_height_increments(godot_object *p_instance, void *p_method_data,
        void *p_user_data, int argc, godot_variant **argv) {
    godot_variant_call_error error;

    // *arguments*
    godot_variant *height_data = argv[0];
    godot_pool_vector2_array values = api->godot_variant_as_pool_vector2_array(argv[1]);
    double amount = api->godot_variant_as_real(argv[2]);

    // var height_array = height_data.get(HEIGHT_ARRAY_NAME)
    godot_variant height_array_variant = api->godot_variant_call(
        height_data, &GET_NAME,
        (const godot_variant *[]){ &HEIGHT_ARRAY_NAME }, 1,
        &error
    );
    print_if_error(&error, "get height_array", __LINE__);
    godot_pool_real_array height_array = api->godot_variant_as_pool_real_array(&height_array_variant);
    godot_pool_real_array_write_access *height_array_access = api->godot_pool_real_array_write(&height_array);
    godot_real *height_ptr = api->godot_pool_real_array_write_access_ptr(height_array_access);

    // var luminance_array = height_data.get(LUMINANCE_ARRAY_NAME)
    godot_variant luminance_array_variant = api->godot_variant_call(
        height_data, &GET_NAME,
        (const godot_variant *[]){ &LUMINANCE_ARRAY_NAME }, 1,
        &error
    );
    print_if_error(&error, "get luminance_array", __LINE__);
    godot_pool_byte_array luminance_array = api->godot_variant_as_pool_byte_array(&luminance_array_variant);
    godot_pool_byte_array_write_access *luminance_array_access = api->godot_pool_byte_array_write(&luminance_array);
    uint8_t *luminance_ptr = api->godot_pool_byte_array_write_access_ptr(luminance_array_access);

    // *algorithm*
    godot_pool_vector3_array_read_access *values_access = api->godot_pool_vector2_array_read(&values);
    const godot_vector2 *values_ptr = api->godot_pool_vector2_array_read_access_ptr(values_access);
    godot_int values_size = api->godot_pool_vector2_array_size(&values);
    for(int i = 0; i < values_size; i++) {
        const godot_vector2 *v = &values_ptr[i];
        int index = (int) api->godot_vector2_get_x(v);
        godot_real depth = api->godot_vector2_get_y(v);
        godot_real height = CLAMP(height_ptr[index] + depth * amount, 0, 1);
        height_ptr[index] = height;
        luminance_ptr[index] = height * 255;
    }

    // height_data.set(HEIGHT_ARRAY_NAME, height_array)
    api->godot_variant_destroy(&height_array_variant);
    api->godot_variant_new_pool_real_array(&height_array_variant, &height_array);
    api->godot_variant_call(
        height_data, &SET_NAME,
        (const godot_variant *[]){ &HEIGHT_ARRAY_NAME, &height_array_variant }, 2,
        &error
    );
    print_if_error(&error, "set height_array", __LINE__);
    // height_data.set(LUMINANCE_ARRAY_NAME, luminance_array)
    api->godot_variant_destroy(&luminance_array_variant);
    api->godot_variant_new_pool_byte_array(&luminance_array_variant, &luminance_array);
    api->godot_variant_call(
        height_data, &SET_NAME,
        (const godot_variant *[]){ &LUMINANCE_ARRAY_NAME, &luminance_array_variant }, 2,
        &error
    );
    print_if_error(&error, "set luminance_array", __LINE__);
    
    // cleanup
    api->godot_pool_vector2_array_read_access_destroy(values_access);
    api->godot_pool_byte_array_write_access_destroy(luminance_array_access);
    api->godot_pool_real_array_write_access_destroy(height_array_access);

    api->godot_pool_byte_array_destroy(&luminance_array);
    api->godot_pool_real_array_destroy(&height_array);

    api->godot_variant_destroy(&luminance_array_variant);
    api->godot_variant_destroy(&height_array_variant);

    api->godot_pool_vector2_array_destroy(&values);

    // return null
    godot_variant ret;
    api->godot_variant_new_nil(&ret);
    return ret;
}

GDCALLINGCONV godot_variant fill_normalmap(godot_object *p_instance, void *p_method_data,
        void *p_user_data, int argc, godot_variant **argv) {
    godot_variant_call_error error;

    // *arguments*
    godot_variant *height_array_variant = argv[0]; // PoolRealArray
    godot_variant *normalmap = argv[1]; // Image
    godot_rect2 rect = api->godot_variant_as_rect2(argv[2]);

    godot_pool_real_array height_array = api->godot_variant_as_pool_real_array(height_array_variant);
    godot_pool_real_array_read_access *height_array_access = api->godot_pool_real_array_read(&height_array);
    const godot_real *height_ptr = api->godot_pool_real_array_read_access_ptr(height_array_access);

    // var size = normalmap.get_size()
    godot_variant size_variant = api->godot_variant_call(
        normalmap, &GET_SIZE_NAME,
        NULL, 0,
        &error
    );
    print_if_error(&error, "normalmap.get_size", __LINE__);
    const godot_vector2 size = api->godot_variant_as_vector2(&size_variant);
    const godot_int size_x = (godot_int) api->godot_vector2_get_x(&size);
    const godot_int size_y = (godot_int) api->godot_vector2_get_y(&size);
    const godot_int bump_scale = MIN(size_x, size_y);
    const godot_int stride = size_x;

    const godot_vector2 rect_position = api->godot_rect2_get_position(&rect);
    const godot_int rect_x = (godot_int) api->godot_vector2_get_x(&rect_position);
    const godot_int rect_y = (godot_int) api->godot_vector2_get_y(&rect_position);

    const godot_vector2 rect_size = api->godot_rect2_get_size(&rect);
    const godot_int rect_end_x = rect_x + (godot_int) api->godot_vector2_get_x(&rect_size);
    const godot_int rect_end_y = rect_y + (godot_int) api->godot_vector2_get_y(&rect_size);

    // *algorithm*
    api->godot_variant_call(
        normalmap, &LOCK_NAME,
        NULL, 0,
        &error
    );
    print_if_error(&error, "normalmap.lock", __LINE__);
    for(godot_int x = rect_x; x < rect_end_x; x++) {
        for(godot_int y = rect_y; y < rect_end_y; y++) {
            godot_int x_left = posmod(x - 1, size_x);
            godot_int x_right = posmod(x + 1, size_x);
            godot_int y_top = posmod(y - 1, size_y);
            godot_int y_bottom = posmod(y + 1, size_y);
            
            // Ref: https://github.com/Scrawk/Terrain-Topology-Algorithms/blob/afe65384254462073f41984c4c8e7e029275d830/Assets/TerrainTopology/Scripts/CreateTopolgy.cs#L162
            godot_real z1 = height_ptr[y_bottom * stride + x_left];
            godot_real z2 = height_ptr[y_bottom * stride + x];
            godot_real z3 = height_ptr[y_bottom * stride + x_right];
            godot_real z4 = height_ptr[y * stride + x_left];
            godot_real z6 = height_ptr[y * stride + x_right];
            godot_real z7 = height_ptr[y_top * stride + x_left];
            godot_real z8 = height_ptr[y_top * stride + x];
            godot_real z9 = height_ptr[y_top * stride + x_right];

            godot_real zx = (z3 + z6 + z9 - z1 - z4 - z7) / 6.0 * bump_scale;
            godot_real zy = (z1 + z2 + z3 - z7 - z8 - z9) / 6.0 * bump_scale;
            godot_vector3 normal;
            api->godot_vector3_new(&normal, -zx, zy, 1.0);
            normal = api->godot_vector3_normalized(&normal);
            godot_color normal_rgb;
            api->godot_color_new_rgb(
                &normal_rgb,
                api->godot_vector3_get_axis(&normal, GODOT_VECTOR3_AXIS_X) * 0.5 + 0.5,
                api->godot_vector3_get_axis(&normal, GODOT_VECTOR3_AXIS_Y) * 0.5 + 0.5,
                api->godot_vector3_get_axis(&normal, GODOT_VECTOR3_AXIS_Z) * 0.5 + 0.5
            );
            godot_variant x_variant, y_variant, normal_rgb_variant;
            api->godot_variant_new_real(&x_variant, x);
            api->godot_variant_new_real(&y_variant, y);
            api->godot_variant_new_color(&normal_rgb_variant, &normal_rgb);
            api->godot_variant_call(
                normalmap, &SET_PIXEL_NAME,
                (const godot_variant *[]){ &x_variant, &y_variant, &normal_rgb_variant }, 3,
                &error
            );
            print_if_error(&error, "normalmap.set_pixel", __LINE__);
        }
    }
    api->godot_variant_call(
        normalmap, &UNLOCK_NAME,
        NULL, 0,
        &error
    );
    print_if_error(&error, "normalmap.unlock", __LINE__);
    
    // cleanup
    api->godot_pool_real_array_read_access_destroy(height_array_access);

    api->godot_pool_real_array_destroy(&height_array);

    // return null
    godot_variant ret;
    api->godot_variant_new_nil(&ret);
    return ret;
}

///////////////////////////////////////////////////////////////////////////////
// API initialization
///////////////////////////////////////////////////////////////////////////////
void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *p_options) {
    api = p_options->api_struct;
    GET_NAME = STR("get");
    GET_SIZE_NAME = STR("get_size");
    LOCK_NAME = STR("lock");
    SET_NAME = STR("set");
    SET_PIXEL_NAME = STR("set_pixel");
    UNLOCK_NAME = STR("unlock");

    godot_string height_array_name = STR("height_array");
    api->godot_variant_new_string(&HEIGHT_ARRAY_NAME, &height_array_name);
    api->godot_string_destroy(&height_array_name);

    godot_string luminance_array_name = STR("luminance_array");
    api->godot_variant_new_string(&LUMINANCE_ARRAY_NAME, &luminance_array_name);
    api->godot_string_destroy(&luminance_array_name);

    // Now find our extensions.
    for(int i = 0; i < api->num_extensions; i++) {
        switch(api->extensions[i]->type) {
            case GDNATIVE_EXT_NATIVESCRIPT: {
                nativescript_api = (godot_gdnative_ext_nativescript_api_struct *) api->extensions[i];
            }; break;
            default: break;
        }
    }
}

void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *p_options) {
    api->godot_variant_destroy(&LUMINANCE_ARRAY_NAME);
    api->godot_variant_destroy(&HEIGHT_ARRAY_NAME);

    api->godot_string_destroy(&UNLOCK_NAME);
    api->godot_string_destroy(&SET_PIXEL_NAME);
    api->godot_string_destroy(&SET_NAME);
    api->godot_string_destroy(&LOCK_NAME);
    api->godot_string_destroy(&GET_SIZE_NAME);
    api->godot_string_destroy(&GET_NAME);

    nativescript_api = NULL;
    api = NULL;
}

void GDN_EXPORT godot_nativescript_init(void *p_handle) {
    nativescript_api->godot_nativescript_register_class(
        p_handle, "HeightAlgorithm_native", "Reference",
        (godot_instance_create_func){ &null_constructor, NULL, NULL },
        (godot_instance_destroy_func){ &null_destructor, NULL, NULL }
    );

    nativescript_api->godot_nativescript_register_method(
        p_handle, "HeightAlgorithm_native", "apply_height_increments",
        (godot_method_attributes){ GODOT_METHOD_RPC_MODE_DISABLED },
        (godot_instance_method){ &apply_height_increments, NULL, NULL }
    );

    nativescript_api->godot_nativescript_register_method(
        p_handle, "HeightAlgorithm_native", "fill_normalmap",
        (godot_method_attributes){ GODOT_METHOD_RPC_MODE_DISABLED },
        (godot_instance_method){ &fill_normalmap, NULL, NULL }
    );
}
