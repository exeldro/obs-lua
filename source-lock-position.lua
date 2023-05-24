obs           = obslua
gs            = nil
sources_count = 1
sources_max   = 20
current_scene = nil
items_to_restore = {}
restoring = false

function item_transform(calldata)
    local item = obs.calldata_sceneitem(calldata,"item")
    local id = obs.obs_sceneitem_get_id(item)
    local item_to_restore = items_to_restore[id]
    if item_to_restore == nil or restoring then
        return
    end
    restoring = true   
    obs.obs_sceneitem_set_pos(item, item_to_restore.pos)
    obs.obs_sceneitem_set_scale(item, item_to_restore.scale)
    obs.obs_sceneitem_set_bounds(item, item_to_restore.bounds)
    restoring = false
end

function source_count_changed(props, property, settings)
    local changed = false
    if settings == nil then
        settings = gs
    end
    if settings ~= nil then
        local sc = obs.obs_data_get_int(settings, "sources_count")
        if sc > 0 then
            sources_count = sc
        end
    end

    local source_array  = {}
    for i = 1, sources_count, 1 
    do
        local p = obs.obs_properties_get(props, "source_" .. i)
        if p == nil then
            changed = true
            local s = obs.obs_properties_add_list(props, "source_" .. i, "Source ".. i, obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
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

    for i = sources_count + 1, sources_max, 1 
    do
        local p = obs.obs_properties_get(props, "source_" .. i)
        if p ~= nil then
            obs.obs_properties_remove_by_name(props, "source_" .. i)
            changed = true
        end
    end

    return changed
end

function script_update(settings)
    sources_count = obs.obs_data_get_int(settings, "sources_count")
end

function script_defaults(settings)
    obs.obs_data_set_default_int(settings, "sources_count", 1)
end

function script_properties()
	local props = obs.obs_properties_create()
    local sources = obs.obs_properties_add_int_slider(props, "sources_count", "Sources", 1, sources_max, 1)
    obs.obs_property_set_modified_callback(sources, source_count_changed)
    source_count_changed(props)
	return props
end

function LoadScene(scene, scene_source)
    items_to_restore = {}
    local items = obs.obs_scene_enum_items(scene)
    for _, item in ipairs(items) do
        local sn = obs.obs_source_get_name(obs.obs_sceneitem_get_source(item))
        for i = 1, sources_count, 1 
        do
            if sn == obs.obs_data_get_string(gs,"source_".. i) then
                local pos = obs.vec2()
                obs.obs_sceneitem_get_pos(item, pos)
                local scale = obs.vec2()
                obs.obs_sceneitem_get_scale(item, scale)
                local bounds = obs.vec2()
                obs.obs_sceneitem_get_bounds(item, bounds)
                items_to_restore[obs.obs_sceneitem_get_id(item)] = {pos = pos, scale = scale, bounds = bounds}
            end
        end
    end
    obs.sceneitem_list_release(items)
end

function script_tick()
    local scene_source = obs.obs_frontend_get_current_preview_scene()
    if scene_source == nil then
        scene_source = obs.obs_frontend_get_current_scene()
    end
    local sn = obs.obs_source_get_name(scene_source)
    if sn == current_scene then
        obs.obs_source_release(scene_source)
        return
    end
    if current_scene ~= nil then
        local s = obs.obs_get_source_by_name(current_scene)
        local sh = obs.obs_source_get_signal_handler(s)
        obs.signal_handler_disconnect(sh,"item_transform",item_transform)
        obs.obs_source_release(s)
    end
    current_scene = sn
    local scene = obs.obs_scene_from_source(scene_source)
    LoadScene(scene, scene_source)
    local sh = obs.obs_source_get_signal_handler(scene_source)
    obs.signal_handler_connect(sh,"item_transform",item_transform)
    obs.obs_source_release(scene_source)
end

function script_load(settings)
    gs = settings
    script_update(settings)
end

function script_unload()

end