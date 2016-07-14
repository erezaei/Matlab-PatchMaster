%%% Sylvia Fechner
%%% Stanford University, 
%%% 20151115
%%% Update: 20160210
%%% Script to analyze data from FALCON in Displacement Clamp
%%% Five sweeps of steps within one series
%%% To commit to github
%%% go to my branch
%%% git add .
%%% git commit -m 'text'
%%% git push origin my branch

%%% comment: program works for single sweeps or series with 5 or more
%%% sweeps within one series

%%% ToDo 

%%% Currently, automatically saved data are saved in the same folder
%%% change automatically for Step and Ramp differently
%%% write into csv file: mac can't write to excel !! 
    % --> which values?
    % how to write each Indentation as col header??? in excel and csv
    % mean indentation from non-averaged signal?
    % normalized max current non-averaged?
    % write which simuli which series and which sweeps kept
    % n of averaged signal
%%% finding function in igor to load excel or csv files
%%% make it work for ramps as well
%%% running average
%%% ToDo maybe: plot (one) indentation over time; currently: Current over
%%% Filenumber

%%% ToDo maybe: make subplots for all Fivestep blocks?
%%% find number of nan values to find out the number of averages
%%% include legend again in current vs indentation


%%  load dat.files 
clear all; close all; clc;
ephysData=ImportPatchData();
%%
% load notes to get several values automatically needed for the conversion of the signals
loadFileMode = 0; % change here, if you want to select a file or load always the same
if loadFileMode  == 0; % 
[filename,pathname] = uigetfile('*.*', 'Load file', 'MultiSelect', 'on'); 
[numbers, text, raw] = xlsread([pathname, filename]);
elseif loadFileMode == 1
[numbers, text, raw] = xlsread('Ephys-Meta-Sylvia.xlsx'); % be careful in which Folder saved.
end

%% Analysis Individual Recording 
close all; clc

%%% hardcoding part:
%%% change:  STF0XX, sampling fequency not yet fully automatic %%%%%% 

name = 'SKS026'; % name of recording. placed into varaibel fiels names%
stimuli = 'FiveStep'; % Single protocols: Step and Ramp-Hold; Five sweeps per protocol:FiveStep, FiveRampHold; does not work with alternative names
Filenumber = 1; % wil be used to extract sampling freuqnecy; first file loaded, maybe change

Files = 1:length(ephysData.(name).protocols);% load all protocols  

% load all data from all protocols 
% load Current, Actuator Sensor, And Cantilver Signal of each step%
% if else statement included to also load protocols which don't have
% ForceClamp data; not necessary for Current
A=[];B=[]; C=[];D=[];   % to get an empty array, if I analyzed different files before
for i = Files(:,1):Files(:,end);
A{i} = ephysData.(name).data{1, i}; %Current
if isempty(ephysData.(name).data{3, i}) == 1
    continue
 else
B{i} = ephysData.(name).data{3, i}; % actuator Sensor
end
 if isempty(ephysData.(name).data{4, i}) ==1
    continue
 else
 C{i} = ephysData.(name).data{4, i}; % Cantilever Signal
 end
  if isempty(ephysData.(name).data{2, i}) == 1 % actuator input
     continue
 else
 D{i} = ephysData.(name).data{2, i}; % actuator SetPoint
  end
end


% find all files with certain protocol name: 
% ifelse statement: if not respective stimuli name (FiveStep or FiveRampHold), then empty array; 
for i = Files(:,1):Files(:,end);
   if find(strcmpi(ephysData.(name).protocols{1,i}, stimuli)) == 1;
        continue
   else 
         A{1, i} = []; B{1, i} = []; C{1, i} = []; D{1, i} = [];          
    end      
end


tf = strcmp('FiveStep',stimuli); % ToDo: replace all tf with isFiveStep
%compare Input Stimuli
isFiveStep = strcmp('FiveStep',stimuli); 
isFiveRamp = strcmp('FiveRampHold',stimuli);
isStep = strcmp('Step',stimuli);
isRamp = strcmp('Ramp-Hold',stimuli);
isFiveSine = strcmp('FiveSinus',stimuli);


% if isFiveStep == 1 || isFiveRamp == 1; %%% if single steps are used, avoid deleting Blocks with less than five
% % replacing "broke" protocols with empty arrays (delete protocols with less then 5 stimuli) 
% for i = 1:length(A);  
%    if size(A{1, i},2) < 5 == 1  %% if less the five stimuli are within a protocol, the array is replaced by empty columns. this assumes that this happens only if I broke the protocol, because I forgot to download the wavetable in labview
%        A{1, i} = [];  B{1, i} = []; C{1, i} = []; D{1, i} = [];
%    else
%        continue
%    end
% end
% else
%    disp 'SingleSteporRamp'
% end


% showing in command prompt: AllStimuli = patchmaster Filenumber; ask for which has less than Five stimuli (exception: single step),
% no need to remove the array with less than 5 stimuli, because it was already deleted in the previous step

