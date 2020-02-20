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
monkeyColors = [{'blue'},{'red'},{'green'},{'magenta'}];
subplot(1,2,1);
b = bar(avPercentHits);
set(gca,'XTickLabel',dispensers);
for i = 1:length(monkeyColors)
    b(i).FaceColor = monkeyColors{i}
end
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

%% Calculate remaining rewards at dispenser switch 

% dispenser IDs for IRstatus sheet : 7,8,9,10 corresponds to box 1,2,3,4 
% add column to dataFiltered that describes which dispenser is opened/
% closed
% this is last column on datasheet
firstDispenser = 7;
for i = 1:length(dataFiltered)
    for j = 1:length(dataFiltered(i).Depletion)
    session = dataFiltered(i).Depletion(j).Task.Data.IRstatus(:,firstDispenser:end);
    dispenserNum = zeros(length(session),1);
    for k = 1:length(session)
        x = find(session(k,:)==1); %this finds what column an IR trigger occured
        if k == 1
            dispenserNum(k,1) = find(session(k,:),1,'first');
        elseif ~isempty(x) %if an IR trigger did occur, write down in a separate variable what dispenser it occured at (ex. [2 2 4 0 4 4 2]
            dispenserNum(k,1) = find(session(k,:),1,'first');
        else 
            dispenserNum(k,1) = - dispenserNum(k-1,1); %negative values = remove hand from apropriate dispenser
        end
    end
    dataFiltered(i).Depletion(j).Task.Data.IRstatus(:,end+1) = dispenserNum;
    dataFiltered(i).Depletion(j).Task.Data.IRstatus(1,end+1) = 0;
      dataFiltered(i).Depletion(j).Task.Data.IRstatus(2:end,end) = diff(abs(dispenserNum));
     
    end
end
%% 
% count aveg number of switches
avgSwitchAll = zeros(1,length(dataFiltered));
for i = 1:length(dataFiltered)
    for j = 1:length(dataFiltered(i).Depletion)
        session = dataFiltered(i).Depletion(j).Task.Data.IRstatus(:,12);
        counter = 0;
        sameDispenser = [];
        for k = 1:length(session)
            if session(k) == 0
                counter = counter + 1;
            elseif session(k) ~= 0
                sameDispenser = [sameDispenser;ceil(counter/2)];
                counter = 0;
            end
        end
        repeatSwitches(j,:,i) = [mean(sameDispenser),sum(abs(session(:,end))>0)];
    end
end

%plot number of trials by switches per monkey 
%Tigger skews data, plot repeatSwitches(:,:,3) to see distribution
subplot(1,2,2);
for i = 1:size(repeatSwitches,3)
scatter(repeatSwitches(:,1,i),repeatSwitches(:,2,i),monkeyColors{i},'filled');
    hold on 
end
legend(dataFiltered.monkey)
title('IR breaks v. # switches')
xlabel('avg IR breaks before switching')
ylabel('number of switches per session')

%% add column to datasheet that is logical reward IR break or not 
IRCombined = struct;
dispLogComb = struct;
for i = 1:length(dataFiltered)
        IRCombined(i).monkey = dataFiltered(i).monkey;
        dispLogComb(i).monkey = dataFiltered(i).monkey;
        IRCombined(i).IRdata = [];
        dispLogComb(i).Log = [];
        for j = 1:length(dataFiltered(i).Depletion) 
            %check isfield(struct,'log') before iterating through, if not,
            %add dataMaster(3).Depletion(i).Task.dispLog to dispLogComb
            IRCombined(i).IRdata = [IRCombined(i).IRdata;dataFiltered(i).Depletion(j).Task.Data.IRstatus];
            logArray = [];
            for k = 1:4
                if ~isempty(dataFiltered(i).Depletion(j).Task.Data.dispenser{1,k})
                    logArray = [logArray;table2array(dataFiltered(i).Depletion(j).Task.Data.dispenser{1,k}.log)];
           
                end
            end
            dispLogComb(i).Log = logArray
        end
  end

%% function to call master data and summary data
function data = masterLoad()
    monkey_data_cleaning
    data = dataFiltered;
end
function summary = summaryLoad()
    monkey_data_cleaning
    summary = summaryFil;
end