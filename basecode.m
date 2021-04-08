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
    
    a = arduino(PortNo, 'Uno');  %this is an internal program in matlab that creates a follower program in the Arduino that is controlled by the leader matlab program.   The first time this runs it will take a little longer as it will downlad the follower program into the arduino.
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
    
    for i=1:length(mat)
        if getappdata(wait,'canceling')
            break
        end
        moveitto(mat(1,i),mat(2,i));
        percent=100*i/length(mat);
        fprintf('Drawing %3.2f%% Complete\n',percent)
        etasec=(length(mat))/(2);
        etamin=cast(etasec/60,'uint8');
        etahr=cast(etamin/60,'uint8');
        etasec=mod(etasec,60);
        etamin=mod(etamin,60);
        msg=sprintf('Drawing %3.2f%% Complete\n ETA: %2.0f Hrs %2.0f Min %2.0f Sec',percent,etahr,etamin,etasec);
        waitbar(percent/100,wait);
    end


    clear all; %this line clears all the variables, including most importantly "a" which shuts down the stepper motors
end