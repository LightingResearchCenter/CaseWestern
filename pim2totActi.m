function totActi = pim2totActi(PIM,epoch)
%PIM2TOTACTI Convert PIM to total activity counts
%   epoch = sampling epoch in minutes

% Validate epoch
if ~any(epoch == [.25,.5,1,2])
    error(['Epoch length of ',num2str(epoch),' minutes is invalid please use one of the following options: 0.25, 0.5, 1, or 2']);
end

% Set scaling factors based on epoch
switch epoch
    case .25
        setSize = 4;
        k1 = 4;
        k2 = .2;
        k3 = .04;
    case .5
        setSize = 2;
        k1 = 2;
        k2 = .2;
        k3 = .04;
    case 1
        setSize = 1;
        k1 = 1;
        k2 = .2;
        k3 = .04;
    case 2
        setSize = 1;
        k1 = .5;
        k2 = .12;
        k3 = 0;
    otherwise
        error('Invalid epoch');
end

% make sure PIM is vertical
PIM = PIM(:);
nPIM = numel(PIM);

% group 3 outer values
group3_1 = zeros(nPIM,1);
group3_2 = zeros(nPIM,1);
for i3 = setSize+1:setSize*2
    group3_1 = circshift(PIM,i3) + group3_1;
    group3_2 = circshift(PIM,-i3) + group3_2;
end
group3 = k3*(group3_1 + group3_2);

% group 2 middle values
group2_1 = zeros(nPIM,1);
group2_2 = zeros(nPIM,1);
for i2 = 1:setSize
    group2_1 = circshift(PIM,i2) + group2_1;
    group2_2 = circshift(PIM,-i2) + group2_2;
end
group2 = k2*(group2_1 + group2_2);

% group 1 center/inner value
group1 = k1*PIM;

% Total activity counts
totActi = group1 + group2 + group3;

end

