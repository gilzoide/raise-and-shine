// Copyright (c) 2021 Gil Barbosa Reis.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
#include <gdnative_api_struct.gen.h>
#include <stdio.h>
#include <stdlib.h>

const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_nativescript_api_struct *nativescript_api = NULL;

godot_method_bind *OBJECT_GET = NULL;
godot_method_bind *OBJECT_SET = NULL;

godot_variant HEIGHT_ARRAY_NAME;
godot_variant LUMINANCE_ARRAY_NAME;

#define STR(s) api->godot_string_chars_to_utf8_with_len(s, sizeof(s))


///////////////////////////////////////////////////////////////////////////////
// Helpers
///////////////////////////////////////////////////////////////////////////////
godot_real clamp(godot_real f, godot_real min, godot_real max) {
    const godot_real t = f < min ? min : f;
    return t > max ? max : t;
}

void print_if_error(godot_variant_call_error *error, const char *method, int line) {
#ifdef DEBUG
    char msg[1024];
    if(error->error != GODOT_CALL_ERROR_CALL_OK) {
        sprintf(msg, "code: %d", error->error);
        api->godot_print_error(msg, method, __FILE__, line);
    }
#endif
}

///////////////////////////////////////////////////////////////////////////////
// Class ctor/dtor
///////////////////////////////////////////////////////////////////////////////
GDCALLINGCONV void *null_constructor(godot_object *p_instance, void *p_method_data) { return NULL; }
GDCALLINGCONV void null_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data) {}

///////////////////////////////////////////////////////////////////////////////
// Methods
///////////////////////////////////////////////////////////////////////////////
GDCALLINGCONV godot_variant apply_height_increments(godot_object *p_instance, void *p_method_data,
        void *p_user_data, int p_num_args, godot_variant **p_args) {
    godot_variant_call_error error;

    // *arguments*
    godot_object *height_data = api->godot_variant_as_object(p_args[0]);
    godot_pool_vector2_array values = api->godot_variant_as_pool_vector2_array(p_args[1]);
    double amount = api->godot_variant_as_real(p_args[2]);

    // var height_array = height_data.get(HEIGHT_ARRAY_NAME)
    godot_variant height_array_variant = api->godot_method_bind_call(
        OBJECT_GET, height_data,
        (const godot_variant *[]){ &HEIGHT_ARRAY_NAME }, 1,
        &error
    );
    print_if_error(&error, "get height_array", __LINE__);
    godot_pool_real_array height_array = api->godot_variant_as_pool_real_array(&height_array_variant);
    godot_pool_real_array_write_access *height_array_access = api->godot_pool_real_array_write(&height_array);
    godot_real *height_ptr = api->godot_pool_real_array_write_access_ptr(height_array_access);

    // var luminance_array = height_data.get(LUMINANCE_ARRAY_NAME)
    godot_variant luminance_array_variant = api->godot_method_bind_call(
        OBJECT_GET, height_data,
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
        godot_real height = clamp(height_ptr[index] + depth * amount, 0, 1);
        height_ptr[index] = height;
        luminance_ptr[index] = height * 255;
    }

    // height_data.set(HEIGHT_ARRAY_NAME, height_array)
    api->godot_variant_destroy(&height_array_variant);
    api->godot_variant_new_pool_real_array(&height_array_variant, &height_array);
    api->godot_method_bind_call(
        OBJECT_SET, height_data,
        (const godot_variant *[]){ &HEIGHT_ARRAY_NAME, &height_array_variant }, 2,
        &error
    );
    print_if_error(&error, "set height_array", __LINE__);
    // height_data.set(LUMINANCE_ARRAY_NAME, luminance_array)
    api->godot_variant_destroy(&luminance_array_variant);
    api->godot_variant_new_pool_byte_array(&luminance_array_variant, &luminance_array);
    api->godot_method_bind_call(
        OBJECT_SET, height_data,
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

///////////////////////////////////////////////////////////////////////////////
// API initialization
///////////////////////////////////////////////////////////////////////////////
void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *p_options) {
    api = p_options->api_struct;
    OBJECT_GET = api->godot_method_bind_get_method("Object", "get");
    OBJECT_SET = api->godot_method_bind_get_method("Object", "set");

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
    OBJECT_SET = NULL;
    OBJECT_GET = NULL;
    nativescript_api = NULL;
    api = NULL;
}

void GDN_EXPORT godot_nativescript_init(void *p_handle) {
    nativescript_api->godot_nativescript_register_class(
        p_handle, "HeightAlgorithm", "Reference",
        (godot_instance_create_func){ &null_constructor, NULL, NULL },
        (godot_instance_destroy_func){ &null_destructor, NULL, NULL }
    );

    nativescript_api->godot_nativescript_register_method(
        p_handle, "HeightAlgorithm", "apply_height_increments",
        (godot_method_attributes){ GODOT_METHOD_RPC_MODE_DISABLED },
        (godot_instance_method){ &apply_height_increments, NULL, NULL }
    );
}
