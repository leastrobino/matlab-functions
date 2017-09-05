%RFP Modal parameter estimation from frequency response function
%   using rational fraction polynomial method.
%
%   Syntax: [freq,h,Q,poles] = RFP(f,H,N,f_lower,f_upper)
%
%   f     : frequency range vector (Hz)
%   H     : FRF measurement (receptance)
%   N     : # of degrees of freedom
%   f_lower, f_upper : frequency bounds
%
%   freq  : natural frequencies (Hz)
%   h     : FRF generated (receptance)
%   Q     : quality factors
%   poles : poles
%
%   Reference: Mark H.Richardson & David L.Formenti "Parameter Estimation
%              from Frequency Response Measurements Using Rational Fraction
%              Polynomials", 1st IMAC Conference, Orlando, FL. November, 1982.

% Chile, March 2002, Cristian Andrés Gutiérrez Acuña, crguti@icqmail.com
% Modified by Léa Strobino, March 2013
% Modified by Etienne Rivet & Sami Karkar, October 2014
% Modified by Léa Strobino, December 2016

function [freq,h,Q,poles] = rfp(f,H,N,f_lower,f_upper)

p = size(H,2);

if nargin > 4
  
  [~,b] = min(abs(f-f_lower));
  [~,e] = min(abs(f-f_upper));
  [freq,h,Q,poles] = rfp(f(b:e),H(b:e,:),N);
  h = [NaN(b-1,p);h;NaN(length(f)-e,p)];
  
else
  
  f_max = max(f);
  f = f./f_max;   % f normalization
  n = 2*N;        % # of polynomial terms in denominator
  m = n-1+4;      % # of polynomial terms in numerator
  
  phi = cell(1,p);
  theta = phi;
  coeff_A = phi;
  coeff_B = phi;
  X = phi;
  G = phi;
  U = phi;
  V = phi;
  
  % orthogonal function that calculates the orthogonal polynomials
  for i = 1:p
    [phi{i},coeff_A{i}] = orthogonal(f,H(:,i),1,m);
    [theta{i},coeff_B{i}] = orthogonal(f,H(:,i),2,n);
    P = sparse(diag(1./H(:,i)))*phi{i};
    W = theta{i}(:,end);
    X{i} = -2*real(P'*theta{i}(:,1:end-1));
    G{i} = 2*real(P'*W);
    U{i} = eye(size(X{i},2))-X{i}.'*X{i};
    V{i} = X{i}'*G{i};
  end
  
  U = cell2mat(vertcat(U(:)));
  V = cell2mat(vertcat(V(:)));
  
  d = -U\V;
  D = [d;1]; % {D} orthogonal denominator polynomial coefficients
  
  % calculation of FRF
  h = zeros(length(f),p);
  for i = p:-1:1
    C = G{i}-X{i}*d; % {C} orthogonal numerator polynomial coefficients
    for j = 1:length(f)
      num = sum(C.'.*phi{i}(j,:));
      den = sum(D.'.*theta{i}(j,:));
      h(j,i) = num/den;
    end
  end
  
  c = coeff_A{1}*C;
  A = c(end:-1:1); % {A} standard numerator polynomial coefficients
  c = coeff_B{1}*D;
  B = c(end:-1:1); % {B} standard denominator polynomial coefficients
  
  % calculation of the poles
  [~,P] = residue(A,B);
  poles = P(1:2:end,1);
  poles = poles(end:-1:1)*f_max;    % poles
  freq = abs(poles);                % natural frequencies
  Q = -abs(poles)./(2*real(poles)); % quality factor
  
end


%ORTHOGONAL Orthogonal polynomials required for rational fraction
%   polynomials method. (This code was written to be used with rfp.m)
%
%   Syntax: [P,coeff] = orthogonal(f,H,phitheta,k_max)
%
%   f        : frequency range vector (Hz)
%   H        : FRF measurement (receptance)
%   phitheta : weighting function (must be 1 for phi matrix or 2 for
%              theta matrix)
%   k_max    : degree of the polynomial
%
%   P        : matrix of the orthogonal polynomials evaluated at the frequencies
%   coeff    : matrix used to transform between the orthogonal polynomial
%              coefficients and the standard polynomial
%
%   Reference: Mark H.Richardson & David L.Formenti "Parameter Estimation
%              from Frequency Response Measurements Using Rational Fraction
%              Polynomials", 1st IMAC Conference, Orlando, FL. November, 1982.

% Chile, March 2002, Cristian Andrés Gutiérrez Acuña, crguti@icqmail.com
% Modified by Etienne Rivet & Sami Karkar, October 2014

function [P,coeff] = orthogonal(f,H,phitheta,k_max)

if phitheta == 1
  q = 1./(abs(H)).^2; % weighting function for phi matrix
else
  q = ones(size(H));  % weighting function for theta matrix
end

R_minus1 = zeros(size(f));
R_0 = 1/sqrt(2*sum(q)).*ones(size(f));
R = [R_minus1 R_0]; % polynomials -1 and 0
coeff = zeros(k_max+1,k_max+2);
coeff(1,2) = 1/sqrt(2*sum(q));

% generating orthogonal polynomials matrix and transform matrix
for k = 1:k_max %#ok<*AGROW>
  Vkm1 = 2*sum(f.*R(:,k+1).*R(:,k).*q);
  Sk = f.*R(:,k+1)-Vkm1*R(:,k);
  Dk = sqrt(2*sum((Sk.^2).*q));
  R = [R Sk/Dk];
  coeff(:,k+2) = -Vkm1*coeff(:,k);
  coeff(2:k+1,k+2) = coeff(2:k+1,k+2)+coeff(1:k,k+1);
  coeff(:,k+2) = coeff(:,k+2)/Dk;
end

R = R(:,2:k_max+2);          % orthogonal polynomials matrix
coeff = coeff(:,2:k_max+2);  % transform matrix

% make complex by multiplying by j^k
for k = 0:k_max
  P(:,k+1) = R(:,k+1)*1j^k; % complex orthogonal polynomials matrix
  jk(1,k+1) = 1j^k;
end
coeff = (jk'*jk).*coeff;    % complex transform matrix
