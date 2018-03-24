%This code plots drifter data (stored in raw_data.m) as  animated dots

% NOTE: code created by Jamie M Johns was tested in matlab version 2013b
% source; https://github.com/JamieMJohns/Animate-river-drifter-trajectories 


% refresh matlab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all % close any open figures
clear all % clear all variables from workspace
clc %clear command window (text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t_skip=10; %number of time-steps to skip in animation (note has mininum value of 1); t_skip=10 will speed animation up by skipping 10 frames

% Loading the drifter data@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    run raw_data.m %runs matlab file "raw_data.m" which creates "cell" variable named "D" [position data of 10 drifters that were released as pairs]
    % Data was recorded in the year 2015 (James Cook University) with the coordinate system being "WGS_1984"
    % Example usage of variable "D" (drifter data):
    %   D = all longitude and lattitude data for ALL 10 drifters
    %   D{j} = all longitude and lattitude data for the the jth drifter (where j is ranges from 1 and 10)
    %   D{j}(k,:) = longitude and lattitude data for the the jth drifter and at the kth time-step (where k ranges from 1 to 2 [respectively longitude and lattitude]
    %   D{j}(k,1) = longitude data for the the jth drifter and at the kth time-step 
    %   D{j}(k,2) = lattitude data for the the jth drifter and at the kth time-step 
    %Note: the difference in time between each time step is five minutes
    %      i.e - D{7}(1,2)=lattitude data for 7th drifter at first time step  [time = 0 minutes]
    %            D{4}(96,1)=longitude data for 4th drifter at 96th time-step  [time = ((96-1) * 5) minutes]
    %            D{3}(17,2)=longitude data for 3rd drifter at 17th time-step  [time = ((17-1) * 5) minutes]
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

%Cleaning the Data#############################################################################################
% This section was created to remove problematic data but is subject to optimisation
    bound=[146.5 147.55 -19.3 -18.8]; %boundary for longitude (min and max) and lattitude (min and max)
    lim_step=[0.1 0.1]; %maximum change allowed between longitude ["lim_step(1)"] and lattitude ["lim_step(2)"]

    fprintf('Maximum number of time-steps for each drifter; \n') %create line in matlab command window
    for j=1:10 % for each drifter
        for t=2:size(D{j},1); %for each time step (t) of 2 till maximum number times for jth drifter          
            if (D{j}(t,2)<bound(1))||(D{j}(t,2)>bound(2))||(D{j}(t,1)<bound(3))||(D{j}(t,1)>bound(4)); %if drifter is position outside boundary; use previous time-step (t-1)  
                                                                                                       %note: || = 'or' argument
                D{j}(t,:)=D{j}(t-1,:); %use previous time-step "t-1" for current time step "t" (if above argument is true)                                                                
            end
            if (abs(D{j}(t,2)-D{j}(t-1,2))>lim_step(2))||(abs(D{j}(t,1)-D{j}(t-1,1))>lim_step(2)) %if change in position (from previous step) is greater than lim_step; use previous time-step (t-1)
                D{j}(t,:)=D{j}(t-1,:); %use previous time-step "t-1" for current time step "t" (if above argument is true)
            end
        end    
        num_data(j)=size(D{j},1); %record maximum number of positions for jth drifter
        max_time_hours(j)=(size(D{j},1)-1).*5./60; %record maximum time data for jth drifter [in hours]
        max_time_days(j)=(size(D{j},1)-1).*5./(60.*24); %record maximum time data for jth drifter [in days]
        fprintf('Drifter %.0f has %.0f time-steps [or maximum %.4f hours (%.2f days) worth of data]\n',j,num_data(j),max_time_hours(j),max_time_days(j)) %create line in matlab command window
    end
%###############################################################################################################



% GRAPHICS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

figure(1) %create figure

% initialise figure data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    whitebg('white')  %set figure background color
    set(figure(1),'position',[164   444   988   520]) %set figure position and size (resolution) [not necessary but saves stretching figure each time you run the code]
    ylabel('Latitude $[^{\circ}]$', 'Interpreter', 'Latex', 'FontSize', 20); %set ylabel for figure
    xlabel('Longitude $[^{\circ}]$', 'Interpreter', 'Latex', 'FontSize', 20); %set xlabel for figure
    title(sprintf('Position of 10 drifters over a maximum time of %.4f days\n location: Townsville QLD AUS',max(max_time_days))) %create figure title [using sprintf() function for input of parameter]
    hold on %keep all subsequent plotted objects [very necessary!]
    col=[1 0 0;0 1 0;0 0 1;0 1 1;1 1 0;1 0 1]; col=[col;col.*0.5]; %set colours for each drifter [in plot], i.e - col(3,:) is colour for 3rd drifter; col(3,1)=red_intensity of 3  col(3,2)=green_intensity of 3 
    for j=1:10 % for each of 10 drifters
        plt(j)=plot3(D{j}(1,2),D{j}(1,1),3,'r.','color',col(j,:),'markers',15);  %plot 1st position for each drifter and create jth plot object for drifter [plt(j)] 
        %xdata = longitude
        %ydata = lattitude
        %zdata = 3 , arbitrary value, to make sure plotted drifter data is above drawn map which usually has z-value of 1
    end
    legend('drifter 1','drifter 2','drifter 3','drifter 4','drifter 5','drifter 6','drifter 7','drifter 8','drifter 9','drifter 10','location','bestoutside') %create legend outside figure
    img = imread('maptown.png'); %read image data of file named 'maptown.png'
    imageback=imagesc([146.5 147.55], [-19.3  -18.8],img); %draw image in figure as background
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Animation $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
     for t=1:t_skip:max(num_data); %for time-steps t=1 till maximum time-step recorded overall drifter data  [in "increments of t_skip"]
        for j=1:10 %for each jth drifter
           if t<num_data(j) %if current time-step(t) is not greater than number of time steps for drifter j
                set(plt(j),'xdata',D{j}(t,2),'ydata',D{j}(t,1))  %update jth plot object by longitude and lattidue [if jth drifter has data for time step (t)]
           end
        end
        %[uncomment the line below if you want to plot time in figure  (note: this may slow down plotting speed)]   
        %title(sprintf('time=%.2fhours (%.4fdays)',t./60,t./(600.*24)), 'FontSize', 12) %list current time in figure
        axis(bound) %set axis for figure
        drawnow %update figure
     end
 %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$