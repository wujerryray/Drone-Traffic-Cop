%% Open-loop gain of active loop filter and PLL

close all;
clear;

% for open-loop gain analysis of the loop filter only
% 2nd-order LF - usually unconditionally stable because phase margin > 45
% degrees

%% Set PLL target specification values

% define N as divider following VCO to PD
N = 1; % no divider

fn = 10.6e3; % [Hz]
d = 2.15; % damping 

Ko = 2*pi*100e6; % [rad/s/V]
Kd = 2/pi; % [V/rad] full-wave switch with Vs = 1

wn = 2*pi*fn; % [rad/s]

%% Define experimental measurement variable and load it in
gain_LF_200 = csvread('FS_LF_1V_200pt.csv', 1, 0); % input CSV output from oscilloscope

% Set the base frequency using Bode plot output from oscilloscope
f_base = gain_LF_200(1:1001, 2);

tau1 = (Ko*Kd)/wn^2; % [s]
tau2 = (2*d)/wn; % [s]

f3dB = 10*fn; % guideline to make pole 5 to 10 times the fn; also not too far to limit higher frequency components after PD
tau3 = (1/(2*pi*f3dB));

w = 2*pi*f_base;
s = 1i*w;

%% Define theoretical variable and use f_base to make calculations
F = (s*tau2 + 1)./(s*tau1); % active loop filter transfer function
% negative sign removed to neglect op-amp inversion

F_preF = F.*(1./(s*tau3+1));

% open loop gain of loop filter including prefilter
G_preF = F_preF;

G_preF_dB = 20*log10(abs(G_preF)); % gain
G_preF_phase = angle(G_preF)*(180/pi); % degrees

% open loop gain of phase-locked loop 
G_preF_scale = ((Ko*Kd*G_preF)./s);

G_mag = abs(G_preF_scale);

G_preF_scale_dB = 20*log10(abs(G_mag)); % gain
G_preF_scale_phase = angle(G_preF_scale)*(180/pi); % degrees

%% Generate Bode plot
figure(1)

subplot(2,2,1) % Plot the gain of active loop filter for theoretical and experimental measurements

% Theoretical response curve
semilogx(f_base, G_preF_dB, 'LineWidth', 2)
grid on;
hold on;
ylabel('Magnitude (dB)', 'FontSize', 12);
title('A) Open Loop Gain of Active Loop Filter')

set(gca, 'FontSize', 10);

% Experimental response curve
semilogx(f_base, gain_LF_200(1:1001,3), 'xr', 'MarkerSize', 3)

legend('Theoretical', 'Experimental', 'Location', 'northeast', 'FontSize', 10)

subplot(2,2,3) % Plot the phase for active loop filter for theoretical and experimental measurements

% Theoretical response curve
semilogx(f_base, G_preF_phase, 'LineWidth', 2)
grid on;
hold on;
xlabel('Frequency (Hz)', 'FontSize', 12);
ylabel(['Phase (', char(176), ')'], 'FontSize', 12);

% Experimental response curve
semilogx(gain_LF_200(1:1001,2), gain_LF_200(1:1001,4)-180, 'xr', 'MarkerSize', 3)

set(gca, 'FontSize', 10);

subplot(2,2,2) % Plot the gain for PLL for theoretical and experimental measurements

% Theoretical response curve
semilogx(f_base, G_preF_scale_dB, 'LineWidth', 2)
grid on;
hold on;
%ylabel('Magnitude (dB)', 'FontSize', 12);
title('B) Open-Loop Gain of Phase-Locked Loop');

% Experimental response curve
% Apply gain factor to measurement values
gain_LF_linear = 10.^(gain_LF_200(1:1001,3)/20);

freq_LF_s = 1i*2*pi*f_base;

gain_LF_scale = ((Ko*Kd)./freq_LF_s).*gain_LF_linear; % measured G

gain_LF_scale_dB = 20*log10(abs(gain_LF_scale));

set(gca, 'FontSize', 10);

semilogx(f_base, gain_LF_scale_dB, 'xr', 'MarkerSize', 3)
%hplot(0, 'm');
vplot(35000, 'm');
%legend('Theoretical', 'Experimental', 'Location', 'northeast', 'FontSize', 10)

subplot(2,2,4) % Plot the phase for PLL for theoretical and experimental measurements

% Theoretical response curve
semilogx(f_base, G_preF_scale_phase, 'LineWidth', 2)
grid on;
hold on;

% Experimental response curve
% Apply gain factor to measurement values
phase_LF_deg = gain_LF_200(1:1001,4)-180; % subtracting 180 degrees due to op-amp

%LF_complex = gain_LF_linear.*cos((gain_LF_200(1:1001,4)-180)*(pi/180)) + 1i*(gain_LF_linear.*sin((gain_LF_200(1:1001, 4)-180))*(pi/180));

LF_complex = gain_LF_linear.*exp(1i*phase_LF_deg*(pi/180));

LF_complex_scale = ((Ko*Kd*LF_complex)./freq_LF_s); % open-loop gain of PLL

G_est_dB = 20*log10(abs(LF_complex_scale));

phase_est_deg = angle(G_est_dB)*(180/pi);

phase_LF_deg = (unwrap(angle(LF_complex_scale))*(180/pi))-360;

semilogx(f_base, phase_LF_deg, 'xr', 'MarkerSize', 3)
xlabel('Frequency (Hz)', 'FontSize', 12);
%ylabel(['Phase (', char(176), ')'], 'FontSize', 12);

vplot(35000, 'm');

set(gca, 'FontSize', 10);

return;