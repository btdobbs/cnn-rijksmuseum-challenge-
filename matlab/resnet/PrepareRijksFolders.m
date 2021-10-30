function PrepareRijksFolders()
    xml_path = "/users/btdobbs/rijks/xml";
    source_path = "/users/btdobbs/rijks/jpg";
    target_path = "/users/btdobbs/rijks/images";
    artwork_threshhold = 50;
    
    CleanupRijksFolders(target_path, "d");
    artists = GetRijksArtistDetails(xml_path);
    CreateRijksFolders(artists, source_path, target_path, artwork_threshhold);
end

