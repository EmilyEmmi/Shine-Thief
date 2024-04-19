#include "src/game/envfx_snow.h"

const GeoLayout balloon_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		// GEO_SHADOW(0, 0, 0),
		GEO_OPEN_NODE(),
			GEO_ASM(0, geo_update_layer_transparency),
			GEO_ASM(LAYER_TRANSPARENT + 3, geo_mario_set_player_colors),
			GEO_DISPLAY_LIST(LAYER_TRANSPARENT, balloon_000_displaylist_mesh_layer_5),
		GEO_CLOSE_NODE(),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, balloon_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
