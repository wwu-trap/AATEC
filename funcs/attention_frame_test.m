%----------------------------------------------------------------------
%                       Attention Test
%----------------------------------------------------------------------

function [AttentionTestFailed,attention_counter] = attention_frame_test(attention_counter)
AttentionTestFailed = false;
Texts_AATEC_Object

window = evalin('caller', 'window');
waitframes = evalin('caller', 'waitframes');
vbl = evalin('caller', 'vbl');
ifi = evalin('caller', 'ifi');
attentionTime = evalin('caller', 'attentionTime');
white = evalin('caller', 'white');
endTime = evalin('caller', 'endTime');
ImgEmoPath = evalin('caller', 'ImgEmoPath');
rectStop = evalin('caller', 'rectStop');
StopY = evalin('caller', 'StopY');
waitPunishment = evalin('caller', 'waitPunishment');
InBetweenTask_vec = evalin('caller', 'InBetweenTask_vec');
InBetweenTask_key = evalin('caller', 'InBetweenTask_key');
ParticipantDir = evalin('caller', 'ParticipantDir');
participantNum = evalin('caller', 'participantNum');
color_test_correct = evalin('caller', 'color_test_correct');
color_test_number = evalin('caller', 'color_test_number');
sessionNum = evalin('caller', 'sessionNum');
TimeBegin = evalin('caller', 'TimeBegin');

if attention_counter < 4
    attention_counter = attention_counter + 1;
else
    attention_counter = 1;
end

% Time limits 3 mins after which the experiments expires
timeStart = GetSecs;
respToBeMade = true ;
while (GetSecs - timeStart) < attentionTime && respToBeMade
    if (GetSecs - timeStart) > (attentionTime - endTime)
        img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
        Texture = Screen('MakeTexture', window, img);
        Screen('DrawTexture', window, Texture, [], rectStop);
        DrawFormattedText(window, InBetweenTextAttention,...
            'center', StopY, white)
        DrawFormattedText(window, InBetweenTask_vec(attention_counter,:),...
            'center', StopY*1.15, white);
    else
        DrawFormattedText(window, InBetweenTask_vec(attention_counter,:),...
            'center', 'center', white);
    end
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    RestrictKeysForKbCheck([]);
    [keyIsDown,~, keyCode] = KbCheck;
    if keyCode(InBetweenTask_key(attention_counter))
        respToBeMade = false;
    elseif keyIsDown && respToBeMade && (GetSecs - timeStart) < (attentionTime - endTime)
        img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
        Texture = Screen('MakeTexture', window, img);
        Screen('DrawTexture', window, Texture, [], rectStop);
        DrawFormattedText(window, WrongResponseText,...
            'center', StopY, white)
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        WaitSecs(waitPunishment);
    end
end

if respToBeMade && (GetSecs - timeStart) > attentionTime
    % Setting the parameters for the last part
    AttentionTestFailed = true;
    TimeEnd = GetSecs-TimeBegin;
    if sessionNum > 1
        % getting the extra variables
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