AllStimuliBlocks = (find(strcmpi(ephysData.(name).protocols, stimuli)))
% LessThanFiveStimuli = [];
% for i=1:length(AllStimuliBlocks)
% LessThanFiveStimuli(i) = isempty(A{1,AllStimuliBlocks(i)});
% end
% %AllStimuliBlocks
% if isStep == 1 || isRamp == 1;
%     disp 'singleSteporRamp'
%     %ToDo for Ramp-Hold as well
% else
% LessThanFiveStimuli %dipslay in command window, if FiveSteps or FiveRamps
% end

% deleting whole blocks of FiveBlockStimuli; Whole block=Filenumber
while 1
prompt = {'BlockNr (leave empty to quit)'};
dlg_title = 'Delete a block?';
num_lines = 1;
defaultans = {''};
IndValues = inputdlg(prompt,dlg_title,num_lines,defaultans);
FirstValue = str2num(IndValues{1});

if isempty(FirstValue) == 1 
     break
 else
    A{1, FirstValue}  = []; 
    B{1, FirstValue}  = [];
    C{1, FirstValue}  = [];
    D{1, FirstValue}  = []; 
 end
end

% removes all empty cells from the cell array
AShort = A(~cellfun('isempty',A)); BShort = B(~cellfun('isempty',B)); CShort = C(~cellfun('isempty',C)); DShort = D(~cellfun('isempty',D));

% concatenating all stimuli
Aall = []; Aall = cat(2,AShort{:}); 
Ball = []; Ball = cat(2,BShort{:}); 
Call = []; Call = cat(2,CShort{:});
Dall = []; Dall = cat(2,DShort{:});

% calculate sampling frequency
fs = ephysData.(name).samplingFreq{1, Files(:,AllStimuliBlocks(1))}; % sampling frequency from first Stimuli loaded; 
interval = 1/fs;   %%% get time interval to display x axis in seconds 
ENDTime = length(Aall)/fs; %%% don't remember why I complicated it
Time = (0:interval:ENDTime-interval)'; 


%%%%%% Subtract leak current
LeakA = []; ASubtract = [];
 for i = 1:size(Aall,2);
LeakA(i) = mean(Aall(1:0.02*fs,i));  %%% take the mean of the first 100 Points: ToDo: maybe dependent on sampling frequency
ASubtract(:,i) = Aall(:,i) - LeakA(i); %%%
 end
 
ActuSensor = [];
for i = 1:size(Ball,2),
ActuSensor(:,i) = Ball(:,i)*1.5; % 1.5 = sensitivity of P-841.10 from Physik Instrumente; travel distance 15 um; within 10 V; ToDo: measure real sensitivity
end


[SlopeActu,MaxZeroSlopeActu,StdZeroSlopeActu,MaxZeroActu,StdZeroActu,MaxActuSensorPlateau,StdActuSensorPlateau,CellMaxActuFirst] = SlopeThreshold(ActuSensor);  

% calculate threshold

StartBase = [];
if isFiveStep == 1 || isStep == 1;
    StartBase = MaxZeroActu + 2*StdZeroActu;   %% play around and modifz 
else
    StartBase = MaxZeroSlopeActu + 4*StdZeroSlopeActu; %
end

disp 'change threshold, if noise of' 
BelowPlateau = [];
BelowPlateau = MaxActuSensorPlateau - 6*StdActuSensorPlateau; % play around and modify


%%%%%% CurrentSignals %%%%%%%
[AvgMaxCurrent,AvgMaxCurrentMinus,AvgMaxCurrentOff,AvgMaxCurrentMinusOff,Start,StartOffBelow,Ende,EndeOff,ASubtractAvg,LengthRamp,LengthInms] = AnalyzeCurrent(isFiveStep,isStep,ActuSensor,StartBase,Aall,ASubtract,fs,SlopeActu,BelowPlateau,CellMaxActuFirst,interval);
% modify for RampAndHold
LengthInms
LengthRamp

% calculate in pA
AverageMaxCurrentMinusppA = AvgMaxCurrentMinus*10^12; LeakAppA = LeakA*10^12; ASubtractppA = ASubtract*10^12; % current in pA to visualize easier in subplot
AallppA=Aall*10^12; 


%%%%%% ForceClampSignals %%%%%%%

% to get Deflection of Cantilever: multiply with Sensitivity 
% get Sensitivity from Notes Day of Recording  
FindRowStiff = strcmpi(raw,name); % name = recorded cell
[Stiffrow,col] = find(FindRowStiff); % Siffrow: row correasponding to recorded cell

headers = raw(1,:);
ind = find(strcmpi(headers, 'Sensitivity(um/V)')); % find col with Sensitivity
Sensitivity = raw(Stiffrow,ind); 
Sensitivity = cell2mat(Sensitivity);

