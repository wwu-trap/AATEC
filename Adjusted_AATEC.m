%----------------------------------------------------------------------
%                     Voreinstellungen
%----------------------------------------------------------------------
close all;
clc;
clear;
sca;
IOPort('closeall');
rng('shuffle');

Screen('Preference', 'SkipSyncTests', 1);

% Setup PTB with some default values
PsychDefaultSetup(2);
rng('shuffle');

%Reinladen der Texte
Texts_AATEC_Object;

currentDir = pwd;

ImgPath = fullfile(currentDir,'Pictures','Object');
ImgPracPath = fullfile(currentDir,'Pictures', 'PicsPracObj');
ImgEmoPath = fullfile(currentDir,"Pictures");


addpath(genpath(currentDir));

if ~exist(fullfile(currentDir, 'Results'),'dir')
    mkdir(fullfile(currentDir, 'Results'))
end
resultsDir = fullfile(currentDir,'Results');

debug=true;

%debug_key = false;
screenNumber=0;
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
WhiteTrans = [white white white 0.5];
grey = (white*.5412);

winCor = [];
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, winCor, 32, 2);

% Flip to clear
DrawFormattedText(window, 'Please wait!!!',...
    'center', 'center', white);
vbl = Screen('Flip', window);
%HideCursor();

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% We will use a range of text sizes
textSize = 44;
smallTextSize = 32;

% Set just now to the standard text size
Screen('TextSize', window, textSize);
Screen('TextFont',window, 'Helvetica');
Screen('TextStyle', window, 0);

%----------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------
% Number of frames to wait before updating the screen
waitframes = 1;

% The timing will be base time (stimulusTime)
% plus a random variable ranging from
% 0-stimulusExtra
stimulusTimeChoice = 3.5;
stimulusTimePreference = 4;
stimulusTimeColorTest= 10;

if debug
    % you can chnage the number of trials for
    % the practice and main part
    NumberofTrials = [6; 6; 4];
    NumberofTrialsPractice = [1; 1; 1];
    attention_trial = 2;
    color_attention_trial = 2;
    color_attention_trial_learning = 2;
    attentionTime = 3*6;
    attentionTimeLong = 8*6;
    endTime = 5;

    % wait for Key press interval time in seconds
    waitVarLong = 1.5;
    waitVarShort = .3;
    waitPunishment = 1.5;
else
    % you can chnage the number of trials for
    % the practice and main part
    NumberofTrials = [48; 48; 15];
    NumberofTrialsPractice = [6; 6; 6];
    attention_trial = 4;
    color_attention_trial = 10;
    color_attention_trial_learning = 8;
    attentionTime = 3*60;
    attentionTimeLong = 8*60;
    endTime = 20;

    % wait for Key press interval time in seconds
    waitVarLong = 3.5;
    waitVarShort = .3;
    waitPunishment = 1.5;
end
% Learning Timing
stimulusTimeAAT = .65;
stimulusTimeEC = .65;
waitLearningAAT = 2;
waitLearningEC = 2;

TimeBegin = GetSecs;


%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
downKey = KbName('DownArrow');
upKey = KbName('UpArrow');
aKey = KbName('a');
dKey = KbName('d');
gKey = KbName('g');
kKey = KbName('k');
qKey = KbName('q');
rKey = KbName('r');
uKey = KbName('u');
cKey = KbName('c');
mKey = KbName('m');
key1 = KbName('1!');
key2 = KbName('2@');
key3 = KbName('3#');
key4 = KbName('4$');
spacekey = KbName('space');

%----------------------------------------------------------------------
%                           Likert Scale
%----------------------------------------------------------------------
% Our scale will span a proportion of the screens x dimension
scaleLengthPix = screenYpixels / 1.5;
scaleHLengthPix = scaleLengthPix / 2;

% setting the y position of the elements
yDownward = .24;
yScalePosition = yCenter + screenYpixels*1.4*yDownward;

