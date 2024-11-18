%----------------------------------------------------------------------
%                       Color Attention Test
%----------------------------------------------------------------------
function [color_test_correct, color_test_number] = color_test(color_name, color_test_correct, color_test_number, direction)
switch nargin
    case 3
        direction = [];
    case 4
    otherwise
        error('inputs are not accepted.')
end
color_test_number = 1 + color_test_number;

Texts_AATEC_Object

window = evalin('caller', 'window');
waitframes = evalin('caller', 'waitframes');
vbl = evalin('caller', 'vbl');
ifi = evalin('caller', 'ifi');
stimulusTimeColorTest = evalin('caller', 'stimulusTimeColorTest');
white = evalin('caller', 'white');
yCenter = evalin('caller', 'yCenter');
ImgEmoPath = evalin('caller', 'ImgEmoPath');
rectStop = evalin('caller', 'rectStop');
StopY = evalin('caller', 'StopY');
waitPunishment = evalin('caller', 'waitPunishment');
screenXpixels = evalin('caller', 'screenXpixels');
screenYpixels = evalin('caller', 'screenYpixels');
color = evalin('caller', 'color');
leftKey = evalin('caller', 'leftKey');
rightKey = evalin('caller', 'rightKey');
downKey = evalin('caller', 'downKey');

% making the color vector
if any(strcmp(color_name, color(1:3)))
    color_vec = color(1:3);
    color_vec = color_vec(randperm(size(color_vec, 1)), :)';
elseif any(strcmp(color_name, color(4:6)))
    color_vec = color(4:6);
    color_vec = color_vec(randperm(size(color_vec, 1)), :)';
end

% finding the correct answer
if strcmp(color_name,color_vec(1))
    correct_res = 1;
elseif strcmp(color_name,color_vec(2))
    correct_res = 2;
elseif strcmp(color_name,color_vec(3))
    correct_res = 3;
end



% defining boxes
box_X_size = screenXpixels*.05;
box_Y_size = screenYpixels*.08;
xCenter_right = screenXpixels*.65;
rect_box_right = [xCenter_right - box_X_size, yCenter - box_Y_size, ...
    xCenter_right + box_X_size, yCenter + box_Y_size];
xCenter_left = screenXpixels*.35;
rect_box_left = [xCenter_left - box_X_size, yCenter - box_Y_size, ...
    xCenter_left + box_X_size, yCenter + box_Y_size];
xCenter_middle = screenXpixels*.5;
rect_box_middle = [xCenter_middle - box_X_size, yCenter - box_Y_size, ...
    xCenter_middle + box_X_size, yCenter + box_Y_size];

% Time limits == attention_time; after which the experiments expires
timeStart = GetSecs;
respToBeMade = true ;
Accuracy = false;
while (GetSecs - timeStart) < stimulusTimeColorTest && respToBeMade
    if isempty(direction)
    DrawFormattedText(window, ColorText,...
        'center', yCenter - screenYpixels*.3, white);
    elseif strcmp(direction, 'right')
        DrawFormattedText(window, ColorTextRight,...
        'center', yCenter - screenYpixels*.3, white);
    elseif strcmp(direction, 'left')
        DrawFormattedText(window, ColorTextLeft,...
        'center', yCenter - screenYpixels*.3, white);
    end
    Screen('FillRect', window, colorTranslator(color_vec(1)), rect_box_left);
    Screen('FillRect', window, colorTranslator(color_vec(2)), rect_box_middle);
    Screen('FillRect', window, colorTranslator(color_vec(3)), rect_box_right);

    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    RestrictKeysForKbCheck([]);
    [~,~, keyCode] = KbCheck;
    if keyCode(leftKey)
        if correct_res == 1
            respToBeMade = false;
            Accuracy = true;
        else
            respToBeMade = false;
            Accuracy = false;
        end
    elseif keyCode(downKey)
        if correct_res == 2
            respToBeMade = false;
            Accuracy = true;
        else
            respToBeMade = false;
            Accuracy = false;
        end
    elseif keyCode(rightKey)
        if correct_res == 3
            respToBeMade = false;
            Accuracy = true;
        else
            respToBeMade = false;
            Accuracy = false;
        end
    end
end
if ~ Accuracy
    respToBeMade = false;
    img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
    Texture = Screen('MakeTexture', window, img);
    Screen('DrawTexture', window, Texture, [], rectStop);
    DrawFormattedText(window, WrongResponseText,...
        'center', StopY, white)
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    WaitSecs(waitPunishment);
end

if respToBeMade
    % Punishment Image
    img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
    Texture = Screen('MakeTexture', window, img);
    Screen('DrawTexture', window, Texture, [], rectStop);
    DrawFormattedText(window, StopText,...
        'center', StopY, white);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    WaitSecs(waitPunishment);
end

if Accuracy
    color_test_correct = 1 + color_test_correct;
end

end
