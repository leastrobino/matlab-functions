%
%  strlen.m
%
%  Created by Léa Strobino.
%  Copyright 2013 hepia. All rights reserved.
%

function l = strlen(s)
s = strtok(s,sprintf('\n'));
s = textscan(s,'%s','Delimiter','\t');
s = s{1};
l = length(s{end});
for i = 1:length(s)-1
  l = l + 4*(floor(length(s{i})/4)+1);
end
