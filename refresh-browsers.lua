obs = obslua
hotkey_id = obs.OBS_INVALID_HOTKEY_ID

function script_properties()
	local props = obs.obs_properties_create()
    obs.obs_properties_add_button(props,"refresh_browsers","Refresh Browsers",refresh_browsers)
	return props
end

function script_description()
	return "Adds hotkey to refesh all browsers"
end

function script_update(settings)

end

function refresh_browsers_trigger(pressed)
	if not pressed then
		return
    end
    refresh_browsers()
end

function refresh_browsers()
    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            local source_id = obs.obs_source_get_unversioned_id(source)
            if source_id == "browser_source" then
                local settings = obs.obs_source_get_settings(source)
                local fps = obs.obs_data_get_int(settings, "fps")
                if fps % 2 == 0 then
                    obs.obs_data_set_int(settings,"fps",fps + 1)
                else
                    obs.obs_data_set_int(settings,"fps",fps - 1)
                end
                obs.obs_source_update(source, settings)
                obs.obs_data_release(settings)
            end
        end
    end
    obs.source_list_release(sources)
end

function script_load(settings)
    hotkey_id = obs.obs_hotkey_register_frontend("refresh_browsers.trigger","Refresh all browsers", refresh_browsers_trigger)
    local hotkey_save_array = obs.obs_data_get_array(settings, "refresh_browsers.trigger")
	obs.obs_hotkey_load(hotkey_id, hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)
end

function script_save(settings)
	local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
	obs.obs_data_set_array(settings, "refresh_browsers.trigger", hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)
end