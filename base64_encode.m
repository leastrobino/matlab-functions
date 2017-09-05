%
%  base64_encode.m
%
%  Created by Léa Strobino.
%  Copyright 2015. All rights reserved.
%

function s = base64_encode(b)
if ischar(b)
  b = uint8(b);
elseif isnumeric(b)
  b = typecast(b,'uint8');
else
  error('base64_encode:UnsupportedClass','Unsupported class: %s.',class(b));
end
s = char(org.apache.commons.codec.binary.Base64.encodeBase64(b)');