indStiffness = find(strcmpi(headers, 'Stiffness (N/m)'));
Stiffness = raw(Stiffrow,indStiffness); 
Stiffness = cell2mat(Stiffness);

[ActuSetPoint,CantiDefl,MeanIndentation,Force,MeanForce,Indentation] = AnalyzeForceClamp(isFiveStep,isStep,Dall,Call,EndeOff,ActuSensor,Sensitivity,Stiffness,fs);

% Calculating Rise time and Overshoot on Cantilever Deflection signals
% shortened to the Onset of the step

% ToDo: needs to be modified for Ramp
 CantiDeflShort = [];
 MeanCantiDefl = [];
 normCantiDefl = [];
  for i = 1:size(CantiDefl,2);
      EndeCanti(i) = Start(i)+1000;
  CantiDeflShort(:,i) = CantiDefl(Start(i):EndeCanti(i),i); 
  MeanCantiDefl(i) =  mean(CantiDefl(0.2*fs:0.4*fs,i));
  normCantiDefl(:,i) = CantiDefl(:,i)/MeanCantiDefl(i);
  end
 
TimeShort = (0:interval:length(CantiDeflShort)/fs-interval)';  
InfoSignal = stepinfo(CantiDeflShort, TimeShort, MeanCantiDefl, 'RiseTimeLimits', [0.0 0.63]); %%% over sorted data?? 
allRiseTime = cat(1,InfoSignal.RiseTime);
allOvershoot = cat(1,InfoSignal.Overshoot);



%% now figures
close all
xScatter = (1:length(MeanIndentation));
LengthInmsForPlot = LengthInms*1000;

%%%current with and without leak subtraction in a subplot %%%%

figure()
for i = 1:size(AallppA,2)
subplot(ceil(size(AallppA,2)/5),5,i)
plot(Time,AallppA(:,i))
%ylim([-5*10^-11 1*10^-11])
hold on
plot(Time,ASubtractppA(:,i))
%RecNum = i; % include number of i within legend or title to easier
%determine the position of the plot
if isFiveStep == 1 || isStep == 1;
title(round(MeanIndentation(i),1)) %% 
else
    title(round(LengthInmsForPlot(i),1)) 
end
end
suptitle({'Current (pA) with (red) and without (blue) leak subtraction';'Bold numbers: Indentation in �m'}) %('')

%%%cantilever signals %%%%
figure()
for i = 1:size(Aall,2)
subplot(ceil(size(AallppA,2)/5),5,i)
plot(Time,CantiDefl(:,i))
%ylim([-5*10^-11 1*10^-11])
%RecNum = i; % include number of i within legend or title to easier
%determine the position of the plot
if isFiveStep == 1 || isStep == 1;
title(round(MeanIndentation(i),1)) %% 
else
    title(round(LengthInmsForPlot(i),1)) 
end
end
suptitle({'Cantilever Deflection'}) %('')



%%%normalized cantilever signals %%%%
figure()
for i = 1:size(Aall,2)
subplot(ceil(size(AallppA,2)/5),5,i)
plot(Time,ActuSensor(:,i))
ylim([-1 16])
%ylim([-5*10^-11 1*10^-11])
%RecNum = i; % include number of i within legend or title to easier
%determine the position of the plot
if isFiveStep == 1 || isStep == 1;
title(round(MeanIndentation(i),1)) %% 
else
    title(round(LengthInmsForPlot(i),1)) 
end
end
suptitle({'Actuator Sensor'}) %('')

%control plot

figure()
subplot(3,2,1)
scatter(xScatter, Start) 
%ylim([0 1000]) % ToDo: change it for Ramps
ylabel('Point')
xlabel('Filenumber')
title('control: Find OnSet of On-Stimulus')
hold on 
subplot(3,2,2)
scatter(xScatter, StartOffBelow) %change to start of below
%ylim([100 1000]) % ToDo: change it for Ramps
ylabel('Point')
xlabel('Filenumber')
title('control: Find OnSet of Off-Stimulus')
hold on 
subplot(3,2,3)
scatter(xScatter, LengthInmsForPlot) %change to start of below
%ylim([100 1000]) % ToDo: change it for Ramps
ylabel('Lengtg of OnSet Stimulus (ms)')
xlabel('Filenumber')
title('Length of Ramp')
subplot(3,2,4)
scatter(xScatter, AverageMaxCurrentMinusppA ) %change to start of below
%ylim([100 1000]) % ToDo: change it for Ramps
ylabel('Current (pA)')
xlabel('Filenumber')
title('control: compare Max current of each stimulus with traces')



%msgbox('if you want to delete a whole block, run again');

%%
%%% Calculate Velocity For RampAndHoldStimuli
%%% TODo: Calculate Velocity from Indentation? Yes. Do it. Do it from fit

