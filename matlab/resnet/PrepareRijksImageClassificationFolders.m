function PrepareRijksImageClassificationFolders(images_folder, image_classification_folder)
    CleanupRijksFolders(image_classification_folder, "l");
    image_files = dir(images_folder);
    for i = 1:length(image_files)
        if image_files(i).name == "." || image_files(i).name == ".."
            continue;
        end
        if image_files(i).isdir == 1
            link_command = strcat("ln -s """, images_folder, "/", image_files(i).name, """ """, image_classification_folder, "/", image_files(i).name, """");
            system(link_command);
        end
    end
end

