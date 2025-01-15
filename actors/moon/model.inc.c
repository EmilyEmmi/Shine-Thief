Lights1 moon_Body_003_f3d_lights = gdSPDefLights1(
	0x7F, 0x7F, 0x7F,
	0xFF, 0xFF, 0xFF, 0x28, 0x28, 0x28);

Gfx moon_body_rgba16_aligner[] = {gsSPEndDisplayList()};
u8 moon_body_rgba16[] = {
	#include "moon/body.rgba16.inc.c"
};

Gfx moon_eye_rgba16_aligner[] = {gsSPEndDisplayList()};
u8 moon_eye_rgba16[] = {
	#include "moon/eye.rgba16.inc.c"
};

Vtx moon_000_displaylist_mesh_layer_1_vtx_0[36] = {
	{{ {121, 41, 50}, 0, {706, 327}, {16, 9, 126, 255} }},
	{{ {15, 77, 0}, 0, {422, 302}, {132, 229, 0, 255} }},
	{{ {-4, -17, 0}, 0, {431, 528}, {155, 78, 0, 255} }},
	{{ {75, 131, 50}, 0, {572, 160}, {250, 31, 123, 255} }},
	{{ {228, 6, 0}, 0, {986, 338}, {127, 2, 0, 255} }},
	{{ {81, -88, 50}, 0, {694, 634}, {7, 243, 126, 255} }},
	{{ {-53, -62, 0}, 0, {360, 665}, {211, 119, 0, 255} }},
	{{ {81, -88, -50}, 0, {694, 634}, {7, 243, 130, 255} }},
	{{ {121, 41, -50}, 0, {706, 327}, {16, 9, 130, 255} }},
	{{ {75, 131, -50}, 0, {572, 160}, {250, 31, 133, 255} }},
	{{ {-31, 177, 0}, 0, {318, 56}, {66, 147, 0, 255} }},
	{{ {123, 176, 0}, 0, {671, 10}, {68, 107, 0, 255} }},
	{{ {165, -159, 0}, 0, {946, 1000}, {90, 166, 0, 255} }},
	{{ {-39, -136, 50}, 0, {483, 815}, {230, 240, 123, 255} }},
	{{ {-165, -85, 0}, 0, {172, 854}, {66, 147, 0, 255} }},
	{{ {-39, -136, -50}, 0, {483, 815}, {230, 240, 133, 255} }},
	{{ {165, -159, 0}, 0, {946, 1000}, {90, 166, 0, 255} }},
	{{ {-27, -216, 0}, 0, {572, 1007}, {237, 130, 0, 255} }},
	{{ {-39, -136, -50}, 0, {483, 815}, {230, 240, 133, 255} }},
	{{ {-39, -136, 50}, 0, {483, 815}, {230, 240, 123, 255} }},
	{{ {-165, -85, 0}, 0, {172, 854}, {66, 147, 0, 255} }},
	{{ {-31, 177, 0}, 0, {318, 56}, {66, 147, 0, 255} }},
	{{ {123, 176, 0}, 0, {671, 10}, {68, 107, 0, 255} }},
	{{ {75, 131, -50}, 0, {572, 160}, {250, 31, 133, 255} }},
	{{ {-92, 177, 0}, 0, {97, 891}, {166, 166, 0, 255} }},
	{{ {-31, 177, 0}, 0, {893, 891}, {66, 147, 0, 255} }},
	{{ {-62, 207, 31}, 0, {495, 493}, {0, 0, 127, 255} }},
	{{ {-62, 207, -31}, 0, {495, 493}, {0, 0, 129, 255} }},
	{{ {-92, 238, 0}, 0, {97, 95}, {166, 90, 0, 255} }},
	{{ {-31, 238, 0}, 0, {893, 95}, {90, 90, 0, 255} }},
	{{ {-226, -85, 0}, 0, {97, 891}, {166, 166, 0, 255} }},
	{{ {-165, -85, 0}, 0, {893, 891}, {66, 147, 0, 255} }},
	{{ {-195, -55, 31}, 0, {495, 493}, {0, 0, 127, 255} }},
	{{ {-195, -55, -31}, 0, {495, 493}, {0, 0, 129, 255} }},
	{{ {-226, -24, 0}, 0, {97, 95}, {166, 90, 0, 255} }},
	{{ {-165, -24, 0}, 0, {893, 95}, {90, 90, 0, 255} }},
};

