clc
clear
%% constnats
lengthOfIRF = 5;
baseline = 100;
useTrend = true;
%% Set the condition IRFs

% condition 1
realIRFs(1,:) = [0 5 7 10 2];
realIRFs(2,:) = [0 10 6 4 3];

numOfConditions = size(realIRFs, 1);
realIRFs = reshape(realIRFs', [1, lengthOfIRF, numOfConditions]);

%% set the stimulus function
stim_func(1,:) = [0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0];
stim_func(2,:) = [0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0];

f = zeros(1, size(stim_func,2)); 
for testedCondition = 1: numOfConditions
    f = f + testedCondition .* stim_func(testedCondition, :);
end

%% convolve the stimuluts function with the IRF
y = zeros(size(f));

for testedCondition = 1: numOfConditions
    convolved = conv(double(f == testedCondition), realIRFs(:,:,testedCondition));
    y = y + convolved(1: length(f));
end

%% add baseline
y = y + baseline;

%% add trend
if (useTrend == true)
    y = y + (0 : length(f) - 1);
end

%% plot the result
y

%% add white gauusian noise

percent=.08;

noise = zeros(size(y));
noiseY = zeros(size(y));
for i=1 :length(y)
       val = y(i);
       smallPerc = val * percent ; % 1 percent noise add
       noise(i) = smallPerc * [ rand(1) - 0.5 ]; % .*T
       noiseY(i) = val + noise(i) ; % small is very small 10e-9
end

 
%plotting commands
 
subplot(3,1,1);
plot(y);
title('Input Signal');
 
subplot(3,1,2);
plot(noise);
title('Generated Noise');
 
subplot(3,1,3);
plot(noiseY);
title(['Signal + Noise for noisePercent= ',num2str(percent)]);

%% test classification

classificationVec = ClassifyTestData(noiseY, f, realIRFs);

% try to choose the best classification for ech trial base on the
% similarity measument

%{
figure
for targetCondition = 1: numOfConditions
    for trialIdx = find(stim_func(targetCondition,:))
        
        testResponse = noiseY(trialIdx : trialIdx + lengthOfIRF - 1)
        
        % use cross correlation to check which condition best fit to the
        % tested respond
        chosencondition = -1;
        bestCrossCorreleation = -1;
        for condition = 1 : numOfConditions
            
            
            disp(['IRF ' num2str(condition) ' is :']);
            IRF = realIRFs(condition,:);
            
            % get the correleation vec
            corrVec = xcorr(testResponse,IRF,'coeff');
            subplot(numOfConditions,1,condition);            
            plot(corrVec);
            title(['condition ' num2str(condition) ' max value ' num2str(max(corrVec))]);
            
            %N = lengthOfIRF + lengthOfIRF - 1;
            %crossCorrelation = ifft(fft(testResponse,N) * conj(fft(IRF,N))');
            
            crossCorrelation = max(corrVec);
            if (crossCorrelation > bestCrossCorreleation)
                chosencondition = condition;
                bestCrossCorreleation = crossCorrelation;
            end
        end
        
              
        disp(['chosen condition : ' num2str(chosencondition) ' for target ' num2str(targetCondition)]);
        waitforbuttonpress
    end
end
%}