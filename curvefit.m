function [c,S_c,out,h] = curvefit(x,y,f,c_0,varargin)
%CURVEFIT solves non-linear least squares problems.
%   CURVEFIT attempts to solve problems of the form:
%   min sum ( (YDATA-FCN(C,XDATA)) / S_YDATA ) ^ 2
%
%   C = CURVEFIT(XDATA,YDATA,FCN) finds the coefficients C to best fit the
%   nonlinear function in FCN to the data YDATA in the least-squares sense.
%
%   FCN is a function handle, with arguments 'c' (coefficients) and 'x' (XDATA).
%   For example, use '@(c,x) c(1)*x.^2+c(2)*x+c(3)' for a quadratic function.
%
%   In order to fit weighted data, the vectors YDATA and S_YDATA have to be
%   merged into a N-by-2 matrix and given as the second input argument:
%   C = CURVEFIT(XDATA,[YDATA S_YDATA],FCN)
%
%   Coefficients estimation can be passed as the fourth argument:
%   C = CURVEFIT(XDATA,YDATA,FCN,C0)
%
%   If axis labels are given, CURVEFIT will plot the data, the fitted function
%   and the residuals:
%   C = CURVEFIT(XDATA,YDATA,FCN,C0,'XLabel',XLABEL,'YLabel',YLABEL)
%
%   [C,S_C] = CURVEFIT(...) returns the standard error of each coefficient,
%   at 95% confidence level.
%
%   [C,S_C,OUT] = CURVEFIT(...) returns a structure that contains information
%   about the optimization in the following fields:
%
%     - Algorithm  : optimization algorithm used,
%     - Iterations : number of iterations,
%     - Message    : exit message,
%     - Residuals  : value of residuals, YDATA-FCN(C,XDATA), at the solution C,
%     - R2         : correlation coefficient,
%     - Q2         : squared 2-norm of the residual,
%                    Q2 = sum ( (YDATA-FCN(C,XDATA)) / S_YDATA ) ^ 2.
%
%See also LSQNONLIN, FMINSEARCH, TINV, PLOT, ERRORBAR.

% Created by Léa Strobino.
% Copyright 2018 hepia. All rights reserved.

persistent optim
if isempty(optim)
  optim = ~isempty(which('lsqnonlin'));
end

% Parse input arguments
Algorithm = [];
LowerBound = [];
UpperBound = [];
XLabel = [];
YLabel = [];
XUnit = [];
YUnit = [];
XLim = [];
YLim = [];
Legend = 'SouthEast';
d = [];
for i = 1:2:numel(varargin)
  switch lower(varargin{i})
    case 'algorithm'
      Algorithm = varargin{i+1};
    case 'lowerbound'
      LowerBound = varargin{i+1};
    case 'upperbound'
      UpperBound = varargin{i+1};
    case 'xlabel'
      XLabel = varargin{i+1};
    case 'ylabel'
      YLabel = varargin{i+1};
    case 'xunit'
      XUnit = varargin{i+1};
    case 'yunit'
      YUnit = varargin{i+1};
    case 'xlim'
      XLim = varargin{i+1};
    case 'ylim'
      YLim = varargin{i+1};
    case 'legend'
      Legend = varargin{i+1};
    otherwise
      continue
  end
  d = [d i i+1]; %#ok<AGROW>
end
varargin(d) = [];
if isempty(Algorithm)
  if optim
    if isempty(LowerBound) && isempty(UpperBound)
      Algorithm = 'levenberg-marquardt';
    else
      Algorithm = 'trust-region-reflective';
    end
  else
    Algorithm = 'simplex';
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

% Generate initial coefficients values
if nargin < 4 || isempty(c_0)
  c_0 = 1;
  while 1
    try
      feval(f,c_0,x);
      break
    catch e
      if strcmp(e.identifier,'MATLAB:badsubscript')
        c_0 = [c_0 1]; %#ok<AGROW>
      else
        rethrow(e);
      end
    end
  end
end