% SlopeSensor = [];  SlopeSensorInd = [];SlopeCantiDefl = []; %Velocity = []; VelocityOff = [];
%     for j = 1:size(ActuSensor,2)
%      for i = 1:length(ActuSensor)-1;
%         SlopeSensor(i,j) = (ActuSensor(i+1,j) - ActuSensor(i,j))/(Time(i+1) - Time(i)); 
%          SlopeCantiDefl(i,j) = (CantiDefl(i+1,j) - CantiDefl(i,j))/(Time(i+1) - Time(i)); 
%    %    TEST(i,j) = (ActuSensor(i+1,j) - ActuSensor(i,j));% SlopeSensor to calculate Velocity, not on Averaged signal! only to determine the onset of the stimulus okay
%        SlopeSensorInd(i,j) = (Indentation(i+1,j) - Indentation(i,j))/(Time(i+1) - Time(i)); 
%      end
%     end    
  
 if isRamp == 1 || isFiveRamp == 1;
 for i = 1:size(Indentation,2);
cftool(Time(Start(i):Start(i)+LengthRamp(i)),Indentation(Start(i):Start(i)+LengthRamp(i),i))
 end 
 else
    disp 'not opening fitTool for Steps currently'
 end
 
%% Refit a Recording
 if isRamp == 1 || isFiveRamp == 1;
  while 1
prompt = {'Enter number of recording, matches subplot (leave empty to quit, enter a number as long as you want to refit a ramp)','Start of Fit','End of Fit: Number of Points after Start of Ramp'};%,'SecondRec','ThirdRec','ForthRec'};
dlg_title = 'Refit a recording?';
num_lines = 1;
defaultans = {'','',''};%,'',''};
IndValues = inputdlg(prompt,dlg_title,num_lines,defaultans);
FirstRec = str2num(IndValues{1});
SecondRec = str2num(IndValues{2});
ThirdRec = str2num(IndValues{3});
%ForthRec = str2num(IndValues{3});

if isempty(FirstRec) == 1
    break
else
cftool(Time(Start(FirstRec)+SecondRec:Start(FirstRec)+LengthRamp(FirstRec)+ThirdRec),Indentation(Start(FirstRec)+SecondRec:Start(FirstRec)+LengthRamp(FirstRec)+ThirdRec,FirstRec));
end
  end
 else
    disp 'not opening fitTool for Steps currently'
 end
    

%% delete single recordings 
%close all
%ToDo: has to be changed for ramps, because I want to average the current with
%same velocity 

ASubtractNew = ASubtractAvg;
AvgMaxCurrentMinusNew = AvgMaxCurrentMinus;
MeanIndentationNew = MeanIndentation;
%AverageMaxNormCurrentNew = 
%TO DO: Someting wrong with the order in command promt
% if I redo AverageMaxCurrentMinus= Nan, I have to reload it again or do it
% as for ASubtract new

while 1
prompt = {'Enter number of recording, matches subplot (leave empty to quit, enter a number as long as you want to delete a recording)'};%,'SecondRec','ThirdRec','ForthRec'};
dlg_title = 'Delete a recording?';
num_lines = 1;
defaultans = {''};%,'','',''};
IndValues = inputdlg(prompt,dlg_title,num_lines,defaultans);
FirstRec = str2num(IndValues{1});
%SecondRec = str2num(IndValues{2});
%ThirdRec = str2num(IndValues{3});
%ForthRec = str2num(IndValues{3});

if isempty(FirstRec) == 1
    break
else
  ASubtractNew(:,FirstRec) = NaN;
  AvgMaxCurrentMinusNew(:,FirstRec) = NaN;
  MeanIndentationNew(:,FirstRec) = NaN;
end
end
%%

% Sort Data 
% change that mergeInd can be finally made by rounded MeanIndentation where
% files were deleted --> problems with NaN values --> maybe solution see
% end of the script

%%%%%% Sort Data
MeanTraces=[];
MeanSameIndCurrent=[];
MeanSameIndForce=[];
NumberTracesPerInd=[];
MeanSameVelIndentation=[];

if isFiveStep == 1 || isStep == 1;
    disp 'Step Round and sort'
