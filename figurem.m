%
%  figurem.m
%
%  Created by L�a Strobino.
%  Copyright 2015 hepia. All rights reserved.
%

function h = figurem(varargin)
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
h = figure(varargin{:});
drawnow();
h.JavaFrame.setMaximized(true);
