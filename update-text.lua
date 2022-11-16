obs = obslua
total_seconds = 0
interval = 1
file_path = ""
source_name = ""
scene_name = ""
prev_text = ""
delay = 2
count_time = -1

function script_properties()
	local props = obs.obs_properties_create()
    obs.obs_properties_add_path(props,"path","Path",obs.OBS_PATH_FILE,"Text (*.txt)",nil)
    obs.obs_properties_add_text(props, "scene", "Scene", obs.OBS_TEXT_DEFAULT)
    local p = obs.obs_properties_add_list(props, "source", "Text Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_enum_sources()
	if sources ~= nil then
        for _, source in ipairs(sources) do
            local id = obs.obs_source_get_unversioned_id(source)
            if id == "text_gdiplus" then
                local name = obs.obs_source_get_name(source)
                obs.obs_property_list_add_string(p, name, name)
            end
		end
	end
    obs.source_list_release(sources)
    obs.obs_properties_add_float(props, "interval","Interval",0.1,10,0.1)
    obs.obs_properties_add_float(props, "delay","Delay",0.1,10,0.1)
	return props
end


function script_description()
	return "Text source update using a file"
end

function script_update(settings)
	file_path = obs.obs_data_get_string(settings, "path")
    source_name = obs.obs_data_get_string(settings, "source")
    scene_name = obs.obs_data_get_string(settings, "scene")
    delay = obs.obs_data_get_double(settings, "delay")
    interval = obs.obs_data_get_double(settings, "interval")
end


function script_load(settings)
    
end

function script_save(settings)

end

function script_tick(seconds)
    if count_time >= 0.0 then
        count_time = count_time + seconds
        if count_time > delay then
            local scene_source = obs.obs_get_source_by_name(scene_name)
            if scene_source then
                local scene = obs.obs_scene_from_source(scene_source)
                local item = obs.obs_scene_find_source(scene, source_name)
                local source = obs.obs_sceneitem_get_source(item)
                if source then
                    local settings = obs.obs_data_create()
                    obs.obs_data_set_string(settings, "text", prev_text)
                    obs.obs_source_update(source, settings)
                    obs.obs_data_release(settings)
                    obs.obs_sceneitem_set_visible(item, true)
                end
                obs.obs_source_release(scene_source)
            end
            count_time = -1
        end
    end
    total_seconds = total_seconds + seconds
    if total_seconds > interval then
        local file = io.open(file_path, "r")
        if file then
            local content = file:read "*a"
            if content ~= prev_text then
                prev_text = content
                count_time = 0.0
                local scene_source = obs.obs_get_source_by_name(scene_name)
                if scene_source then
                    local scene = obs.obs_scene_from_source(scene_source)
                    local item = obs.obs_scene_find_source(scene, source_name)
                    obs.obs_sceneitem_set_visible(item, false)                    
                    obs.obs_source_release(scene_source)
                end
            end
            file:close()
        end
        total_seconds = 0
    end
end