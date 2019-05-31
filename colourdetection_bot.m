
clc;
clear all;


 a=arduino('com6','uno');
writeDigitalPin(a,'D13',0);

vid = videoinput('winvideo',1);
set(vid,'FramesPerTrigger',Inf);             % for continuously capturing the videos      
set(vid,'ReturnedColorspace','rgb');
vid.FrameGrabInterval = 5;                   % for capturing frame at 5 ms interval
%********************************************

disp('Hi! Im Colour Detection Bot. Pleasure to meet you. ');
choice=input('Press 1 to begin.....');


while(choice == 1)
    
co = [640,360]
start(vid);
while(vid.FramesAcquired<=150)
    data = getsnapshot(vid);
    im = imsubtract(data(:,:,1),rgb2gray(data));
    im = medfilt2(im,[3 3]);
    im = im2bw(im,0.15);
    im = bwareaopen(im,1600);
    
    bw = bwlabel(im,8);
    stats = regionprops(bw,'BoundingBox','Centroid');
    imshow(data);
    hold on
    
    for i = 1:length(stats)
        bb = stats(i).BoundingBox;
        bc = stats(i).Centroid;
        if(mod(vid.FramesAcquired,10)==0)
            if(abs(bc(1)-co(1)) >= abs(bc(2)-co(2)))
                if(bc(1)-co(1)<0)
                    disp('right')
                 writeDigitalPin(a,'D011',0); %11
                 writeDigitalPin(a,'D010',0);%10
                 
                 writeDigitalPin(a,'D08',1); %8
                 writeDigitalPin(a,'D09',0);%9
                 
                 pause(5);                    co = bc;
                end
                if(bc(1)-co(1)>=0)
                    disp('left')
                 writeDigitalPin(a,'D011',0); %11
                 writeDigitalPin(a,'D010',1);%10
                 
                 writeDigitalPin(a,'D08',0); %8
                 writeDigitalPin(a,'D09',0);%9
                 co = bc;
                end
            else
                if(bc(2)-co(2)<0)
                    disp('up')
                 writeDigitalPin(a,'D011',0); %11
                 writeDigitalPin(a,'D010',1);%10
                 
                 writeDigitalPin(a,'D08',1); %8
                 writeDigitalPin(a,'D09',0);%9   co = bc;
                end
                if(bc(2)-co(2)>=0)
                    disp('down')
                 writeDigitalPin(a,'D011',1); %11
                 writeDigitalPin(a,'D010',0);%10
                 
                 writeDigitalPin(a,'D08',0); %8
                 writeDigitalPin(a,'D09',1);%9
                    co = bc;
                end
           end
        end

        rectangle('Position',bb,'EdgeColor','g','LineWidth',2)
        plot(bc(1),bc(2),'-m+')
    end
    hold off
end
stop(vid);
flushdata(vid);
choice=input('Would you like explore some more?(1/2) ');
end

disp('Thank You');
writeDigitalPin(a,'D13',0);
clear all;