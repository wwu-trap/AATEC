%----------------------------------------------------------------------
%                       Attention vector
%----------------------------------------------------------------------
function attention_trial_vec = attention_vector(NumberofTrials, task, attention_trial, nnum)
attention_trial_vec = [];
if task ~= 3
    base_num = floor((NumberofTrials(task)-nnum)/attention_trial);
else
    base_num = floor((NumberofTrials(task)*3-nnum)/attention_trial);
end

for ii = 1:attention_trial
    if ii == 1 && (base_num - nnum) > 1
        attention_trial_vec = [attention_trial_vec (randperm(base_num - nnum,1) + nnum)];
    elseif ii == 1
        attention_trial_vec = [attention_trial_vec (randperm(base_num,1) + nnum)];
    else
        attention_trial_vec = [attention_trial_vec randperm(base_num,1)];
    end
end

attention_trial_vec = attention_trial_vec + repmat(base_num,1,attention_trial)*diag(0:attention_trial-1);

end
