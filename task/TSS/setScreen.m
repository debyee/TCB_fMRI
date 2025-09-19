function p = setScreen(p)
%SETSCREEN Summary of this function goes here
%   Detailed explanation goes here

%To quiet Psychtoolbox (and other things)
Screen('Preference','SkipSyncTests',1);
Screen('Preference','VisualDebuglevel',0);
Screen('Preference','SuppressAllWarnings',1);

% PsychDebugWindowConfiguration([],1);

% Define Screen parameters
p.screenNum = max(Screen('Screens'));
[wPtr,screenSize] = Screen('OpenWindow',p.screenNum);
p.wPtr = wPtr;

Screen('BlendFunction', p.wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

p.screenSize = screenSize;
p.xRes = screenSize(3);                                         % Gets x (horizonal) resolution in pixels
p.yRes = screenSize(4);                                         % Gets y (vertical) resolution in pixels
p.xCenter = p.xRes/2;                                           % Gets x (horizonal) center in pixels
p.yCenter = p.yRes/2;                                           % Gets y (vertical) center in pixels

HideCursor;                                                     % Hides mouse cursor
Screen('FillRect',wPtr,[0,0,0]);                                % Creates solid black background
Screen(wPtr,'Flip');                                            % Flips everything onto

end