% Coordiantes of the scale left and right ends
leftEnd = [xCenter - scaleHLengthPix yScalePosition];
rightEnd = [xCenter + scaleHLengthPix yScalePosition];
scaleLineCoords = [leftEnd' rightEnd'];

% Scale line thickness
scaleLineWidth = 10;

% Make a base Rect relative to the size of the screen: this will be the
% toggle we can slide on the slider
dim = screenYpixels  / 36;
hDim = dim / 2;
baseRect = [0 0 dim/2 dim*1.5];

% Number of lines on our likert scale
numScaleLines = 11;

% The lines will be linearly spaced over the scale: here we make the xy
% coordinateas of each point
xPosScaleLines = linspace(xCenter - scaleHLengthPix, xCenter + scaleHLengthPix, numScaleLines);
yPosScaleLines = repmat(yScalePosition, 1, numScaleLines);
xyScaleLines = [xPosScaleLines-2; yPosScaleLines - 10; xPosScaleLines + 2; yPosScaleLines + 10];

% Text labels for the scale
sliderLabels = {lowerLikert, upperLikert};

% Get bounding boxes for the scale end label text
textBoundsAll = nan(2, 4);
for i = 1:2
    [~, ~, textBoundsAll(i, :)] = DrawFormattedText(window, sliderLabels{i}, 0, 0, white);
end

% Width and height of the scale end label text bounding boxs
textWidths = textBoundsAll(:, 3)';
textHeights = (-textBoundsAll(:, 2) + textBoundsAll(:, 4))';
halfTextHeights = textHeights / 2;


% Do the same for the numbers that we will put on the buttons. Here we
% toggle first to the smaller text size we will be using for the labels for
% the buttons then reinstate the standard text size
numBoundsAll = nan(numScaleLines, 4);
for i = 1:numScaleLines
    [~, ~, numBoundsAll(i, :)] = DrawFormattedText(window, num2str(i), 0, 0, white);
end

% Width and height of the scale number text bounding boxs
numWidths = numBoundsAll(:, 3)';
halfNumWidths = numWidths / 2;
numHeights = (-numBoundsAll(:, 2) + numBoundsAll(:, 4))';
halfNumHeights = numHeights / 2;

% Position of the scale text so that it is at the ends of the scale but does
% not overlap with the scales lines. Make sure it is also
% centered in the y dimension of the screen. To do this we used the bounding
% boxes of the text, plus a little gap so that the text does not completely
% edge the slider toggle in the x dimension
textPixGap = 50;
leftTextPosX = xCenter - scaleHLengthPix - hDim - textWidths(1) - textPixGap;
rightTextPosX = xCenter + scaleHLengthPix + hDim + textPixGap;

leftTextPosY = yScalePosition + halfTextHeights(1);
rightTextPosY = yScalePosition + halfTextHeights(2);

