PsychDefaultSetup(2); 
% Open up a window on the screen and clear it.

whichScreen = max(Screen('Screens'));
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
[w,rec] = Screen('OpenWindow', whichScreen);
%[w,rec] = Screen('OpenWindow', whichScreen, black, [100,100,500,600]);
[X, Y] = Screen('WindowSize', w);
Screen('TextFont', w, 'Ariel');
Screen('TextSize', w, 50);

sqrt2=sqrt(2);
r=round(Y*0.05);
R=round(min(X,Y)-2*r)/2;
ya=round(Y/2);
xa=round(X/2-R);
yb=ya;
xb=xa+2*R;
yc=r;
xc=round(X/2);
yd=Y-r;
xd=xc;
xe=round(xc-R/sqrt2);
ye=round(ya-R/sqrt2);
yf=ye;
xf=round(xc+R/sqrt2);
yg=round(ya+R/sqrt2);
xg=xe;
xh=xf;
yh=yg;

[xCenter, yCenter] = RectCenter(rec); % relative to the w
baseRect = [0 0 r r];

recta = [ xa ya r+xa r+ya ];
rectb = [ xb yb r+xb r+yb ];
rectc = [ xc yc r+xc r+yc ];
rectd = [ xd yd r+xd r+yd ];
recte = [ xe ye r+xe r+ye ];
rectf = [ xf yf r+xf r+yf ];
rectg = [ xg yg r+xg r+yg ];
recth = [ xh yh r+xh r+yh ];

rects={recta;rectb;rectc;rectd;recte;rectf;rectg;recth};
rects=transpose(cell2mat(rects));
red = [255 0 0]; % target
green = [0 255 0]; % default
blue = [0 0 255];  % hit

index=[1 2 3 4 5 6 7 8];
index=repelem(index, 20);
index=index(randperm(length(index)));

sampleTime = 0.01;
startTime = GetSecs;
nextTime = startTime+sampleTime;

trajectories={};
for i=index(1:20)
    targetRect=rects(:,i);
    Screen('FillOval', w, green, rects);
    Screen('FillOval', w, red, targetRect);
    %Screen('Flip', w);
    [xCenter, yCenter] = RectCenter(rec);
    Screen('Drawtext',w,'New trial in 2 seconds.',xCenter,yCenter,[255 255 255]);
    Screen('Flip', w,[],1);
    
    % Move the cursor to the center of the screen
    SetMouse(xCenter,yCenter,whichScreen);

    % Loop and track the mouse, drawing the contour
    [theX,theY] = GetMouse(w);
    thePoints = [theX theY];

    while 1
        [x,y,buttons] = GetMouse(w);
        textString1 = ['X:' num2str(round(x)) ',Y:' num2str(round(y))];
        DrawFormattedText(w, textString1, 100 ,100);
        textString2 = ['X pixels:' num2str(round(X)) ',Y pixels:' num2str(round(Y))];
        DrawFormattedText(w, textString2, 100 ,150);

        if ~buttons(1)
            %break;
        end
        if (x ~= theX || y ~= theY)
            [numPoints, two]=size(thePoints);
            for j= 1:numPoints-1
                Screen('DrawLine',w,128,thePoints(j,1),thePoints(j,2),thePoints(j+1,1),thePoints(j+1,2));
            end
            %Screen('Flip', w);
            Screen('Flip', w,[],1);
            theX = x; theY = y;

            if (GetSecs > nextTime)
                thePoints = [thePoints ; x y];
                nextTime   = nextTime+sampleTime;
            end

            inside = IsInRect(x, y, targetRect);
            if inside == 1
                Screen('FillOval', w, blue, targetRect);
                Screen('Flip', w);
            end

            if inside == 1
                WaitSecs(1);
                break;
            end
        end
    end
trajectories{end+1}=thePoints;
end
% Close up
sca;

% Plot the contour in a Matlab figure
plot(thePoints(:,1),rec(RectBottom)-thePoints(:,2));
save trajectories.mat trajectories

