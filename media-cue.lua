obs         = obslua
hotkey_id   = obs.OBS_INVALID_HOTKEY_ID
source_name = ""
time_ms        = 1000

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source")
    time_ms = obs.obs_data_get_int(settings, "time")
end

function script_description()
	return "Select a media source and cue point \n\nMade by Exeldro"
end

function script_properties()
    props = obs.obs_properties_create()
	local p = obs.obs_properties_add_list(props, "source", "Media Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_enum_sources()
	if sources ~= nil then
        for _, source in ipairs(sources) do
            local name = obs.obs_source_get_name(source)
            obs.obs_property_list_add_string(p, name, name)
		end
	end
    obs.source_list_release(sources)
    p = obs.obs_properties_add_int(props,"time","Time",-100000,1000000,1000)
    obs.obs_property_int_set_suffix(p, "ms")
    return props
end

function play_cue(pressed)
    if not pressed then
		return
    end
    local source = obs.obs_get_source_by_name(source_name)
    if source == nil then
        return
    end
    if time_ms < 0 then
        local duration = obs.obs_source_media_get_duration(source)
        if duration + time_ms > 0 then
            obs.obs_source_media_set_time(source, duration + time_ms)
        end
    else    
        obs.obs_source_media_set_time(source, time_ms)
    end
    obs.obs_source_media_play_pause(source, false)
    obs.obs_source_release(source)
end

function script_load(settings)
    hotkey_id = obs.obs_hotkey_register_frontend("media_cue","Play Cue", play_cue)
    local hotkey_save_array = obs.obs_data_get_array(settings, "media_cue")
	obs.obs_hotkey_load(hotkey_id, hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)
    script_update(settings)
end

function script_save(settings)
    local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
	obs.obs_data_set_array(settings, "media_cue", hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
end