function [p] = setScannerParams(p)

% TTL Device
p.device.num.ttl = -1;
p.TTLkey = 't';

% TR Length
p.TRlength = 1.2;

if p.isScanningVersion
    p.numStartDummyScans = 3;
    p.durStartDummyScans = p.TRlength * p.numStartDummyScans;
    
    p.numEndDummyScans = 8;
    p.durEndDummyScans = p.TRlength * p.numEndDummyScans;
end

% Get device numbers if scanning 
if p.isScanningVersion && p.curSession == 2         % only set response box for scanning portion
    
    % PsycHIDTest
    curDevices = PsychHID('Devices');
    curDevNumResp = nan;
    
    for devInd = 1:length(curDevices)
        if strcmpi(curDevices(devInd).usageName,'Keyboard')
            if strcmpi(curDevices(devInd).manufacturer,'Current Designs, Inc.')
                curDevNumResp = devInd;
            elseif strcmpi(curDevices(devInd).manufacturer,'Apple Inc.')
                curDevNumExptr = devInd;
            elseif strcmpi(curDevices(devInd).product,'Apple Internal Keyboard / Trackpad')
                curDevNumExptr = devInd;
            end
            
        end
    end
    
    if isnan(curDevNumResp)
        disp('ERROR: Response Box not found! Make sure the response box is plugged in and matlab has been restarted.');
        curResp = input('Continue without specifying the device? (1 = Yes, 0 = No): ','s');
        
        if strcmpi(curResp,'1')
            p.device.num.resp = -1;
        else
            error('Please change the device parameters that you are looking for in setScannerParams.m.');
        end
    else
        disp(['Device ',num2str(curDevNumResp),' found! Usage name: ',curDevices(curDevNumResp).usageName,'; Manufacturer: ',curDevices(curDevNumResp).manufacturer]);
        curResp = input('Continue with this device? (1 = Yes, 0 = No): ','s');
        
        if strcmpi(curResp,'1')
            p.device.num.resp = curDevNumResp;
        else
            error('Please change the device parameters that you are looking for in setScannerParams.m.');
        end
    end
    
    if isnan(curDevNumExptr)
        disp('ERROR: Experimenter Keyboard not found! Make sure it is pluged in and matlab has been restarted.');
        curResp = input('Continue without specifying the device? (1 = Yes, 0 = No): ','s');
        
        if strcmpi(curResp,'1')
            p.device.num.exptr = -1;
        else
            error('Please change the device parameters that you are looking for in setScannerParams.m.');
        end
    else
        p.device.num.exptr = curDevNumExptr;
    end
    
    % if we are debugging, we do not need to detect the response box
    if p.debug == 1
        p.keyArrayStrVec = 'dfjk';
        p.responseBox = 0;
        p.isJoystick = 0;
    else      
        p.keyArrayStrVec = 'bygr';
        p.responseBox = 1;
        p.isJoystick = 0;
    end
    
else
    p.device.num.resp = -1;
    p.device.num.exptr = -1;
end

end