RoundMeanInd = round(MeanIndentation,1); % change to get it from MeanIndentation New with NaN values
[SortInd sorted_index] = sort(RoundMeanInd'); % get index of mean indentations
SortCurrent = AvgMaxCurrentMinusNew(sorted_index);
SortCurrentOff = AvgMaxCurrentMinusOff(sorted_index); %change that it works for deleting traces
%SortNormCurrent = AverageMaxCurrentMinusNew(sorted_index); % don't need it
%here, because normalize it afterwards ? maybe change it?
SortForce = MeanForce(sorted_index);
transAsub = ASubtractNew';
SortASubtract = transAsub(sorted_index,:);
transMeanIndentation = MeanIndentation'; % wrong, needs to be over Indentation
SortMeanIndentation = transMeanIndentation(sorted_index,:);
%SortASubtract = SortASubtract'; keep it as row, easier to calculate
MergeInd = [];
MergeInd = builtin('_mergesimpts',SortInd,0.2,'average'); %%% merge values with +/- 0.1 distance
tolerance = 0.2; % tolerance to group indentations
k =[];
[~,FRow] = mode(SortInd); %gets the Frequency of the most frequent value
FindSameInd= NaN(FRow,length(MergeInd)); % determine row length with highest probability of most frequent value
if size(Aall,2) > 5
FindSameIndInitial = {};
for k = 1:length(MergeInd);
FindSameIndInitial{k} = find([SortInd] >MergeInd(k)-tolerance & [SortInd]<MergeInd(k)+tolerance);
end
FindSameIndNaN = padcat(FindSameIndInitial{:});
FindSameInd = FindSameIndNaN;
for i = 1:length(MergeInd);
[r,c] = find(isnan(FindSameInd(:,i))); % fails, if only one Block of recording; include it into if statement for this reason
while sum(isnan(FindSameInd(:,i)))>0
FindSameInd(r,i) =FindSameInd(r-1,i);
end
end
else %% if only one FiveStepProtcol was applied
    FindSameInd = [];
    for k = 1:length(MergeInd);
FindSameInd(:,k) = find([SortInd] >MergeInd(k)-tolerance & [SortInd]<MergeInd(k)+tolerance);
    end    
end   
%FindLogicalNumberOfTraces = FindLogicalNumberOfTraces'
%NumberTracesPerInd = NumberTracesPerInd';
for k = 1:length(MergeInd);
%FindSameIndInitial{k} = find([SortInd] >MergeInd(k)-tolerance & [SortInd]<MergeInd(k)+tolerance);
MeanSameIndCurrent(k) = nanmean(SortCurrent(FindSameInd(:,k))); %average MaxCurrent*-1 with same indentation
MeanSameIndCurrentOff(k) = nanmean(SortCurrentOff(FindSameInd(:,k))); %TODO: something wrong
MeanSameIndForce(k) = nanmean(SortForce(FindSameInd(:,k))); %average Force with same Indentation
MeanTraces(k,:) = nanmean(SortASubtract((FindSameInd(1,k)):(FindSameInd(end,k)),:),1); % mean traces in a row vector; problem with mean traces; problem, when inddentation oonly ones
MeanTracesIndentation(k,:) = nanmean(SortMeanIndentation((FindSameInd(1,k)):(FindSameInd(end,k)),:),1);
%MeanNormSameIndCurrent
end
MeanTracesIndentation = MeanTracesIndentation'
else
    disp 'Ramp Round and Sort';
   % RoundMeanInd = round(Velocity,1);   
[SortVel sorted_index] = sort(Velocity); % get index of mean Velocity
SortCurrent = AvgMaxCurrentMinusNew(sorted_index);
SortIndentation = MeanIndentation(sorted_index);
%SortNormCurrent = AverageMaxCurrentMinusNew(sorted_index); % Do I need this; yes, normalized to Off Response
SortForce = MeanForce(sorted_index);
transAsub = ASubtractNew';
SortASubtract = transAsub(sorted_index,:);
%SortASubtract = SortASubtract'; keep it as row, easier to calculate
MergeVel = [];
SortVel = SortVel';
MergeVel = builtin('_mergesimpts',SortVel,10,'average');%'average'); %%% TODO: does not work merged Velocity values with +/- 0.1 distance
tolerance = 10; % tolerance to group velocity
%TODo: find best value for velocity merge
k =[];
[~,FRow] = mode(SortVel); % TODO: does not work for Velocity gets the Frequency of the most frequent value
FindSameInd= NaN(10,length(MergeVel)); % determine row length with highest probability of most frequent value
%ToDo: changeValue: currently hardcoded.
if size(Aall,2) ~=5% > 5 %ToDo: change, it is not working, if single ramp is equal 5
FindSameIndInitial = {};
for k = 1:length(MergeVel);
FindSameIndInitial{k} = find([SortVel] >MergeVel(k)-tolerance & [SortVel]<MergeVel(k)+tolerance);
end

FindSameIndNaN = padcat(FindSameIndInitial{:});
FindSameInd = FindSameIndNaN;


for i = 1:length(MergeVel);
[r,c] = find(isnan(FindSameInd(:,i))); % fails, if only one Block of recording; include it into if statement for this reason
while sum(isnan(FindSameInd(:,i)))>0
FindSameInd(r,i) =FindSameInd(r-1,i);
end
end


else %% if only one FiveStepProtcol was applied
    FindSameInd = [];
    for k = 1:length(MergeVel);
FindSameInd(:,k) = find([SortVel] >MergeVel(k)-tolerance & [SortVel]<MergeVel(k)+tolerance);
    end   
end

