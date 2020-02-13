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
wholeFolder = wholeFolder(~ismember({wholeFolder.name},{'.','..'}));

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
     if contains(wholeFolderCell(1,i),experiment1)
         files = dir([wholeFolderCell{2,i},filesep,wholeFolderCell{1,i}]);
         files = files(~ismember({files.name},{'.','..'}));
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
 
 
 
 
 
 
