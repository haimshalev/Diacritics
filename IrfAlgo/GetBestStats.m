function [statsMask, higherstats, lowerstats] = GetBestStats(stats, stdCoeff)

    higherstats = stats - (0.5 + (stdCoeff .* std(stats(stats~=0))));
    higherstats(higherstats <= 0) = 0;

    lowerstats = (0.5 - (stdCoeff .* std(stats(stats~=0)))) - stats;
    lowerstats(lowerstats <= 0) = 0;
    lowerstats(stats == 0) = 0;

    statsMask = higherstats ~= 0 | lowerstats ~= 0;

end