escapeKey = KbName('ESCAPE');
while KbCheck; end % Wait until all keys are released.

while 1
    % Check the state of the keyboard.
    [ keyIsDown, seconds, keyCode ] = KbCheck;
    keyCode = find(keyCode, 1);

    % If the user is pressing a key, then display its code number and name.
    if keyIsDown
        % Note that we use find(keyCode) because keyCode is an array.
        % See 'help KbCheck'
        fprintf('You pressed key %i which is %s\n', keyCode, KbName(keyCode));

        if keyCode == escapeKey
            break;
        end

        % If the user holds down a key, KbCheck will report multiple events.
        % To condense multiple 'keyDown' events into a single event, we wait until all
        % keys have been released.
        KbReleaseWait;
    end
end