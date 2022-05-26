obs           = obslua
gs            = nil
group_count  = 1
groups_max   = 20
sources_max  = 20
item_to_set_visible = nil

function script_description()
	return "Make groups of sources that react on the visibility of the other sources in the group"
end

function item_visible(calldata)
    local visible = obs.calldata_bool(calldata,"visible")
    local item = obs.calldata_sceneitem(calldata,"item")
    local source = obs.obs_sceneitem_get_source(item)
    local source_name = obs.obs_source_get_name(source)
    for i = 1, group_count, 1 
    do 
        local source_count = obs.obs_data_get_int(gs, "group_" .. i .. "_source_count")
        local vis = obs.obs_data_get_int(gs, "group_" .. i .. "_visibility")
        if vis ~= 1 or visible then
            for j = 1, source_count, 1
            do
                if source_name == obs.obs_data_get_string(gs, "group_" .. i .. "_source_"..j) then
                    local scene = obs.obs_sceneitem_get_scene(item)
                    local vis_count = 0
                    for k = 1, source_count, 1
                    do
                        if k ~= j then
                            local other_item = obs.obs_scene_find_source(scene, obs.obs_data_get_string(gs, "group_" .. i .. "_source_"..k))
                            if other_item ~= nil then
                                if vis == 0 then
                                    if obs.obs_sceneitem_visible(other_item) ~= visible then
                                        obs.obs_sceneitem_set_visible(other_item, visible)
                                    end
                                elseif vis == 1 then
                                    if obs.obs_sceneitem_visible(other_item) == visible then
                                        obs.obs_sceneitem_set_visible(other_item, not visible)
                                    end
                                elseif vis == 2 then
                                    if visible then
                                        if obs.obs_sceneitem_visible(other_item) then
                                            obs.obs_sceneitem_set_visible(other_item, false)
                                        end
                                    else
                                        if obs.obs_sceneitem_visible(other_item) then
                                            vis_count = vis_count +1
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if vis == 2 and not visible and vis_count == 0 then
                        item_to_set_visible = item
                    end
                end
            end
        end
    end
end

function source_count_changed(props, property, settings)
    local changed = false
    if settings == nil then
        settings = gs
    end
    if settings == nil then
        return changed
    end
    local propname = obs.obs_property_name(property)
    local group_index = tonumber(string.sub(propname,7,8))
    if group_index == nil then
        group_index = tonumber(string.sub(propname,7,7))
    end
    local group = obs.obs_property_group_content(obs.obs_properties_get(props, "group_" .. group_index .. "_group"))
    local source_count = obs.obs_data_get_int(settings, "group_" .. group_index .. "_source_count")
    if source_count <= 1 then
        source_count = 1
    end

    local source_array  = {}
    for i = 1, source_count, 1 
    do
        local p = obs.obs_properties_get(group, "group_" .. group_index .. "_source_" .. i)
        if p == nil then
            changed = true
            local s = obs.obs_properties_add_list(group, "group_" .. group_index .. "_source_" .. i, "Source ".. i, obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
            table.insert(source_array, s)
        end
    end 
    if changed then
        local sources = obs.obs_enum_sources()
        if sources ~= nil then
            for _, source in ipairs(sources) do
                local name = obs.obs_source_get_name(source)
                for key,value in pairs(source_array) do
                    obs.obs_property_list_add_string(value, name, name)
                end
            end
            obs.source_list_release(sources)
        end
    end

    for i = source_count + 1, sources_max, 1 
    do
        local p = obs.obs_properties_get(group, "group_" .. group_index .. "_source_" .. i)
        if p ~= nil then
            obs.obs_properties_remove_by_name(group, "group_" .. group_index .. "_source_" .. i)
            changed = true
        end
    end

    return changed
end

function group_count_changed(props, property, settings)
    local changed = false

    if settings ~= nil then
        local gc = obs.obs_data_get_int(settings, "group_count")
        if gc > 0 then
            group_count = gc
        end
    end

    for i = 1, group_count, 1 
    do 
        local p = obs.obs_properties_get(props, "group_" .. i .. "_group")
        if p == nil then
            changed = true
            local group = obs.obs_properties_create()
            local s = obs.obs_properties_add_list(group, "group_" .. i .. "_visibility", "Visibility", obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
            obs.obs_property_list_add_int(s, "Match", 0)
            obs.obs_property_list_add_int(s, "Unique", 1)
            obs.obs_property_list_add_int(s, "Always 1", 2)

            local sources = obs.obs_properties_add_int_slider(group, "group_" .. i .. "_source_count", "Sources", 1, groups_max, 1)
            obs.obs_property_set_modified_callback(sources, source_count_changed)
            obs.obs_properties_add_group(props, "group_" .. i .. "_group", "Group ".. i, obs.OBS_GROUP_NORMAL, group)
            source_count_changed(props, sources, settings)
        end
    end

    for i = group_count + 1, groups_max, 1 
    do
        local p = obs.obs_properties_get(props, "group_" .. i .. "_group")
        if p ~= nil then
            obs.obs_properties_remove_by_name(props, "group_" .. i .. "_group")
            changed = true
        end
    end
    return changed
end

function script_update(settings)
    group_count = obs.obs_data_get_int(settings, "group_count")
end

function script_defaults(settings)
    obs.obs_data_set_default_int(settings, "group_count", 1)
end

function script_properties()
	local props = obs.obs_properties_create()
    local groups = obs.obs_properties_add_int_slider(props, "group_count", "Groups", 1, groups_max, 1)
    obs.obs_property_set_modified_callback(groups, group_count_changed)
    group_count_changed(props)
	return props
end

function loaded(cd)
    if gs == nil then
        return
    end
    local source = obs.calldata_source(cd, "source")
    local source_id = obs.obs_source_get_id(source)
    if source_id == "group" or source_id == "scene" then
        local sh = obs.obs_source_get_signal_handler(source);
        obs.signal_handler_disconnect(sh,"item_visible",item_visible)
        obs.signal_handler_connect(sh,"item_visible",item_visible)
    end
end

function script_load(settings)
    gs = settings
    script_update(settings)
    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            local source_id = obs.obs_source_get_id(source)
            if source_id == "group" then
                local sh = obs.obs_source_get_signal_handler(source);
                obs.signal_handler_disconnect(sh,"item_visible",item_visible)
                obs.signal_handler_connect(sh,"item_visible",item_visible)
            end
        end
        obs.source_list_release(sources)
    end

    local scenes = obs.obs_frontend_get_scene_names()
    if scenes ~= nil then
        for _, scene in ipairs(scenes) do
            local source =  obs.obs_get_source_by_name(scene)
            if source ~= nil then
                local sh = obs.obs_source_get_signal_handler(source);
                obs.signal_handler_disconnect(sh,"item_visible",item_visible)
                obs.signal_handler_connect(sh,"item_visible",item_visible)
                obs.obs_source_release(source)
            end
        end
    end
    local sh = obs.obs_get_signal_handler()
    obs.signal_handler_connect(sh, "source_load", loaded)
end

function script_unload()

end

function script_tick()
    if item_to_set_visible ~= nil then
        obs.obs_sceneitem_set_visible(item_to_set_visible, true)
        item_to_set_visible = nil
    end
end