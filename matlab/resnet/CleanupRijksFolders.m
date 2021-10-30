function CleanupRijksFolders(images_path, type)
    image_files = dir(images_path);
    for i = 1:length(image_files)
        if image_files(i).name == "." || image_files(i).name == ".."
            continue;
        end
        if image_files(i).isdir == 1
            artist_path = strcat(image_files(i).folder, "/", image_files(i).name);
            if type == "l"
                unlink_command = strcat("unlink """, artist_path, """");
                system(unlink_command);
            elseif type == "d"
                rmdir(artist_path, 's');
            end
        end
    end
end
