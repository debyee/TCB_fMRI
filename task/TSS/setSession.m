function p = setSession(p)

%% Seed random number generator
rng('shuffle','twister');


%% Get session info
p.date = datestr(now,'mm-dd-yy');                   % gets date
p.startTime = datestr(now,'HH:MM:SS.FFF PM');       % gets start time
computerName = evalc('!hostname');                  % gets computer's name
p.computerName = computerName(1:end-1);             % gets rid of space at end of name


if p.isScanningVersion || p.isPostScanningVersion
    p.curSession = input('What is the session number? (1 = practice, 2 = scan, 3 = post-scan): ');
    
    while 1
        switch p.curSession
            case 1
                break
            case 2
                break
            case 3
                break
            otherwise
                p.curSession = (input('Invalid session number, please enter again: '));
        end
    end
        
end

%% Set device info 
if p.isScanningVersion || p.isPostScanningVersion
    p.curDevice = input('What is the device being used (1 = DY Laptop, 2 = AS Laptop, 3 = MRF computer): ');
    
    while 1
        switch p.curDevice
            case 1
                break
            case 2
                break
            case 3
                break
            otherwise
                p.curDevice = (input('Invalid session number, please enter again: '));
        end
    end
        
end

end

