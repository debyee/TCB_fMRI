function testScanConfig

% TTL Device
TTLdevice = -1;
TTLkey = '1';

keyArray = 'bygr';
isJoystick = 0;

% Get device numbers if scanning
curDevices = PsychHID('Devices');
curDevNumResp = nan;

for devInd = 1:length(curDevices)
    if strcmpi(curDevices(devInd).usageName,'Keyboard')
        if strcmpi(curDevices(devInd).manufacturer,'Current Designs, Inc.')
            curDevNumResp = devInd;
        elseif strcmpi(curDevices(devInd).manufacturer,'Apple Inc.')
            curDevNumExptr = devInd;
        end
        
    end
end

if isnan(curDevNumResp)
    disp('ERROR: Response Box not found! Make sure the response box is pluged in and matlab has been restarted.');
    curResp = input('Continue without specifying the device? (1 = Yes, 0 = No): ','s');
    
    if strcmpi(curResp,'1')
        respDeviceNum = -1;
    else
        error('Please change the device parameters that you are looking for in setScannerParams.m.');
    end
else
    disp(['Device ',num2str(curDevNumResp),' found! Usage name: ',curDevices(curDevNumResp).usageName,'; Manufacturer: ',curDevices(curDevNumResp).manufacturer]);
    curResp = input('Continue with this device? (1 = Yes, 0 = No): ','s');
    
    if strcmpi(curResp,'1')
        respDeviceNum = curDevNumResp;
    else
        error('Please change the device parameters that you are looking for in setScannerParams.m.');
    end
end

if isnan(curDevNumExptr)
    disp('ERROR: Experimenter Keyboard not found! Make sure it is pluged in and matlab has been restarted.');
    curResp = input('Continue without specifying the device? (1 = Yes, 0 = No): ','s');
    
    if strcmpi(curResp,'1')
        exptrDeviceNum = -1;
    else
        error('Please change the device parameters that you are looking for in setScannerParams.m.');
    end
else
    exptrDeviceNum = curDevNumExptr;
end



%% Check triggers
disp('Waiting for trigger...');

FlushEvents;
keyIsDown = 0; TTLpress = '';  % temp assignment

while 1
    
    [keyIsDown,~,keyCode] = KbCheck(TTLdevice);
    
    if keyIsDown
        TTLpress = KbName(keyCode);
        TTLpress = TTLpress(1);
    end
    
    keyIsDown = 0;
    
    if (strcmpi(TTLpress,TTLkey))
        disp('Trigger detected!');
        break;
    end
end

WaitSecs(2);



%% Check Button Box Responses
disp('Waiting for button presses...');

keyCounter = 0;

while 1
    
    [whichKey, rt] = MRcollectResponse(inf,respDeviceNum,keyArray,isJoystick);
    
    FlushEvents;
    keyIsDown = 0; keyPress = NaN; % temp assignment
    
    while ~keyIsDown
        
        [keyIsDown, ~, keyCode] = KbCheck(respDeviceNum);
        
        if keyIsDown
            
            while KbCheck(respDeviceNum) end   % this checks that key is not being held down
            
            if isJoystick
                keyPress = find(keyCode);
            else
                keyPress = KbName(keyCode);
            end
            
            if iscell(keyPress)
                keyPress = keyPress{1};
            else
                keyPress = keyPress(1);
            end
            
            disp([keyPress, ' button detected!']);
            keyCounter = keyCounter + 1;
            
            keyIsDown = 0; keyPress = NaN; % temp assignment
            
            if keyCounter == 4
                break
            end
        end
    end
end

return
