%% HRV analysis

load("data.mat"); 
fs = 128; 
RR_intervals = diff(heart_beats) / fs; 
RR_times_sec = heart_beats(1:end-1) / fs;
RR_times_min = RR_times_sec / 3600; 

total_time_min = RR_times_min(end);
split_points = linspace(0, total_time_min, 5); 

figure;
for i = 1:4
    subplot(4,1,i);
    t_start = split_points(i);
    t_end = split_points(i+1);
    idx = RR_times_min >= t_start & RR_times_min < t_end;
    plot(RR_times_min(idx), RR_intervals(idx), '-b');
    ylabel('RR (s)');
    xlabel('Time (h)');
end
sgtitle('RR Intervals Over Time');

%% Time domain characteristics

SDNN = std(RR_intervals);
segment_length = 300; 
total_duration = RR_times_sec(end);
num_segments = floor(total_duration / segment_length);

segment_means = [];

for i = 1:num_segments
    t_start = (i-1) * segment_length;
    t_end = i * segment_length;
    idx = RR_times_sec >= t_start & RR_times_sec < t_end;
    
    if sum(idx) > 1
        segment_means(end+1) = mean(RR_intervals(idx));
    end
end

SDANN = std(segment_means);
diff_RR = diff(RR_intervals);
rMSSD = sqrt(mean(diff_RR.^2));
diff_ms = abs(diff_RR) * 1000; 
NN50 = sum(diff_ms > 50);
pNN50 = 100 * NN50 / length(diff_ms);

%% RR distribution

RR_ms = RR_intervals * 1000; 
figure;
histogram(RR_ms, 'BinWidth', 20, 'FaceColor', [0.2 0.6 0.8]);

xlabel('RR Interval (ms)');
ylabel('Frequency');
xlim([0 2000])
title('RR/NN Interval Histogram');
grid on;

%% Poincare plot

RR_n     = RR_ms(1:end-1);
RR_nplus = RR_ms(2:end);

diffs = (RR_nplus - RR_n) / sqrt(2);
sums  = (RR_nplus + RR_n) / sqrt(2);
SD1 = std(diffs); 
SD2 = std(sums);  

mean_rr = mean(RR_ms);

figure;
scatter(RR_n, RR_nplus, 10, 'filled', 'MarkerFaceColor', [0.2 0.6 0.8]);
hold on;

lims = [min([RR_n; RR_nplus]), max([RR_n; RR_nplus])];
plot(lims, lims, '--k', 'LineWidth', 1);

theta = linspace(0, 2*pi, 100);
x_ellipse = SD2 * cos(theta);
y_ellipse = SD1 * sin(theta);
R = [1/sqrt(2), -1/sqrt(2); 1/sqrt(2), 1/sqrt(2)];
ellipse_coords = R * [x_ellipse; y_ellipse];
plot(ellipse_coords(1,:) + mean_rr, ellipse_coords(2,:) + mean_rr, 'r-', 'LineWidth', 1.5);

scale = 1.5; 
sd2_line = [-SD2, SD2] * scale;
plot(mean_rr + sd2_line, mean_rr + sd2_line, 'g-', 'LineWidth', 1.5);

sd1_line = [-SD1, SD1] * scale;
plot(mean_rr + sd1_line, mean_rr - sd1_line, 'm-', 'LineWidth', 1.5);

xlabel('RR_n (ms)');
ylabel('RR_{n+1} (ms)');
title(sprintf('Poincaré Plot\nSD1 = %.2f ms, SD2 = %.2f ms', SD1, SD2));
legend({'RR Pairs', 'Identity Line', 'Ellipse', 'SD2 Axis', 'SD1 Axis'}, 'Location', 'best');
axis equal;
grid on;
