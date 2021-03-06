%
%  sym2latex.m
%
%  Created by L�a Strobino.
%  Copyright 2016 hepia. All rights reserved.
%

function s = sym2latex(s)
greek = ['(alpha|beta|chi|delta|epsilon|eta|gamma|iota|kappa|lambda|'...
  'mu|nu|omega|phi|psi|rho|sigma|tau|theta|upsilon|xi|zeta|'...
  'Alpha|Beta|Chi|Delta|Epsilon|Eta|Gamma|Iota|Kappa|Lambda|'...
  'Mu|Nu|Omega|Phi|Psi|Rho|Sigma|Tau|Theta|Upsilon|Xi|Zeta)'];
if isa(s,'sym')
  s = latex(s);
end
s = strrep(s,'_{V}\mathrm{ar}','');
s = strrep(s,'\mathrm{log}','\ln');
s = regexprep(s,['\\mathrm{' greek '}'],'\\$1');
s = regexprep(s,'\\mathrm{(.*?)}','$1');
s = regexprep(s,'\\!','');
if ~nargout
  if ispc
    fs = 14;
  else
    fs = 20;
  end
  h = figure(...
    'Color',[1 1 1],...
    'DockControls','off',...
    'MenuBar','none',...
    'Resize','off',...
    'Toolbar','none',...
    'WindowStyle','normal');
  a = axes(...
    'Units','pixels',...
    'Parent',h,...
    'Position',[10 10 1 1],...
    'Visible','off');
  t = text(0,0,['$$' s '$$'],...
    'Units','pixels',...
    'FontSize',fs,...
    'HorizontalAlignment','left',...
    'Interpreter','LaTeX',...
    'Parent',a,...
    'VerticalAlignment','bottom');
  ss = get(0,'ScreenSize');
  w = warning('off','MATLAB:handle_graphics:exceptions:SceneNode');
  e = get(t,'Extent');
  warning(w);
  if all(e == 0)
    close(h);
    warning('sym2latex:LatexSyntaxError','Syntax error in LaTeX string.');
  else
    set(h,'Position',[(ss(3:4)-e(3:4))/2-10 e(3:4)+20]);
    set(a,'Position',[10 10 e(3:4)]);
  end
end
