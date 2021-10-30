function [artists_out] = GetRijksArtistDetails(xml_path)
    token_start = "<dc:creator>";
    token_end = "</dc:creator>";

    xml_files = dir(xml_path);
    artists = containers.Map;
    for i = 1:length(xml_files)
        if xml_files(i).isdir == 0
            artwork_file_path = strcat(xml_files(i).folder, "/", xml_files(i).name);
            artwork_xml = fileread(artwork_file_path);
            creators = extractBetween(artwork_xml, token_start, token_end);
            for j = 1:length(creators)
                artist = strtrim(creators{j});
                artist = decodeHTMLEntities(artist);
                artist = replace(artist,": ","~");
                artist = replace(artist,":","~");
 				artist = replace(artist,", ","_");
 				artist = replace(artist,",","_");
 				artist = replace(artist,".","");
                artist = replace(artist,"'","");
 				artist = replace(artist," ","-");
                artist = extractAfter(artist,"~");
                if artist == ""
                    artist = "unknown";
                end
                if isKey(artists, artist)
                    artists(artist) = strcat(artists(artist), ",", artwork_file_path);
                else
                    artists(artist) = artwork_file_path;
                end
                break;
            end
        end 
    end
    artists_out = artists;
end