%FindLogicalNumberOfTraces = FindLogicalNumberOfTraces'
%NumberTracesPerInd = NumberTracesPerInd'
for k = 1:length(MergeVel);
%FindSameIndInitial{k} = find([SortInd] >MergeInd(k)-tolerance & [SortInd]<MergeInd(k)+tolerance);
MeanSameIndCurrent(k) = nanmean(SortCurrent(FindSameInd(:,k))); %average MaxCurrent*-1 with same indentation
MeanSameIndForce(k) = nanmean(SortForce(FindSameInd(:,k))); %average Force with same Indentation
MeanTraces(k,:) = nanmean(SortASubtract((FindSameInd(1,k)):(FindSameInd(end,k)),:),1); % mean traces in a row vector; problem with mean traces; problem, when inddentation oonly ones
MeanSameVelIndentation(k) = nanmean(SortIndentation(FindSameInd(:,k)));
end
end

%%%% maybe useful for later
% problem with not existing NaN values in FindSameInd
% FindSameIndValues = NaN(5,17); %size FindSameInd
% FindSameIndCurrent = NaN(5,17);
%     for k = 1:numel(FindSameInd);
% FindSameIndValues(k)= SortInd(FindSameInd(k)); %) >MergeInd(k)-tolerance & SortInd<MergeInd(k)+tolerance;
% FindSameIndCurrent(k) = AvgMaxCurrentMinusNew(FindSameInd(k));
%     end   
%     

%TODO: MeanTraces: first 30 values NAN; why
%ToDo: MeanSameIndCurrent for off current

NormMeanCurrent=[];
MeanTraces = MeanTraces'; % transpose to column vector for export to igor

MeanSameIndCurrent = MeanSameIndCurrent';
MeanSameIndForce = MeanSameIndForce';
MeanTracesppA = MeanTraces*10^12; % to get current in pA
NormMeanCurrent = MeanSameIndCurrent/max(MeanSameIndCurrent); % normalize by fit values

if isFiveStep == 1 || isStep == 1;
    disp 'step has no velocity calulation yet - maybe make it'
else
MeanSameVelIndentation = MeanSameVelIndentation';
end


% include here calculation of 
% FindLogicalNumberOfTraces = isnan(FindSameInd) == 0;
% TracesPerIndentation = sum(FindLogicalNumberOfTraces);
% TracesPerIndentation = TracesPerIndentation';
%missing calculation for numer of traces for only one block

figure()
plot(Time, MeanTracesppA) % plot Current in pA
%xlim([0 0.6])

ylabel('Current (pA)')
xlabel('Time')
title((name))

% move export Data to the bottom.... 


%%
%%%% Figure Summary Analysis

xScatter = (1:length(MeanIndentation));
figure()
subplot(3,2,1)
scatter(xScatter, LeakAppA) 
title('control: Leak Current')
ylabel('Current (pA)')
xlabel('number of file (in recorded order)')


hold on 
subplot(3,2,2)
if isFiveStep == 1 || isFiveRamp == 1;
    i = 1;
while i <= length(MeanIndentation)
scatter(MeanIndentation(i:i+4), AverageMaxCurrentMinusppA(i:i+4),'LineWidth',2)%,'filled') %% would be nice to see the change in leak
%set(h, 'SizeData', markerWidth^2)
hold on
i = i+5;
title('Mean Cur vs Ind')
xlim([0 max(MeanIndentation)+1])
ylabel('Current (pA)')
xlabel('Indentation (um)')
%hold on 
% for j = 1:size(Aall,2)/5
% %legend(Files(j))  % include legend again
% end
end
else
scatter(MeanIndentation, AverageMaxCurrentMinusppA,'LineWidth',2)
title('Mean Cur vs Ind')
xlim([0 max(MeanIndentation)+1])
ylabel('Current (pA)')
xlabel('Indentation (um)')
end

hold on 

subplot(3,2,3)
scatter(xScatter, Start) 
%ylim([100 1000]) % ToDo: change it for Ramps
ylabel('Point')
xlabel('Filenumber')
title('control: Find OnSet of Stimulus')
hold on 
subplot(3,2,3)
scatter(xScatter, StartOffBelow) %change to start of below
%ylim([100 1000]) % ToDo: change it for Ramps
ylabel('Point')
xlabel('Filenumber')
title('control: Find OnSet of Stimulus')
hold on 
subplot(3,2,4)
if isFiveStep == 1 || isFiveRamp == 1;
    i = 1;
while i <= length(MeanIndentation)
scatter(Velociy(i:i+4), AverageMaxCurrentMinusppA(i:i+4),'LineWidth',2)%,'filled') %% would be nice to see the change in leak
%set(h, 'SizeData', markerWidth^2)
hold on
i = i+5;
title('Mean Cur vs Vel')
xlim([0 max(MeanIndentation)+1])
ylabel('Current (pA)')
xlabel('Velocity(um/s)')
%hold on 
% for j = 1:size(Aall,2)/5
% %legend(Files(j))  % include legend again
% end
end
else
scatter(Velocity, AverageMaxCurrentMinusppA,'LineWidth',2)
title('Mean Cur vs Ind')
%xlim([0 max(MeanIndentation)+1])
ylabel('Current (pA)')
xlabel('Velocity(um/s)')
end
%xlabel('Velocity')
%title('control: Current over time')
% hold on
% xscatterMergeInd = length(MergeInd)
% 
% set(p1,'markerfacecolor','r')
% set(p2,'markerfacecolor','g')
%ylim([100 1000]) % ToDo: change it for Ramps
% ylabel('Current (pA)')
hold on
xlabels{1} = 'Velocity (um/s)';
xlabels{2} = '';
ylabels{1} = 'Current (pA)';
ylabels{2} = 'Ind (um)';
subplot(3,2,5)
[ax,hl1,hl2] = plotxx(Velocity,AverageMaxCurrentMinusppA,Velocity,MeanIndentation,xlabels,ylabels)



