%
%  wrapd.m
%
%  Created by L�a Strobino.
%  Copyright 2013 hepia. All rights reserved.
%

function q = wrapd(p)
q = mod(p+180,360)-180;
