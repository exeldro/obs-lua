obs         = obslua
source_name = ""
last_state  = obs.OBS_MEDIA_STATE_NONE

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source")
end

function script_description()
	return "Select a media source to change visibility after playback\n\nMade by Exeldro"
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
    return props
end

function script_load(settings)
    script_update(settings)
end

function script_save(settings)

end

function script_tick(seconds)
    local source = obs.obs_get_source_by_name(source_name)
    if source ~= nil then
        local state = obs.obs_source_media_get_state(source)
        if last_state ~= state then
            last_state = state
            if state == obs.OBS_MEDIA_STATE_STOPPED or state == obs.OBS_MEDIA_STATE_ENDED then
                local scenes = obs.obs_frontend_get_scenes()
                if scenes ~= nil then
                    for _, scenesource in ipairs(scenes) do
                        local scene = obs.obs_scene_from_source(scenesource)
                        local sceneitems = obs.obs_scene_enum_items(scene)
                        for i, sceneitem in ipairs(sceneitems) do
                            local itemsource = obs.obs_sceneitem_get_source(sceneitem)
                            local sourcename = obs.obs_source_get_name(itemsource)
                            if sourcename == source_name then
                                obs.obs_sceneitem_set_visible(sceneitem, false)
                            end
                        end
                    end
                end
            end
        end
    end
    obs.obs_source_release(source)
end