%%%% maybe useful later
% figure()
% %subplot(3,2,5)
% i = 1
% while i <= length(MergeInd)
% scatter(FindSameIndValues(:,i), FindSameIndCurrent(:,i),'LineWidth',2)
% hold on
% i = i+1;
% end


%%
hold on 
subplot(3,2,4)
plot(Time,ASubtractppA)
%xlim([0 max(MeanIndentation)+1])
ylabel('Current (pA)')
xlabel('Time (s)')
title('Current')

%%% plotting ForceClamp signals in a subplot
allRiseTimeInms = allRiseTime*1000;

figure()
subplot(3,3,1)
plot(Time,CantiDefl)
%xlim([0 0.6])
xlabel('Time (s)')
title('Cantilever Deflection')
ylabel('Deflection (�m)')
hold on
subplot(3,3,2)
plot(Time,Indentation)
%xlim([0 0.6])
xlabel('Time (s)')
ylabel('Indentation (�m)')
title('Indentation')

hold on
subplot(3,3,3)
plot(Time,Force)
xlim([0 0.6])
xlabel('Time (s)')
ylabel('Force (�N)')
title('Force')
hold on
subplot(3,3,4)
plot(Time,ActuSetPoint)
%xlim([0 0.6])
xlabel('Time (s)')
ylabel('Displacement (�m)')
title('Displacement ActuSetPoint')
hold on
subplot(3,3,5)
plot(Time,ActuSensor)
%xlim([0 0.6])
xlabel('Time (s)')
ylabel('Displacement (�m)')
title('Displacement ActuSensor')
hold on
subplot(3,3,6)
plot(Time,normCantiDefl)
%xlim([0 0.6])
xlabel('Time (s)')
ylabel('normalized Deflection')
title('Cantilever Defl norm')
hold on
subplot(3,3,7)
scatter(MeanIndentation, allRiseTimeInms)  
%xlim([0 0.3])
title('RiseTime (CantiDefl)')
ylabel('Rise Time Tau (ms)')
xlabel('Indentation')
xlim([0 max(MeanIndentation)+1])
 hold on
 subplot(3,3,8)
 scatter(MeanIndentation, allOvershoot)  
 %xlim([0 max(MeanIndentation)+1])
 ylabel('% to steady state')
 xlabel('Indentation (�m)')
 title('Overshoot (CantiDefl)')
hold on 
subplot(3,3,9)
i = 1;
while i <= length(MeanIndentation)
scatter(MeanIndentation(i:i+4), MeanForce(i:i+4),'LineWidth',2)%,'filled') %% would be nice to see the change in leak
%set(h, 'SizeData', markerWidth^2)
hold on
i = i+5;
title('Mean Force vs Ind')
xlim([0 max(MeanIndentation)+1])
ylabel('Force (�N)')
xlabel('Indentation (�m)')
hold on 
for j = 1:size(Aall,2)/5
%legend(Files(j))  % include legend again
end
end




%%
%%% 

%rToDo: MergeIndRow = num2str(MergeIndRow);%how to write each Indentation as col header???

%Export Data
if isFiveStep == 1 || isStep == 1; 

% ToDo change for Current ExportData = [MergeInd,MeanSameIndCurrent,NormMeanCurrent,MeanSameIndForce];
MeanIndentationVer=MeanIndentation';
MeanForceVer=MeanForce';

ExportMeanSameIndDataMechanics = [MergeInd,MeanSameIndForce];
ExportMeanDataMechanics = [MeanIndentationVer,MeanForceVer];

else
ExportData = [MergeVel,MeanSameVelIndentation,MeanSameIndCurrent,NormMeanCurrent,MeanSameIndForce];  %MeanSameIndCurrent means here: current at same velocities
end

%%% write Matlabvariables
if isFiveStep == 1 || isStep == 1;
save(sprintf('Step-%s.mat',name)); %save(sprintf('%sTEST.mat',name))
else
save(sprintf('Ramp-%s.mat',name));
end

%%%ToDO: include if RampHold, save RampSTF00X, if Step, StepXXX, otherwise,
%%%it overwrites the analysis

%%% write as csv, because cannot write with mac to excel

