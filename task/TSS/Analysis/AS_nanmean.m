function nmean = AS_nanmean(arr1)

nmean = mean(arr1(find(~isnan(arr1))));


return