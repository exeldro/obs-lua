obs = obslua
hotkey_id = obs.OBS_INVALID_HOTKEY_ID
sources = {4,5}
toggle_position = true

-- desktop-1 = 1
-- desktop-2 = 2
-- mic-1 = 3
-- mic-2 = 4
-- mic-3 = 5



function script_properties()
	local props = obs.obs_properties_create()
    obs.obs_properties_add_button(props,"toggle_ptt","Toggle Push To Talk",toggle_ptt)
	return props
end

function script_description()
	return "Adds hotkey to toggle enable push to talk"
end

function script_update(settings)

end

function toggle_ptt_trigger(pressed)
	if not pressed then
		return
    end
    toggle_ptt()
end

function toggle_ptt()
	toggle_position = not toggle_position
	for _, source in next, sources do		
		local source_ref = nil
		if type(source) == "number" then
			source_ref = obs.obs_get_output_source(source)
		elseif type(source) == "string" then
			source_ref = obs.obs_get_source_by_name(source)
		end
		if source_ref ~= nil then
			obs.obs_source_enable_push_to_talk(source_ref, toggle_position)
			obs.obs_source_release(source_ref)
		end
	end
end

function script_load(settings)
    hotkey_id = obs.obs_hotkey_register_frontend("toggle_ptt_trigger","Toggle Push To Talk", toggle_ptt_trigger)
    local hotkey_save_array = obs.obs_data_get_array(settings, "toggle_ptt_trigger")
	obs.obs_hotkey_load(hotkey_id, hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)
end

function script_save(settings)
	local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
	obs.obs_data_set_array(settings, "toggle_ptt_trigger", hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)
end