%Rijks (Rike's) Museum
trainingSetup = load("/users/btdobbs/jobs/resnet_101.mat");
images_folder = "/users/btdobbs/rijks/images";
image_classification_folder = "/users/btdobbs/rijks/image_classification";
PrepareRijksImageClassificationFolders(images_folder, image_classification_folder);
class_removal = [68 100 3 97 3 63 0];
for j = 1:length(class_removal)
    image_data_store = imageDatastore(image_classification_folder,'IncludeSubfolders',true,'LabelSource','foldernames');
    tic
    [confusion_matrix,labels] = DoResNet(trainingSetup, image_data_store);
    toc
    worstPerformingIndex = GetWorstPerformingIndex(confusion_matrix, class_removal(j));
    for i = 1:length(worstPerformingIndex)
        artist_path = strcat(image_classification_folder, "/", labels{worstPerformingIndex(i)});
        unlink_command = strcat("unlink """, artist_path, """");
        system(unlink_command);
        confusion_matrix(worstPerformingIndex(i),:) = [];
        confusion_matrix(:,worstPerformingIndex(i)) = [];
    end
end
