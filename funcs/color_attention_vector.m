%----------------------------------------------------------------------
%                       Color Attention vector
%----------------------------------------------------------------------
function color_attention_trial_vec = color_attention_vector(NumberofTrials, task, color_attention_trial)
color_attention_trial_vec = [];
if task == 4
    base_num = floor(NumberofTrials/color_attention_trial);
elseif task ~= 3
    base_num = floor(NumberofTrials(task)/color_attention_trial);
else
    base_num = floor((NumberofTrials(task)*3)/color_attention_trial);
end

for ii = 1:color_attention_trial
    if ii == 1 && (base_num - 1) > 1
        color_attention_trial_vec = [color_attention_trial_vec (randperm(base_num - 1,1) + 1)];
    elseif ii == 1
        color_attention_trial_vec = [color_attention_trial_vec (randperm(base_num,1) + 1)];
    else
        color_attention_trial_vec = [color_attention_trial_vec randperm(base_num,1)];
    end
end

color_attention_trial_vec = color_attention_trial_vec + repmat(base_num,1,color_attention_trial)*diag(0:color_attention_trial-1);

end
