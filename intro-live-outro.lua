obs = obslua
intro_source_name = ""
intro_scene_name  = ""
live_source_name  = ""
live_scene_name   = ""
outro_source_name = ""
outro_scene_name  = ""

last_action = 0
retry_seconds = 5

function script_tick(seconds)
    if obs.obs_frontend_streaming_active() then
        local scene = obs.obs_frontend_get_current_scene()
        if scene ~= nil then
            local scene_name = obs.obs_source_get_name(scene)
            if scene_name == intro_scene_name then
                local intro_source = obs.obs_get_source_by_name(intro_source_name)
                if intro_source ~= nil then
                    local media_state = obs.obs_source_media_get_state(intro_source)
                    if media_state == obs.OBS_MEDIA_STATE_PLAYING then
                    elseif media_state == obs.OBS_MEDIA_STATE_BUFFERING then
                    elseif media_state == obs.OBS_MEDIA_STATE_PAUSED then
                    else
                        local live_scene = obs.obs_get_source_by_name(live_scene_name)
                        if live_scene ~= nil then
                            obs.obs_frontend_set_current_scene(live_scene)
                            obs.obs_source_release(live_scene)
                        end
                    end
                    obs.obs_source_release(intro_source)
                end
            elseif scene_name == live_scene_name then
                local live_source = obs.obs_get_source_by_name(live_source_name)
                if live_source ~= nil then
                    local media_state = obs.obs_source_media_get_state(live_source)
                    if media_state == obs.OBS_MEDIA_STATE_PLAYING then
                    else
                        local outro_scene = obs.obs_get_source_by_name(outro_scene_name)
                        if outro_scene ~= nil then
                            obs.obs_frontend_set_current_scene(outro_scene)
                            obs.obs_source_release(outro_scene)
                        end
                    end
                    obs.obs_source_release(live_source)
                end
            elseif scene_name == outro_scene_name then
                local outro_source = obs.obs_get_source_by_name(outro_source_name)
                if outro_source ~= nil then
                    local media_state = obs.obs_source_media_get_state(outro_source)
                    if media_state == obs.OBS_MEDIA_STATE_PLAYING then
                    elseif media_state == obs.OBS_MEDIA_STATE_BUFFERING then
                    elseif media_state == obs.OBS_MEDIA_STATE_PAUSED then
                    else
                        if last_action > retry_seconds then
                            obs.obs_frontend_streaming_stop()
                            last_action = 0
                        end
                    end
                    obs.obs_source_release(outro_source)
                end
            end 
            obs.obs_source_release(scene)
        end
    else
        local live_source = obs.obs_get_source_by_name(live_source_name)
        if live_source ~= nil then
            local media_state = obs.obs_source_media_get_state(live_source)
            if media_state == obs.OBS_MEDIA_STATE_PLAYING then
                local scene = obs.obs_frontend_get_current_scene()
                if scene ~= nil then
                    if obs.obs_source_get_name(scene) == intro_scene_name then
                        obs.obs_source_release(scene)
                    else
                        obs.obs_source_release(scene)
                        scene = obs.obs_get_source_by_name(intro_scene_name)
                        if scene ~= nil then
                            obs.obs_frontend_set_current_scene(scene)
                            obs.obs_source_release(scene)
                        end
                    end
                else
                    scene = obs.obs_get_source_by_name(intro_scene_name)
                    if scene ~= nil then
                        obs.obs_frontend_set_current_scene(scene)
                        obs.obs_source_release(scene)
                    end
                end
                if last_action > retry_seconds then
                    obs.obs_frontend_streaming_start()
                    last_action = 0
                end
            elseif media_state == obs.OBS_MEDIA_STATE_NONE then
                if last_action > retry_seconds then
                    obs.obs_source_media_restart(live_source)
                    last_action = 0
                end
            elseif media_state == obs.OBS_MEDIA_STATE_ENDED then
                if last_action > retry_seconds then
                    obs.obs_source_media_restart(live_source)
                    last_action = 0
                end
            elseif media_state == obs.OBS_MEDIA_STATE_STOPPED then
                if last_action > retry_seconds then
                    obs.obs_source_media_restart(live_source)
                    last_action = 0
                end
            elseif media_state == obs.OBS_MEDIA_STATE_ERROR then
                if last_action > retry_seconds then
                    obs.obs_source_media_restart(live_source)
                    last_action = 0
                end
            end
            obs.obs_source_release(live_source)
        end
    end
    last_action = last_action + seconds
end

function script_update(settings)
    intro_source_name = obs.obs_data_get_string(settings, "intro_source")
    intro_scene_name = obs.obs_data_get_string(settings, "intro_scene")
    live_source_name = obs.obs_data_get_string(settings, "live_source")
    live_scene_name = obs.obs_data_get_string(settings, "live_scene")
    outro_source_name = obs.obs_data_get_string(settings, "outro_source")
    outro_scene_name = obs.obs_data_get_string(settings, "outro_scene")
end

function script_description()
	return "Intro, Live and outro\n\nMade by Exeldro"
end

function script_properties()
    props = obs.obs_properties_create()
	local intro = obs.obs_properties_add_list(props, "intro_source", "Intro Media Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    local live = obs.obs_properties_add_list(props, "live_source", "Live Media Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    local outro = obs.obs_properties_add_list(props, "outro_source", "Outro Media Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)

	local sources = obs.obs_enum_sources()
	if sources ~= nil then
        for _, source in ipairs(sources) do
            local name = obs.obs_source_get_name(source)
            obs.obs_property_list_add_string(intro, name, name)
            obs.obs_property_list_add_string(live, name, name)
            obs.obs_property_list_add_string(outro, name, name)
		end
	end
    obs.source_list_release(sources)
    obs.obs_properties_add_text(props, "intro_scene", "Intro Scene", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "live_scene", "Live Scene", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "outro_scene", "Outro Scene", obs.OBS_TEXT_DEFAULT)
    return props
end

function script_defaults(settings)

end

function script_load(settings)
    script_update(settings)
end

function script_save(settings)

end