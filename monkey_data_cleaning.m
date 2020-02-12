%%create struct with monkeys as fields that contain each session 

%specify experiment 
experiment = '_depl';
slash = '\';

%pull data from dropbox 
%folder should contain files in format monkeyName_experimentType
masterFilePath = uigetdir('','Select file');
wholeFolder = dir(masterFilePath);
wholeFolder = wholeFolder(~ismember({wholeFolder.name},{'.','..'}));

%make struct for master datasheet separated by monkey
dataMaster = struct;
for i = 1:length(wholeFolder)
    if contains(wholeFolder(i).name,experiment)
        dataMaster(i).monkey = wholeFolder(i).name(1:end-length(experiment));
    end
end

%make structure with data from all sessions with 1 monkey
wholeFolderCell = struct2cell(wholeFolder);
for i = 1:size(wholeFolderCell,2)
    if contains(wholeFolderCell(1,i),'depl')
        files = dir([wholeFolderCell{2,i},slash,wholeFolderCell{1,i}]);
        files = files(~ismember({files.name},{'.','..'}));
    end
    cd(files(1).folder)
    for j = 1:length(files)
        
        Data(j).session = 
end
        
