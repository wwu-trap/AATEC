%----------------------------------------------------------------------
%                       General Attention vector
%----------------------------------------------------------------------
function AttentionTestFailed = general_attention(text, wait, sessionNum)

AttentionTestFailed = false;
switch nargin
    case 2
        sessionNum = evalin('caller', 'sessionNum');
    case 3
    otherwise
        error('inputs are not accepted.')
end
Texts_AATEC_Object

window = evalin('caller', 'window');
waitframes = evalin('caller', 'waitframes');
vbl = evalin('caller', 'vbl');
ifi = evalin('caller', 'ifi');
attentionTime = evalin('caller', 'attentionTimeLong');
white = evalin('caller', 'white');
endTime = evalin('caller', 'endTime');
ImgEmoPath = evalin('caller', 'ImgEmoPath');
rectStop = evalin('caller', 'rectStop');
StopY = evalin('caller', 'StopY');
waitPunishment = evalin('caller', 'waitPunishment');
ParticipantDir = evalin('caller', 'ParticipantDir');
participantNum = evalin('caller', 'participantNum');
color_test_correct = evalin('caller', 'color_test_correct');
color_test_number = evalin('caller', 'color_test_number');
TimeBegin = evalin('caller', 'TimeBegin');
grey = evalin('caller', 'grey');

RestrictKeysForKbCheck([]);
respToBeMade = true;
timeStart = GetSecs;
while GetSecs - timeStart < attentionTime && respToBeMade
    if (GetSecs - timeStart) > (attentionTime - endTime)
        img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
        Texture = Screen('MakeTexture', window, img);
        Screen('DrawTexture', window, Texture, [], rectStop);
        DrawFormattedText(window, InBetweenTextAttention,...
            'center', StopY, white)
    else
        DrawFormattedText(window, text,...
            'center', 'center', white);
        if sessionNum == 4
            rectBox = evalin('caller', 'rectBox');
            pen_width = evalin('caller', 'pen_width');
            rectBox = rectBox + [0, 300, 0, 300];
            rect = evalin('caller', 'rect');
            rect = rect + [0, 300, 0, 300];
            img = imread(fullfile(ImgEmoPath,'StopSign', 'Person.png'));
            img = coloring_fucntion(img, white);
            % drawing the box around the image
            Screen('FrameRect', window, colorTranslator('w'), rectBox, pen_width);
            % drawing the Image
            Texture = Screen('MakeTexture', window, img);
            Screen('DrawTexture', window, Texture, [], rect);
        end
    end

    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % checking for a button press
    [keyIsDown,~, ~] = KbCheck;
    if keyIsDown && GetSecs - timeStart > wait
        respToBeMade = false;
    end
end
if respToBeMade && (GetSecs - timeStart) > attentionTime
    % Setting the parameters for the last part
    AttentionTestFailed = true;
    TimeEnd = GetSecs-TimeBegin;

    if sessionNum > 1
        CounterErrorAAT = evalin('caller', 'CounterErrorAAT');
        CounterErrorEC = evalin('caller', 'CounterErrorEC');
        trialEC = evalin('caller', 'trialEC');
        trialAAT = evalin('caller', 'trialAAT');

        attentional_text(ParticipantDir, participantNum, AttentionTestFailed, TimeEnd, ...
            color_test_correct, color_test_number,...
            CounterErrorAAT, CounterErrorEC, trialEC, trialAAT)
    else
        attentional_text(ParticipantDir, participantNum, AttentionTestFailed, TimeEnd, ...
            color_test_correct, color_test_number)
    end

    img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
    Texture = Screen('MakeTexture', window, img);
    Screen('DrawTexture', window, Texture, [], rectStop);
    DrawFormattedText(window, UnattentiveText,...
        'center', StopY, white)
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    WaitSecs(waitPunishment);
    ShowCursor;
    close all
    warning('Terminated by user input:!!nothing is saved!!')
    sca;
    return
end

end