% The numbers are aligned to be directly under the relevent button (tops of
% their bounding boxes "numShiftDownPix" below the button y coordinate, and
% aligned laterally such that the centre of the text bounding boxes aligned
% with the x coordinate of the button
numShiftDownPix = 80;
xNumText = xPosScaleLines - halfNumWidths;
yNumText = yPosScaleLines + halfNumHeights + numShiftDownPix;

% Our slider will span a proportion of the screens x dimension
sliderLengthPix = screenYpixels / 1.5;
sliderHLengthPix = sliderLengthPix / 2;

%----------------------------------------------------------------------
%                       Participant Info
%----------------------------------------------------------------------
% Rect for the stopsign

try
    getNumber = true;
    participantNum = 100000 + randperm(899999,1);
    while getNumber
        if ~isfolder(fullfile(resultsDir, ['Participant_', int2str(participantNum)]))
            getNumber = false;
        else
            participantNum = 100000 + randperm(899999,1);
        end
    end

    participantNumInt = participantNum;
    participantNum = int2str(participantNum);

    if ~exist(fullfile(resultsDir, ['Participant_', participantNum]),'dir')
        mkdir(fullfile(resultsDir, ['Participant_', participantNum]))
    end
    ParticipantDir = fullfile(resultsDir, ['Participant_', participantNum]);

catch error
    pnet('closeall');
    sca;
    warning('something is not working properly: Participant Number!!');
    rethrow(error);
end


%----------------------------------------------------------------------
%                       logfile
%----------------------------------------------------------------------
%Speichert alles
ChoiceResponses = [];
realNumber = [];
realSychronicity = [];
realDuration = [];

TaskOneData = struct('ID',{}, 'Session', {},'TrialID1',{},'ImageNr',{},'Color',{},...
    'YesNoPosition',{},'RT',{},'Choice',{});

TaskTwoData = struct('ID',{}, 'Session', {},'TrialID2',{},'ImageNr',{},'Color',{},...
    'LikertPos',{},'RT',{}, 'Pref',{});

%TaskThreeData = struct('ID',{}, 'Session', {},'TrialID3',{},'ImageRightNr',{},...
%    'ImageLeftNr',{}, 'ColorImageRight',{},'ColorImageLeft',{},...
%    'Choice',{},'RT',{});

LearningData = struct('ID',{}, 'Session', {},'TrialID',{},'ImageNr',{},...
    'Color',{}, 'LearningMethod',{}, 'LearningValence',{},'Response',{},...
    'RT',{},'RTAfter',{},'Accuracy', {},'ExtraTime',{},'YesNoPosition',{},...
    'SoundWave',{},'SoundOrder',{},'ECImageValence',{}, 'ECImageNr',{}, ...
    'Block_order_var',{});



%for sessionNum = 1:3
sessionNum=1;
% Practice Images
dirImagesPrac = dir(ImgPracPath);
list= cellfun(@isempty,regexp({dirImagesPrac.name},'.*\.png$'));
dirImagesPrac=dirImagesPrac(~list);
dirImagesPrac = dirImagesPrac(randperm(size(dirImagesPrac, 1)), :);

% Main Images
dirImages = dir(ImgPath); %511
list= cellfun(@isempty,regexp({dirImages.name},'.*\.png$'));
dirImages=dirImages(~list);
dirImages = dirImages(randperm(size(dirImages, 1)), :);


dirImagesPositive = dir(fullfile(ImgEmoPath,'Positive'));
list= cellfun(@isempty,regexp({dirImagesPositive.name},'.*\.jpg$'));
dirImagesPositive=dirImagesPositive(~list);
dirImagesPositive = dirImagesPositive(randperm(size(dirImagesPositive, 1)), :);

dirImagesNegative = dir(fullfile(ImgEmoPath,'Negative'));
list= cellfun(@isempty,regexp({dirImagesNegative.name},'.*\.jpg$'));
dirImagesNegative=dirImagesNegative(~list);
dirImagesNegative = dirImagesNegative(randperm(size(dirImagesNegative, 1)), :);





if sessionNum == 1
    color = [{'r'}; {'b'}; {'y'}; {'o'}; {'g'}; {'p'}];
    color = color(randperm(size(color, 1)), :)';
    n =length(dirImages)/length(color);
    color_vec = repmat(color,1,n)';
    [dirImages.color] = color_vec{:};
    save(fullfile(ParticipantDir, strcat('color_', participantNum, '.mat')), 'color');
    save(fullfile(ParticipantDir, strcat('dirImages_', participantNum, '.mat')), 'dirImages');
else
    pnet('closeall');
    sca;
    error(sprintf(['The participant should first finish the first session correctly!\n' ...
        'Also please check whether you entered the participants ID correctly.']));
    rethrow(error);
end


% randomizing the practice vectors
colorPrac = [{'.'}; {','}; {';'}; {'['}; {']'}; {'!'}];
[dirImagesPrac.color] = colorPrac{:};
dirImagesTask1Prac = dirImagesPrac(randperm(size(dirImagesPrac, 1)), :);
dirImagesTask2Prac = dirImagesPrac(randperm(size(dirImagesPrac, 1)), :);


% randomizing the Task One vector, 549
randomize = true;
while randomize
    randomize = false;
    dirImagesTask1 = dirImages(randperm(size(dirImages, 1)), :);
    for ii = 3:length(dirImagesTask1)
        if strcmp(dirImagesTask1(ii).color,dirImagesTask1(ii-1).color)
            if strcmp(dirImagesTask1(ii-1).color,dirImagesTask1(ii-2).color)
                randomize = true;
            end
        end
    end
end
dirImagesTask2=dirImagesTask1;



% loading a template Image for finding the size of the image
imgSize = imread(fullfile(ImgPath, dirImagesTask1(1).name));
% Rect for the faces
scaleFactor = .25;
baseSize = scaleFactor*[size(imgSize,2) size(imgSize,1)];
rect = [xCenter - baseSize(1)/2, yCenter - baseSize(2)/2,...
    xCenter + baseSize(1)/2, yCenter + baseSize(2)/2];
% Rect for the stopsign
squareSize = 150;
rectStop = [xCenter - squareSize, yCenter - squareSize,...
    xCenter + squareSize, yCenter + squareSize];
% Rect for comparative choice task
scaleFactorComp = .25;
baseSizeComp = scaleFactorComp*[size(imgSize,2) size(imgSize,1)];
xCenterRight = screenXpixels*.60;
rectRight = [xCenterRight - baseSizeComp(1)/2, yCenter - baseSizeComp(2)/2,...
    xCenterRight + baseSizeComp(1)/2, yCenter + baseSizeComp(2)/2];
xCenterLeft = screenXpixels*.40;
rectLeft = [xCenterLeft - baseSizeComp(1)/2, yCenter - baseSizeComp(2)/2,...
    xCenterLeft + baseSizeComp(1)/2, yCenter + baseSizeComp(2)/2];

% position of questions according to images
YesNoX = [xCenter + baseSize(1)/2 - 55, xCenter - baseSize(1)/2 - 20];
YesNoY = yCenter + screenYpixels*1.3*yDownward; %Edit: Nach unten verschoben
StopY = yCenter + screenYpixels*.20;


Question1X =[xCenter+baseSize(1)/2-450]; %+ baseSize(1)/2 - 55, xCenter - baseSize(1)/2 - 20
Question1Y = yCenter + screenYpixels*yDownward;

Question2X =[xCenter+baseSize(1)/2-450]; %+ baseSize(1)/2 - 55, xCenter - baseSize(1)/2 - 20
Question2Y = yCenter + screenYpixels*yDownward;

Question3X =[xCenter+baseSize(1)/2-450]; %+ baseSize(1)/2 - 55, xCenter - baseSize(1)/2 - 20
Question3Y = yCenter + screenYpixels*yDownward;

Question4X =[xCenter+baseSize(1)/2-450]; %+ baseSize(1)/2 - 55, xCenter - baseSize(1)/2 - 20
Question4Y = yCenter + screenYpixels*yDownward;

% Producing Zooming matrix based on the image size
ZoomingDistance = 50;
ZoomingDistanceMin = 30;
xyZoomScale=(size(imgSize,2)/size(imgSize,1));
ZoomingMatrix = 2*[-1*xyZoomScale,-1,1*xyZoomScale,1];
% Rect for the box
pen_width = 10;
baseBoxNum = 20;
rectBox = rect + [-baseBoxNum*xyZoomScale,-baseBoxNum,baseBoxNum*xyZoomScale,baseBoxNum];
rectBoxRight = rectRight + [-baseBoxNum*xyZoomScale,-baseBoxNum,baseBoxNum*xyZoomScale,baseBoxNum];
rectBoxLeft = rectLeft + [-baseBoxNum*xyZoomScale,-baseBoxNum,baseBoxNum*xyZoomScale,baseBoxNum];




try

    if sessionNum == 1  



        %----------------------------------------------------------
        %Mit iBlocks setzt du wie viele Durchführungen du machen willst
        %Eine Durchführung sind zwei Blocks
        %Beispiel:
        %Für insgesamt drei Durchführung mit jeweils 4 Fragen (zwei Likert und zwei Ja/Nein)
        %Setze iBlocks auf 6
        %----------------------------------------------------------
        startingBlock = 1;
        iBlocks = 6;
    

        for Block = startingBlock:iBlocks


            index = ceil(Block / 2);

            img = imread(fullfile(ImgPath, dirImagesTask1(index).name));%Bildnr
            Texture = Screen('MakeTexture', window, img);

            if mod(Block, 2) == 1
                %if Block == 1 || Block == 3 || Block == 5 %|| Block == 7
                Screen('TextSize', window, textSize);
                numTrials = 2;%NumberofTrials(1); % Debug=True also 6 %numTrials in dem Fall anzahl an Bilders


                for trial= 1: numTrials
                    %Zahl.sub
                    trialsub = [];
                    if mod(Block, 2) == 1  % Prüft, ob Block ungerade ist
                        trialsub = trial + ((Block - 1) / 2) * numTrials;
                    end



                        %if Block == 1 %|| Block == 3
                        %    trialsub = trial;
                        %elseif Block == 3%5
                        %    trialsub = trial + numTrials;
                        %elseif Block == 5%7
                        %    trialsub = trial + 2*numTrials;
                        %end


                        RT = []; % Reaktionsziet
                        Choice = []; % Speichert die Antwort


                        if mod(trial, 2) ~= 0 %wenn ungerade
                            Screen('DrawTexture', window, Texture, [], rect);
                            DrawFormattedText(window, YesText,...
                                YesNoX(1), YesNoY, white);
                            DrawFormattedText(window, NoText,...
                                YesNoX(2), YesNoY, white);
                            DrawFormattedText(window, Question1,...
                                Question1X, Question1Y, white);
                            Screen('Flip', window);

                        else
                            Screen('DrawTexture', window, Texture, [], rect);
                            DrawFormattedText(window, YesText,...
                                YesNoX(1), YesNoY, white);
                            DrawFormattedText(window, NoText,...
                                YesNoX(2), YesNoY, white);
                            DrawFormattedText(window, Question2,...
                                Question1X, Question1Y, white);
                            Screen('Flip', window);
                        end



                        timeStart = GetSecs;
                        WaitSecs(waitVarShort);
                        RestrictKeysForKbCheck([]);
                        respToBeMade = true;
                        while respToBeMade && (GetSecs - timeStart) < stimulusTimeChoice
                            % Check the keyboard. The person should press either
                            % 'm' or 'c' to accept or reject the picture
                            [keyIsDown,secs, keyCode] = KbCheck;
                            if keyCode(escapeKey) && debug_key
                                ShowCursor;
                                close all
                                warning('Terminated by user input:!!nothing is saved!!')
                                sca;
                                return
                            elseif keyCode(mKey)
                                Choice = 'Yes';
                                RT = GetSecs - timeStart;
                                respToBeMade = false;
                            elseif keyCode(cKey)
                                Choice = 'No';
                                RT = GetSecs - timeStart;
                                respToBeMade = false;
                            end
                        end

                        TaskOneData(trialsub).ID = ['Sub_', num2str(participantNum)];
                        TaskOneData(trialsub).Session = ['Session_', num2str(sessionNum)];
                        TaskOneData(trialsub).TrialID1 = ['Trial_',num2str(trialsub)];
                        TaskOneData(trialsub).ImageNr = dirImagesTask1(index).name;
                        TaskOneData(trialsub).YesNoPosition = '1';
                        TaskOneData(trialsub).RT = RT;
                        TaskOneData(trialsub).Choice = Choice;

                    end





                    %----------------------------------------------------------------------
                    %                           The Preference Task
                    %----------------------------------------------------------------------

                    %elseif Block == 2 || Block == 4 || Block == 6 %|| Block == 8
                elseif mod(Block, 2) == 0

                    Blockneu = Block -1;
                    Texture = Screen('MakeTexture', window, img);

                    %nnumTrials = 2;%NumberofTrials(2);
                    Screen('TextSize', window, textSize);

                    for trial= 1: numTrials
                        % start of the main task
                        trialsub = [];
                       % if Block == 2 %|| Block == 4
                       %     trialsub = trial;
                       % elseif Block == 4
                       %     trialsub = trial+numTrials;
                       % elseif Block == 6
                       %     trialsub = trial+2*numTrials;
                       % end

                        if mod(Block, 2) == 0  % Prüft, ob Block ungerade ist
                        trialsub = trial + ((Block - 2) / 2) * numTrials;
                        end


                        RT = [];
                        Pref = [];

                        Texture = Screen('MakeTexture', window, img);

                        Screen('DrawLines', window, scaleLineCoords, scaleLineWidth, WhiteTrans);

                        if mod(trial, 2) ~= 0
                            DrawFormattedText(window, Question3,...
                                Question1X, Question1Y, white);
                        else
                            DrawFormattedText(window, Question4,...
                                Question1X, Question1Y, white);
                        end
                        DrawFormattedText(window, sliderLabels{1}, leftTextPosX, leftTextPosY, WhiteTrans);
                        DrawFormattedText(window, sliderLabels{2}, rightTextPosX, rightTextPosY, WhiteTrans);
                        % Draw the Question for the slider
                        %DrawFormattedText(window, LikertQues, 'center', yCenter + screenYpixels*.25, white);
                        % Draw the likert scale lines
                        Screen('FillRect', window, WhiteTrans, xyScaleLines);
                        % We now set the toggles initial position
                        sx = xPosScaleLines(round(length(xPosScaleLines)/2));
                        centeredRect = CenterRectOnPointd(baseRect, sx, yPosScaleLines(1));
                        % Draw the slider
                        Screen('FillRect', window, white , centeredRect);
                        % drawing the box around the image
                        %Screen('FrameRect', window, colortmp, rectBox, pen_width);
                        % Draw the actual image
                        Screen('DrawTexture', window, Texture, [], rect);
                        % Flip to show
                        Screen('Flip', window);

                        % Preparing for the response
                        RestrictKeysForKbCheck([]);
                        respToBeMade = true;
                        % Here we set the initial position of the mouse to the centre of the screen
                        SetMouse(xCenter, yCenter, window);
                        % timing information
                        timeStart = GetSecs;
                        WaitSecs(waitVarShort);
                        while respToBeMade && (GetSecs - timeStart) < stimulusTimePreference
                            % Get the current position of the mouse
                            [mx, my, buttons] = GetMouse(window);
                            % sliding the red cox based on the cursor's
                            % psoition
                            if mx > xCenter + scaleHLengthPix
                                sx = xCenter + scaleHLengthPix;
                            elseif mx < xCenter - scaleHLengthPix
                                sx = xCenter - scaleHLengthPix;
                            else
                                sx = mx;
                            end
                            Preftmp = (sx - (xCenter - scaleHLengthPix)) / scaleLengthPix;
                            % Check the keyboard
                            [keyIsDown,secs, keyCode] = KbCheck;
                            if keyCode(escapeKey) && debug_key
                                ShowCursor;
                                close all
                                warning('Terminated by user input:!!nothing is saved!!')
                                sca;
                                return
                            elseif buttons(1) || buttons (2) || buttons (3)
                                RT = GetSecs - timeStart;
                                Pref = Preftmp;
                                respToBeMade = false;
                            end


                            Screen('DrawLines', window, scaleLineCoords, scaleLineWidth, WhiteTrans);
                            % Text for the ends of the slider
                            if mod(trial, 2) ~= 0
                                DrawFormattedText(window, Question3,...
                                    Question1X, Question1Y, white);
                            else
                                DrawFormattedText(window, Question4,...
                                    Question1X, Question1Y, white);
                            end
                            % Draw the scale line

                            DrawFormattedText(window, sliderLabels{1}, leftTextPosX, leftTextPosY, WhiteTrans);
                            DrawFormattedText(window, sliderLabels{2}, rightTextPosX, rightTextPosY, WhiteTrans);
                            % Draw the Question for the slider
                            %DrawFormattedText(window, LikertQues, 'center', yCenter + screenYpixels*.25, white);
                            % Draw the likert scale lines
                            Screen('FillRect', window, WhiteTrans, xyScaleLines);
                            % Center the slidre toggle on its new screen position
                            centeredRect = CenterRectOnPointd(baseRect, sx, yPosScaleLines(1));
                            Screen('FillRect', window, white , centeredRect);
                            % drawing the box around the image
                            %Screen('FrameRect', window, colortmp, rectBox, pen_width);
                            % Draw the actual image
                            Screen('DrawTexture', window, Texture, [], rect);
                            % Report the current slider position
                            %DrawFormattedText(window, ['Rating: ' num2str(round(Preftmp * 100)) '%'],...
                            %   'center', yCenter + screenYpixels * 0.35, white);
                            % Flip to show
                            Screen('Flip', window);

                        end

                        TaskTwoData(trialsub).ID = ['Sub_', num2str(participantNum)];
                        TaskTwoData(trialsub).Session = ['Session_', num2str(sessionNum)];
                        TaskTwoData(trialsub).TrialID2 = ['Trial_', num2str(trialsub)];
                        TaskTwoData(trialsub).ImageNr = dirImagesTask2(index).name;%Bildnr Blockne
                        TaskTwoData(trialsub).YesNoPosition = '1';
                        TaskTwoData(trialsub).RT = RT;
                        TaskTwoData(trialsub).Pref = Pref;

                    end

                end

            end



        end


    catch error
        pnet('closeall');
        sca;

        warning(strcat('something is not working properly: Main Experimental Loop,', ...
            'in the session ',int2str(sessionNum), '!'));
        rethrow(error);

    end





    %end

    %----------------------------------------------------------------------
    %                       Saving Logfiles
    %----------------------------------------------------------------------
    logfile = struct();
    %if sessionNum == 1
    logfile = struct('ParticipantNum',participantNum,'SessionNum',sessionNum,...
        'TaskOneData', TaskOneData, 'TaskTwoData',TaskTwoData);
    % elseif sessionNum == 2
    %logfile = struct('ParticipantNum',participantNum,'SessionNum',sessionNum,...
    %    'LearningData', LearningData);
    %elseif sessionNum == 3
    %logfile = struct('ParticipantNum',participantNum,'SessionNum',sessionNum,...
    %    'TaskOneData', TaskOneData, 'TaskTwoData',TaskTwoData, ...
    %    'TaskThreeData', TaskThreeData);
    %end

    if ~isfile(fullfile(ParticipantDir,['logFile_',participantNum,'_',num2str(sessionNum),'.mat']))
        save(fullfile(ParticipantDir, ['logFile_',participantNum,'_',num2str(sessionNum),'.mat']),...
            'logfile');
        save(fullfile(ParticipantDir, ['logFile_full_',participantNum,'_',num2str(sessionNum),'.mat']))
    else
        save(fullfile(ParticipantDir, ['logFile_',participantNum,'_',num2str(sessionNum),...
            datestr(now,'mm-dd-yyyy_HH-MM'),'.mat']),'logfile');
        save(fullfile(ParticipantDir, ['logFile_full_',participantNum,'_',num2str(sessionNum),...
            datestr(now,'mm-dd-yyyy_HH-MM'),'.mat']))
    end

    % Close the log file
    %fclose(logFile);
    %----------------------------------------------------------------------
    %                         Cleaning UP
    %----------------------------------------------------------------------

    % Close all open socket connections
    sca;
    pnet('closeall');
    IOPort('closeall');
    % Display a message
    disp('connection closed');
    close all
    % save the attentional text
    %TimeEnd = GetSecs-TimeBegin;
    %attentional_text(ParticipantDir, participantNum, AttentionTestFailed, TimeEnd, ...
    %    color_test_correct, color_test_number,...
    %    CounterErrorAAT, CounterErrorEC, trialEC, trialAAT)

    fprintf('*******************************\n')
    fprintf('Experiment was finished successfully and everything is saved\n')
    fprintf('*******************************\n')
