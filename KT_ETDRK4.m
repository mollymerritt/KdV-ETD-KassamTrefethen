% KT_ETDRK4.m
%
% Exponential time differencing method for solving the KdV equation given
% by Kassam & Trefethen (2005) using ETDRK4 scheme
%
% Uses numerical solution if input is 'numerical'
% Uses exact solution if input is 'exact'
%
% u_t = (1/6) * epsilon * u_xxx - (F-1) * u_x + (3/2) * alpha * u * u_x


function [u_numerical, u_exact] = KT_ETDRK4(h, N)

% Spatial grid:
nplots = 50;
%N = 128;
Left = 50;
dx = 2*Left/N;
nu = 1;
xi = 0.5;
x = ((dx-Left):dx:Left)';

% Precompute various ETDRK4 scalar quantities:
%h = 1/4; % time step
k = [0:N/2 -N/2+1:-1]'*(pi/Left); % wave numbers
alpha = 1;
epsilon = 1;
F = 1;
L = -1i*(k.^3).*(epsilon/6)-1i*k*(F-1); % linear operator
E = exp(h*L); E2 = exp(h*L/2);
M = 16; % no. of points for complex means
r = exp(1i*pi*((1:M)-.5)/M); % roots of unity
LR = h*L(:,ones(M,1)) + r(ones(N,1),:);
Q = h*real(mean( (exp(LR/2)-1)./LR ,2));
f1 = h*real(mean( (-4-LR+exp(LR).*(4-3*LR+LR.^2))./LR.^3 ,2));
f2 = h*real(mean( (2+LR+exp(LR).*(-2+LR))./LR.^3 ,2));
f3 = h*real(mean( (-4-3*LR-LR.^2+exp(LR).*(4-LR))./LR.^3 ,2));

aa = .5;
t = 0;
U = F - 1 - (1/2)*alpha*aa;

% Main time-stepping loop:
tmax = 150; nmax = round(tmax/h); nplt = floor((tmax/100)/h)*2;
uu = zeros(nmax/nplt,N);

u_exact = zeros(nmax/nplt,N);
u_exact(1,:) = aa * sech( (((-3/2)*alpha*aa/(-2*epsilon))^(1/2)) * (x-U*t) ).^2; % exact solution
u = u_exact(1,:)';
u_hat = fft(u);

% tdata = h:h:tmax;
tdata = linspace(h,tmax,50);
g = 1i*k*(3/4)*alpha; % nonlinear operator
for n = 1:nmax
  t = n*h;
  Nu_hat = g.*fft(real(ifft(u_hat)).^2);
  a = E2.*u_hat + Q.*Nu_hat;
  Na = g.*fft(real(ifft(a)).^2);
  b = E2.*u_hat + Q.*Na;
  Nb = g.*fft(real(ifft(b)).^2);
  c = E2.*a + Q.*(2*Nb-Nu_hat);
  Nc = g.*fft(real(ifft(c)).^2);
  u_hat = E.*u_hat + Nu_hat.*f1 + 2*(Na+Nb).*f2 + Nc.*f3;
  if mod(n,nplt)==0
    u = real(ifft(u_hat));
    uu((n/nplt),:) = u;
    u_exact(n/nplt,:) = aa * sech( (((-3/2)*alpha*aa/(-2*epsilon))^(1/2)) * (x-U*t) ).^2;
  end
end


figTitle = ['h = ',num2str(h),' , N = ',num2str(N)];
figure('Name', figTitle)

% Plot results:
subplot(3,1,1)
waterfall(x,tdata,real(uu)), view(0,70),
xlim([-Left,Left]);
ylim([0,tmax]);
title('Numerical');
grid off

subplot(3,1,2)
waterfall(x,tdata,u_exact), view(0,70),
xlim([-Left,Left]);
ylim([0,tmax]);
title('Exact');

% Plot solution
u_numerical = uu(nmax/nplt,:);
u_exact = u_exact(nmax/nplt,:);
subplot(3,1,3)
plot(x,u,x,u_exact)
title('Solution');



return