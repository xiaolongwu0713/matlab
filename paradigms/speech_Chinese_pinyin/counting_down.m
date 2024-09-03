function counting_down(i,w,prompt,n,progress)
    [xc,yc] = WindowCenter(w);%xc=960,yc=540
    [width, height]=Screen('WindowSize', w);
    % two gree dots
    first_dot_center_x=xc-800;
    rect=[first_dot_center_x first_dot_center_x+200 xc;
          yc yc yc;
          first_dot_center_x+100 first_dot_center_x+300 xc+100;
          yc-100 yc-100 yc-100];
      
    tmp=split(prompt, ' ');
    
    a=char(tmp(1));
    b=char(tmp(2));
    c=char(tmp(3));
    
    %% two dots at the begining
    if i==1
        if n==1
            colors=[155 155 155;
                    155 155 155;
                    155 155 155];
        elseif n==2
            colors=[0 155 155;
                    255 155 155;
                    0 155 155];
        elseif ismember(n, [3,4,5,6])
            colors=[0 0 155;
                255 255 155;
                0 0 155];
        elseif n>6
            colors=[0 0 255;
                255 255 0;
                0 0 0];

        end
    else
          
    % no dot at the begining
    
        if n==1
            colors=[0 0 155;
                    0 0 155;
                    0 0 155];
        elseif n==2
            colors=[0 0 155;
                    0 0 155;
                    0 0 155];
        elseif ismember(n, [3,4,5,6])
            colors=[0 0 155;
                0 0 155;
                0 0 155];
        elseif n>6
            colors=[0 0 255;
                0 0 0;
                0 0 0];

        end
    end
    
    %% text    
    
    Screen('FillOval',w,colors,rect);
    pa=rect(1,2)+200;
    pb=pa+100;
    pc=pa+200;
    
    pa2=xc+200;
    pb2=pa2+100;
    pc2=pb2+100;
    if n<4
         % 1:  If it is set to 1, then the “y” pen start location defines the base line of drawn text, otherwise it defines the top of the drawn text. 
        Screen('Drawtext',w,a,pa,yc,[155 155 155],[],1);
        Screen('Drawtext',w,b,pb,yc,[155 155 155],[],1);
        Screen('Drawtext',w,c,pc,yc,[155 155 155],[],1);
        Screen('Drawtext',w,a,pa2,yc,[155 155 155],[],1);
        Screen('Drawtext',w,b,pb2,yc,[155 155 155],[],1);
        Screen('Drawtext',w,c,pc2,yc,[155 155 155],[],1);
    elseif n==4
        Screen('Drawtext',w,a,pa,yc,[0 255 0],[],1);
        Screen('Drawtext',w,b,pb,yc,[155 155 155],[],1);
        Screen('Drawtext',w,c,pc,yc,[155 155 155],[],1);
        Screen('Drawtext',w,a,pa2,yc,[155 155 155],[],1);
        Screen('Drawtext',w,b,pb2,yc,[155 155 155],[],1);
        Screen('Drawtext',w,c,pc2,yc,[155 155 155],[],1);
        
    elseif n==5
        Screen('Drawtext',w,a,pa,yc,[0 255 0],[],1);
        Screen('Drawtext',w,b,pb,yc,[0 255 0],[],1);
        Screen('Drawtext',w,c,pc,yc,[155 155 155],[],1);
        Screen('Drawtext',w,a,pa2,yc,[155 155 155],[],1);
        Screen('Drawtext',w,b,pb2,yc,[155 155 155],[],1);
        Screen('Drawtext',w,c,pc2,yc,[155 155 155],[],1);
    elseif n==6 | n==7
        Screen('Drawtext',w,a,pa,yc,[0 255 0],[],1);
        Screen('Drawtext',w,b,pb,yc,[0 255 0],[],1);
        Screen('Drawtext',w,c,pc,yc,[0 255 0],[],1);  
        Screen('Drawtext',w,a,pa2,yc,[155 155 155],[],1);
        Screen('Drawtext',w,b,pb2,yc,[155 155 155],[],1);
        Screen('Drawtext',w,c,pc2,yc,[155 155 155],[],1);
    elseif n==8
        Screen('Drawtext',w,a,pa,yc,[0 255 0],[],1);
        Screen('Drawtext',w,b,pb,yc,[0 255 0],[],1);
        Screen('Drawtext',w,c,pc,yc,[0 255 0],[],1);  
        Screen('Drawtext',w,a,pa2,yc,[255 0 0],[],1);
        Screen('Drawtext',w,b,pb2,yc,[155 155 155],[],1);
        Screen('Drawtext',w,c,pc2,yc,[155 155 155],[],1);
    elseif n==9
        Screen('Drawtext',w,a,pa,yc,[0 255 0],[],1);
        Screen('Drawtext',w,b,pb,yc,[0 255 0],[],1);
        Screen('Drawtext',w,c,pc,yc,[0 255 0],[],1);  
        Screen('Drawtext',w,a,pa2,yc,[255 0 0],[],1);
        Screen('Drawtext',w,b,pb2,yc,[255 0 0],[],1);
        Screen('Drawtext',w,c,pc2,yc,[155 155 155],[],1);
    elseif n==10
        Screen('Drawtext',w,a,pa,yc,[0 255 0],[],1);
        Screen('Drawtext',w,b,pb,yc,[0 255 0],[],1);
        Screen('Drawtext',w,c,pc,yc,[0 255 0],[],1);  
        Screen('Drawtext',w,a,pa2,yc,[255 0 0],[],1);
        Screen('Drawtext',w,b,pb2,yc,[255 0 0],[],1);
        Screen('Drawtext',w,c,pc2,yc,[255 0 0],[],1);
    end
    
    Screen('Drawtext',w,progress,width-200,height-100,[255 255 255],[],1);
    %Screen('FillOval',w,[0 255 0],[xc-width/2-400,yc-300,xc-width/2,yc+100]);
    Screen('Flip',w); 
    
end