obs           = obslua
source_name   = ""
enable_hotkey_id     = obs.OBS_INVALID_HOTKEY_ID
disable_hotkey_id     = obs.OBS_INVALID_HOTKEY_ID

function enable_button_clicked(props, p)
	source_enable(true)
	return false
end

function enable_hotkey(pressed)
	if pressed then
		source_enable(true)
    end
end

function disable_button_clicked(props, p)
	source_enable(false)
	return false
end

function disable_hotkey(pressed)
	if pressed then
		source_enable(false)
    end
end

function source_enable(enable)
    local scenes = obs.obs_frontend_get_scenes()
    if scenes ~= nil then
        for _, scenesource in ipairs(scenes) do
            local scenename = obs.obs_source_get_name(scenesource)
            local scene = obs.obs_scene_from_source(scenesource)
            local sceneitems = obs.obs_scene_enum_items(scene)
            local maxindex = 0
            local index = 1
            for i, sceneitem in ipairs(sceneitems) do
                local source = obs.obs_sceneitem_get_source(sceneitem)
                local sourcename = obs.obs_source_get_name(source)
                if sourcename == source_name then
                    obs.obs_sceneitem_set_visible(sceneitem,enable)
                end
            end
            obs.sceneitem_list_release(sceneitems)
        end
        obs.source_list_release(scenes)
        --obs.obs_frontend_source_list_free(scenes)
    end
end

function script_properties()
	local props = obs.obs_properties_create()
    local p = obs.obs_properties_add_list(props, "source", "Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            local name = obs.obs_source_get_name(source)
             obs.obs_property_list_add_string(p, name, name)
        end
        obs.source_list_release(sources)
    end
    obs.obs_properties_add_button(props, "source_enable", "Enable", enable_button_clicked)
    obs.obs_properties_add_button(props, "source_disable", "Disable", disable_button_clicked)
	return props
end

function script_description()
	return "Add hotkeys to enable and disable a source on all scenes"
end

function script_update(settings)
    local sn = obs.obs_data_get_string(settings, "source")
    if source_name ~= sn then
        obs.obs_hotkey_unregister(enable_hotkey)
        source_name = sn
        enable_hotkey_id = obs.obs_hotkey_register_frontend("enable_" .. sn, "Enable " .. sn, enable_hotkey)
        local hotkey_save_array = obs.obs_data_get_array(settings, "enable_hotkey")
        obs.obs_hotkey_load(enable_hotkey_id, hotkey_save_array)
        obs.obs_data_array_release(hotkey_save_array)
        disable_hotkey_id = obs.obs_hotkey_register_frontend("disable_" .. sn, "Disable " .. sn, disable_hotkey)
        hotkey_save_array = obs.obs_data_get_array(settings, "disable_hotkey")
        obs.obs_hotkey_load(disable_hotkey_id, hotkey_save_array)
        obs.obs_data_array_release(hotkey_save_array)
    end
    
end

function script_defaults(settings)

end

function script_save(settings)
	local hotkey_save_array = obs.obs_hotkey_save(enable_hotkey_id)
	obs.obs_data_set_array(settings, "enable_hotkey", hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
    hotkey_save_array = obs.obs_hotkey_save(disable_hotkey_id)
	obs.obs_data_set_array(settings, "disable_hotkey", hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)
end

function script_load(settings)
    script_update(settings)
end
