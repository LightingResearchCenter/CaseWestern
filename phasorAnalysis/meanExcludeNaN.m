function MEAN = meanExcludeNaN(A)
%MEANEXCLUDENAN Removes Nan elements before taking mean

B = A(~isnan(A));
MEAN = mean(B);
end