if isFiveStep == 1 || isStep == 1;
    %disp 'csv save file has to be written'
   % MergeIndRow = MergeInd';

%save Means of same indentation in csv file
filename = sprintf('StepSameInd-%s.csv',name) ;
fid = fopen(filename, 'w');
%ExportData = [MergeVel,SortIndentation,MeanSameIndCurrent,NormMeanCurrent,MeanSameIndForce]
fprintf(fid, 'MergeInd-%s, MeanSameIndForce-%s \n',name,name); %, MergeInd,MeanSameIndCurrent, asdasd, ..\n); %\n means start a new line
fclose(fid);
dlmwrite(filename, ExportMeanSameIndDataMechanics, '-append', 'delimiter', '\t'); %Use '\t' to produce tab-delimited files.

%save single Indentation values in separate csv file
filename = sprintf('StepSingleInd-%s.csv',name) ;
fid = fopen(filename, 'w');
fprintf(fid, 'Ind-%s, Force-%s \n',name,name); %, MergeInd,MeanSameIndCurrent, asdasd, ..\n); %\n means start a new line
fclose(fid);
dlmwrite(filename, ExportMeanDataMechanics, '-append', 'delimiter', '\t'); %Use '\t' to produce tab-delimited files.

else
filename = sprintf('Ramp%s.csv',name) ;
fid = fopen(filename, 'w');
% how to include the Filenumber?
%ExportData = [MergeVel,SortIndentation,MeanSameIndCurrent,NormMeanCurrent,MeanSameIndForce]
fprintf(fid, 'MergeVel, Indentation,MeanCurrent, NormMeanCurrent, MeanForce \n'); %, MergeInd,MeanSameIndCurrent, asdasd, ..\n); %\n means start a new line
fclose(fid);
%ExportData = [MergeInd,MeanSameIndCurrent,NormMeanCurrent,MeanSameIndForce,TracesPerIndentation];
dlmwrite(filename, ExportData, '-append', 'delimiter', '\t'); %Use '\t' to produce tab-delimited files.
filename = sprintf('%sTraces.csv',name) ;
fid = fopen(filename, 'w');
%dlmwrite(filename,MergeIndRow,'-append', 'precision', '%.6f','\t')
% how to include the Filenumber?
fprintf(fid,'Ind1, Ind2, Ind3, Ind4, Ind5, Ind6, Ind7, Ind8, Ind9,Ind10,Ind11,Ind12,Ind13,Ind14 \n'); %, MergeInd,MeanSameIndCurrent, asdasd, ..\n); %\n means start a new line
fclose(fid);
dlmwrite(filename, MeanTraces, '-append', 'delimiter', '\t'); %Use '\t' to produce tab-delimited files.
end



%%
% int_cols = all(isnan(MeanIndentationNew)|round(MeanIndentationNew)==MeanIndentationNew,1);
% it = MeanIndentationNew(:,int_cols);
% 
% test = [1   NaN   2.2   3.2  4;
%      NaN 7.9   5.1   NaN  5;
%      3    5.5  NaN   4.1  NaN];
% int_cols = all(isnan(MeanIndentationNew)|round(MeanIndentationNew)==MeanIndentationNew,1);
% it = MeanIndentationNew(:,int_cols);
% flt = MeanIndentationNew(:,~int_cols);

% write excel sheet
% col_header={name,'MeanInd','MeanCurrent','NormMeanCurrent','MeanForce','TracesPerIndentation'};     %Row cell array (for column labels)
% %row_header(1:10,1)={'Time'};     %Column cell array (for row labels)
% xlswrite(name,MergeInd,'Sheet1','B2');     %Write data
% xlswrite(name,MeanSameIndCurrent,'Sheet1','C2');     %Write data
% xlswrite(name,NormMeanCurrent,'Sheet1','D2');     %Write data
% xlswrite(name,MeanSameIndForce,'Sheet1','E2');     %Write data
% xlswrite(name,TracesPerIndentation,'Sheet1','F2'); 
% xlswrite(name,col_header,'Sheet1','A1');     %Write column header
% %xlswrite('My_file.xls',row_header,'Sheet1','A2');      %Write row header
% col_header2={name,'Ind1','Ind2','Ind3','Ind4','Ind5','Ind6','Ind7','Ind8','Ind9','Ind10','Ind11','Ind12','Ind13','Ind14'}; %ToDO - get the values for the
% %Indentations
% xlswrite(name,MeanTraces,'Sheet2', 'B2');   
% xlswrite(name,col_header2,'Sheet2','B1'); 

%find number of nan values to find out the number of averages
%average traces 
%how to average two columns
%  for k = 1:length(MergeInd);
%      for i = 1:length(FindSameInd(:,k));
% % MeanTracesCurrent(:,k) = nanmean(SortASubtract(FindSameInd(:,k)))
% %B(:,nn+1) MeanTracesCurrent = nanmean(SortASubtract(:,1:2))
%      end
%  end




