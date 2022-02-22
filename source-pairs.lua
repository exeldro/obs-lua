obs           = obslua
gs            = nil
pair_count    = 1
pairs_max     = 20

function pair_count_changed(props, property, settings)
    local scene_array  = {}
    local source_array  = {}
    local changed = false
    if settings ~= nil then
        local pc = obs.obs_data_get_int(settings, "pair_count")
        if pc > 0 then
            pair_count = pc
        end
    end
    for i = 1, pair_count, 1 
    do 
        local p = obs.obs_properties_get(props, "pair_" .. i .. "_group")
        if p == nil then
            changed = true
            local group = obs.obs_properties_create()
            table.insert(scene_array, obs.obs_properties_add_list(group, "pair_" .. i .. "_scene_a", "Scene or group", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING))
            table.insert(source_array, obs.obs_properties_add_list(group, "pair_" .. i .. "_source_a", "Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING))
            table.insert(scene_array, obs.obs_properties_add_list(group, "pair_" .. i .. "_scene_b", "Scene or group", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING))
            table.insert(source_array, obs.obs_properties_add_list(group, "pair_" .. i .. "_source_b", "Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING))
            obs.obs_properties_add_bool(group, "pair_" .. i .. "_same", "Same")
            obs.obs_properties_add_group(props, "pair_" .. i .. "_group", "Pair ".. i, obs.OBS_GROUP_NORMAL, group)
        end
    end
    if changed then
        local sources = obs.obs_enum_sources()
        if sources ~= nil then
            for _, source in ipairs(sources) do
                source_id = obs.obs_source_get_id(source)
                local name = obs.obs_source_get_name(source)
                if source_id == "group" then
                    for key,value in pairs(scene_array) do
                        obs.obs_property_list_add_string(value, name, name)
                    end
                else
                    for key,value in pairs(source_array) do
                        obs.obs_property_list_add_string(value, name, name)
                    end
                end
            end
            obs.source_list_release(sources)
        end
            
        local scenes = obs.obs_frontend_get_scene_names()
        if scenes ~= nil then
            for _, scene in ipairs(scenes) do
                for key,value in pairs(scene_array) do
                    obs.obs_property_list_add_string(value, scene, scene)
                end
                for key,value in pairs(source_array) do
                    obs.obs_property_list_add_string(value, scene, scene)
                end
            end
        end
    end

    for i = pair_count + 1, pairs_max, 1 
    do
        local p = obs.obs_properties_get(props, "pair_" .. i .. "_group")
        if p ~= nil then
            obs.obs_properties_remove_by_name(props, "pair_" .. i .. "_group")
            changed = true
        end
    end
    return changed
end

function script_properties()
	local props = obs.obs_properties_create()
    local pairs = obs.obs_properties_add_int_slider(props, "pair_count", "Pairs", 1, pairs_max, 1)
    obs.obs_property_set_modified_callback(pairs, pair_count_changed)
    pair_count_changed(props)
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
    for i = 1, pair_count, 1 
    do 
        if sceneName == obs.obs_data_get_string(gs, "pair_"..i.."_scene_b") and sourceName == obs.obs_data_get_string(gs, "pair_"..i.."_source_b") then
            local otherSceneSource = obs.obs_get_source_by_name(obs.obs_data_get_string(gs, "pair_"..i.."_scene_a"))
            if otherSceneSource ~= nil then
                local otherScene = obs.obs_group_or_scene_from_source(otherSceneSource)
                if otherScene ~= nil then
                    local otherItem = obs.obs_scene_find_source(otherScene, obs.obs_data_get_string(gs, "pair_"..i.."_source_a"))
                    if otherItem ~= nil and otherItem ~= item then
                        if obs.obs_data_get_bool(gs, "pair_"..i.."_same") then
                            if obs.obs_sceneitem_visible(otherItem) ~= visible then
                                obs.obs_sceneitem_set_visible(otherItem, visible)
                            end
                        else
                            if obs.obs_sceneitem_visible(otherItem) == visible then
                                obs.obs_sceneitem_set_visible(otherItem, not visible)
                            end
                        end
                    end
                end
                obs.obs_source_release(otherSceneSource)
            end
        elseif sceneName == obs.obs_data_get_string(gs, "pair_"..i.."_scene_a") and sourceName == obs.obs_data_get_string(gs, "pair_"..i.."_source_a") then
            local otherSceneSource = obs.obs_get_source_by_name(obs.obs_data_get_string(gs, "pair_"..i.."_scene_b"))
            if otherSceneSource ~= nil then
                local otherScene = obs.obs_group_or_scene_from_source(otherSceneSource)
                if otherScene ~= nil then
                    local otherItem = obs.obs_scene_find_source(otherScene, obs.obs_data_get_string(gs, "pair_"..i.."_source_b"))
                    if otherItem ~= nil and otherItem ~= item then
                        if obs.obs_data_get_bool(gs, "pair_"..i.."_same") then
                            if obs.obs_sceneitem_visible(otherItem) ~= visible then
                                obs.obs_sceneitem_set_visible(otherItem, visible)
                            end
                        else
                            if obs.obs_sceneitem_visible(otherItem) == visible then
                                obs.obs_sceneitem_set_visible(otherItem, not visible)
                            end
                        end
                    end
                end
                obs.obs_source_release(otherSceneSource)
            end
        end
    end
end

function script_update(settings)
    pair_count = obs.obs_data_get_int(settings, "pair_count")
    for i = 1, pair_count, 1 
    do 
        local sourceName = obs.obs_data_get_string(settings, "pair_"..i.."_scene_a")
        local source = obs.obs_get_source_by_name(sourceName)
        if source ~= nil then
            local sh = obs.obs_source_get_signal_handler(source);
            obs.signal_handler_disconnect(sh,"item_visible",item_visible)
            obs.signal_handler_connect(sh,"item_visible",item_visible)
            obs.obs_source_release(source)
        end
        sourceName = obs.obs_data_get_string(settings, "pair_"..i.."_scene_b")
        source = obs.obs_get_source_by_name(sourceName)
        if source ~= nil then
            local sh = obs.obs_source_get_signal_handler(source);
            obs.signal_handler_disconnect(sh,"item_visible",item_visible)
            obs.signal_handler_connect(sh,"item_visible",item_visible)
            obs.obs_source_release(source)
        end
    end
end

function script_defaults(settings)
    obs.obs_data_set_default_int(settings, "pair_count", 1)
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