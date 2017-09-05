function hpol = polardb(varargin)
%POLARDB  Polar coordinate dB plot.
%   POLARDB(THETA,RHO) makes a plot using polar coordinates of
%   the angle THETA, in radians, versus the radius RHO.
%   POLARDB(THETA,RHO,S) uses the linestyle specified in string S.
%   See PLOT for a description of legal linestyles.
%   POLARDB(THETA,RHO,S,RLIM,RUNIT) sets the radius limits and unit.
%
%   POLARDB(AX,...) plots into AX instead of GCA.
%
%   H = POLARDB(...) returns a handle to the plotted object in H.
%
%   Example:
%      t = 0:.005:2*pi;
%      polardb(t,200*abs(sin(2*t).*cos(2*t)),'r-');
%
%   See also POLAR, PLOT, LOGLOG, SEMILOGX, SEMILOGY.

% Created by Léa Strobino.
% Copyright 2016 hepia. All rights reserved.

narginchk(2,6);
if ishghandle(varargin{1})
  narginchk(3,6);
  a = varargin{1};
  varargin = varargin(2:end);
else
  narginchk(2,5);
  a = [];
end

lineStyle = 'auto';
RLim = [0 100];
RUnit = 'dB';
switch length(varargin)
  case 2
    [theta,rho] = deal(varargin{1:2});
  case 3
    [theta,rho,lineStyle] = deal(varargin{1:3});
    if ~ischar(lineStyle)
      RLim = lineStyle;
      lineStyle = 'auto';
    end
  case 4
    [theta,rho,lineStyle,RLim] = deal(varargin{1:4});
    if ~ischar(lineStyle)
      RUnit = RLim;
      RLim = lineStyle;
      lineStyle = 'auto';
    end
  otherwise
    [theta,rho,lineStyle,RLim,RUnit] = deal(varargin{1:5});
end
if ischar(theta) || ischar(rho) || ischar(RLim) || ...
    ~ischar(lineStyle) || (~isempty(RUnit) && ~ischar(RUnit))
  error(message('MATLAB:polar:InvalidInputType'));
end
if ~isequal(size(theta),size(rho)) || numel(RLim) ~= 2 || RLim(2) <= RLim(1)
  error(message('MATLAB:polar:InvalidInputDimensions'));
end

% get hold state
a = newplot(a);
nextPlot = get(a,'NextPlot');
holdState = ishold(a);

try
  % get the axis grid color
  gridAlpha = get(a,'GridAlpha');
  color = get(a,'GridColor').*gridAlpha+get(a,'Color').*(1-gridAlpha);
catch
  % get x-axis text color so grid is in same color
  color = get(a,'XColor');
end
gridLineStyle = get(a,'GridLineStyle');

% only do grids if hold is off
if ~holdState
  
  % hold on to current text defaults, reset them to the
  % axes' font attributes so tick marks use them
  fontAngle = get(a,'DefaultTextFontAngle');
  fontName = get(a,'DefaultTextFontName');
  fontSize = get(a,'DefaultTextFontSize');
  fontWeight = get(a,'DefaultTextFontWeight');
  fontUnits = get(a,'DefaultTextUnits');
  set(a,...
    'DefaultTextFontAngle',get(a,'FontAngle'),...
    'DefaultTextFontName',get(a,'FontName'),...
    'DefaultTextFontSize',get(a,'FontSize'),...
    'DefaultTextFontWeight',get(a,'FontWeight'),...
    'DefaultTextUnits','data');
  
  % check radial limits and ticks
  r = RLim(2)-RLim(1);
  rticks = floor(r/5);
  while rticks > 5 % see if we can reduce the number
    if rem(rticks,2) == 0
      rticks = rticks/2;
    elseif rem(rticks,3) == 0
      rticks = rticks/3;
    else
      break
    end
  end
  
  % make a radial grid
  hold(a,'on');
  
  % define a circle
  t = 0:pi/50:2*pi;
  x = cos(t);
  y = sin(t);
  % really force points on x/y axes to lie on them exactly
  x([26 76]) = [0 0];
  y([1 51 101]) = [0 0 0];
  % plot background if necessary
  if ~ischar(get(a,'Color'))
    patch('XData',r*x,'YData',r*y,...
      'EdgeColor',color,'FaceColor',get(a,'Color'),...
      'HandleVisibility','off','Parent',a);
  end
  
  % plot spokes
  t = (4:9)*pi/6;
  cost = cos(t);
  sint = sin(t);
  line(r*[-cost ; cost],r*[-sint ; sint],'LineStyle',gridLineStyle,'Color',color,...
    'LineWidth',1,'HandleVisibility','off','Parent',a);
  
  % annotate spokes in degrees
  rt = 1.1*r;
  for i = 1:length(t)
    text(rt*cost(i),rt*sint(i),sprintf('%.0f°',i*30),...
      'HorizontalAlignment','center','HandleVisibility','off','Parent',a);
    if i == 6
      s = '0°';
    else
      s = sprintf('%.0f°',180+i*30);
    end
    text(-rt*cost(i),-rt*sint(i),s,...
      'HorizontalAlignment','center','HandleVisibility','off','Parent',a);
  end
  
  % draw radial circles
  ri = r/rticks;
  if ~isempty(RUnit)
    RUnit = [' ' RUnit];
  end
  for i = 0:ri:r
    if i
      h = line(i*x,i*y,'LineStyle',gridLineStyle,'Color',color,...
        'LineWidth',1,'HandleVisibility','off','Parent',a);
    end
    text(0,-i+ri/20,...
      sprintf('%.0f%s',RLim(1)+i,RUnit),...
      'HorizontalAlignment','center','VerticalAlignment','bottom',...
      'HandleVisibility','off','Parent',a);
  end
  set(h,'LineStyle','-'); % make outer circle solid
  
  % set view to 2-D
  view(a,2);
  % set axis limits
  set(a,'XLim',r*[-1 1],'YLim',r*[-1.15 1.15],...
    'XLimMode','manual','YLimMode','manual',...
    'UserData',struct('RLim',RLim));
  
  % reset defaults
  set(a,...
    'DefaultTextFontAngle',fontAngle,...
    'DefaultTextFontName',fontName,...
    'DefaultTextFontSize',fontSize,...
    'DefaultTextFontWeight',fontWeight,...
    'DefaultTextUnits',fontUnits);
  
end

% transform data to cartesian coordinates
try %#ok<TRYNC>
  u = get(a,'UserData');
  RLim = u.RLim;
end
rho(rho > RLim(2)) = NaN;
rho = rho-RLim(1);
rho(rho < 0) = NaN;
x = rho.*cos(theta+pi/2);
y = rho.*sin(theta+pi/2);

% plot data on top of grid
if strcmp(lineStyle,'auto')
  h = plot(x,y,'Parent',a);
else
  h = plot(x,y,lineStyle,'Parent',a);
end

if nargout == 1
  hpol = h;
end

if ~holdState
  set(a,'Visible','off','DataAspectRatio',[1 1 1],'NextPlot',nextPlot);
end
set(get(a,'XLabel'),'Visible','on');
set(get(a,'YLabel'),'Visible','on');
set(get(a,'Title'),'Visible','on');
