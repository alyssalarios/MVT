%% Load all data from all monkeys, clean, and reshape data for analysis

%% CREATE STRUCT WITH FIELDS = EXPERIMENTS AND ROWS = MONKEY IDENTITY 
%each monkey-experiment cell contains a struct with data from all sessions
%single field in that struct 'Task' represents one session
%length of dataMaster(x).experiment is number of sessions that monkey has
%with an experiment
%------------------------------------------------------------------------
%specify experiment 
experiment1 = '_depl';

%pull data from dropbox 
%folder should contain files in format monkeyName_experimentType
masterFilePath = uigetdir('','Select file');
wholeFolder = dir(masterFilePath);
wholeFolder = wholeFolder(~ismember({wholeFolder.name},{'.','..','.DS_Store'}));

%make struct for master datasheet separated by monkey
dataMaster = struct;
for i = 1:length(wholeFolder)
    if contains(wholeFolder(i).name,experiment1)
        dataMaster(i).monkey = wholeFolder(i).name(1:end-length(experiment1));
    end
end

%make structure with all data from each monkey in experiment1
 wholeFolderCell = struct2cell(wholeFolder);
 for i = 1:size(wholeFolderCell,2)
     if contains(wholeFolderCell{1,i},experiment1)
         files = dir([wholeFolderCell{2,i},filesep,wholeFolderCell{1,i}]);
         files = files(~ismember({files.name},{'.','..','.DS_Store'}));
     else
         continue
     end
     for j = 1:length(files)
         matFilePath = [files(j).folder,filesep,files(j).name];
         Data(j) = load(matFilePath,'Task');
     end
     dataMaster(i).Depletion = Data;
     clear Data
 end

 %% EXPLORING PARAMETER CONSISTENCY 
 % make compiled lists of Data.dispenser, task_params (2), 
 % and reward_params
 %-----------------------------------------------------------------------
 %TASK PARAMS
 %gives taskParamsCompiled information about task parameters
 %across all sessions with all monkeys
 %errorCoords gives which monkeys/sessions are missing this data i =
 %Monkey (1 = Darwin, 2 = Drogo, 3 = Izzy, 4 = Tigger), J = session #
 
 fieldNames = fieldnames(dataMaster(1).Depletion(1).Task.task_params)';
 fieldNames{2,1} = {};
 taskParamsCompiled = struct(fieldNames{:});
 errorCoords = [];
for i = 1:length(dataMaster)
        for j = 1:length(dataMaster(i).Depletion)
            if isfield(dataMaster(i).Depletion(j).Task,'task_params')
            taskParamsCompiled = [taskParamsCompiled,dataMaster(i).Depletion(j).Task.task_params];
            
            else 
                errorCoords = [errorCoords;i,j];
            end
        end
end

 %REWARD PARAMS
 %gives rewardParamsCompiled: information about task parameters
 %across all sessions with all monkeys
 %errorCoords gives which monkeys/sessions are missing this data i =
 %Monkey (1 = Darwin, 2 = Drogo, 3 = Izzy, 4 = Tigger), J = session #

 fieldNames = fieldnames(dataMaster(1).Depletion(1).Task.reward_params)';
 fieldNames{2,1} = {};
 rewardParamsCompiled = struct(fieldNames{:});
 errorCoords = [];
for i = 1:length(dataMaster)
        for j = 1:length(dataMaster(i).Depletion)
            if isfield(dataMaster(i).Depletion(j).Task,'reward_params')
            rewardParamsCompiled = [rewardParamsCompiled,dataMaster(i).Depletion(j).Task.reward_params];
            
            else
                errorCoords = [errorCoords;i,j];
            end
        end
end

 %% SUMMARY OF ALL SESSIONS
 % n x m x 4 cell array - each z stack is a monkey, rows are sessions and
 % columns are variables

 %set column titles for summary array
 columnNames = {'TotalRewards','SessionDuration','SampleRate'};
 summaryAll = cell(max(numSesh),length(columnNames),4);
 for i = 1:length(columnNames)
     summaryAll(1,i,:) = columnNames(i);
 end
 
 hoursCol = 4;
 minsCol = 5;
 secsCol = 6;
 
 %count number of total trials for each session
 numSesh = zeros(1,length(dataMaster));
 for i = 1:length(dataMaster)
     numSesh(i) = length(dataMaster(i).Depletion);
 end

 
 %get index i and j 
  for i = 1:length(dataMaster)
      for j = 1:length(dataMaster(i).Depletion)
          rewardCount = 0;
          
          % add counters from each dispenser k 
          for k = 1:length(dataMaster(i).Depletion(j).Task.Data.dispenser)
              if isempty(dataMaster(i).Depletion(j).Task.Data.dispenser{1,k})
                  continue
              end
              rewardCount = rewardCount + dataMaster(i).Depletion(j).Task. ...
                  Data.dispenser{1,k}.Reward_counter;
          end
          
          %remove first row of IR status - sample rate not consistent
          dataMaster(i).Depletion(j).Task.Data.IRstatus(1,:) =[];
          
          %calculate duration of each session
          %correct for column order if not consistent amongst sessions 
          %hard coded columns 4-6 hours/minutes/seconds in some sessions
          %some sessions have IR status as columns 1:4 
          if length(unique(dataMaster(i).Depletion(j).Task.Data.IRstatus(:,minsCol))) == 1
              %correct for inconsistent order
              dataMaster(i).Depletion(j).Task.Data.IRstatus(:,end+1:end+hoursCol) = ...
                  dataMaster(i).Depletion(j).Task.Data.IRstatus(:,1:hoursCol);
              dataMaster(i).Depletion(j).Task.Data.IRstatus(:,1:hoursCol) = [];
          end
          
          if dataMaster(i).Depletion(j).Task.Data.IRstatus(1,hoursCol) == ...
                dataMaster(i).Depletion(j).Task.Data.IRstatus(end,hoursCol)
            minuteCount = (dataMaster(i).Depletion(j).Task.Data.IRstatus(end,minsCol) ...
                - dataMaster(i).Depletion(j).Task.Data.IRstatus(1,minsCol)) ...
                + (dataMaster(i).Depletion(j).Task.Data.IRstatus(end,secsCol) ...
                - dataMaster(i).Depletion(j).Task.Data.IRstatus(1,secsCol)) / 60;
          
          else 
              minuteCount = dataMaster(i).Depletion(j).Task.Data.IRstatus(end,minsCol) ...
                  + dataMaster(i).Depletion(j).Task.Data.IRstatus(end,secsCol) / 60 ...
                  + 60 - dataMaster(i).Depletion(j).Task.Data.IRstatus(1,minsCol) ...
                  + (60 - dataMaster(i).Depletion(j).Task.Data.IRstatus(1,secsCol)) / 60;
          end
          %calculate sample rate 
          %based on number of IRstatus data points
          %hits / minute
          sampleRate = length(dataMaster(i).Depletion(j).Task.Data.IRstatus) / minuteCount;
          
          %add parameters to apropriate summary column 
          summaryAll{j+1,1,i} = rewardCount;
          summaryAll{j+1,2,i} = minuteCount;
          summaryAll{j+1,3,i} = sampleRate;
      end
  end
 
 
 
 
 
 
 
 
