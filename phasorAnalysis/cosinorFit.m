function [M,A,phi] = cosinorFit( Time, Value, Freq, n)
%time is the timestamps in days
%value is the set of values you're fitting
%Freq is the frequency in 1/days
%n is the order of the fit

A = zeros(1, n);
phi = zeros(1, n);

C = zeros(2*n + 1, 2*n + 1);
D = zeros(1, 2*n + 1);

% preallocate variables
m = length(Time);
omega = zeros(1, n);
xj = zeros(m,n);
zj = zeros(m,n);
for i = 1:n
    omega(i) = 2*i*pi*Freq;
    xj(:,i) = cos(omega(i)*Time);
    zj(:,i) = sin(omega(i)*Time);
end

yj = zeros(size(xj));
for i = 2:2:2*n
    yj(:,i - 1) = xj(:,i/2);
    yj(:,i) = zj(:,i/2);
end

num = length(Time);

C(1, 1) = num;
for j = 2:2:2*n
    C(1, j) = sum(xj(:,j/2));
    C(j, 1) = sum(xj(:,j/2));
    C(1, j + 1) = sum(zj(:,j/2));
    C(j + 1, 1) = sum(zj(:,j/2));
end

for i = 2:2*n + 1
    for j = 2:2*n + 1
        C(i, j) = sum(yj(:,(i - 1)).*yj(:,(j - 1)));
    end
end

D(1) = sum(Value);
for i = 2:2*n + 1
    D(i) = sum(yj(:,(i - 1)).*(Value));
end

D = D';

x = C\D;

M = x(1);

for i = 1:n
    A(i) = sqrt(x(2*i)^2 + (x(2*i + 1)^2));
    phi(i) = -atan2(x(2*i + 1), x(2*i));
end


