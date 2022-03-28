obs = obslua
gs = nil

function script_properties()
	local props = obs.obs_properties_create()
    obs.obs_properties_add_bool(props,"include_scene_collection", "Include Scene Collection Name")
    obs.obs_properties_add_path(props,"save_path","Path", obs.OBS_PATH_DIRECTORY, nil, nil)
    obs.obs_properties_add_button(props,"load","Load (point to files in the selected path)", load)
    obs.obs_properties_add_button(props,"import","Import (read the files in the path into the scene collection)", import)
    obs.obs_properties_add_button(props,"export","Export (write the notes to the path)", export)
    obs.obs_properties_add_button(props,"save","Save (write the notes to the path and point to it)", save)
	return props
end

function load()
    import_export(false, true)
end

function import()
    import_export(false, false)
end

function export()
    import_export(true, false)
end

function save()
    import_export(true, true)
end

function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
 end

function import_export(export, update_link)
    local path = obs.obs_data_get_string(gs, "save_path")
    if path == nil or string.len(path) < 1 then
        print("no path")
        return
    end
    local issn =  obs.obs_data_get_bool(gs, "include_scene_collection")
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
                    if export then
                        local snotes = obs.obs_data_get_string(scene_settings, "notes")
                        local fnotes = ""
                        local f = io.open(obs.obs_data_get_string(scene_settings, "notes_file"), "rb")
                        if f ~= nil then
                            fnotes = f:read "*a"
                            f:close()
                        end
                        local filewrite = io.open(file, "w")
                        if string.len(fnotes) > 0 then
                            filewrite:write(fnotes)
                        elseif string.len(snotes) > 0 then
                            filewrite:write(snotes)
                        end
                        filewrite:close()
                        if update_link then
                            obs.obs_data_set_string(scene_settings, "notes_file", file)
                        end
                    else
                        if update_link then
                            if file_exists(file) then
                                obs.obs_data_set_string(scene_settings, "notes_file", file)
                            end
                        else
                            local fnotes = ""
                            local f = io.open(file, "rb")
                            if f ~= nil then
                                fnotes = f:read "*a"
                                obs.obs_data_set_string(scene_settings, "notes", fnotes)
                                obs.obs_data_set_string(scene_settings, "notes_file", "")
                                f:close()
                            end
                        end
                    end
                    obs.obs_data_release(scene_settings)
                end
                obs.obs_source_release(source)
            end
        end
    end
end


function script_update(settings)

end

function script_load(settings)
    gs = settings
end

function script_save(settings)

end