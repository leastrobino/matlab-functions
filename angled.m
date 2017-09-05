%ANGLED  Phase angle.
%   ANGLED(H) returns the phase angles, in degrees, of a matrix with
%   complex elements.
%
%   Class support for input X:
%      float: double, single
%
%   See also ABS, ANGLE, UNWRAPD.

% Created by Léa Strobino.
% Copyright 2013 hepia. All rights reserved.

function p = angled(h)
p = (180/pi)*atan2(imag(h),real(h));
