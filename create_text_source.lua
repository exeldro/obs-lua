obs = obslua
hotkey_id = obs.OBS_INVALID_HOTKEY_ID
global_settings = nil

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "source_name", "Source Name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_font(props, "font", "Font")
    obs.obs_properties_add_color(props, "color", "Color")
    local p = obs.obs_properties_add_int_slider(props, "opacity", "Opacity", 0, 100, 1)
	obs.obs_property_int_set_suffix(p, "%")
    obs.obs_properties_add_color(props, "bk_color", "Background Color")
    local p = obs.obs_properties_add_int_slider(props, "bk_opacity", "Background Opacity", 0, 100, 1)
	obs.obs_property_int_set_suffix(p, "%")

    local outline = obs.obs_properties_create()
    obs.obs_properties_add_int(outline, "outline_size", "Size", 1, 20, 1);
    obs.obs_properties_add_color(outline, "outline_color", "Color")
    local p = obs.obs_properties_add_int_slider(outline, "outline_opacity", "Opacity", 0, 100, 1)
	obs.obs_property_int_set_suffix(p, "%")
    obs.obs_properties_add_group(props, "outline", "Outline", obs.OBS_GROUP_CHECKABLE, outline)

    p = obs.obs_properties_add_list(props, "align", "Align", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    obs.obs_property_list_add_string(p, "Left", "left")
	obs.obs_property_list_add_string(p, "Center", "center")
	obs.obs_property_list_add_string(p, "Right", "right")
    p = obs.obs_properties_add_list(props, "valign", "Vertical Align", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    obs.obs_property_list_add_string(p, "Top", "top")
	obs.obs_property_list_add_string(p, "Center", "center")
	obs.obs_property_list_add_string(p, "Bottom", "bottom")
    local extents = obs.obs_properties_create()
    obs.obs_properties_add_int(extents, "extents_cx", "X", 32, 8000, 1)
	obs.obs_properties_add_int(extents, "extents_cy", "Y", 32, 8000, 1)
	obs.obs_properties_add_bool(extents, "extents_wrap", "Wrap")
    obs.obs_properties_add_group(props, "extents", "Extents", obs.OBS_GROUP_CHECKABLE, extents)
    obs.obs_properties_add_text(props, "text", "Text", obs.OBS_TEXT_MULTILINE)
    return props
end

function script_defaults(settings)
    local font = obs.obs_data_create()
    obs.obs_data_set_default_string(font, "face", "Arial")
	obs.obs_data_set_default_int(font, "size", 256)
	obs.obs_data_set_default_obj(settings, "font", font)
    obs.obs_data_release(font)

    obs.obs_data_set_default_string(settings, "source_name", "Text")
    obs.obs_data_set_default_int(settings, "color", 0xFFFFFF)
    obs.obs_data_set_default_int(settings, "opacity", 100)
    obs.obs_data_set_default_int(settings, "bk_color", 0x000000)
	obs.obs_data_set_default_int(settings, "bk_opacity", 0)
    obs.obs_data_set_default_int(settings, "outline_size", 2);
	obs.obs_data_set_default_int(settings, "outline_color", 0xFFFFFF);
	obs.obs_data_set_default_int(settings, "outline_opacity", 100);
    obs.obs_data_set_default_string(settings, "align", "left")
    obs.obs_data_set_default_string(settings, "valign", "top")

    obs.obs_data_set_default_bool(settings, "extents_wrap", true)
	obs.obs_data_set_default_int(settings, "extents_cx", 100)
	obs.obs_data_set_default_int(settings, "extents_cy", 100)
end

function script_description()
	return "Adds hotkey to add a text source"
end

function script_update(settings)
    
end

function create_text_source_trigger(pressed)
	if not pressed then
		return
    end
    local source_base_name = obs.obs_data_get_string(global_settings, "source_name")
    local source_name = source_base_name
    local source = obs.obs_get_source_by_name(source_name)
    local source_count = 1
    while source ~= nil
    do
        obs.obs_source_release(source)
        source_name = source_base_name .." "..source_count
        source = obs.obs_get_source_by_name(source_name)
        source_count = source_count + 1
    end

    local settings = obs.obs_data_create_from_json(obs.obs_data_get_json(global_settings))
    local windows = false
    if os ~= nil then
        local os_name = os.getenv('OS')
        if os_name ~= nil then 
            if os_name:lower():match('windows') then
                windows = true
            end
        end
    end
    if windows then
        source = obs.obs_source_create(obs.obs_get_latest_input_type_id("text_gdiplus"), source_name, settings, nil)
    else
        source = obs.obs_source_create(obs.obs_get_latest_input_type_id("text_ft2_source"), source_name, settings, nil)
    end
    obs.obs_data_release(settings)
    if source ~= nil then
        local scene_source = obs.obs_frontend_get_current_scene()
        local scene = obs.obs_scene_from_source(scene_source)
        local item = obs.obs_scene_add(scene, source)
        local pos = obs.vec2()
        pos.x = obs.obs_source_get_width(scene_source)/2
        pos.y = obs.obs_source_get_height(scene_source)/2
        obs.obs_sceneitem_set_pos(item, pos)
        obs.obs_sceneitem_set_alignment(item, 0)
        obs.obs_source_release(scene_source)
        obs.obs_source_release(source)
    end
end

function script_load(settings)
    global_settings = settings
    hotkey_id = obs.obs_hotkey_register_frontend("create_text_source.trigger","Add Text Source", create_text_source_trigger)
    local hotkey_save_array = obs.obs_data_get_array(settings, "create_text_source.trigger")
	obs.obs_hotkey_load(hotkey_id, hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)
end

function script_save(settings)
	local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
	obs.obs_data_set_array(settings, "create_text_source.trigger", hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)
end

function script_unload()

end