obs           = obslua
gs            = nil

function script_properties()
	local props = obs.obs_properties_create()
    local scene1 = obs.obs_properties_add_list(props, "scene1", "Scene or group", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    local source1 = obs.obs_properties_add_list(props, "source1", "Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    local scene2 = obs.obs_properties_add_list(props, "scene2", "Scene or group", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    local source2 = obs.obs_properties_add_list(props, "source2", "Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            source_id = obs.obs_source_get_id(source)
            local name = obs.obs_source_get_name(source)
            if source_id == "group" then
                obs.obs_property_list_add_string(scene1, name, name)
                obs.obs_property_list_add_string(scene2, name, name)
            else
                obs.obs_property_list_add_string(source1, name, name)
                obs.obs_property_list_add_string(source2, name, name)
            end
        end
        obs.source_list_release(sources)
    end
        
    local scenes = obs.obs_frontend_get_scene_names()
    if scenes ~= nil then
        for _, scene in ipairs(scenes) do
            obs.obs_property_list_add_string(scene1, scene, scene)
            obs.obs_property_list_add_string(scene2, scene, scene)
        end
    end

	return props
end

function script_description()
	return "Toggle visibility between 2 sources"
end

function item_visible(calldata)
    local visible = obs.calldata_bool(calldata,"visible")
    local item = obs.calldata_sceneitem(calldata,"item")
    local source = obs.obs_sceneitem_get_source(item)
    local sourceName = obs.obs_source_get_name(source)
    local scene = obs.obs_sceneitem_get_scene(item)
    local sceneSource = obs.obs_scene_get_source(scene)
    local sceneName = obs.obs_source_get_name(sceneSource)
    if sceneName == obs.obs_data_get_string(gs, "scene2") and sourceName == obs.obs_data_get_string(gs, "source2") then
        local otherSceneSource = obs.obs_get_source_by_name(obs.obs_data_get_string(gs, "scene1"))
        if otherSceneSource ~= nil then
            local otherScene = obs.obs_group_or_scene_from_source(otherSceneSource)
            if otherScene ~= nil then
                local otherItem = obs.obs_scene_find_source(otherScene, obs.obs_data_get_string(gs, "source1"))
                if otherItem ~= nil and otherItem ~= item then
                    if obs.obs_sceneitem_visible(otherItem) == visible then
                        obs.obs_sceneitem_set_visible(otherItem, not visible)
                    end
                end
            end
            obs.obs_source_release(otherSceneSource)
        end
    elseif sceneName == obs.obs_data_get_string(gs, "scene1") and sourceName == obs.obs_data_get_string(gs, "source1") then
        local otherSceneSource = obs.obs_get_source_by_name(obs.obs_data_get_string(gs, "scene2"))
        if otherSceneSource ~= nil then
            local otherScene = obs.obs_group_or_scene_from_source(otherSceneSource)
            if otherScene ~= nil then
                local otherItem = obs.obs_scene_find_source(otherScene, obs.obs_data_get_string(gs, "source2"))
                if otherItem ~= nil and otherItem ~= item then
                    if obs.obs_sceneitem_visible(otherItem) == visible then
                        obs.obs_sceneitem_set_visible(otherItem, not visible)
                    end
                end
            end
            obs.obs_source_release(otherSceneSource)
        end
    end
end

function script_update(settings)
    local sourceName = obs.obs_data_get_string(settings, "scene1")
    local source = obs.obs_get_source_by_name(sourceName)
    if source ~= nil then
        local sh = obs.obs_source_get_signal_handler(source);
        obs.signal_handler_disconnect(sh,"item_visible",item_visible)
        obs.signal_handler_connect(sh,"item_visible",item_visible)
        obs.obs_source_release(source)
    end
    sourceName = obs.obs_data_get_string(settings, "scene2")
    source = obs.obs_get_source_by_name(sourceName)
    if source ~= nil then
        local sh = obs.obs_source_get_signal_handler(source);
        obs.signal_handler_disconnect(sh,"item_visible",item_visible)
        obs.signal_handler_connect(sh,"item_visible",item_visible)
        obs.obs_source_release(source)
    end
end

function script_defaults(settings)

end

function script_save(settings)

end

function loaded(cd)
    if gs == nil then
        return
    end
    local source = obs.calldata_source(cd, "source")
    local sn = obs.obs_source_get_name(source)

    local sourceName = obs.obs_data_get_string(gs, "scene1")
    if sn == sourceName then
        local sh = obs.obs_source_get_signal_handler(source);
        obs.signal_handler_disconnect(sh,"item_visible",item_visible)
        obs.signal_handler_connect(sh,"item_visible",item_visible)
    end

    sourceName = obs.obs_data_get_string(gs, "scene2")
    if sn == sourceName then
        local sh = obs.obs_source_get_signal_handler(source);
        obs.signal_handler_disconnect(sh,"item_visible",item_visible)
        obs.signal_handler_connect(sh,"item_visible",item_visible)
    end
end

function script_load(settings)
    gs = settings
    local sh = obs.obs_get_signal_handler()
    obs.signal_handler_connect(sh, "source_load", loaded)
    script_update(settings)
end

function script_unload()

end