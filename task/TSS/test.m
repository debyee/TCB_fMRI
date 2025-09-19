deviceIndex = 3;

escapeKey = KbName('ESCAPE');
KbQueueCreate(deviceIndex);
while KbCheck; end % Wait until all keys are released.

KbQueueStart(deviceIndex);
KbQueueFlush(deviceIndex);

while 1
    [pressed, firstPress] = KbQueueCheck(deviceIndex);

    if pressed
        fprintf('You pressed key %i which is %s\n', min(find(firstPress)), KbName(min(find(firstPress))));

        if firstPress(escapeKey)
            break;
        end
    end
end

KbQueueRelease(deviceIndex);
