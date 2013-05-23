function Ap = EnrightPeriodogramMean(X,p)
%Calculates the Enright periodogram on column vector X using range of
%periods given by p. Formulation taken from Philip G. Sokolove adn Wayne N.
%Bushell, Teh Chi Square Periodogram: Its Utility for Analysis of Circadian
%Rythms, J. Theor. Biol. (1978) Vol 72, pp 131-160.

N = length(X);
Ap = [];
for i = 1:length(p)
    P = p(i); % true as long as p is an integer, i.e. no fractional periods (for now)
    %K = ceil(N/p(1));
    K = floor(N/P);
    %Xcyclic = repmat(X,1,ceil(K*P/N));
    %Xsubset = Xcyclic(1:K*P);
    Xsubset = X(1:K*P);
    M = (reshape(Xsubset,P,K))';
    if N/P > K
        partialRow = [(X(K*P+1:end))' mean(M(:,N-K*P+1:P),1)];% fill empty cells with mean taken along 1st dimension
        M = [M;partialRow];
    end
    Xmean = mean(M); % column means
    Xp = mean(Xmean);
    Ap(i) = sqrt(1/P*sum((Xmean-Xp).^2));
end
