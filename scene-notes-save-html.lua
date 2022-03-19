obs = obslua

function script_properties()
	local props = obs.obs_properties_create()
    obs.obs_properties_add_bool(props,"include_scene_collection", "Include Scene Collection Name")
    obs.obs_properties_add_path(props,"save_path","Path", obs.OBS_PATH_DIRECTORY, nil, nil)
	return props
end

function script_update(settings)
    local path = obs.obs_data_get_string(settings, "save_path")
    if path == nil or string.len(path) < 1 then
        print("no path")
        return
    end
    local issn =  obs.obs_data_get_bool(settings, "include_scene_collection")
    local scenes = obs.obs_frontend_get_scene_names()
    if scenes ~= nil then
        for _, scene in ipairs(scenes) do
            local source = obs.obs_get_source_by_name(scene)
            if source ~= nil then
                local scene_settings = obs.obs_source_get_settings(source)
                if scene_settings ~= nil then
                    local file = scene
                    if issn then
                        file = obs.obs_frontend_get_current_scene_collection().." "..file
                    end
                    file = path .. "/"..obs.os_generate_formatted_filename("html",false,file)
                    print(file)
                    local notes = obs.obs_data_get_string(setting, "notes")
                    local f = io.open(obs.obs_data_get_string(scene_settings, "notes_file"), "rb")
                    if f ~= nil then
                        notes = f:read "*a"
                        f:close()
                    end
                    local filewrite = io.open(file, "w")
                    filewrite:write(notes)
                    filewrite:close()
                    obs.obs_data_set_string(scene_settings, "notes_file", file)
                    obs.obs_data_release(scene_settings)
                end
                obs.obs_source_release(source)
            end
        end
    end
end

function script_load(settings)

end

function script_save(settings)

end