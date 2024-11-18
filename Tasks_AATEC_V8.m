%----------------------------------------------------------------------
%                       AATEC Tasks
%                Copyright: @A.Zahedi 2024
%----------------------------------------------------------------------

% Clear the workspace
close all;
clc;
clear;
sca;
IOPort('closeall');
rng('shuffle');

Texts_AATEC_Object;

Screen('Preference', 'SkipSyncTests', 1);
conBlack = 1;

% Setup PTB with some default values
PsychDefaultSetup(2);

% Seed the random number generator.
rng('shuffle');

%----------------------------------------------------------------------
%                       Essential Paths
%----------------------------------------------------------------------
currentDir = pwd;
ImgPath = fullfile(currentDir,'Pictures','Object');
ImgPracPath = fullfile(currentDir,'Pictures', 'PicsPracObj');
ImgEmoPath = fullfile(currentDir,"Pictures");

%----------------------------------------------------------------------
%                       Monitor
%----------------------------------------------------------------------

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Screen('Preference', 'SkipSyncTests', 0)

% Query the maximum priority level
% topPriorityLevel = MaxPriority(window);
% Priority(topPriorityLevel);

% Define black, white and grey
white = WhiteIndex(screenNumber);
WhiteTrans = [white white white 0.5];
grey = (white*.5412);
black = BlackIndex(screenNumber);

% Open the screen
debug = false;
debug_key = false;

if debug
    winCor = []; %[0 0 720 450];
else
    winCor = [];
end
if conBlack == false
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, winCor, 32, 2);
else
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, winCor, 32, 2);
end

% Flip to clear
DrawFormattedText(window, 'Please wait!!!',...
    'center', 'center', white);
vbl = Screen('Flip', window);
HideCursor();

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
stimulusTimeChoice = 1.5;
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
    waitVarLong = .5;
    waitVarShort = .3;
    waitPunishment = .5;
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
AttentionTestFailed = false;
%----------------------------------------------------------------------
%                       Fixation Cross
%----------------------------------------------------------------------
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 6;

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
yScalePosition = yCenter + screenYpixels*yDownward;

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
%                           Attention vector
%---------------------------------------------------------------------- 
attention_counter = 0;
InBetweenTask_vec = [InBetweenTask1; InBetweenTask2; InBetweenTask3; InBetweenTask4];
InBetweenTask_key = [aKey, dKey, gKey, kKey];

color_test_correct = 0;
color_test_number = 0;
%----------------------------------------------------------------------
%                       Participant Info
%----------------------------------------------------------------------
% Rect for the stopsign
squareSize = 150;
rectStop = [xCenter - squareSize, yCenter - squareSize,...
    xCenter + squareSize, yCenter + squareSize];
StopY = yCenter + screenYpixels*.20;

try
    if ~exist(fullfile(currentDir, 'Results'),'dir')
        mkdir(fullfile(currentDir, 'Results'))
    end
    resultsDir = fullfile(currentDir,'Results');

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

    % Text with attention time
    AttentionTestFailed = general_attention(ParText, waitVarShort*3, 1);
    if AttentionTestFailed
        return
    end

catch error
    pnet('closeall');
    sca;
    warning('something is not working properly: Participant Number!!');
    rethrow(error);
end



%----------------------------------------------------------------------
%                           Sound Setting
%----------------------------------------------------------------------
AssertOpenGL;
Fs = 48000;                                     % Sampling Frequency wave high
secs = .1;
t  = linspace(0, secs, Fs*secs+1);              % Time Vector + 1 sample
t(end) = [];                                    % remove extra sample
w1 = 2*pi*1440;
s1 = [sin(w1*t); sin(w1*t)]; 
w2 = 2*pi*2500;                                 % Radian Value To Create 1440 Hz Tone
s2 = [sin(w2*t); sin(w2*t)];                                 % Create second Tone

% Counterbalancing the sound order based on the participants number
sound = [];
sound_name = [];
if rem(participantNumInt,4) == 0
    sound = [{s1} {s2}];
    sound_name = [{'S1'} {'S2'}];
elseif rem(participantNumInt,4) == 1
    sound = [{s2} {s1}];
    sound_name = [{'S2'} {'S1'}];
elseif rem(participantNumInt,4) == 2
    sound = [{s2} {s1}];
    sound_name = [{'S2'} {'S1'}];
elseif rem(participantNumInt,4) == 3
    sound = [{s1} {s2}];
    sound_name = [{'S1'} {'S2'}];
end

save(fullfile(ParticipantDir, strcat('sound_', participantNum, '.mat')), 'sound');
% % Perform basic initialization of the sound driver:
% InitializePsychSound;
nrchannels = 2;
% Try with the 'freq'uency we wanted:
pahandle = PsychPortAudio('Open', [], [], 0, Fs, nrchannels);

try
    % Sound checkup
    sound_test_order = repelem([1 2], 3);
    sound_test_order = sound_test_order(randperm(length(sound_test_order)));
    ll = 1;
    DrawFormattedText(window, SoundText,...
                'center', 'center', white);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    WaitSecs(waitVarShort*3);
    timeStart = GetSecs;
    wait = true;
    while wait && GetSecs - timeStart < attentionTime
        if (GetSecs - timeStart) > (attentionTime - endTime)
            img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
            Texture = Screen('MakeTexture', window, img);
            Screen('DrawTexture', window, Texture, [], rectStop);
            DrawFormattedText(window, InBetweenTextAttention,...
                'center', StopY, white)
            DrawFormattedText(window, SoundTextShort,...
                'center', StopY*1.15, white);
        else
            DrawFormattedText(window, SoundText,...
                'center', 'center', white);
        end
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

        % Fill the audio playback buffer with the audio data 'wavedata':
        PsychPortAudio('FillBuffer', pahandle, sound{sound_test_order(ll)});
        if ll < length(sound_test_order)
            ll = ll +1;
        else
            ll = 1;
            sound_test_order = sound_test_order(randperm(length(sound_test_order)));
        end
        % Start audio playback for 'repetitions' repetitions of the sound data,
        % start it immediately (0) and wait for the playback to start, return onset
        % timestamp.
        t1 = PsychPortAudio('Start', pahandle, 1, 0, 1);
        timeStartSound = GetSecs;
        while (GetSecs - timeStartSound) < 4*waitVarShort
            RestrictKeysForKbCheck(spacekey);
            [keyIsDown,secs, keyCode] = KbCheck;
            if keyCode(spacekey)
                wait = false;
            end
        end
    end
    if wait && (GetSecs - timeStart) > attentionTime
        % Setting the parameters for the last part
        AttentionTestFailed = true;
        TimeEnd = GetSecs-TimeBegin;

        attentional_text(ParticipantDir, participantNum, AttentionTestFailed, TimeEnd, ...
            color_test_correct, color_test_number)

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

catch error
    pnet('closeall');
    sca;
    warning('something is not working properly: Participant Number!!');
    rethrow(error);
end
%----------------------------------------------------------------------
%                       logfile
%----------------------------------------------------------------------
ChoiceResponses = [];
realNumber = [];
realSychronicity = [];
realDuration = [];

TaskOneData = struct('ID',{}, 'Session', {},'TrialID1',{},'ImageNr',{},'Color',{},...
    'YesNoPosition',{},'RT',{},'Choice',{});

TaskTwoData = struct('ID',{}, 'Session', {},'TrialID2',{},'ImageNr',{},'Color',{},...
    'LikertPos',{},'RT',{}, 'Pref',{});

TaskThreeData = struct('ID',{}, 'Session', {},'TrialID3',{},'ImageRightNr',{},...
    'ImageLeftNr',{}, 'ColorImageRight',{},'ColorImageLeft',{},...
    'Choice',{},'RT',{});

