%% Filter and explore depletion data 
%load all Data
dataMaster = masterLoad();
summaryMaster = summaryLoad();
%% Filter experiments with different reward parameters
% reward params for Darwin session 1 is not consistent with others
dataFiltered = dataMaster;
summaryFil = summaryMaster;
dataFiltered(1).Depletion(1) = [];

%filter out sessions with 22 or fewer rewards
rewardThresh = 22;
timeThresh = 20;
for i = 1:length(dataFiltered)
        lowHits = find(cell2mat(summaryMaster(2:end,1,i)) <= rewardThresh | ...
            cell2mat(summaryMaster(2:end,2,i)) <= timeThresh);
        dataFiltered(i).Depletion(lowHits) = [];
        for j = 1:length(lowHits)
            summaryFil{lowHits(j)+1,3,i} = 'filtered';
        end
end

%% distribution between dispensers
dispensers = categorical({'1','2','3','4'});
%count dispenser hits
dispenserHits = [];
for i = 1:length(dataFiltered)
    for j = 1:length(dataFiltered(i).Depletion)
        dispenserHits(j,:,i) = sum(dataFiltered(i).Depletion(j).Task.Data.IRstatus(:,7:10));
    end
end

%make matrix w average hits per dispenser per monkey
avPercentHits = zeros(4,4);
SEMs = zeros(4,4);
for i = 1:length(dataFiltered)
    totalHits = sum(dispenserHits(:,:,i),2);
    percentHits = dispenserHits(:,:,i) ./ totalHits;
    for j = 1:4
        if any(dispenserHits(:,j,i))
            avPercentHits(j,i) = nanmean(percentHits(:,j));
            SEMs(j,i) = nanstd(percentHits(:,j))/sqrt(length(percentHits(:,j)));
        end
    end
end
   
        
%% function to call master data and summary data
function data = masterLoad()
    monkey_data_cleaning
    data = dataMaster;
end
function summary = summaryLoad()
    monkey_data_cleaning
    summary = summaryAll;
end