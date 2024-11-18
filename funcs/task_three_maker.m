
%----------------------------------------------------------------------
%                       Task Three Vector Maker
%----------------------------------------------------------------------

function out_vec = task_three_maker(in_vec, color, NumberofTrials)
switch nargin
    case 0
        error('at least 1 input is needed.')
    case 1
        color = [];
        NumberofTrials = [];
    case 2
        NumberofTrials = [];
    case 3
    otherwise
        error('Max of 3 inputs are accepted.')
end

if isempty(color)
    color = [{'r'}; {'b'}; {'y'}; {'o'}; {'g'}; {'p'}];
end

if isempty(NumberofTrials)
    NumberofTrials = [5; 5; 5];
end

out_vec = struct('NameRight', {}, 'NameLeft', {},...
    'ColorRight', {}, 'ColorLeft', {});
n =length(in_vec)/length(color);
for ii= 1:3
    for jj = 1:3
        tmp1 = in_vec([in_vec.color] == color{ii});
        r1 = randi(n,1,NumberofTrials(3));
        tmp1Chosen = tmp1(r1,:);
        tmp2 = in_vec([in_vec.color] == color{3+jj});
        r2 = randi(n,1,NumberofTrials(3));
        tmp2Chosen = tmp2(r2,:);
        for nn = 1:NumberofTrials(3)
            if randperm(2,1) == 1
                out_vec(end+1) = struct('NameRight', tmp1Chosen(nn).name, 'NameLeft', tmp2Chosen(nn).name,...
                    'ColorRight', tmp1Chosen(nn).color, 'ColorLeft', tmp2Chosen(nn).color);
            else
                out_vec(end+1) = struct('NameRight', tmp2Chosen(nn).name, 'NameLeft', tmp1Chosen(nn).name,...
                    'ColorRight', tmp2Chosen(nn).color, 'ColorLeft', tmp1Chosen(nn).color);
            end
        end
    end
end
out_vec = out_vec';
end
