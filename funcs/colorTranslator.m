%----------------------------------------------------------------------
%                       Color Translator
%----------------------------------------------------------------------
function color = colorTranslator(name)

% defining better colors
red = [0.6350 0.0780 0.1840];
green = [0.1660 0.5740 0.1880];
blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.8490 0.5940 0.1250];
purple = [0.4940 0.1840 0.5560];

if strcmp(name, 'r')
    color = red;
elseif strcmp(name, 'b')
    color = blue;
elseif strcmp(name, 'g')
    color = green;
elseif strcmp(name, 'y')
    color = yellow;
elseif strcmp(name, 'o')
    color = orange;
elseif strcmp(name, 'p')
    color = purple;
else 
    color = [1 1 1];
end
end
