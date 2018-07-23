%
%  add_certificate.m
%
%  Created by Léa Strobino.
%  Copyright 2018 hepia. All rights reserved.
%

function add_certificate(cert)
d = fileparts(mfilename('fullpath'));
if ~nargin
  cert = dir(fullfile(d,'*.cer'));
  cert = fullfile(d,cert(1).name);
end
jre = fullfile(matlabroot,'sys','java','jre',computer('arch'),'jre');
keytool = fullfile(jre,'bin','keytool');
cacerts = fullfile(jre,'lib','security','cacerts');
if ispc
  sudo = '';
else
  sudo = 'sudo ';
end
system(sprintf('%s"%s" -importcert -alias meteoswiss -file "%s" -keystore "%s" -storepass changeit',sudo,keytool,cert,cacerts));
