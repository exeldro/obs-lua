obs = obslua
hotkey_id = obs.OBS_INVALID_HOTKEY_ID
source_base_name = "Text"
font = nil

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "source_name", "Source Name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_font(props, "font", "Font")
    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "source_name", "Text")
end

function script_description()
	return "Adds hotkey to add a text source"
end

function script_update(settings)
    source_base_name = obs.obs_data_get_string(settings, "source_name")
    if font ~= nil then
        obs.obs_data_release(font)
    end
    font = obs.obs_data_get_obj(settings, "font")
end

function create_text_source_trigger(pressed)
	if not pressed then
		return
    end
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
    local text_settings = obs.obs_data_create()
    obs.obs_data_set_obj(text_settings, "font", font)
    if os.getenv('OS'):lower():match('windows') then
        source = obs.obs_source_create("text_gdiplus", source_name, text_settings, nil)
    else
        source = obs.obs_source_create("text_ft2_source", source_name, text_settings, nil)
    end
    obs.obs_data_release(text_settings)
    if source ~= nil then
        local scene_source = obs.obs_frontend_get_current_scene()
        local scene = obs.obs_scene_from_source(scene_source)
        local item = obs.obs_scene_add(scene, source)
        obs.obs_source_release(scene_source)
        obs.obs_source_release(source)
    end
end

function script_load(settings)
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
    if font ~= nil then
        obs.obs_data_release(font)
        font = nil
    end
end