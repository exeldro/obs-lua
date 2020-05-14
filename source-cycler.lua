obs           = obslua
source_name   = ""
visible_index = 1
hotkey_id     = obs.OBS_INVALID_HOTKEY_ID
hotkey2_id    = obs.OBS_INVALID_HOTKEY_ID

function group_loop_step_button_clicked(props, p)
	group_loop_step(true)
	return false
end

function group_loop_step(pressed)
	if pressed then
		group_loop(1)
    end
end

function group_loop_back_button_clicked(props, p)
	group_loop_back(true)
	return false
end

function group_loop_back(pressed)
	if pressed then
		group_loop(-1)
    end
end

function group_loop(diff)
    local scenes = obs.obs_frontend_get_scenes()
    if scenes ~= nil then
        for _, scenesource in ipairs(scenes) do
            local scenename = obs.obs_source_get_name(scenesource)
            local scene = obs.obs_scene_from_source(scenesource)
            local sceneitems = obs.obs_scene_enum_items(scene)
            local maxindex = 0
            local index = 1
            for i, sceneitem in ipairs(sceneitems) do
                if scenename == source_name then
                    obs.obs_sceneitem_set_visible(sceneitem, index == visible_index)
                    maxindex = index
                    index = index + 1
                else
                    local source = obs.obs_sceneitem_get_source(sceneitem)
                    local sourcename = obs.obs_source_get_name(source)
                    if sourcename == source_name then
                        local group = obs.obs_group_from_source(source)
                        local groupitems = obs.obs_scene_enum_items(group)
                        for j, groupitem in ipairs(groupitems) do
                            obs.obs_sceneitem_set_visible(groupitem, index == visible_index)
                            maxindex = index
                            index = index + 1
                        end
                        visible_index = visible_index + 1
                        if visible_index > maxindex then
                            visible_index = 1
                        end
                    end
                end
            end
            obs.sceneitem_list_release(sceneitems)
            if scenename == source_name then
                visible_index = visible_index + diff
                if visible_index > maxindex then
                    visible_index = 1
                elseif visible_index < 1 then
                    visible_index = maxindex
                end
            end
        end
        obs.source_list_release(scenes)
        --obs.obs_frontend_source_list_free(scenes)
    end
end

function script_properties()
	local props = obs.obs_properties_create()
    local p = obs.obs_properties_add_list(props, "source", "Group Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, source in ipairs(sources) do
            source_id = obs.obs_source_get_id(source)
            if source_id == "group" then
                local name = obs.obs_source_get_name(source)
                obs.obs_property_list_add_string(p, name, name)
            end
        end
        obs.source_list_release(sources)
    end
        
    local scenes = obs.obs_frontend_get_scene_names()
    if scenes ~= nil then
        for _, scene in ipairs(scenes) do
            obs.obs_property_list_add_string(p, scene, scene)
        end
    end
    obs.obs_properties_add_button(props, "step_button", "Step loop", group_loop_step_button_clicked)
    obs.obs_properties_add_button(props, "back_button", "Back loop", group_loop_back_button_clicked)
	return props
end

function script_description()
	return "Sets a group source to act as a visibility loop"
end

function script_update(settings)
    local sn = obs.obs_data_get_string(settings, "source")
    if source_name ~= sn then
        obs.obs_hotkey_unregister(group_loop_step)
        source_name = sn
        hotkey_id = obs.obs_hotkey_register_frontend("group_loop_step_" .. sn, "Group Loop " .. sn, group_loop_step)
        local hotkey_save_array = obs.obs_data_get_array(settings, "group_loop_hotkey")
        obs.obs_hotkey_load(hotkey_id, hotkey_save_array)
        obs.obs_data_array_release(hotkey_save_array)
        hotkey2_id = obs.obs_hotkey_register_frontend("group_loop_back_" .. sn, "Group Back " .. sn, group_loop_back)
        hotkey_save_array = obs.obs_data_get_array(settings, "group_loop_hotkey2")
        obs.obs_hotkey_load(hotkey2_id, hotkey_save_array)
        obs.obs_data_array_release(hotkey_save_array)
    end
    
end

function script_defaults(settings)

end

function script_save(settings)
	local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
	obs.obs_data_set_array(settings, "group_loop_hotkey", hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
    hotkey_save_array = obs.obs_hotkey_save(hotkey2_id)
	obs.obs_data_set_array(settings, "group_loop_hotkey2", hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)
end

function script_load(settings)
    script_update(settings)
end
