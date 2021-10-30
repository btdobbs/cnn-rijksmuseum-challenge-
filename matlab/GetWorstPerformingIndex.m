function WorstPerformingIndex = GetWorstPerformingIndex(confusion_matrix, count)
    class_count = size(confusion_matrix,1);
    total_observations = sum(confusion_matrix,'all');
    true_positives = diag(confusion_matrix);
    false_positives = sum(confusion_matrix,2) - true_positives;
    false_negatives = sum(confusion_matrix,1)' - true_positives;
    true_negatives = total_observations - true_positives - false_positives - false_negatives;
    true_negative_rate_macro = true_negatives./(true_negatives+false_positives);
    true_positive_rate_macro = true_positives./(true_positives+false_negatives);
    balanced_accuracy_macro = (true_negative_rate_macro+true_positive_rate_macro)./2;
    balanced_accuracy_macro_nan = isnan(balanced_accuracy_macro);
    nan_index = find(balanced_accuracy_macro_nan, 1);
    if length(nan_index) > count
        nan_index = nan_index(1, count);
    end
    [~, index] = mink(balanced_accuracy_macro, count - length(nan_index));
    WorstPerformingIndex = sort([nan_index; index],'descend');
end