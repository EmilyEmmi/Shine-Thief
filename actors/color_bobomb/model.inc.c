Lights1 color_bobomb_body_right_lights = gdSPDefLights1(
	0x7F, 0x7F, 0x7F,
	0xFF, 0xFF, 0xFF, 0x28, 0x28, 0x28);

Lights1 color_bobomb_shoes_lights = gdSPDefLights1(
	0x7F, 0x51, 0x13,
	0xFF, 0xA7, 0x31, 0x28, 0x28, 0x28);

Lights1 color_bobomb_fuse_lights = gdSPDefLights1(
	0x7F, 0x7F, 0x7F,
	0xFF, 0xFF, 0xFF, 0x28, 0x28, 0x28);

Gfx color_bobomb_bob_omb_body_ia8_aligner[] = {gsSPEndDisplayList()};
u8 color_bobomb_bob_omb_body_ia8[] = {
	#include "color_bobomb/bob-omb_body.ia8.inc.c"
};

Gfx color_bobomb_bob_omb_eyes_rgba16_ia8_aligner[] = {gsSPEndDisplayList()};
u8 color_bobomb_bob_omb_eyes_rgba16_ia8[] = {
	#include "color_bobomb/bob-omb_eyes.rgba16.ia8.inc.c"
};

Vtx color_bobomb_000_displaylist_mesh_layer_4_vtx_0[4] = {
	{{ {-49, 49, 0}, 0, {2012, 4}, {0, 0, 127, 255} }},
	{{ {-49, -49, 0}, 0, {2012, 2012}, {0, 0, 127, 255} }},
	{{ {49, -49, 0}, 0, {4, 2012}, {0, 0, 127, 255} }},
	{{ {49, 49, 0}, 0, {4, 4}, {0, 0, 127, 255} }},
};

Gfx color_bobomb_000_displaylist_mesh_layer_4_tri_0[] = {
	gsSPVertex(color_bobomb_000_displaylist_mesh_layer_4_vtx_0 + 0, 4, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 2, 3, 0),
	gsSPEndDisplayList(),
};

Vtx color_bobomb_000_offset_005_mesh_layer_1_vtx_0[16] = {
	{{ {85, 0, -32}, 0, {-16, -16}, {97, 245, 174, 255} }},
	{{ {79, 28, -20}, 0, {-16, -16}, {74, 94, 212, 255} }},
	{{ {79, 28, 15}, 0, {-16, -16}, {73, 93, 48, 255} }},
	{{ {33, 28, -34}, 0, {-16, -16}, {254, 95, 172, 255} }},
	{{ {32, 0, -41}, 0, {-16, -16}, {251, 249, 129, 255} }},
	{{ {68, -30, -21}, 0, {-16, -16}, {53, 152, 206, 255} }},
	{{ {85, 0, 27}, 0, {-16, -16}, {96, 248, 83, 255} }},
	{{ {32, 0, 37}, 0, {-16, -16}, {253, 253, 127, 255} }},
	{{ {33, 28, 29}, 0, {-16, -16}, {0, 95, 85, 255} }},
	{{ {-29, 28, 12}, 0, {-16, -16}, {184, 88, 57, 255} }},
	{{ {-29, 28, -16}, 0, {-16, -16}, {184, 89, 201, 255} }},
	{{ {-36, 0, -20}, 0, {-16, -16}, {155, 214, 191, 255} }},
	{{ {27, -26, -31}, 0, {-16, -16}, {235, 155, 181, 255} }},
	{{ {68, -30, 16}, 0, {-16, -16}, {53, 151, 48, 255} }},
	{{ {27, -26, 27}, 0, {-16, -16}, {235, 155, 75, 255} }},
	{{ {-36, 0, 16}, 0, {-16, -16}, {156, 214, 66, 255} }},
};

