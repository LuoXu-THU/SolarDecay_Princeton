%% Introduction

% Developed by Luo Xu Princeton CEE

% Princeton University plan to achieve net-zero emission by 2046. Planned
%The project produces 5.4 megawatts of peak power

% Set solar capcity factor is 20% in Princeton

%00:00 - Approximately 0 MW
%03:00 - Approximately 0 MW
%06:00 - Approximately 0.73 MW
%09:00 - Approximately 3.28 MW
%12:00 - 5.4 MW (peak)
%15:00 - Approximately 3.28 MW
%18:00 - Approximately 0.73 MW
%21:00 - Approximately 0 MW

time_points = [0, 3, 6, 9, 12, 15, 18, 21];
SolarGen_0 = [0, 0, 0.73, 3.28, 5.4, 3.28, 0.73, 0];



%% Hurricane imapct

%load("Ida_0902.mat")
load("Ida_Data_0902.mat")
% for t = 1:length(solar_percent_int)
%     gen_solar_output_int(t,:) = gen_solar_output.*solar_percent_int(t)/100;
% 
%     gen_solar_output_decay(t,:) =  gen_solar_output_int(t,:).* exp_decay(t,index_utility_solar_connect);
% end

LAT_PU = 40.3431;
LON_PU = -74.6551;
Category = ones(1,8); %Category 1


LAT_hurricane_center = Ida_Data_0902(:,5);
LON_hurricane_center = Ida_Data_0902(:,6);
ROCI = Ida_Data_0902(:,9);

%% Solar Decay Factor
for t = 1:length(time_points)
                
    [arclen_grid,az_grid] = distance(LAT_PU,LON_PU,LAT_hurricane_center(t),LON_hurricane_center(t));

    distance_bus(t) = deg2km(arclen_grid);
    R_dist(t) = distance_bus(t)/ ROCI(t);

    if (R_dist(t) + (-0.126*Category(t)+1.15)) / (2.48-0.139*Category(t)) <=1
        factor_decay(t) = (0.0965*Category(t)+ 1.97) * log( (R_dist(t) + (-0.126*Category(t)+1.15)) / (2.48-0.139*Category(t))   );
    else
        factor_decay(t) = 0;
    end

    exp_decay(t) = exp(factor_decay(t));

%     [arclen_grid,az_grid] = distance(m,n,LAT_center,LON_center);
%     grid_dis = deg2km(arclen_grid);

end


%% Acutal Solar geneartion 
for t = 1:length(time_points)
    %SolarGen_Real(t) = gen_solar_output.*solar_percent_int(t)/100;

    SolarGen_Real(t) =  SolarGen_0(t).* exp_decay(t);
end


%% Plot
% Interpolate to 1 hour

% Define new time points for 1-hour intervals
new_time_points = 0:1:21;

% Perform linear interpolation
SolarGen_0_interp = interp1(time_points, SolarGen_0, new_time_points, 'linear');
SolarGen_Real_interp = interp1(time_points, SolarGen_Real, new_time_points, 'linear');



% Create the plot
figure(1);
plot(new_time_points, SolarGen_0_interp , '-o', 'DisplayName', '2046 PU Solar Generation without Hurricane');
hold on;

% Add plot for actual generation
plot(new_time_points, SolarGen_Real_interp, '-x', 'DisplayName', '2046 PU Solar Generation under Hurricane Ida');

% Additional plot settings
xlabel('Time of Day (hours)');
ylabel('Power Generation (MW)');
title('Solar Power Generation in Princeton Univ by 2046');
legend('show');
grid on;
