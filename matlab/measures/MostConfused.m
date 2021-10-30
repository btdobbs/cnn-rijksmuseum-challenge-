function [r, c] = MostConfused(confusion_matrix)
    cm_no_diag = confusion_matrix - diag(diag(confusion_matrix));
    M = max(cm_no_diag, [], 'all');
    [r, c] = find(cm_no_diag == M);
end
