%
%  wrap.m
%
%  Created by L�a Strobino.
%  Copyright 2013 hepia. All rights reserved.
%

function q = wrap(p)
q = mod(p+pi,2*pi)-pi;