Gfx color_bobomb_000_offset_005_mesh_layer_1_tri_0[] = {
	gsSPVertex(color_bobomb_000_offset_005_mesh_layer_1_vtx_0 + 0, 16, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(3, 1, 0, 0),
	gsSP1Triangle(3, 0, 4, 0),
	gsSP1Triangle(4, 0, 5, 0),
	gsSP1Triangle(6, 5, 0, 0),
	gsSP1Triangle(0, 2, 6, 0),
	gsSP1Triangle(7, 6, 2, 0),
	gsSP1Triangle(7, 2, 8, 0),
	gsSP1Triangle(8, 2, 1, 0),
	gsSP1Triangle(8, 1, 3, 0),
	gsSP1Triangle(3, 9, 8, 0),
	gsSP1Triangle(3, 10, 9, 0),
	gsSP1Triangle(4, 10, 3, 0),
	gsSP1Triangle(4, 11, 10, 0),
	gsSP1Triangle(12, 11, 4, 0),
	gsSP1Triangle(4, 5, 12, 0),
	gsSP1Triangle(12, 5, 13, 0),
	gsSP1Triangle(6, 13, 5, 0),
	gsSP1Triangle(14, 13, 6, 0),
	gsSP1Triangle(14, 6, 7, 0),
	gsSP1Triangle(7, 15, 14, 0),
	gsSP1Triangle(8, 15, 7, 0),
	gsSP1Triangle(8, 9, 15, 0),
	gsSP1Triangle(15, 9, 10, 0),
	gsSP1Triangle(15, 10, 11, 0),
	gsSP1Triangle(12, 15, 11, 0),
	gsSP1Triangle(12, 14, 15, 0),
	gsSP1Triangle(12, 13, 14, 0),
	gsSPEndDisplayList(),
};

Vtx color_bobomb_000_offset_008_mesh_layer_1_vtx_0[16] = {
	{{ {32, 0, 41}, 0, {-16, -16}, {252, 253, 127, 255} }},
	{{ {-36, 0, 20}, 0, {-16, -16}, {155, 215, 65, 255} }},
	{{ {27, -26, 31}, 0, {-16, -16}, {235, 155, 74, 255} }},
	{{ {33, 28, 33}, 0, {-16, -16}, {0, 95, 84, 255} }},
	{{ {79, 28, 20}, 0, {-16, -16}, {74, 92, 48, 255} }},
	{{ {84, 0, 32}, 0, {-16, -16}, {95, 247, 84, 255} }},
	{{ {68, -29, 21}, 0, {-16, -16}, {55, 152, 49, 255} }},
	{{ {27, -26, -27}, 0, {-16, -16}, {237, 155, 181, 255} }},
	{{ {-36, 0, -16}, 0, {-16, -16}, {155, 215, 191, 255} }},
	{{ {-28, 28, -12}, 0, {-16, -16}, {185, 90, 201, 255} }},
	{{ {-28, 28, 16}, 0, {-16, -16}, {186, 90, 56, 255} }},
	{{ {33, 28, -29}, 0, {-16, -16}, {255, 96, 173, 255} }},
	{{ {79, 28, -15}, 0, {-16, -16}, {75, 92, 212, 255} }},
	{{ {84, 0, -27}, 0, {-16, -16}, {97, 244, 174, 255} }},
	{{ {68, -29, -16}, 0, {-16, -16}, {55, 152, 207, 255} }},
	{{ {32, 0, -37}, 0, {-16, -16}, {253, 250, 129, 255} }},
};

Gfx color_bobomb_000_offset_008_mesh_layer_1_tri_0[] = {
	gsSPVertex(color_bobomb_000_offset_008_mesh_layer_1_vtx_0 + 0, 16, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(3, 1, 0, 0),
	gsSP1Triangle(0, 4, 3, 0),
	gsSP1Triangle(0, 5, 4, 0),
	gsSP1Triangle(2, 5, 0, 0),
	gsSP1Triangle(2, 6, 5, 0),
	gsSP1Triangle(7, 6, 2, 0),
	gsSP1Triangle(7, 2, 1, 0),
	gsSP1Triangle(7, 1, 8, 0),
	gsSP1Triangle(1, 9, 8, 0),
	gsSP1Triangle(1, 10, 9, 0),
	gsSP1Triangle(3, 10, 1, 0),
	gsSP1Triangle(11, 10, 3, 0),
	gsSP1Triangle(3, 12, 11, 0),
	gsSP1Triangle(3, 4, 12, 0),
	gsSP1Triangle(13, 12, 4, 0),
	gsSP1Triangle(13, 4, 5, 0),
	gsSP1Triangle(5, 14, 13, 0),
	gsSP1Triangle(5, 6, 14, 0),
	gsSP1Triangle(7, 14, 6, 0),
	gsSP1Triangle(15, 14, 7, 0),
	gsSP1Triangle(7, 8, 15, 0),
	gsSP1Triangle(15, 8, 9, 0),
	gsSP1Triangle(15, 9, 11, 0),
	gsSP1Triangle(11, 9, 10, 0),
	gsSP1Triangle(11, 13, 15, 0),
	gsSP1Triangle(11, 12, 13, 0),
	gsSP1Triangle(15, 13, 14, 0),
	gsSPEndDisplayList(),
};

Vtx color_bobomb_006_offset_mesh_layer_1_vtx_0[12] = {
	{{ {0, -100, 59}, 0, {-16, -16}, {0, 75, 103, 255} }},
	{{ {-53, -140, 27}, 0, {-16, -16}, {168, 177, 48, 255} }},
	{{ {0, -141, 58}, 0, {-16, -16}, {0, 176, 99, 255} }},
	{{ {-53, -99, 28}, 0, {-16, -16}, {169, 77, 52, 255} }},
	{{ {53, -99, 28}, 0, {-16, -16}, {87, 77, 52, 255} }},
	{{ {53, -140, 27}, 0, {-16, -16}, {88, 177, 48, 255} }},
	{{ {0, -138, -64}, 0, {-16, -16}, {0, 181, 153, 255} }},
	{{ {-53, -139, -33}, 0, {-16, -16}, {169, 179, 204, 255} }},
	{{ {-53, -98, -32}, 0, {-16, -16}, {168, 79, 208, 255} }},
	{{ {0, -97, -63}, 0, {-16, -16}, {0, 80, 157, 255} }},
	{{ {53, -98, -32}, 0, {-16, -16}, {88, 79, 208, 255} }},
	{{ {53, -139, -33}, 0, {-16, -16}, {87, 179, 204, 255} }},
};

Gfx color_bobomb_006_offset_mesh_layer_1_tri_0[] = {
	gsSPVertex(color_bobomb_006_offset_mesh_layer_1_vtx_0 + 0, 12, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 3, 1, 0),
	gsSP1Triangle(3, 0, 4, 0),
	gsSP1Triangle(4, 0, 2, 0),
	gsSP1Triangle(4, 2, 5, 0),
	gsSP1Triangle(6, 5, 2, 0),
	gsSP1Triangle(6, 2, 1, 0),
	gsSP1Triangle(6, 1, 7, 0),
	gsSP1Triangle(3, 7, 1, 0),
	gsSP1Triangle(3, 8, 7, 0),
	gsSP1Triangle(9, 8, 3, 0),
	gsSP1Triangle(4, 9, 3, 0),
	gsSP1Triangle(4, 10, 9, 0),
	gsSP1Triangle(10, 4, 5, 0),
	gsSP1Triangle(10, 5, 11, 0),
	gsSP1Triangle(6, 11, 5, 0),
	gsSP1Triangle(9, 11, 6, 0),
	gsSP1Triangle(8, 9, 6, 0),
	gsSP1Triangle(8, 6, 7, 0),
	gsSP1Triangle(9, 10, 11, 0),
	gsSPEndDisplayList(),
};

Vtx color_bobomb_000_offset_009_mesh_layer_4_vtx_0[6] = {
	{{ {128, -47, -49}, 0, {-16, -16}, {255, 255, 255, 255} }},
	{{ {128, 32, -49}, 0, {-16, 974}, {255, 255, 255, 255} }},
	{{ {133, 32, 0}, 0, {464, 974}, {255, 255, 255, 255} }},
	{{ {133, -47, 0}, 0, {464, -16}, {255, 255, 255, 255} }},
	{{ {128, 32, 50}, 0, {974, 974}, {255, 255, 255, 255} }},
	{{ {128, -47, 50}, 0, {974, -16}, {255, 255, 255, 255} }},
};

Gfx color_bobomb_000_offset_009_mesh_layer_4_tri_0[] = {
	gsSPVertex(color_bobomb_000_offset_009_mesh_layer_4_vtx_0 + 0, 6, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 2, 3, 0),
	gsSP1Triangle(3, 2, 4, 0),
	gsSP1Triangle(3, 4, 5, 0),
	gsSPEndDisplayList(),
};


Gfx mat_color_bobomb_body_right[] = {
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsSPCopyLightsPlayerPart(CAP),
	gsDPSetTextureImage(G_IM_FMT_IA, G_IM_SIZ_8b_LOAD_BLOCK, 1, color_bobomb_bob_omb_body_ia8),
	gsDPSetTile(G_IM_FMT_IA, G_IM_SIZ_8b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 2047, 256),
	gsDPSetTile(G_IM_FMT_IA, G_IM_SIZ_8b, 8, 0, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 6, 0, G_TX_WRAP | G_TX_NOMIRROR, 6, 0),
	gsDPSetTileSize(0, 0, 0, 252, 252),
	gsSPEndDisplayList(),
};

Gfx mat_color_bobomb_shoes[] = {
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsSPSetLights1(color_bobomb_shoes_lights),
	gsSPEndDisplayList(),
};

Gfx mat_color_bobomb_fuse[] = {
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsSPSetLights1(color_bobomb_fuse_lights),
	gsSPEndDisplayList(),
};

Gfx mat_color_bobomb_eyes[] = {
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0),
	gsSPClearGeometryMode(G_LIGHTING),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetTextureImage(G_IM_FMT_IA, G_IM_SIZ_8b_LOAD_BLOCK, 1, color_bobomb_bob_omb_eyes_rgba16_ia8),
	gsDPSetTile(G_IM_FMT_IA, G_IM_SIZ_8b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 511, 512),
	gsDPSetTile(G_IM_FMT_IA, G_IM_SIZ_8b, 4, 0, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 5, 0, G_TX_WRAP | G_TX_NOMIRROR, 5, 0),
	gsDPSetTileSize(0, 0, 0, 124, 124),
	gsSPEndDisplayList(),
};

Gfx mat_revert_color_bobomb_eyes[] = {
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPEndDisplayList(),
};

Gfx color_bobomb_000_displaylist_mesh_layer_4[] = {
	gsSPDisplayList(mat_color_bobomb_body_right),
	gsSPDisplayList(color_bobomb_000_displaylist_mesh_layer_4_tri_0),
	gsSPEndDisplayList(),
};

Gfx color_bobomb_000_offset_005_mesh_layer_1[] = {
	gsSPDisplayList(mat_color_bobomb_shoes),
	gsSPDisplayList(color_bobomb_000_offset_005_mesh_layer_1_tri_0),
	gsSPEndDisplayList(),
};

Gfx color_bobomb_000_offset_008_mesh_layer_1[] = {
	gsSPDisplayList(mat_color_bobomb_shoes),
	gsSPDisplayList(color_bobomb_000_offset_008_mesh_layer_1_tri_0),
	gsSPEndDisplayList(),
};

Gfx color_bobomb_006_offset_mesh_layer_1[] = {
	gsSPDisplayList(mat_color_bobomb_fuse),
	gsSPDisplayList(color_bobomb_006_offset_mesh_layer_1_tri_0),
	gsSPEndDisplayList(),
};

Gfx color_bobomb_000_offset_009_mesh_layer_4[] = {
	gsSPDisplayList(mat_color_bobomb_eyes),
	gsSPDisplayList(color_bobomb_000_offset_009_mesh_layer_4_tri_0),
	gsSPDisplayList(mat_revert_color_bobomb_eyes),
	gsSPEndDisplayList(),
};

Gfx color_bobomb_material_revert_render_settings[] = {
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

