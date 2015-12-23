#version 400

#pragma include "Includes/Configuration.inc.glsl"

// Tell the lighting pipeline we are doing this in screen space, so gl_FragCoord
// is available.
#define IS_SCREEN_SPACE 1

#pragma include "Includes/LightCulling.inc.glsl"
#pragma include "Includes/PositionReconstruction.inc.glsl"
#pragma include "Includes/LightingPipeline.inc.glsl"
#pragma include "Includes/GBuffer.inc.glsl"

in vec2 texcoord;
out vec4 result;

uniform GBufferData GBuffer;

void main() {    

    // Extract material properties
    ivec2 coord = ivec2(gl_FragCoord.xy);
    float depth = get_gbuffer_depth(GBuffer, coord);
    Material m = unpack_material(GBuffer);
    ivec3 tile = get_lc_cell_index(coord, distance(MainSceneData.camera_pos, m.position));

    // Don't shade pixels out of the shading range
    if (tile.z >= LC_TILE_SLICES) {
        result = vec4(0);
        return;
    }

    // Apply all lights
    result.xyz = shade_material_from_tile_buffer(m, tile);
    result.w = 1.0;


    /*
    
    Various debugging modes for previewing materials
    
    */

    #if MODE_ACTIVE(DIFFUSE)
        result.xyz = vec3(m.basecolor);
    #endif

    #if MODE_ACTIVE(ROUGHNESS)
        result.xyz = vec3(m.roughness);
    #endif

    #if MODE_ACTIVE(SPECULAR)
        result.xyz = vec3(m.specular);
    #endif

    #if MODE_ACTIVE(NORMAL)
        result.xyz = vec3(m.normal);
    #endif

    #if MODE_ACTIVE(METALLIC)
        result.xyz = vec3(m.metallic);
    #endif

    #if MODE_ACTIVE(TRANSLUCENCY)
        result.xyz = vec3(m.translucency);
    #endif
}