% Run algorithm
o = [{'Display','none','MaxFunEval',1E4,'MaxIter',1E4},varargin];
if strcmpi(Algorithm,'nelder-mead-simplex') || strcmpi(Algorithm,'simplex')
  if ~isempty(LowerBound) || ~isempty(UpperBound)
    error('curvefit:simplex:bounds','The Nelder-Mead simplex algorithm does not handle bound constraints.');
  end
  o = optimset(o{:});
  [c,Q2,~,o] = fminsearch(@(c)sum(((y-feval(f,c,x))./S_y).^2),c_0,o);
else
  o = optimoptions('lsqnonlin','Algorithm',Algorithm,o{:});
  [c,Q2,~,~,o] = lsqnonlin(@(c)(y-feval(f,c,x))./S_y,c_0,LowerBound,UpperBound,o);
end

% Post-processing
c = c.';
v = n-numel(c);
t = tinv(.975,v);
y_fit = feval(f,c,x);
J = bsxfun(@times,1./S_y,jacobian(f,c,x,y_fit));
cov = inv(J'*J)*Q2/v; %#ok<MINV>
S_c = t*sqrt(diag(cov));
r = y-y_fit;
R2 = 1-sum(abs(r).^2)/sum(abs(y-mean(y)).^2);
if nargout > 2
  out = struct(...
    'Algorithm',o.algorithm,...
    'Iterations',o.iterations,...
    'Message',o.message,...
    'Residuals',r,...
    'R2',R2,...
    'Q2',Q2);
end

% Plot
if ~isempty(XLabel) && ~isempty(YLabel)
  if ~isempty(XUnit)
    XLabel = [XLabel ' / ' XUnit];
  end
  if ~isempty(YUnit)
    YLabel = [YLabel ' / ' YUnit];
  end
  a(2) = subplot(2,1,2);
  if w
    h(5) = errorbar(a(2),x,r./y_fit,S_y./y_fit,'k.','MarkerSize',12);
  else
    h(5) = plot(a(2),x,r./y_fit,'k.','MarkerSize',12);
  end
  set(a(2).XLabel,'String',XLabel,'Interpreter','LaTeX');
  set(a(2).YLabel,'String','Residuals','Interpreter','LaTeX');
  a(2).Title.Interpreter = 'LaTeX';
  a(1) = subplot(2,1,1);
  if isempty(XLim)
    plot(a(1),x,0);
    XLim = a(1).XLim;
  end
  x_fit = (0:250)'/250*(XLim(2)-XLim(1))+XLim(1);
  y_fit = feval(f,c,x_fit);
  J = jacobian(f,c,x_fit,y_fit);
  d = t*sqrt(sum((J*cov).*J,2));
  h(2:4) = plot(a(1),x_fit,y_fit,'r-',x_fit,y_fit+d,'r:',x_fit,y_fit-d,'r:');
  a(1).NextPlot = 'add';
  if w
    h(1) = errorbar(a(1),x,y,S_y,'k.','MarkerSize',12);
  else
    h(1) = plot(a(1),x,y,'k.','MarkerSize',12);
  end
  a(1).NextPlot = 'replace';
  if ~isempty(YLim)
    a(1).YLim = YLim;
  end
  set(a(1).XLabel,'String',XLabel,'Interpreter','LaTeX');
  set(a(1).YLabel,'String',YLabel,'Interpreter','LaTeX');
  a(1).Title.Interpreter = 'LaTeX';
  if isfinite(R2) && ~strcmpi(Legend,'none')
    legend(a(1),{sprintf('$R^2=%.4f$',R2)},'Box','off','Interpreter','LaTeX','Location',Legend);
  end
  set(a,'TickLabelInterpreter','LaTeX','XGrid','on','YGrid','on','XLim',XLim);
  linkaxes(a,'x');
  h = h(:);
end

function J = jacobian(f,c,x,y)
p = numel(c);
J = zeros(numel(x),p);
e = eps^(1/3);
for i = 1:p
  c_ = 0*c;
  if c(i) == 0
    nb = sqrt(norm(c));
    c_(i) = e*(nb+(nb==0));
  else
    c_(i) = e*c(i);
  end
  J(:,i) = (feval(f,c+c_,x)-y)/c_(i);
end
