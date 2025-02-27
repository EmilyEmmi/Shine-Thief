#include "src/game/envfx_snow.h"

const GeoLayout pow_block_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_CULLING_RADIUS(300),
		GEO_OPEN_NODE(),
			GEO_SHADOW(0, 180, 70),
			GEO_OPEN_NODE(),
				GEO_SWITCH_CASE(4, geo_switch_anim_state),
				GEO_OPEN_NODE(),
					GEO_NODE_START(),
					GEO_OPEN_NODE(),
						GEO_DISPLAY_LIST(LAYER_OPAQUE, pow_block_000_displaylist_mesh_layer_1),
						GEO_DISPLAY_LIST(LAYER_ALPHA, pow_block_000_displaylist_mesh_layer_4),
					GEO_CLOSE_NODE(),
				GEO_CLOSE_NODE(),
			GEO_CLOSE_NODE(),
		GEO_CLOSE_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, pow_block_material_revert_render_settings),
		GEO_DISPLAY_LIST(LAYER_ALPHA, pow_block_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