LearningData = struct('ID',{}, 'Session', {},'TrialID',{},'ImageNr',{},...
    'Color',{}, 'LearningMethod',{}, 'LearningValence',{},'Response',{},...
    'RT',{},'RTAfter',{},'Accuracy', {},'ExtraTime',{},'YesNoPosition',{},...
    'SoundWave',{},'SoundOrder',{},'ECImageValence',{}, 'ECImageNr',{}, ...
    'Block_order_var',{});

for sessionNum = 1:3
    %----------------------------------------------------------------------
    %                           Images
    %----------------------------------------------------------------------
    % Practice Images
    dirImagesPrac = dir(ImgPracPath);
    list= cellfun(@isempty,regexp({dirImagesPrac.name},'.*\.png$'));
    dirImagesPrac=dirImagesPrac(~list);
    dirImagesPrac = dirImagesPrac(randperm(size(dirImagesPrac, 1)), :);

    % Main Images
    dirImages = dir(ImgPath);
    list= cellfun(@isempty,regexp({dirImages.name},'.*\.png$'));
    dirImages=dirImages(~list);
    dirImages = dirImages(randperm(size(dirImages, 1)), :);
    
    if sessionNum == 1
        color = [{'r'}; {'b'}; {'y'}; {'o'}; {'g'}; {'p'}];
        color = color(randperm(size(color, 1)), :)';
        n =length(dirImages)/length(color);
        color_vec = repmat(color,1,n)';
        [dirImages.color] = color_vec{:};
        save(fullfile(ParticipantDir, strcat('color_', participantNum, '.mat')), 'color');
        save(fullfile(ParticipantDir, strcat('dirImages_', participantNum, '.mat')), 'dirImages');
    elseif sessionNum == 3 || sessionNum == 2
        if isfile(fullfile(ParticipantDir,strcat('dirImages_', participantNum, '.mat')))
            load(fullfile(ParticipantDir,strcat('dirImages_', participantNum, '.mat')));
            load(fullfile(ParticipantDir,strcat('color_', participantNum, '.mat')));
        else
            pnet('closeall');
            sca;
            error(sprintf(['The participant should first finish the first session correctly!\n' ...
                'Also please check whether you entered the participants ID correctly.']));
            rethrow(error);
        end
    end
    % randomizing the practice vectors
    colorPrac = [{'.'}; {','}; {';'}; {'['}; {']'}; {'!'}];
    [dirImagesPrac.color] = colorPrac{:};
    dirImagesTask1Prac = dirImagesPrac(randperm(size(dirImagesPrac, 1)), :);
    dirImagesTask2Prac = dirImagesPrac(randperm(size(dirImagesPrac, 1)), :);

    % randomizing the Task One vector
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

    
    % randomizing the Task Two vector
    randomize = true;
    while randomize
        randomize = false;
        dirImagesTask2 = dirImages(randperm(size(dirImages, 1)), :);
        for ii = 3:length(dirImagesTask2)
            if strcmp(dirImagesTask2(ii).color,dirImagesTask2(ii-1).color)
                if strcmp(dirImagesTask2(ii-1).color,dirImagesTask2(ii-2).color)
                    randomize = true;
                end
            end
        end
    end
    
    dirImagesTask3 = struct('NameRight', {}, 'NameLeft', {},...
        'ColorRight', {}, 'ColorLeft', {});
    dirImagesTask3Prac =struct('NameRight', {}, 'NameLeft', {},...
        'ColorRight', {}, 'ColorLeft', {});

    if sessionNum == 3
        dirImagesTask3 = task_three_maker(dirImages,color, NumberofTrials);
        dirImagesTask3Prac = task_three_maker(dirImagesPrac,colorPrac', NumberofTrialsPractice);
    end
    % randomizing the Task Three vector
    dirImagesTask3 = dirImagesTask3(randperm(size(dirImagesTask3, 1)), :);
    dirImagesTask3Prac = dirImagesTask3Prac(randperm(size(dirImagesTask3Prac, 1)), :);
    
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
    YesNoY = yCenter + screenYpixels*yDownward;
    StopY = yCenter + screenYpixels*.20;
    
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
    %----------------------------------------------------------------------
    %                        creating the LearningImageVector
    %----------------------------------------------------------------------
    if sessionNum == 2
        dirImagesLearning = struct;
        LearningMethod = [{'AAT'} {'EC'}];
        LearningValence = [{'p'} {'m'} {'n'}];
        for ii = 1:length(LearningMethod)
            for jj = 1:length(LearningValence)
                tmp = [];
                if ii == 1
                    tmp = [dirImages([dirImages.color] == color{jj})];
                elseif ii == 2
                    tmp = [dirImages([dirImages.color] == color{(jj+3)})];
                end
    
                LearningMethod_vec = repmat(LearningMethod(ii),1,length(tmp));
                [tmp.LearningMethod] = LearningMethod_vec{:};
                LearningValence_vec = repmat(LearningValence(jj),1,length(tmp));
                [tmp.LearningValence] = LearningValence_vec{:};
    
                if ii == 1 && jj == 1
                    f = fieldnames(tmp)';
                    f{2,1} = {};
                    dirImagesLearning = struct(f{:});
                end
                for kk = 1:length(tmp)
                    dirImagesLearning(end+1) = tmp(kk);
                end
            end
        end
        % randomizing the LearningVector for separate mini blocks
        dirImagesLearning = struct2table(dirImagesLearning');
        dirImagesLearningAAT = dirImagesLearning(strcmp(dirImagesLearning.LearningMethod, 'AAT'),:);
        dirImagesLearningAAT = dirImagesLearningAAT(randperm(size(dirImagesLearningAAT, 1)), :);
        dirImagesLearningEC = dirImagesLearning(strcmp(dirImagesLearning.LearningMethod, 'EC'),:);
        dirImagesLearningEC = dirImagesLearningEC(randperm(size(dirImagesLearningEC, 1)), :);
        dirImagesLearning = table2struct( ...
            [dirImagesLearningAAT(1:height(dirImagesLearningAAT)/2,:);...
            dirImagesLearningEC(1:height(dirImagesLearningEC)/2,:);...
            dirImagesLearningAAT((height(dirImagesLearningAAT)/2)+1:end,:);...
            dirImagesLearningEC((height(dirImagesLearningEC)/2)+1:end,:)] ...
            );
        % the LearningVector for practice part
        dirImagesLearningPrac = [dirImagesPrac(randperm(size(dirImagesPrac, 1)), :); ...
            dirImagesPrac(randperm(size(dirImagesPrac, 1)), :)];
        PracLearningMethodVector = [{'AAT'} {'AAT'}  {'AAT'} {'AAT'} {'AAT'} {'AAT'} ...
            {'EC'} {'EC'} {'EC'} {'EC'} {'EC'} {'EC'}];
        [dirImagesLearningPrac.LearningMethod] = PracLearningMethodVector{:};
        PracLearningValence = [{'p'} {'m'} {'n'} {'p'} {'m'} {'n'} {'p'} {'m'} {'n'} {'p'} {'m'} {'n'}];
        [dirImagesLearningPrac.LearningValence] = PracLearningValence{:};


        dirImagesPositive = dir(fullfile(ImgEmoPath,'Positive'));
        list= cellfun(@isempty,regexp({dirImagesPositive.name},'.*\.jpg$'));
        dirImagesPositive=dirImagesPositive(~list);
        dirImagesPositive = dirImagesPositive(randperm(size(dirImagesPositive, 1)), :);
    
        dirImagesNegative = dir(fullfile(ImgEmoPath,'Negative'));
        list= cellfun(@isempty,regexp({dirImagesNegative.name},'.*\.jpg$'));
        dirImagesNegative=dirImagesNegative(~list);
        dirImagesNegative = dirImagesNegative(randperm(size(dirImagesNegative, 1)), :);
    
        % loading a template Image for finding the size of the image
        imgSize2 = imread(fullfile(dirImagesPositive(1).folder, dirImagesPositive(1).name));
    
        % Rect for the emotional images
        scaleFactorEmo = .4;
        xCenterRightEmo = screenXpixels*.65;
        xCenterLeftEmo = screenXpixels*.35;
        baseSize2 = scaleFactorEmo*[size(imgSize2,2) size(imgSize2,1)];
        rect2 = [xCenter - baseSize2(1)/2, yCenter - baseSize2(2)/2,...
            xCenter + baseSize2(1)/2, yCenter + baseSize2(2)/2];
        rect2Left = [xCenterLeftEmo  - baseSize2(1)/2, yCenter - baseSize2(2)/2,...
            xCenterLeftEmo + baseSize2(1)/2, yCenter + baseSize2(2)/2];
        rect2Right = [xCenterRightEmo - baseSize2(1)/2, yCenter - baseSize2(2)/2,...
            xCenterRightEmo + baseSize2(1)/2, yCenter + baseSize2(2)/2];
    end

    if sessionNum == 1
        % Text with attention time
        AttentionTestFailed = general_attention(ParText2, waitVarShort*3, 4);
        if AttentionTestFailed
            return
        end
    end

    %----------------------------------------------------------------------
    %                       Experimental loop
    %----------------------------------------------------------------------
    try
        %----------------------------------------------------------------------
        %                       Adiminstrating Tasks
        %----------------------------------------------------------------------
        if sessionNum == 1 || sessionNum == 3
            iBlocks = 8;
            startingBlock = 1;
            if sessionNum == 3
                startingBlock = 3;
            end

            % Text with attention time
            if sessionNum == 1
                AttentionTestFailed = general_attention(SessionOneText, waitVarLong);
            elseif sessionNum == 3
                AttentionTestFailed = general_attention(SessionThreeText, waitVarLong);
            end
            if AttentionTestFailed
                return
            end

            for Block = startingBlock:iBlocks
                %----------------------------------------------------------------------
                %                           The Choice Task
                %----------------------------------------------------------------------
                if Block == 1 || Block == 3 || Block == 5 || Block == 7
                    Screen('TextSize', window, textSize);
                    if Block == 1
                        numTrials = NumberofTrialsPractice(1);
                    else
                        numTrials = NumberofTrials(1);
                    end
                    isiTimeSecs =  .45 + rand(numTrials,1)/10; isiTimeFrames = round(isiTimeSecs / ifi);
                    
                    % Text with attention time
                    if Block == 3 && sessionNum == 3
                        AttentionTestFailed = general_attention(RestTextOneBlockThree, waitVarLong/2);
                    elseif Block == 1
                        AttentionTestFailed = general_attention(TaskOneText, waitVarLong/2);

                    elseif Block == 3 && sessionNum == 1
                        AttentionTestFailed = general_attention(EndofPracticeText, waitVarLong/2);

                    elseif Block == 5 || Block == 7
                        AttentionTestFailed = general_attention(RestTextOne, waitVarLong/2);
                    end
                    if AttentionTestFailed
                        return
                    end

                    if Block ~= 1
                        if debug
                            attention_trial_vec =  attention_vector(NumberofTrials, 1, attention_trial,2);
                            color_attention_trial_vec = color_attention_vector(NumberofTrials, 1, color_attention_trial);
                        else
                            attention_trial_vec =  attention_vector(NumberofTrials, 1, attention_trial,6);
                            color_attention_trial_vec = color_attention_vector(NumberofTrials, 1, color_attention_trial);
                        end
                    end

                    for trial= 1: numTrials
                        % start of the main task
                        trialsub = [];
                        if Block == 1 || Block == 3
                            trialsub = trial;
                        elseif Block == 5
                            trialsub = trial + numTrials;
                        elseif Block == 7
                            trialsub = trial + 2*numTrials;
                        end
                        Screen('DrawLines', window, allCoords,...
                            lineWidthPix, white, [xCenter yCenter], 2);
                        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                        WaitSecs(isiTimeFrames(trial)*ifi);
    
                        RT = [];
                        Choice = [];
                        % Drawing the yes-no question
                        DrawFormattedText(window, YesText,...
                            YesNoX(1), YesNoY, white);
                        DrawFormattedText(window, NoText,...
                            YesNoX(2), YesNoY, white);
                        % loading the image for the presentation
                        if Block == 1
                            img = imread(fullfile(ImgPracPath, dirImagesTask1Prac(trialsub).name));
                            colortmp = colorTranslator(dirImagesTask1Prac(trialsub).color);
                            img = coloring_fucntion(img, colortmp);
                        else
                            img = imread(fullfile(ImgPath, dirImagesTask1(trialsub).name));
                            colortmp = colorTranslator(dirImagesTask1(trialsub).color);
                            img = coloring_fucntion(img, colortmp);
                        end
                        % drawing the Image
                        Texture = Screen('MakeTexture', window, img);
                        % drawing the box around the image
                        Screen('FrameRect', window, colortmp, rectBox, pen_width);
                        %drawing the image
                        Screen('DrawTexture', window, Texture, [], rect);
                        % Flip to the screen
                        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
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

                        % For the missing trials
                        if respToBeMade
                            % Punishment Image
                            img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
                            Texture = Screen('MakeTexture', window, img);
                            Screen('DrawTexture', window, Texture, [], rectStop);
                            DrawFormattedText(window, StopText,...
                                'center', StopY, white);
                            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                            WaitSecs(waitPunishment);
                            respToBeMade = false;
                        end

                        % Managing logfiles
                        if Block ~= 1
                            TaskOneData(trialsub).ID = ['Sub_', num2str(participantNum)];
                            TaskOneData(trialsub).Session = ['Session_', num2str(sessionNum)];
                            TaskOneData(trialsub).TrialID1 = ['Trial_',num2str(trialsub)];
                            TaskOneData(trialsub).ImageNr = dirImagesTask1(trialsub).name;
                            TaskOneData(trialsub).Color = dirImagesTask1(trialsub).color;
                            TaskOneData(trialsub).YesNoPosition = '1';
                            TaskOneData(trialsub).RT = RT;
                            TaskOneData(trialsub).Choice = Choice;
                        end
                        %----------------------------------------------------------------------
                        %                           Attention test
                        %----------------------------------------------------------------------
                        if Block ~= 1 && any(trial == color_attention_trial_vec)
                            Screen('DrawLines', window, allCoords,...
                                lineWidthPix, white, [xCenter yCenter], 2);
                            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                            WaitSecs(isiTimeFrames(trial)*ifi);

                            [color_test_correct, color_test_number] = color_test(dirImagesTask1(trialsub).color, ...
                                color_test_correct, color_test_number);
                        end
                        if Block ~= 1 && any(trial == attention_trial_vec)
                            Screen('DrawLines', window, allCoords,...
                                lineWidthPix, white, [xCenter yCenter], 2);
                            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                            WaitSecs(isiTimeFrames(trial)*ifi);

                            [AttentionTestFailed,attention_counter] = attention_frame_test(attention_counter);
                            if AttentionTestFailed
                                return
                            end
                        end
                    end
                %----------------------------------------------------------------------
                %                           The Preference Task
                %----------------------------------------------------------------------
                elseif Block == 2 || Block == 4 || Block == 6 || Block == 8
                    Screen('TextSize', window, smallTextSize);
                    if Block == 2
                        numTrials = NumberofTrialsPractice(2);
                    else
                        numTrials = NumberofTrials(2);
                    end
                    Screen('TextSize', window, textSize);
                    isiTimeSecs =  .45 + rand(numTrials,1)/10; isiTimeFrames = round(isiTimeSecs / ifi);

                    % Text with attention time
                    if Block == 2
                        AttentionTestFailed = general_attention(TaskTwoText, waitVarLong/2);
                    elseif Block == 4
                        AttentionTestFailed = general_attention(RestTextTwoOne, waitVarLong/2);
                    elseif Block == 6 || Block == 8
                        AttentionTestFailed = general_attention(RestTextTwo, waitVarLong/2);
                    end
                    if AttentionTestFailed
                        return
                    end


                    if Block ~= 2
                        if debug
                            attention_trial_vec =  attention_vector(NumberofTrials, 2, attention_trial,2);
                            color_attention_trial_vec = color_attention_vector(NumberofTrials, 2, color_attention_trial);
                        else
                            attention_trial_vec =  attention_vector(NumberofTrials, 2, attention_trial,6);
                            color_attention_trial_vec = color_attention_vector(NumberofTrials, 2, color_attention_trial);
                        end
                    end

                    for trial= 1: numTrials
                        % start of the main task
                        trialsub = [];
                        if Block == 2 || Block == 4
                            trialsub = trial;
                        elseif Block == 6
                            trialsub = trial+numTrials;
                        elseif Block == 8
                            trialsub = trial+2*numTrials;
                        end

                        Screen('DrawLines', window, allCoords,...
                            lineWidthPix, white, [xCenter yCenter], 2);
                        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                        WaitSecs(isiTimeFrames(trial)*ifi);
    
                        RT = [];
                        Pref = [];
    
                        % Reading the correct Image
                        if Block ==2
                            img = imread(fullfile(ImgPracPath, dirImagesTask2Prac(trialsub).name));
                            colortmp = colorTranslator(dirImagesTask2Prac(trialsub).color);
                            img = coloring_fucntion(img, colortmp);
                        else
                            img = imread(fullfile(ImgPath, dirImagesTask2(trialsub).name));
                            colortmp = colorTranslator(dirImagesTask2(trialsub).color);
                            img = coloring_fucntion(img, colortmp);
                        end
                        Texture = Screen('MakeTexture', window, img);
    
                        % Draw the scale line
                        Screen('DrawLines', window, scaleLineCoords, scaleLineWidth, WhiteTrans);
                        % Text for the ends of the slider
                        DrawFormattedText(window, sliderLabels{1}, leftTextPosX, leftTextPosY, WhiteTrans);
                        DrawFormattedText(window, sliderLabels{2}, rightTextPosX, rightTextPosY, WhiteTrans);
                        % Draw the Question for the slider
                        % DrawFormattedText(window, LikertQues, 'center', yCenter + screenYpixels*.25, white);
                        % Draw the likert scale lines
                        Screen('FillRect', window, WhiteTrans, xyScaleLines);
                        % We now set the toggles initial position
                        sx = xPosScaleLines(round(length(xPosScaleLines)/2));
                        centeredRect = CenterRectOnPointd(baseRect, sx, yPosScaleLines(1));
                        % Draw the slider
                        Screen('FillRect', window, white , centeredRect);
                        % drawing the box around the image
                        Screen('FrameRect', window, colortmp, rectBox, pen_width);
                        % Draw the actual image
                        Screen('DrawTexture', window, Texture, [], rect);
                        % Flip to show
                        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
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
                            % Draw the scale line
                            Screen('DrawLines', window, scaleLineCoords, scaleLineWidth, WhiteTrans);
                            % Text for the ends of the slider
                            DrawFormattedText(window, sliderLabels{1}, leftTextPosX, leftTextPosY, WhiteTrans);
                            DrawFormattedText(window, sliderLabels{2}, rightTextPosX, rightTextPosY, WhiteTrans);
                            % Draw the Question for the slider
                            % DrawFormattedText(window, LikertQues, 'center', yCenter + screenYpixels*.25, white);
                            % Draw the likert scale lines
                            Screen('FillRect', window, WhiteTrans, xyScaleLines);
                            % Center the slidre toggle on its new screen position
                            centeredRect = CenterRectOnPointd(baseRect, sx, yPosScaleLines(1));
                            Screen('FillRect', window, white , centeredRect);
                            % drawing the box around the image
                            Screen('FrameRect', window, colortmp, rectBox, pen_width);
                            % Draw the actual image
                            Screen('DrawTexture', window, Texture, [], rect);
                            % Report the current slider position
                            % DrawFormattedText(window, ['Rating: ' num2str(round(Preftmp * 100)) '%'],...
                            %     'center', yCenter + screenYpixels * 0.35, white);
                            % Flip to show
                            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                        end

                        % For the missing trials
                        if respToBeMade
                            % Punishment Image
                            img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
                            Texture = Screen('MakeTexture', window, img);
                            Screen('DrawTexture', window, Texture, [], rectStop);
                            DrawFormattedText(window, StopText,...
                                'center', StopY, white);
                            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                            WaitSecs(waitPunishment);
                            respToBeMade = false;
                        end
    
                        % Maanaging logfiles
                        if Block ~= 2
                            TaskTwoData(trialsub).ID = ['Sub_', num2str(participantNum)];
                            TaskTwoData(trialsub).Session = ['Session_', num2str(sessionNum)];
                            TaskTwoData(trialsub).TrialID2 = ['Trial_', num2str(trialsub)];
                            TaskTwoData(trialsub).ImageNr = dirImagesTask2(trialsub).name;
                            TaskTwoData(trialsub).Color = dirImagesTask2(trialsub).color;
                            TaskTwoData(trialsub).YesNoPosition = '1';
                            TaskTwoData(trialsub).RT = RT;
                            TaskTwoData(trialsub).Pref = Pref;
                        end

                        % ----------------------------------------------------------------------
                        %                           Attention test
                        % ----------------------------------------------------------------------
                        if Block ~= 2 && any(trial == color_attention_trial_vec)
                            Screen('DrawLines', window, allCoords,...
                                lineWidthPix, white, [xCenter yCenter], 2);
                            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                            WaitSecs(isiTimeFrames(trial)*ifi);

                            [color_test_correct, color_test_number] = color_test(dirImagesTask2(trialsub).color, ...
                                color_test_correct, color_test_number);
                        end
                        if Block ~= 2 && any(trial == attention_trial_vec)
                            Screen('DrawLines', window, allCoords,...
                                lineWidthPix, white, [xCenter yCenter], 2);
                            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                            WaitSecs(isiTimeFrames(trial)*ifi);

                            [AttentionTestFailed,attention_counter] = attention_frame_test(attention_counter);
                            if AttentionTestFailed
                                return
                            end
                        end
                    end
                end
    
            end
    
            %----------------------------------------------------------------------
            %                      The comparative Choice Task 
            %----------------------------------------------------------------------
            if sessionNum == 3
                for Block = 1:4
                    if Block == 1
                        numTrials = NumberofTrialsPractice(3);
                    else
                        numTrials = NumberofTrials(3)*3;
                    end
                    Screen('TextSize', window, textSize);

                    % Text with attention time
                    if Block == 1
                        AttentionTestFailed = general_attention(TaskThreeText, waitVarLong/3);
                    elseif Block == 2 || Block == 3 || Block == 4
                        AttentionTestFailed = general_attention(RestText, waitVarLong/3);
                    end
                    if AttentionTestFailed
                        return
                    end

                    if Block ~= 1
                        if debug
                            attention_trial_vec =  attention_vector(NumberofTrials, 3, attention_trial,2);
                            color_attention_trial_vec = color_attention_vector(NumberofTrials, 3, color_attention_trial);
                        else
                            attention_trial_vec =  attention_vector(NumberofTrials, 3, attention_trial,5);
                            color_attention_trial_vec = color_attention_vector(NumberofTrials, 3, color_attention_trial);
                        end
                    end

                    isiTimeSecs =  .45 + rand(numTrials,1)/10; isiTimeFrames = round(isiTimeSecs / ifi);
                    for trial= 1: numTrials

                        % start of the main task
                        trialsub = [];
                        if Block == 1
                            trialsub = trial;
                        else           
                            trialsub = trial + NumberofTrials(3)*3*(Block - 2);
                        end
                        
                        Screen('DrawLines', window, allCoords,...
                            lineWidthPix, white, [xCenter yCenter], 2);
                        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                        WaitSecs(isiTimeFrames(trial)*ifi);
    
                        RT = [];
                        Choice = [];
                        if Block == 1
                            colortmpR = colorTranslator(dirImagesTask3Prac(trialsub).ColorRight);
                            colortmpL = colorTranslator(dirImagesTask3Prac(trialsub).ColorLeft);
                            % Loading the right and left images
                            imgright = imread(fullfile(ImgPracPath, dirImagesTask3Prac(trialsub).NameRight));
                            imgleft = imread(fullfile(ImgPracPath, dirImagesTask3Prac(trialsub).NameLeft));
                        else
                            colortmpR = colorTranslator(dirImagesTask3(trialsub).ColorRight);
                            colortmpL = colorTranslator(dirImagesTask3(trialsub).ColorLeft);
                            % Loading the right and left images
                            imgright = imread(fullfile(ImgPath, dirImagesTask3(trialsub).NameRight));
                            imgleft = imread(fullfile(ImgPath, dirImagesTask3(trialsub).NameLeft));
                        end
                        % Making the figures colored
                        imgright = coloring_fucntion(imgright, colortmpR);
                        imgleft = coloring_fucntion(imgleft, colortmpL);

                        % drawing two boxes around the images
                        Screen('FrameRect', window, colortmpR, rectBoxRight, pen_width);
                        Screen('FrameRect', window, colortmpL, rectBoxLeft, pen_width);
                        %drawing the images
                        Textureright = Screen('MakeTexture', window, imgright);
                        Textureleft = Screen('MakeTexture', window, imgleft);
                        Screen('DrawTexture', window, Textureright, [], rectRight);
                        Screen('DrawTexture', window, Textureleft, [], rectLeft);
    
                        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
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
                                Choice = 'right';
                                RT = GetSecs - timeStart;
                                respToBeMade = false;
                            elseif keyCode(cKey)
                                Choice = 'left';
                                RT = GetSecs - timeStart;
                                respToBeMade = false;
                            end
                        end

                        % For the missing trials
                        if respToBeMade
                            % Punishment Image
                            img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
                            Texture = Screen('MakeTexture', window, img);
                            Screen('DrawTexture', window, Texture, [], rectStop);
                            DrawFormattedText(window, StopText,...
                                'center', StopY, white);
                            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                            WaitSecs(waitPunishment);
                            respToBeMade = false;
                        end

                        % Managing logfiles
                        if Block ~= 1
                            TaskThreeData(trialsub).ID = ['Sub_', num2str(participantNum)];
                            TaskThreeData(trialsub).Session = ['Session_', num2str(sessionNum)];
                            TaskThreeData(trialsub).TrialID3 = ['Trial_',num2str(trialsub)];
                            TaskThreeData(trialsub).ImageRightNr = dirImagesTask3(trialsub).NameRight;
                            TaskThreeData(trialsub).ColorImageRight = dirImagesTask3(trialsub).ColorRight;
                            TaskThreeData(trialsub).ImageLeftNr = dirImagesTask3(trialsub).NameLeft;
                            TaskThreeData(trialsub).ColorImageLeft = dirImagesTask3(trialsub).ColorLeft;
                            TaskThreeData(trialsub).RT = RT;
                            TaskThreeData(trialsub).Choice = Choice;
                        end

                        %----------------------------------------------------------------------
                        %                           Attention test
                        %----------------------------------------------------------------------
                        % if Block ~= 1 && any(trial == color_attention_trial_vec)
                        %     Screen('DrawLines', window, allCoords,...
                        %         lineWidthPix, white, [xCenter yCenter], 2);
                        %     vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                        %     WaitSecs(isiTimeFrames(trial)*ifi);
                        %     if randperm(2,1) == 1
                        %     [color_test_correct, color_test_number] = color_test(dirImagesTask3(trialsub).ColorRight, ...
                        %         color_test_correct, color_test_number, 'right');
                        %     else
                        %         [color_test_correct, color_test_number] = color_test(dirImagesTask3(trialsub).ColorLeft, ...
                        %         color_test_correct, color_test_number, 'left');
                        %     end
                        % end
                        if Block ~= 1 && any(trial == attention_trial_vec)
                            Screen('DrawLines', window, allCoords,...
                                lineWidthPix, white, [xCenter yCenter], 2);
                            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                            WaitSecs(isiTimeFrames(trial)*ifi);
                            [AttentionTestFailed,attention_counter] = attention_frame_test(attention_counter);
                            if AttentionTestFailed
                                return
                            end
                        end

                    end
                end
            end
            %----------------------------------------------------------------------
            %                       Learning Phase
            %----------------------------------------------------------------------
        elseif sessionNum == 2

            % Text with attention time
            AttentionTestFailed = general_attention(LearningText, waitVarLong);
            if AttentionTestFailed
                return
            end

            Block_order = [];
            if rem(participantNumInt,2) == 0
                Block_order_var = '1_2';
                Block_order = [1 2 3 4 5 6];
            else
                Block_order_var = '2_1';
                Block_order = [2 1 4 3 6 5];
            end

            for Block = Block_order
                % reseting thevariables for changing the timing of the tasks
                if strcmp(Block_order_var,'1_2') 
                    if Block == 1 || Block == 3
                        % Variables for changing the timing of the tasks
                        trialAAT = 0;
                        trialEC = 0;
                        trialECP = 0;
                        trialECN = 0;
                        ExtraTimeAAT = 0;
                        ExtraTimeEC = 0;
                        CounterErrorAAT = 0;
                        CounterErrorEC = 0;
                    end
                else
                    if Block == 2 || Block == 4
                        % Variables for changing the timing of the tasks
                        trialAAT = 0;
                        trialEC = 0;
                        trialECP = 0;
                        trialECN = 0;
                        ExtraTimeAAT = 0;
                        ExtraTimeEC = 0;
                        CounterErrorAAT = 0;
                        CounterErrorEC = 0;
                    end
                end

                Screen('TextSize', window, textSize);
                if Block == 1 || Block == 2
                    numTrials = length(dirImagesLearningPrac)/2;
                else
                    numTrials = length(dirImagesLearning)/4;
                end
                % shuffeling the emotional images
                dirImagesNegative = dirImagesNegative(randperm(size(dirImagesNegative, 1)), :);
                dirImagesPositive = dirImagesPositive(randperm(size(dirImagesPositive, 1)), :);
                % isi jitters
                isiTimeSecs =  1 + rand(numTrials,1)/5; isiTimeFrames = round(isiTimeSecs / ifi);
                isiLearningTimeSecs =  rand(numTrials,1)/5;
                
                % Text with attention time
                if Block == 1
                    AttentionTestFailed = general_attention(LearningPractF, waitVarLong/2);
                elseif Block == 2
                    AttentionTestFailed = general_attention(LearningPractS, waitVarLong/2);
                elseif (strcmp(Block_order_var,'1_2') && Block == 3) || (strcmp(Block_order_var,'2_1') && Block == 4)
                    AttentionTestFailed = general_attention(EndOfPracticeLearning, waitVarLong/2);
                elseif Block == 3 || Block == 5
                    AttentionTestFailed = general_attention(LearbningRestTextOne, waitVarLong/2);
                elseif Block == 4 || Block == 6
                    AttentionTestFailed = general_attention(LearbningRestTextTwo, waitVarLong/2);
                end
                if AttentionTestFailed
                    return
                end


                if Block == 1
                    % First sound training
                    DrawFormattedText(window, LearningPractFOne,...
                        'center', 'center', white);
                    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                    wait = true;
                    while wait
                        PsychPortAudio('FillBuffer', pahandle, sound{1});
                        t1 = PsychPortAudio('Start', pahandle, 1, 0, 1);
                        WaitSecs(4*waitVarShort);
                        RestrictKeysForKbCheck([]);
                        [keyIsDown,secs, keyCode] = KbCheck;
                        if keyCode(mKey)
                            wait = false;
                        end
                    end
    
                    % Second sound training
                    DrawFormattedText(window, LearningPractFTwo,...
                        'center', 'center', white);
                    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                    wait = true;
                    while wait
                        PsychPortAudio('FillBuffer', pahandle, sound{2});
                        t1 = PsychPortAudio('Start', pahandle, 1, 0, 1);
                        WaitSecs(4*waitVarShort);
                        RestrictKeysForKbCheck([]);
                        [keyIsDown,secs, keyCode] = KbCheck;
                        if keyCode(cKey)
                            wait = false;
                        end
                    end
                end
    
    
                % for debugging only
                if debug
                    if Block == 1|| Block ==2
                        trial_replace = 1:floor(numTrials/2);
                    else
                        trial_replace = 1:floor(numTrials/6);
                    end
                else
                    trial_replace = 1:numTrials;
                end
                emo_direction_order = repelem([1 2], numTrials/2);
                emo_direction_order = emo_direction_order(randperm(length(emo_direction_order)));
                if Block ~= 1 && Block ~= 2
                    if debug
                        color_attention_trial_vec = color_attention_vector(floor(numTrials/6), 4, color_attention_trial_learning);
                    else
                        color_attention_trial_vec = color_attention_vector(numTrials, 4, color_attention_trial_learning);
                    end
                end

                % Presenting LearningVector
                for trial = trial_replace
                    if Block == 1 || Block == 2
                        trialsub = trial + (Block -1)*numTrials;
                    else
                        trialsub = trial + (Block -3)*numTrials;
                    end

                    % Stimuli presentation
                    RT = [];
                    Response = [];
                    Accuracy = [];
                    RTAfter = [];

                    % the trial information will be trasnfered to tmp
                    tmp = [];
                    if Block == 1|| Block ==2
                        tmp = dirImagesLearningPrac(trialsub);
                        % Loading the image
                        img = imread(fullfile(ImgPracPath, tmp.name));
                    else
                        tmp = dirImagesLearning(trialsub);
                        % Loading the image
                        img = imread(fullfile(ImgPath, tmp.name));
                    end
                    Screen('DrawLines', window, allCoords,...
                        lineWidthPix, white, [xCenter yCenter], 2);
                    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                    WaitSecs(isiTimeFrames(trial)*ifi);
                    
                    % drawing the box around the image
                    colortmp = colorTranslator(tmp.color);
                    Screen('FrameRect', window, colortmp, rectBox, pen_width);
                    % Drawing the colored image
                    img = coloring_fucntion(img, colortmp);
                    % drawing the image
                    Texture = Screen('MakeTexture', window, img);
                    Screen('DrawTexture', window, Texture, [], rect);
                    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
                    timeStart = GetSecs;
                    if strcmp(tmp.LearningMethod, 'AAT')
                        trialAAT = trialAAT +1;
                        if strcmp(tmp.LearningValence, 'p') || strcmp(tmp.LearningValence, 'n')
                            if strcmp(tmp.LearningValence, 'p')
                                wavedata = sound{1};
                                SoundWave = sound_name{1};
                            elseif strcmp(tmp.LearningValence, 'n')
                                wavedata = sound{2};
                                SoundWave = sound_name{2};
                            end
                            % Updating the logfile
                            tmp.SoundWave = SoundWave;
                            tmp.SoundOrder = strcat(sound_name{1},'_',sound_name{2});

                            % Fill the audio playback buffer with the audio data 'wavedata':
                            PsychPortAudio('FillBuffer', pahandle, wavedata);
                            % Start audio playback for 'repetitions' repetitions of the sound data,
                            % start it immediately (0) and wait for the playback to start, return onset
                            % timestamp.
                            WaitSecs(stimulusTimeAAT + isiLearningTimeSecs(trial));

                            t1 = PsychPortAudio('Start', pahandle, 1, 0, 1);
                        end
                        
                        RestrictKeysForKbCheck([]);
                        timeStartBeep = GetSecs;
                        respToBeMade = true;
                        while respToBeMade 
                            % Check the keyboard. The person should press either
                            % 'm' or 'c' to accept the left or the right image
                            [keyIsDown,secs, keyCode] = KbCheck;
                            if keyCode(escapeKey) && debug_key
                                ShowCursor;
                                close all
                                warning('Terminated by user input:!!nothing is saved!!')
                                sca;
                                return
                            elseif keyCode(mKey) || keyCode(cKey)
                                if keyCode(mKey)
                                    Response = 'App';
                                    if strcmp(tmp.LearningValence,'p')
                                        Accuracy = true;
                                        respToBeMade = false;
                                    else
                                        Accuracy = false;
                                    end
                                elseif keyCode(cKey)
                                    Response = 'Avo';
                                    if strcmp(tmp.LearningValence,'n')
                                        Accuracy = true;
                                        respToBeMade = false;
                                    else
                                        Accuracy = false;
                                    end
                                end
                                RT = GetSecs - timeStart;
                                RTAfter = GetSecs - timeStartBeep;

    
                                % Zooming
                                counterlocal = 0;
                                recttmp = rect;
                                rectBoxtmp = rectBox;
                                if Accuracy
                                    while keyIsDown && counterlocal < ZoomingDistance
                                        if keyCode(mKey)
                                            rectBoxtmp = rectBoxtmp + ZoomingMatrix;
                                            recttmp = recttmp + ZoomingMatrix;
                                        elseif keyCode(cKey)
                                            rectBoxtmp = rectBoxtmp - ZoomingMatrix;
                                            recttmp = recttmp - ZoomingMatrix;
                                        end
                                        counterlocal = counterlocal + 1;
                                        % drawing the box around the imag
                                        Screen('FrameRect', window, colortmp, rectBoxtmp, pen_width);
                                        %drawing the image
                                        Screen('DrawTexture', window, Texture, [], recttmp);
                                        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                                        [keyIsDown,secs, keyCode] = KbCheck;
                                    end

                                    if counterlocal < ZoomingDistance - ZoomingDistanceMin
                                        respToBeMade = false;
                                        Accuracy = false;
                                        % Punishment Image
                                        img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
                                        Texture = Screen('MakeTexture', window, img);
                                        Screen('DrawTexture', window, Texture, [], rectStop);
                                        DrawFormattedText(window, TooShortText,...
                                            'center', StopY, white);
                                        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                                        WaitSecs(waitPunishment*2);
                                    end
                                end

                            elseif (GetSecs - timeStartBeep) > (waitLearningAAT + ExtraTimeAAT*ifi)
                                if isempty(Accuracy)
                                    if strcmp(tmp.LearningValence, 'm')
                                        Response = 'CR';
                                        RT = 'NA';
                                        RTAfter = 'NA';
                                        Accuracy = true;
                                        respToBeMade = false;
                                    else
                                        Accuracy = false;
                                        respToBeMade = false;

                                        % Punishment Image
                                        img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
                                        Texture = Screen('MakeTexture', window, img);
                                        Screen('DrawTexture', window, Texture, [], rectStop);
                                        DrawFormattedText(window, StopText,...
                                            'center', StopY, white);
                                        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                                        WaitSecs(waitPunishment);
                                    end
                                elseif ~Accuracy
                                    respToBeMade = false;
                                    % Punishment Image
                                    img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
                                    Texture = Screen('MakeTexture', window, img);
                                    Screen('DrawTexture', window, Texture, [], rectStop);
                                    DrawFormattedText(window, WrongResponseText,...
                                        'center', StopY, white);
                                    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                                    WaitSecs(waitPunishment);
                                end
                            end
                        end
                        
                        if ~Accuracy
                            CounterErrorAAT = CounterErrorAAT + 1;
                        end
    
    
                    elseif strcmp(tmp.LearningMethod, 'EC')
                        trialEC = trialEC +1;
                        WaitSecs(stimulusTimeEC + isiLearningTimeSecs(trial));
    
                        % Unconditioned Image Preparation
                        if strcmp(tmp.LearningValence, 'p')
                            trialECP = trialECP +1;
                            imgEmo = imread(fullfile(dirImagesPositive(trialECP).folder, dirImagesPositive(trialECP).name));
                            tmp.ECImageValence = 'Positive';
                            tmp.ECImageNr = dirImagesPositive(trialECP).name;
                        elseif strcmp(tmp.LearningValence, 'n')
                            trialECN = trialECN +1;
                            imgEmo = imread(fullfile(dirImagesNegative(trialECN).folder, dirImagesNegative(trialECN).name));
                            tmp.ECImageValence = 'Negative';
                            tmp.ECImageNr = dirImagesNegative(trialECN).name;
                        end

                        if strcmp(tmp.LearningValence, 'p') || strcmp(tmp.LearningValence, 'n')
                                % drawing the emotional image
                                TextureEmo = Screen('MakeTexture', window, imgEmo);
                                if emo_direction_order(trial) == 1
                                    % drawing the emotional image
                                    Screen('DrawTexture', window, TextureEmo, [], rect2Right);

                                    % drawing the box around the image
                                    Screen('FrameRect', window, colortmp, rectBoxLeft, pen_width);

                                    % drawing the image
                                    Screen('DrawTexture', window, Texture, [], rectLeft);
                                else
                                    % drawing the emotional image
                                    Screen('DrawTexture', window, TextureEmo, [], rect2Left);

                                    % drawing the box around the image
                                    Screen('FrameRect', window, colortmp, rectBoxRight, pen_width);

                                    % drawing the image
                                    Screen('DrawTexture', window, Texture, [], rectRight);
                                end
                        else
                            if emo_direction_order(trial) == 1
                                % drawing the box around the image
                                Screen('FrameRect', window, colortmp, rectBoxLeft, pen_width);

                                % drawing the image
                                Screen('DrawTexture', window, Texture, [], rectLeft);
                            else
                                % drawing the box around the image
                                Screen('FrameRect', window, colortmp, rectBoxRight, pen_width);

                                % drawing the image
                                Screen('DrawTexture', window, Texture, [], rectRight);
                            end

                        end

                        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

                        RestrictKeysForKbCheck([]);
                        timeStartEmo = GetSecs;
                        respToBeMade = true;
                        while (GetSecs - timeStartEmo) < (waitLearningEC + ExtraTimeEC*ifi)
                            if respToBeMade
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
                                    Response = 'Positive';
                                    if strcmp(tmp.LearningValence,'p')
                                        Accuracy = true;
                                    else
                                        Accuracy = false;
                                        CounterErrorEC = CounterErrorEC + 1;
                                    end
                                    RT = GetSecs - timeStart;
                                    RTAfter = GetSecs - timeStartEmo;
                                    respToBeMade = false;
                                elseif keyCode(cKey)
                                    Response = 'Negative';
                                    if strcmp(tmp.LearningValence,'n')
                                        Accuracy = true;
                                    else
                                        Accuracy = false;
                                        CounterErrorEC = CounterErrorEC + 1;
                                    end
                                    RT = GetSecs - timeStart;
                                    RTAfter = GetSecs - timeStartEmo;
                                    respToBeMade = false;
                                end
                            end
                        end

                        if respToBeMade
                            if strcmp(tmp.LearningValence,'m')
                                Accuracy = true;
                                RT = 'NA';
                                RTAfter = 'NA';
                                Response = 'CR';
                            else
                                Accuracy = false;
                                CounterErrorEC = CounterErrorEC + 1;

                                % Punishment Image
                                img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
                                Texture = Screen('MakeTexture', window, img);
                                Screen('DrawTexture', window, Texture, [], rectStop);
                                DrawFormattedText(window, StopText,...
                                    'center', StopY, white);
                                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                                WaitSecs(waitPunishment);
                                respToBeMade = false;
                            end
                        elseif ~Accuracy
                            % Punishment Image
                            img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
                            Texture = Screen('MakeTexture', window, img);
                            Screen('DrawTexture', window, Texture, [], rectStop);
                            DrawFormattedText(window, WrongResponseText,...
                                'center', StopY, white);
                            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                            WaitSecs(waitPunishment);
                        end
                        
                    end
    
                    % Managing logfiles
                    if ~(Block == 1 || Block == 2)
                        LearningData(trialsub).ID = ['Sub_', num2str(participantNum)];
                        LearningData(trialsub).Session = ['Session_', num2str(sessionNum)];
                        if strcmp(Block_order_var,'1_2')
                            LearningData(trialsub).TrialID = ['Trial_',num2str(trialsub)];
                        elseif strcmp(Block_order_var,'2_1')
                            if Block == 4
                                LearningData(trialsub).TrialID = ['Trial_',num2str(trial)];
                            elseif Block == 3
                                LearningData(trialsub).TrialID = ['Trial_',num2str(trial + numTrials)];
                            elseif Block == 6
                                LearningData(trialsub).TrialID = ['Trial_',num2str(trial + 2*numTrials)];
                            elseif Block == 5
                                LearningData(trialsub).TrialID = ['Trial_',num2str(trial + 3*numTrials)];
                            end
                        end
                        LearningData(trialsub).ImageNr = tmp.name;
                        LearningData(trialsub).Color = tmp.color;
                        LearningData(trialsub).LearningMethod = tmp.LearningMethod;
                        LearningData(trialsub).LearningValence = tmp.LearningValence;
                        LearningData(trialsub).RT = RT;
                        LearningData(trialsub).RTAfter = RTAfter;
                        LearningData(trialsub).Response = Response;
                        LearningData(trialsub).Accuracy = Accuracy;
                        LearningData(trialsub).Block_order_var = Block_order_var;
                        if strcmp(tmp.LearningMethod, 'AAT') && ~strcmp(tmp.LearningValence,'m')
                            LearningData(trialsub).SoundWave = tmp.SoundWave;
                            LearningData(trialsub).SoundOrder = tmp.SoundOrder;
                        elseif strcmp(tmp.LearningMethod, 'EC') && ~strcmp(tmp.LearningValence,'m')
                            LearningData(trialsub).ECImageValence = tmp.ECImageValence;
                            LearningData(trialsub).ECImageNr = tmp.ECImageNr;
                        end
                    end
    
                    % Adjusting Timing of the Learning Method
                    if strcmp(tmp.LearningMethod, 'AAT')
                        if ~(Block == 1 || Block == 2)
                            % Recording the timing information
                            LearningData(trialsub).ExtraTime = ExtraTimeAAT;
                        end
                        if trialAAT > 6
                            if CounterErrorAAT/trialAAT > .8 && abs(ExtraTimeAAT) < 10
                                ExtraTimeAAT = ExtraTimeAAT + 1;
                            elseif CounterErrorAAT/trialAAT < .2 && abs(ExtraTimeAAT) < 4
                                ExtraTimeAAT = ExtraTimeAAT - 1;
                            end
                        end
                    elseif strcmp(tmp.LearningMethod, 'EC')
                        if ~(Block == 1 || Block == 2)
                            LearningData(trialsub).ExtraTime = ExtraTimeEC;
                        end
                         if trialEC > 6
                            if CounterErrorEC/trialEC > .8 && abs(ExtraTimeEC) < 10
                                ExtraTimeEC = ExtraTimeEC + 1;
                            elseif CounterErrorEC/trialEC < .2 && abs(ExtraTimeEC) < 4
                                ExtraTimeEC = ExtraTimeEC - 1;
                            end
                         end
                    end


                    % color attention test
                    if Block ~= 1 && Block ~= 2 && any(trial == color_attention_trial_vec)
                        Screen('DrawLines', window, allCoords,...
                            lineWidthPix, white, [xCenter yCenter], 2);
                        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                        WaitSecs(isiTimeFrames(trial)*ifi);

                        [color_test_correct, color_test_number] = color_test(tmp.color, ...
                            color_test_correct, color_test_number);
                    end

                end
            end
        end

        %----------------------------------------------------------------------
        %                       Saving Logfiles
        %----------------------------------------------------------------------
        logfile = struct();
        if sessionNum == 1
            logfile = struct('ParticipantNum',participantNum,'SessionNum',sessionNum,...
                'TaskOneData', TaskOneData, 'TaskTwoData',TaskTwoData);
        elseif sessionNum == 2
            logfile = struct('ParticipantNum',participantNum,'SessionNum',sessionNum,...
                'LearningData', LearningData);
        elseif sessionNum == 3
            logfile = struct('ParticipantNum',participantNum,'SessionNum',sessionNum,...
                'TaskOneData', TaskOneData, 'TaskTwoData',TaskTwoData, ...
                'TaskThreeData', TaskThreeData);
        end
    
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

        %----------------------------------------------------------------------
        %                       Attention test and the last part
        %----------------------------------------------------------------------
        % End of experiment screen. Time limits n mins
        % after which the experiments expires
        Screen('DrawLines', window, allCoords,...
            lineWidthPix, white, [xCenter yCenter], 2);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        WaitSecs(isiTimeFrames(end)*ifi);

        timeStart = GetSecs;
        respToBeMade = true ;
        while (GetSecs - timeStart) < attentionTimeLong && respToBeMade
            if (GetSecs - timeStart) > (attentionTimeLong - endTime)
                img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
                Texture = Screen('MakeTexture', window, img);
                Screen('DrawTexture', window, Texture, [], rectStop);
                DrawFormattedText(window, InBetweenTextAttention,...
                    'center', StopY, white)
                if sessionNum == 1
                    DrawFormattedText(window, InBetweenText1Short,...
                        'center', StopY*1.15, white);
                elseif sessionNum  == 2
                    DrawFormattedText(window, InBetweenText2Short,...
                        'center', StopY*1.15, white)
                elseif sessionNum  == 3
                    DrawFormattedText(window, InBetweenText3Short,...
                        'center', StopY*1.15, white)
                end
            elseif sessionNum == 1
                DrawFormattedText(window, InBetweenText1,...
                    'center', 'center', white);
            elseif sessionNum  == 2
                DrawFormattedText(window, InBetweenText2,...
                    'center', 'center', white)
            elseif sessionNum  == 3
                DrawFormattedText(window, InBetweenText3,...
                    'center', 'center', white)
            end
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            RestrictKeysForKbCheck([]);
            [keyIsDown,secs, keyCode] = KbCheck;
            if (sessionNum == 1 && keyCode(qKey)) || ...
                    (sessionNum == 2 && keyCode(rKey)) || ...
                    (sessionNum == 3 && keyCode(uKey))
                respToBeMade = false;
            elseif keyIsDown && respToBeMade && (GetSecs - timeStart) < (attentionTimeLong - endTime)
                img = imread(fullfile(ImgEmoPath,'StopSign', 'Stop.png'));
                Texture = Screen('MakeTexture', window, img);
                Screen('DrawTexture', window, Texture, [], rectStop);
                DrawFormattedText(window, WrongResponseText,...
                    'center', StopY, white)
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                WaitSecs(waitPunishment);
            end
        end

        if respToBeMade && (GetSecs - timeStart) > attentionTimeLong
            % Setting the parameters for the last part
            AttentionTestFailed = true;
            TimeEnd = GetSecs-TimeBegin;
            if sessionNum > 1
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
                'center', StopY , white)
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            WaitSecs(waitPunishment);
            ShowCursor;
            close all
            warning('Terminated by user input:!!nothing is saved!!')
            sca;
            return
        end

    catch error
        pnet('closeall');
        sca;
        PsychPortAudio('Stop', pahandle);
        PsychPortAudio('Close', pahandle);
        warning(strcat('something is not working properly: Main Experimental Loop,', ...
            'in the session ',int2str(sessionNum), '!'));
        rethrow(error);
    end

end

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
TimeEnd = GetSecs-TimeBegin;
attentional_text(ParticipantDir, participantNum, AttentionTestFailed, TimeEnd, ...
            color_test_correct, color_test_number,...
            CounterErrorAAT, CounterErrorEC, trialEC, trialAAT)

fprintf('*******************************\n')
fprintf('Experiment was finished successfully and everything is saved\n')
fprintf('*******************************\n')

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

%----------------------------------------------------------------------
%                       Saving the attentional text
%----------------------------------------------------------------------
function attentional_text(ParticipantDir, participantNum, AttentionTestFailed, TimeEnd, ...
    color_test_correct, color_test_number,...
    CounterErrorAAT, CounterErrorEC, trialEC, trialAAT)
switch nargin
    case 6
        CounterErrorAAT = [];
        CounterErrorEC = [];
        trialEC = [];
        trialAAT = [];
    case 10
    otherwise
        error('inputs are not accepted.')
end
if ~isfile(fullfile(ParticipantDir,['AttentionTest_',participantNum,'.txt']))
    % Open a text file for writing
    fileID = fopen(fullfile(ParticipantDir,['AttentionTest_',participantNum,'.txt']), 'w');
else
    % Open a text file for writing
    fileID = fopen(fullfile(ParticipantDir,['AttentionTest_',participantNum,...
        datestr(now,'mm-dd-yyyy_HH-MM'),'.txt']), 'w');
end

if AttentionTestFailed
    boolText = 'true';
else
    boolText = 'false';
end

% Print header text and values from variable A
fprintf('*******************************\n')
fprintf('The timing and attention tests results\n')
fprintf('*******************************\n')
fprintf(fileID, 'Did the participant fail the attention test:\n %s \n',boolText);
fprintf(fileID, 'How long did the Matlab Section last:\n%f\n',TimeEnd);
if ~isempty(CounterErrorAAT) && ~isempty(CounterErrorEC) && ~isempty(trialAAT) && ~isempty(trialEC)
    fprintf(fileID, 'How accurate was the AAT training:\n %f \n',1- CounterErrorAAT/trialAAT);
    fprintf(fileID, 'How accurate was the EC training:\n %f \n',1 - CounterErrorEC/trialEC);
else
    fprintf(fileID, 'How accurate was the AAT training:\n NA \n');
    fprintf(fileID, 'How accurate was the EC training:\n NA \n');
end

if color_test_number ~= 0
    fprintf(fileID, 'How accurate was the color test:\n %f \n',color_test_correct/color_test_number);
    fprintf(fileID, 'How many color tests:\n %f \n', color_test_number);
else
    fprintf(fileID, 'How accurate was the color test:\n NA \n');
    fprintf(fileID, 'How many color tests:\n NA \n');
end


% Close the file
fclose(fileID);
end


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

%----------------------------------------------------------------------
%                       Coloring of Stimuli
%----------------------------------------------------------------------

function    rgbImage = coloring_fucntion(image, color)

grey = evalin('caller', 'grey');

img_tmp = image;
img_tmp(img_tmp<240)=0; img_tmp(img_tmp~=0)=255;

rgbImage = cat(3, img_tmp, img_tmp, img_tmp);


[rows, columns, ~] = size(rgbImage);

for ii=1:rows
    for jj=1:columns
        if rgbImage(ii,jj,1) == 0
            rgbImage(ii,jj,:) = color*255;

        elseif rgbImage(ii,jj,1) == 255
            rgbImage(ii,jj,:) = 255*[grey,grey,grey];

        end
    end
end

end
