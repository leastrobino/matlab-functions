%
%  unwrapd.m
%
%  Created by Léa Strobino.
%  Copyright 2013 hepia. All rights reserved.
%

function q = unwrapd(p,varargin)
q = (180/pi)*unwrap((pi/180)*p,varargin{:});
