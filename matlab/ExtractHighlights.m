class_counts = [34 97 100 197 200 300 368 374 958 1199];

for i = class_counts
    confusion_matrix_file = strcat('cm_', string(i), '.mat');
    labels_file = strcat('labels_', string(i), '.mat');
    confusion_matrix = load(confusion_matrix_file).confusion_matrix;
    %disp(confusion_matrix_file);
    labels = load(labels_file).labels;
    %disp(labels_file);
    bestPerformingIndex = GetBestPerformingIndexVector(confusion_matrix);
    disp('class');
    disp(string(i));
    %disp(bestPerformingIndex);
    disp('best performing');
    disp(string(labels(bestPerformingIndex)));
    [a1, a2] = MostConfused(confusion_matrix);
    disp('most confused');
    disp(string(labels(a1)));
    disp(string(labels(a2)));
    disp('most true positives');
    [max_tp, index] = max(diag(confusion_matrix));
    disp(string(labels(index)));
    disp(max_tp);
end
