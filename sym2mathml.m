%
%  sym2mathml.m
%
%  Created by Léa Strobino.
%  Copyright 2016 hepia. All rights reserved.
%

function o = sym2mathml(s)
s = sym2latex(s);
if nargout
  o = latex2mathml(s);
else
  latex2mathml(s);
end
