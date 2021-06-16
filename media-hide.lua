obs           = obslua

function source_enable(source, enable)
    local sourcename = obs.obs_source_get_name(source)

    local scenes = obs.obs_frontend_get_scenes()
    if scenes ~= nil then
        for _, scenesource in ipairs(scenes) do
            local scenename = obs.obs_source_get_name(scenesource)
            local scene = obs.obs_scene_from_source(scenesource)
            local sceneitems = obs.obs_scene_enum_items(scene)
            local index = 1
            for i, sceneitem in ipairs(sceneitems) do
                local group = obs.obs_group_from_source(obs.obs_sceneitem_get_source(sceneitem))
                if group ~= nil then
                    local groupitems = obs.obs_scene_enum_items(group)
                    for _, groupitem in ipairs(groupitems) do
                        if sourcename == obs.obs_source_get_name(obs.obs_sceneitem_get_source(groupitem)) then
                            if obs.obs_sceneitem_visible(groupitem) ~= enable then
                                obs.obs_sceneitem_set_visible(groupitem,enable)
                            end
                        end
                    end
                end
                if sourcename == obs.obs_source_get_name(obs.obs_sceneitem_get_source(sceneitem)) then
                    if obs.obs_sceneitem_visible(sceneitem) ~= enable then
                        obs.obs_sceneitem_set_visible(sceneitem,enable)
                    end
                end
            end
            obs.sceneitem_list_release(sceneitems)
        end
        obs.source_list_release(scenes)
    end
end

function script_properties()
	local props = obs.obs_properties_create()
    return props;
end

function script_description()
	return "Hide media sources when ended"
end

function script_update(settings)

end

function script_defaults(settings)

end

function media_ended(cd)
    local source = obs.calldata_source(cd, "source")
    source_enable(source, false);
end

function listen_media_ended(source) 
    local sh = obs.obs_source_get_signal_handler(source);
    obs.signal_handler_disconnect(sh,"media_ended",media_ended)
    obs.signal_handler_connect(sh,"media_ended",media_ended)
end

function source_create(cd)
    listen_media_ended(obs.calldata_source(cd, "source"))
end

function script_load(settings)
    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            listen_media_ended(source)
        end
        obs.source_list_release(sources)
    end
    local sh = obs.obs_get_signal_handler()
    obs.signal_handler_connect(sh, "source_create", source_create)
end

function script_unload()

end