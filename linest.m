function [c,S_c,R2,Q2,h] = linest(x,y,xvar,xunit,yvar,yunit,varargin)
%LINEST solves linear least squares problems.
%   C = LINEST(XDATA,YDATA) finds the coefficients C to best fit a linear
%   function to the data YDATA in the least-squares sense.
%
%   In order to fit weighted data, the vectors YDATA and S_YDATA have to be
%   merged into a N-by-2 matrix and given as the second input argument:
%   C = LINEST(XDATA,[YDATA S_YDATA])
%
%   If axis variables and units are given, LINEST will plot the data, the
%   fitted function and the confidence interval:
%   C = LINEST(XDATA,YDATA,XVAR,XUNIT,YVAR,YUNIT)
%
%   [C,S_C] = LINEST(...) returns the standard error of each coefficient,
%   at 95% confidence level.
%
%   [C,S_C,R2] = LINEST(...) returns the correlation coefficient R^2.
%
%   [C,S_C,R2,Q2] = LINEST(...) returns the sum of the squares:
%   Q2 = sum ( (YDATA-C(1)*XDATA-C(2)) / S_YDATA ) ^ 2

% Created by Léa Strobino.
% Copyright 2016 hepia. All rights reserved.

degree = 1;
if nargin > 2 && isnumeric(xvar)
  narginchk(3,3);
  degree = xvar;
end

% Parse input arguments
XLim = [];
YLim = [];
Legend = 'SouthEast';
for i = 1:2:numel(varargin)
  switch lower(varargin{i})
    case 'xlim'
      XLim = varargin{i+1};
    case 'ylim'
      YLim = varargin{i+1};
    case 'legend'
      Legend = varargin{i+1};
    otherwise
      error('linest:InvalidParamName','Unrecognized parameter name ''%s''.',varargin{i});
  end
end

x = x(:);
n = numel(x);
if size(y,1) ~= n
  y = y.';
end
if size(y,2) > 1
  S_y = y(:,2);
  y = y(:,1);
  w = true;
else
  S_y = 1;
  w = false;
end

% Compute coefficients and standard errors
X = bsxfun(@power,x,degree:-1:0);
W = diag(S_y.^-2);
c = (X'*W*X)\X'*W*y;
p = n-length(c);
t = tinv(.975,p);
r = y-X*c;
Q2 = sum((abs(r)./abs(S_y)).^2);
[~,R] = qr(bsxfun(@times,1./S_y,X),0);
Ri = inv(R);
cov = (Ri*Ri')*Q2/p;
S_c = t*sqrt(diag(cov));
R2 = 1-sum(abs(r).^2)/sum(abs(y-mean(y)).^2);

% Plot
if nargin > 2 && ~isnumeric(xvar)
  if nargin == 4
    yvar = xunit;
    xunit = [];
    yunit = [];
  end
  if isempty(xunit)
    XLabel = ['$' xvar '$'];
  else
    XLabel = ['$' xvar '$ / ' xunit];
  end
  if isempty(yunit)
    YLabel = ['$' yvar '$'];
  else
    YLabel = ['$' yvar '$ / ' yunit];
  end
  a = gca();
  if isempty(XLim)
    plot(a,x,0);
    XLim = a.XLim;
  end
  x_fit = (0:250)'/250*(XLim(2)-XLim(1))+XLim(1);
  y_fit = c(1)*x_fit+c(2);
  J = [x_fit ones(251,1)];
  d = t*sqrt(sum((J*cov).*J,2));
  h = plot(a,x_fit,y_fit,'r-',NaN,NaN,'.',x_fit,y_fit+d,'r:',x_fit,y_fit-d,'r:','Marker','none');
  h(2) = [];
  a.NextPlot = 'add';
  if w
    h = [errorbar(a,x,y,S_y,'k.','MarkerSize',12) ; h];
  else
    h = [plot(a,x,y,'k.','MarkerSize',12) ; h];
  end
  a.NextPlot = 'replace';
  if ~isempty(YLim)
    a.YLim = YLim;
  end
  set(a.XLabel,'String',XLabel,'Interpreter','LaTeX');
  set(a.YLabel,'String',YLabel,'Interpreter','LaTeX');
  a.Title.Interpreter = 'LaTeX';
  set(a,'TickLabelInterpreter','LaTeX','XGrid','on','YGrid','on','XLim',XLim);
  if isfinite(R2) && ~strcmpi(Legend,'none')
    l = {sprintf('$R^2=%.4f$',R2)};
    if all(isreal(c))
      d = -floor(log10(S_c));
      s = fixd(S_c,d);
      for i = 1:2
        if any(s{i} == '.') && s{i}(end) == '0'
          d(i) = d(i)-1;
        end
      end
      s = [yvar '='];
      if c(1) < 0
        s = [s '-'];
      end
      if isfinite(d(1))
        s = [s '(' fixd(abs(c(1)),d(1))];
        s = [s '\pm ' fixd(S_c(1),d(1)) ')'];
      else
        s = [s double2str(abs(c(1)),3)];
      end
      s = [s '\cdot ' xvar];
      if c(2) < 0
        s = [s '-'];
      else
        s = [s '+'];
      end
      if isfinite(d(2))
        s = [s '(' fixd(abs(c(2)),d(2))];
        s = [s '\pm ' fixd(S_c(2),d(2)) ')'];
      else
        s = [s double2str(abs(c(2)),3)];
      end
      l = [['$' s '$'] l];
    end
    legend(l,'Box','off','Interpreter','LaTeX','Location',Legend);
  end
end