Gfx moon_000_displaylist_mesh_layer_1_tri_0[] = {
	gsSPVertex(moon_000_displaylist_mesh_layer_1_vtx_0 + 0, 16, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(1, 0, 3, 0),
	gsSP1Triangle(3, 0, 4, 0),
	gsSP1Triangle(4, 0, 5, 0),
	gsSP1Triangle(0, 2, 5, 0),
	gsSP1Triangle(5, 2, 6, 0),
	gsSP1Triangle(7, 6, 2, 0),
	gsSP1Triangle(8, 7, 2, 0),
	gsSP1Triangle(8, 2, 1, 0),
	gsSP1Triangle(1, 9, 8, 0),
	gsSP1Triangle(1, 10, 9, 0),
	gsSP1Triangle(1, 3, 10, 0),
	gsSP1Triangle(10, 3, 11, 0),
	gsSP1Triangle(3, 4, 11, 0),
	gsSP1Triangle(9, 11, 4, 0),
	gsSP1Triangle(9, 4, 8, 0),
	gsSP1Triangle(4, 7, 8, 0),
	gsSP1Triangle(4, 12, 7, 0),
	gsSP1Triangle(4, 5, 12, 0),
	gsSP1Triangle(12, 5, 13, 0),
	gsSP1Triangle(5, 6, 13, 0),
	gsSP1Triangle(14, 13, 6, 0),
	gsSP1Triangle(14, 6, 15, 0),
	gsSP1Triangle(7, 15, 6, 0),
	gsSP1Triangle(12, 15, 7, 0),
	gsSPVertex(moon_000_displaylist_mesh_layer_1_vtx_0 + 16, 14, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 3, 1, 0),
	gsSP1Triangle(1, 3, 4, 0),
	gsSP1Triangle(1, 4, 2, 0),
	gsSP1Triangle(5, 6, 7, 0),
	gsSP1Triangle(8, 9, 10, 0),
	gsSP1Triangle(8, 11, 9, 0),
	gsSP1Triangle(12, 11, 8, 0),
	gsSP1Triangle(12, 8, 10, 0),
	gsSP1Triangle(12, 10, 13, 0),
	gsSP1Triangle(10, 9, 13, 0),
	gsSP1Triangle(11, 13, 9, 0),
	gsSP1Triangle(12, 13, 11, 0),
	gsSPVertex(moon_000_displaylist_mesh_layer_1_vtx_0 + 30, 6, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 3, 1, 0),
	gsSP1Triangle(4, 3, 0, 0),
	gsSP1Triangle(4, 0, 2, 0),
	gsSP1Triangle(4, 2, 5, 0),
	gsSP1Triangle(2, 1, 5, 0),
	gsSP1Triangle(3, 5, 1, 0),
	gsSP1Triangle(4, 5, 3, 0),
	gsSPEndDisplayList(),
};

Vtx moon_001_displaylist_mesh_layer_4_vtx_0[8] = {
	{{ {103, 48, 67}, 0, {-16, -16}, {255, 255, 255, 255} }},
	{{ {103, -81, 67}, 0, {-16, 1008}, {255, 255, 255, 255} }},
	{{ {178, -81, 36}, 0, {1008, 1008}, {255, 255, 255, 255} }},
	{{ {178, 48, 36}, 0, {1008, -16}, {255, 255, 255, 255} }},
	{{ {29, 48, 36}, 0, {-16, -16}, {255, 255, 255, 255} }},
	{{ {103, -81, 67}, 0, {1008, 1008}, {255, 255, 255, 255} }},
	{{ {103, 48, 67}, 0, {1008, -16}, {255, 255, 255, 255} }},
	{{ {29, -81, 36}, 0, {-16, 1008}, {255, 255, 255, 255} }},
};

Gfx moon_001_displaylist_mesh_layer_4_tri_0[] = {
	gsSPVertex(moon_001_displaylist_mesh_layer_4_vtx_0 + 0, 8, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 2, 3, 0),
	gsSP1Triangle(4, 5, 6, 0),
	gsSP1Triangle(4, 7, 5, 0),
	gsSPEndDisplayList(),
};


Gfx mat_moon_Body_003_f3d[] = {
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, 0, 0, 0, ENVIRONMENT, TEXEL0, 0, SHADE, 0, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsSPSetLights1(moon_Body_003_f3d_lights),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, moon_body_rgba16),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 1023, 256),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 5, 0, G_TX_WRAP | G_TX_NOMIRROR, 5, 0),
	gsDPSetTileSize(0, 0, 0, 124, 124),
	gsSPEndDisplayList(),
};

Gfx mat_moon_Eyes_003_f3d[] = {
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0),
	gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, moon_eye_rgba16),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 1023, 256),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 5, 0, G_TX_WRAP | G_TX_NOMIRROR, 5, 0),
	gsDPSetTileSize(0, 0, 0, 124, 124),
	gsSPEndDisplayList(),
};

Gfx mat_revert_moon_Eyes_003_f3d[] = {
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_SHADE | G_LIGHTING),
	gsSPEndDisplayList(),
};

Gfx moon_000_displaylist_mesh_layer_1[] = {
	gsSPDisplayList(mat_moon_Body_003_f3d),
	gsSPDisplayList(moon_000_displaylist_mesh_layer_1_tri_0),
	gsSPEndDisplayList(),
};

Gfx moon_001_displaylist_mesh_layer_4[] = {
	gsSPDisplayList(mat_moon_Eyes_003_f3d),
	gsSPDisplayList(moon_001_displaylist_mesh_layer_4_tri_0),
	gsSPDisplayList(mat_revert_moon_Eyes_003_f3d),
	gsSPEndDisplayList(),
};

Gfx moon_material_revert_render_settings[] = {
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

