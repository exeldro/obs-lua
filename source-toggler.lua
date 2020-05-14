obs           = obslua
gs            = nil
function script_properties()
    local props = obs.obs_properties_create()
    local p = obs.obs_properties_add_editable_list(props, "sources", "Scenes and Groups",obs.OBS_EDITABLE_LIST_TYPE_STRINGS,nil,nil)
	return props
end

function script_description()
	return "toggle between sources visible in a scene"
end

function item_visible(calldata)
    local visible = obs.calldata_bool(calldata,"visible")
    if not visible then
        return
    end
    local item = obs.calldata_sceneitem(calldata,"item")
    local source = obs.obs_sceneitem_get_source(item)
    local sourceName = obs.obs_source_get_name(source)
    local scene = obs.obs_sceneitem_get_scene(item)
    local sceneitems = obs.obs_scene_enum_items(scene)
    for i, sceneitem in ipairs(sceneitems) do
        local itemsource = obs.obs_sceneitem_get_source(sceneitem)
        local isn = obs.obs_source_get_name(itemsource)
        if sourceName ~= isn then
            obs.obs_sceneitem_set_visible(sceneitem, false)
        end
    end
    obs.sceneitem_list_release(sceneitems)
end

function script_update(settings)
    local sourceNames =  obs.obs_data_get_array(settings, "sources");
    local count = obs.obs_data_array_count(sourceNames);
    for i = 0,count do 
        local item = obs.obs_data_array_item(sourceNames, i);
        local sourceName = obs.obs_data_get_string(item, "value");
        local source = obs.obs_get_source_by_name(sourceName)
        if source ~= nil then
            local sh = obs.obs_source_get_signal_handler(source);
            obs.signal_handler_disconnect(sh,"item_visible",item_visible)
            obs.signal_handler_connect(sh,"item_visible",item_visible)
            obs.obs_source_release(source)
        end
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

    local sourceNames =  obs.obs_data_get_array(gs, "sources");
    local count = obs.obs_data_array_count(sourceNames);
    for i = 0,count do 
        local item = obs.obs_data_array_item(sourceNames, i);
        local sourceName = obs.obs_data_get_string(item, "value");
        if sn == sourceName then
            local sh = obs.obs_source_get_signal_handler(source);
            obs.signal_handler_disconnect(sh,"item_visible",item_visible)
            obs.signal_handler_connect(sh,"item_visible",item_visible)
        end
    end
    obs.obs_data_array_release(sourceNames)

end

function script_load(settings)
    gs = settings
    local sh = obs.obs_get_signal_handler()
    obs.signal_handler_connect(sh, "source_load", loaded)
end

function script_unload()

end
