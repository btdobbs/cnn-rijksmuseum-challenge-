function CreateRijksFolders(artists, source_path, target_path, artwork_threshhold)
    for artist = keys(artists)
        artworks = split(artists(artist{1}),",");
        % setup artists with an artwork count greater than or equal to the threshhold
        if length(artworks) >= artwork_threshhold
            temp_artist = replace(artist{1},"'","");
            new_target_path = strcat(target_path, "/", temp_artist);
            mkdir(new_target_path);
            for i = 1:length(artworks)
                artwork = replace(artworks(i),"xml","jpg");
                [~,file_name,file_ext] = fileparts(artwork);
                file_name = strcat(file_name,file_ext);
                link_command = strcat("ln -s """, source_path, "/", file_name, """ """, new_target_path, "/", file_name, """");
                system(link_command);
            end
        end
    end
end

