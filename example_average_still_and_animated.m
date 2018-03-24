%This code estimates average data for surface and bottom drifters (that have enough data)
% and plots still frame of the data as well producing animation in second figure

% NOTE: code created by Jamie M Johns was tested in matlab version 2013b
% source; https://github.com/JamieMJohns/Animate-river-drifter-trajectories 


% refresh matlab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all % close any open figures
clear all % clear all variables from workspace
clc %clear command window (text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

frame_skip=100; %number of time-steps to skip in animation (note has mininum value of 1); t_skip=10 will speed animation up by skipping 10 frames

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



% Get average positions for surface and bottom drifters $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    % surface drifters (with at least 3500 timesteps [time of 12.15 days]); 1 7 10
    % bottom drifters (with at least 3500 timesteps [time of 12.15 days]); 2 4 6
    t=1:3500; %time_steps to record averages
    D_surface(t,1)=(D{1}(t,1)+D{7}(t,1)+D{10}(t,1))./3; %get average longitude for drifters 1,7,10 over time-steps "t"
    D_surface(t,2)=(D{1}(t,2)+D{7}(t,2)+D{10}(t,2))./3; %get average lattitude for drifters 1,7,10 over time-steps "t"
    D_bottom(t,1)=(D{2}(t,1)+D{4}(t,1)+D{6}(t,1))./3; %get average longitude for drifters 2,4,6 over time-steps "t"
    D_bottom(t,2)=(D{2}(t,2)+D{4}(t,2)+D{6}(t,2))./3; %get average lattitude for drifters 2,4,6 over time-steps "t"
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



% GRAPHICS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

figure(1) %create figure

% initialise figure data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    whitebg('white')  %set figure background color
    set(figure(1),'position',[164   444   988   520]) %set figure position and size (resolution) [not necessary but saves stretching figure each time you run the code]
    ylabel('Latitude $[^{\circ}]$', 'Interpreter', 'Latex', 'FontSize', 20); %set ylabel for figure
    xlabel('Longitude $[^{\circ}]$', 'Interpreter', 'Latex', 'FontSize', 20); %set xlabel for figure
    title(sprintf('Average drifter positions over %.4f days\n location: Townsville QLD AUS',(3500-1).*5./(60.*24)),'fontsize',12) %create figure title [using sprintf() function for input of parameter]
    hold on %keep all subsequent plotted objects [very necessary!]
    img = imread('maptown.png'); %read image data of file named 'maptown.png'
    imageback=imagesc([146.5 147.55], [-19.3  -18.8],img); %draw image in figure as background
    plot3(D_surface(:,2),D_surface(:,1),3.*ones(3500,1),'b.','markers',10); %plot average position for surface drifters
    plot3(D_bottom(:,2),D_bottom(:,1),3.*ones(3500,1),'r.','markers',10); %plot average position for bottom drifters
    %xdata = longitude
    %ydata = lattitude
    %zdata = 3 , arbitrary value, to make sure plotted drifter data is above drawn map which usually has z-value of 1    
    legend('surface drifter','bottom drifters','location','southoutside','Orientation','horizontal') %create legend outside figuree
    axis(bound) %set axis for figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% GRAPHICS ANIMATED @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% same as above but with shading added to plots
figure(2) %create figure

% initialise figure data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    whitebg('white')  %set figure background color
    set(figure(2),'position',[300   444   988   520]) %set figure position and size (resolution) [not necessary but saves stretching figure each time you run the code]
    ylabel('Latitude $[^{\circ}]$', 'Interpreter', 'Latex', 'FontSize', 20); %set ylabel for figure
    xlabel('Longitude $[^{\circ}]$', 'Interpreter', 'Latex', 'FontSize', 20); %set xlabel for figure
    hold on %keep all subsequent plotted objects [very necessary!]
    img = imread('maptown.png'); %read image data
    imageback=imagesc([146.5 147.55], [-19.3  -18.8],img); %read image data of file named 'maptown.png'
    j=[1 frame_skip:frame_skip:3600]; %list of frames to live update figure 2 (in increments of frame_skip)
    legend('surface drifter','bottom drifters','location','southoutside','Orientation','horizontal') %create legend outside figuree
    axis(bound) %set axis for figure
    for t=1:3500 % for each time step
    col_surface=[0 0 1].*(3501-t)./(3500); %paramtise colour for surface drifter
    col_bottom=[1 0 0].*(3501-t)./(3500); %paramtise colour for bottom drifter
    plot3(D_surface(t,2),D_surface(t,1),3,'b.','markers',10,'color',col_surface); %plot average position for surface drifters
    plot3(D_bottom(t,2),D_bottom(t,1),3,'r.','markers',10,'color',col_bottom); %plot average position for bottom drifters
    %xdata = longitude
    %ydata = lattitude
    %zdata = 3 , arbitrary value, to make sure plotted drifter data is above drawn map which usually has z-value of 1
        %BELOW: determine if frame should be visually updated
        if sum(t==j)~=0 %if t is in list of frames to update visually
           title(sprintf('Average drifter positions over %.2fdays\n location: Townsville QLD AUS',(t-1).*5./(60.*24)),'fontsize',12) %create figure title [using sprintf() function for input of parameter]
           drawnow  %drawnow (update frame
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%