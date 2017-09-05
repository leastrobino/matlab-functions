close all
clear all

m = MeteoSwiss();
stations = fieldnames(m.stations);

%% Overview

T_overview = m.getTemperature();
p_overview = m.getPressureQNH();

fprintf('\nTemperature, Pressure QNH:\n');
for i = 1:length(stations)
  s = stations{i};
  if isnan(T_overview.(s))
    T = '--- ';
  else
    T = sprintf('%.1f',T_overview.(s));
  end
  if isnan(p_overview.(s))
    p = '---';
  else
    p = sprintf('%.0f',p_overview.(s));
  end
  fprintf('  <strong>%s</strong>:   %s%s, %s %s\n',...
    m.stations.(s).name,...
    T,T_overview.unit,...
    p,p_overview.unit);
end
fprintf('\n');

%% Measurements for Geneva

station = 'GVE';
format = 'dd/MM H:mm';

T = m.getTemperature(station);
p = m.getPressureQNH(station);
H = m.getHumidity(station);

figure();

h(1) = subplot(3,1,1);
plot(T.xdata,T.ydata,'DatetimeTickFormat',format);
grid on
legend(T.legend,...
  'Box','off',...
  'Location','SouthOutside',...
  'Orientation','Horizontal');
ylabel(['Temperature (' T.unit ')']);

h(2) = subplot(3,1,2);
plot(p.xdata,p.ydata,'DatetimeTickFormat',format);
grid on
legend(p.legend,...
  'Box','off',...
  'Location','SouthOutside',...
  'Orientation','Horizontal');
ylabel(['Pressure (' p.unit ')']);

h(3) = subplot(3,1,3);
plot(H.xdata,H.ydata,'DatetimeTickFormat',format);
grid on
legend(H.legend,...
  'Box','off',...
  'Location','SouthOutside',...
  'Orientation','Horizontal');
ylabel(['Humidity (' H.unit ')']);

for i = 1:length(h)
  h(i).XTick = 4*floor(h(i).XTick(1)/4):.25:4*ceil(h(i).XTick(end)/4);
end

axes(h(1));
title(sprintf('Station: %s   Coordinates: %d,%d   Altitude: %d m',...
  m.stations.(station).name,...
  m.stations.(station).coordinates(1),m.stations.(station).coordinates(2),...
  m.stations.(station).altitude));
