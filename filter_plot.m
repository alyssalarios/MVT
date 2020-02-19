%% explore depletion data 
%load filtered Data
dataFiltered = masterLoad();
summaryFil = summaryLoad();
%% distribution between dispensers
dispensers = categorical({'1','2','3','4'});
%count dispenser hits
dispenserHits = [];
for i = 1:length(dataFiltered)
    for j = 1:length(dataFiltered(i).Depletion)
        dispenserHits(j,:,i) = sum(dataFiltered(i).Depletion(j).Task.Data.IRstatus(:,7:10));
    end
end

%make matrix w average percent hits per session +SEM
avPercentHits = zeros(4,4);
SEMs = zeros(4,4);
for i = 1:length(dataFiltered)
    totalHits = sum(dispenserHits(:,:,i),2);
    percentHits = dispenserHits(:,:,i) ./ totalHits;
    for j = 1:4
        if any(dispenserHits(:,j,i))
            avPercentHits(j,i) = nanmean(percentHits(:,j));
            SEMs(j,i) = std(percentHits(~isnan(percentHits(:,j)),j)) ...
            ./sqrt(length(percentHits(~isnan(percentHits(:,j)),j)));
        end
    end
end

%plot dispenser distributions
b = bar(avPercentHits);
set (gca,'XTickLabel',dispensers);
hold on 

ax1 = [0.75 1.75 2.75 3.75];
er1 = errorbar(ax1,avPercentHits(:,1),SEMs(:,1));
er1.Color = [0 0 0];
er1.LineStyle = 'none';

ax2 = [0.95 1.95 2.95 3.95];
er2 = errorbar(ax2,avPercentHits(:,2),SEMs(:,2));
er2.Color = [0 0 0];
er2.LineStyle = 'none';

ax3 = [1.1 2.1 3.1 4.1];
er3 = errorbar(ax3,avPercentHits(:,3),SEMs(:,3));
er3.Color = [0 0 0];
er3.LineStyle = 'none';

ax4 = [1.25 2.25 3.25 4.25];
er4 = errorbar(ax4,avPercentHits(:,4),SEMs(:,4));
er4.Color = [0 0 0];
er4.LineStyle = 'none';
legend(b,dataFiltered.monkey)
title('Dispenser Preferences')
xlabel('Dispenser')
ylabel('mean Percent of total breaks per session')

%% 
%% Calculate remaining rewards at dispenser switch 
% switch_tracker = zeros(length(dispensers),1);
% for i = 1:length(dispensers)
%     x = find(dispensers(i,:)==1); %this finds what column an IR trigger occured
%     if ~isempty(x) %if an IR trigger did occur, write down in a separate variable what dispenser it occured at (ex. [2 2 4 0 4 4 2]
%         switch_tracker(i,1) = find(dispensers(i,:)==1);
%     else
%     end
% end

%% function to call master data and summary data
function data = masterLoad()
    monkey_data_cleaning
    data = dataFiltered;
end
function summary = summaryLoad()
    monkey_data_cleaning
    summary = summaryFil;
end