%
%  base64_decode.m
%
%  Created by Léa Strobino.
%  Copyright 2015. All rights reserved.
%

function b = base64_decode(s)
if ischar(s)
  s = uint8(s);
elseif ~isa(s,'uint8')
  error('base64_decode:UnsupportedClass','Unsupported class: %s.',class(s));
end
if ~org.apache.commons.codec.binary.Base64.isArrayByteBase64(s)
  error('base64_decode:InvalidArray','Input is not Base64 encoded.');
end
b = org.apache.commons.codec.binary.Base64.decodeBase64(s);
b = typecast(b,'uint8');
