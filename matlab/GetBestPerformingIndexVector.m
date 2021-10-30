function BestPerformingIndexVector = GetBestPerformingIndexVector(confusion_matrix)
    total_observations = sum(confusion_matrix,'all');
    true_positives = diag(confusion_matrix);
    false_positives = sum(confusion_matrix,2) - true_positives;
    false_negatives = sum(confusion_matrix,1)' - true_positives;
    true_negatives = total_observations - true_positives - false_positives - false_negatives;
    true_negative_rate_macro = true_negatives./(true_negatives+false_positives);
    true_positive_rate_macro = true_positives./(true_positives+false_negatives);
    balanced_accuracy_macro = (true_negative_rate_macro+true_positive_rate_macro)./2;
    [max_value, ~] = maxk(balanced_accuracy_macro, 1);
    BestPerformingIndexVector = find(balanced_accuracy_macro == max_value);
end