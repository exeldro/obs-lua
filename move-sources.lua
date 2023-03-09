obs = obslua
gs = nil

function move_item(item)
    local denominator = obs.obs_data_get_int(gs,"denominator")
    local numerator = obs.obs_data_get_int(gs,"numerator")
    if obs.obs_data_get_bool(gs, "pos") then
        local pos = obs.vec2()
        obs.obs_sceneitem_get_pos(item, pos)
        pos.x = pos.x / denominator * numerator;
        pos.y = pos.y / denominator * numerator;
        obs.obs_sceneitem_set_pos(item, pos)
        --print("moved to".. pos.x .."x"..pos.y)
    end
    if obs.obs_data_get_bool(gs, "scale") then
        local scale = obs.vec2()
        obs.obs_sceneitem_get_scale(item, scale)
        scale.x = scale.x / denominator * numerator;
        scale.y = scale.y / denominator * numerator;
        obs.obs_sceneitem_set_scale(item, scale)
        --print("scaled to".. scale.x .."x"..scale.y)
    end
    if obs.obs_data_get_bool(gs, "bounds") then
        local bounds = obs.vec2()
        obs.obs_sceneitem_get_bounds(item, bounds)
        bounds.x = bounds.x / denominator * numerator;
        bounds.y = bounds.y / denominator * numerator;
        obs.obs_sceneitem_set_bounds(item, bounds)
        --print("bounds to".. bounds.x .."x"..bounds.y)
    end
end

function script_go(props, prop)
    local scenes = obs.obs_frontend_get_scene_names()
    if scenes ~= nil then
        for _, scene_name in ipairs(scenes) do
            local scene_source =  obs.obs_get_source_by_name(scene_name)
            if scene_source ~= nil then
                local scene = obs.obs_scene_from_source(scene_source)
                local items = obs.obs_scene_enum_items(scene)
                for _, item in ipairs(items) do
                    local source = obs.obs_sceneitem_get_source(item)
                    local id = obs.obs_source_get_unversioned_id(source)
                    if obs.obs_data_get_bool(gs, id) then
                        move_item(item)
                    else
                        local group = obs.obs_group_from_source(source)
                        if group ~= nil then
                            local group_items = obs.obs_scene_enum_items(group)
                            for _, group_item in ipairs(group_items) do
                                local source2 = obs.obs_sceneitem_get_source(group_item)
                                local id2 = obs.obs_source_get_unversioned_id(source2)
                                if obs.obs_data_get_bool(gs, id2) then
                                    move_item(group_item)
                                end
                            end
                            obs.sceneitem_list_release(group_items)
                        end
                    end
                end
                obs.sceneitem_list_release(items)
                obs.obs_source_release(scene_source)
            end
        end
    end
end

function script_properties()
	local props = obs.obs_properties_create()
    local source_types  = {}
    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            local id = obs.obs_source_get_unversioned_id(source)
            local dn = obs.obs_source_get_display_name(id)
            local found = false
            for key,value in pairs(source_types) do
                if value == id then
                    found = true
                end
            end
            if found == false then
                local flags = obs.obs_source_get_output_flags(source)
                if bit.band(flags,obs.OBS_SOURCE_VIDEO) ~= 0 then
                    obs.obs_properties_add_bool(props, id, dn)
                end
                table.insert(source_types, id)
            end
        end
        obs.source_list_release(sources)
    end
    obs.obs_properties_add_int(props, "numerator", "Numerator", 1, 1000, 1)
    obs.obs_properties_add_int(props, "denominator", "Denominator", 1, 1000, 1)
    obs.obs_properties_add_bool(props, "pos", "Position")
    obs.obs_properties_add_bool(props, "scale", "Scale")
    obs.obs_properties_add_bool(props, "bounds", "Bounds")
    obs.obs_properties_add_button(props, "go", "Go", script_go)
	return props
end

function script_defaults(settings)
    obs.obs_data_set_default_int(settings, "numerator", 2)
    obs.obs_data_set_default_int(settings, "denominator", 3)
end

function script_description()
	return "test"
end

function script_update(settings)
    gs = settings
end

function script_load(settings)
    gs = settings
end

function script_save(settings)

end