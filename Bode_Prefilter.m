%% Open-loop gain of prefilter block

close all;
clear all;

% for open-loop gain analysis of the loop filter only
% 2nd-order LF - usually unconditionally stable because phase margin > 45
% degrees

%% Set PLL target specification values

% define N as divider following VCO to PD
N = 1; % no divider

fn = 10.6e3; % [Hz]
d = 2.15; % damping 

Ko = 2*pi*100e6; % [rad/s/V]
Kd = 2/pi; % [V/rad] assume full-wave switch with Vs = 1

wn = 2*pi*fn; % [rad/s]

%% Define experimental measurement variable and load it in
gain = csvread('PREF100K.csv', 1, 0); % input CSV output from oscilloscope

% Set the base frequency using Bode plot output from oscilloscope
f_base = gain(:, 2);

tau1 = (Ko*Kd)/wn^2; % [s]
tau2 = (2*d)/wn; % [s]

f3dB = 10*fn; % guideline to make pole 5 to 10 times the fn; also not too far to limit higher frequency components after PD
tau3 = (1/(2*pi*f3dB));

w = 2*pi*f_base;
s = 1i*w;
F = (s*tau2 + 1)./(s*tau1); % active loop filter transfer function
% negative sign removed to neglect op-amp inversion

%% Define theoretical variable and use f_base to make calculations

F_preF = F.*(1./(s*tau3+1));

% open loop gain of loop filter including prefilter
G_preF = (1./(s*tau3+1));

G_preF_dB = 20*log10(abs(G_preF)); % gain
G_preF_phase = angle(G_preF)*(180/pi); % degrees

%% Generate Bode plot
figure(1)
subplot(2,1,1)

semilogx(f_base, G_preF_dB, 'Linewidth', 2)
grid on;
hold on;
ylabel('Magnitude (dB)');

semilogx(f_base, gain(:,3), 'xr')

legend('Theoretical', 'Experimental', 'Location', 'southwest')

subplot(2,1,2)
semilogx(f_base, G_preF_phase, 'Linewidth', 2)
grid on;
hold on;
xlabel('Frequency (Hz)');
ylabel(['Phase (', char(176), ')']);

semilogx(f_base, gain(:,4), 'xr')

return;
