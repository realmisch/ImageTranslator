%This is the main code that runs and controls functions.  With this code
%the arduino stepper commands are controlled to move in x y positions
%stored in position matrix, mat: columns of x and y positions

%important if this code is stopped prematurly global variable "a" must be
%cleared.  You can type "clear all" into command window.  If this is not done
%the stepper motors will remain powered on drawing current.

%make sure you 'com' is set to the correct port.  You can determine the
%proper port by going into the arduino app and seeing what port is opened.
%This changes when using different computers and different boards.

function [] = basecode(path,PortNo)
    clear global;

    global a; % create an arduino object
    
    %this is an internal program in matlab that creates a follower program in the Arduino that is controlled by the leader matlab program.   The first time this runs it will take a little longer as it will downlad the follower program into the arduino.
    a = arduino(PortNo, 'Uno');  
    %Set and configure pins for arduino
    global stepX dirX stepY dirY enPin;

    stepX = 'D2';
    dirX  = 'D5';
    stepY = 'D3';
    dirY  = 'D6';
    enPin = 'D8';

    configurePin(a,'D2','DigitalOutput')
    configurePin(a,'D5','DigitalOutput')
    configurePin(a,'D3','DigitalOutput')
    configurePin(a,'D6','DigitalOutput')
    configurePin(a,'D8','DigitalOutput')

    % Set initial position, lower left hand corner
    %note full range is approximately rangex=875 full rangey=610
    %repeatively going out of range causes the cables to slip in the
    %etch-a-sketch and will wear it out more quickly
    global currentx currenty;
    currentx=0;
    currenty=0;

    %establishes where backlash starts: 0 is negative, 1 is positive
    %note initial value only influences minor position of x,y start axis
    global currentdirx currentdiry;
    currentdirx=1;
    currentdiry=1;

    %set initial backlash; number of steps after changeing direciton in order for
    %visible movement to occur. This is a positive value
    global backlashx backlashy;
    backlashx=8;
    backlashy=9;

    global time;
    time=0; %This value of time pauses bewteen movements. note because of arduino and matlab communication this can only increase the speed to a certain degree. 0 is full speed.


    %pull up list of x,y points to travel to, mat
    %A seperate function should be put here.
    [mat]=path;        


    %runs through each travel point using fuction moveitto.  This function
    %relies on the global variables that are setup in this program and therefore cannot be run
    %without the basecode.

    wait=waitbar(0,'Drawing Image','Name','Drawing Progress','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(wait,'canceling',0);
    %Calculate the distance taken by the path using Pythagorean Method
    dist0=0;
    for c=2:length(mat)
        dist0=dist0+((mat(1,c)-mat(1,c-1)).^2+(mat(2,c)-mat(2,c-1)).^2).^(0.5);
    end        
    
    for i=1:length(mat)
        distance=0;
        for j=2:i
            distance=distance+((mat(1,j)-mat(1,j-1)).^2+(mat(2,j)-mat(2,j-1)).^2).^(0.5);
        end
        if getappdata(wait,'canceling')
            break
        end
        moveitto(mat(1,i),mat(2,i));
        %waitbar for updating drawing progress
        msg=sprintf('Printing %3.2f%% Complete',100*distance/dist0);
        waitbar(distance/dist0,wait,msg);
    end


    clear all; %this line clears all the variables, including most importantly "a" which shuts down the stepper motors
end