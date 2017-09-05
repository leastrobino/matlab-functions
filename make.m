%
%  make.m
%
%  Created by Léa Strobino.
%  Copyright 2016 hepia. All rights reserved.
%

function make(varargin)

if nargin == 0
  varargin = {'clean','all'};
end

warning('off','MATLAB:DELETE:FileNotFound');

if any(strcmpi(varargin,'clean'))
  m = mexext('all');
  for i = 1:length(m)
    delete(['*.' m(i).ext]);
  end
  delete *.p
end

if any(strcmpi(varargin,'all')) || any(strcmpi(varargin,'dist'))
  if numel(dir('*.c'))
    mex *.c
  end
  pcode -nocheck *
  delete make.p startup.p
end

if any(strcmpi(varargin,'dist'))
  [~,~] = mkdir('dist');
  [~,~] = copyfile('*.p','dist');
  d = dir('*.p');
  m = mexext('all');
  for i = 1:length(m)
    [~,~] = copyfile(['*.' m(i).ext],'dist');
    d = [d ; dir(['*.' m(i).ext])]; %#ok<AGROW>
  end
  for i = 1:length(d)
    [~,f] = fileparts(d(i).name);
    h = fopen([f '.m'],'r');
    if h > 0
      s = '';
      try %#ok<TRYNC>
        l = strtrim(fgets(h));
        while isempty(l) || ~all(strfind(l,'function') ~= 1)
          l = strtrim(fgets(h));
        end
        while isempty(l) || l(1) == '%'
          s = [s l 10]; %#ok<AGROW>
          l = strtrim(fgets(h));
        end
      end
      fclose(h);
      h = fopen(['dist/' f '.m'],'w');
      fwrite(h,[deblank(s) 10]);
      fclose(h);
    end
  end
end
