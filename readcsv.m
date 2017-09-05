function [d,header] = readcsv(filename,rows,columns,delimiter)
%READCSV Read a comma separated value file.
%   D = READCSV('filename') reads a comma separated value formatted file
%   "filename". The result is returned in D. The file can only contain
%   numeric values.
%
%   D = READCSV('filename',R,C) reads data from the comma separated value
%   formatted file starting at row R and column C.
%
%   D = READCSV('filename',[R Nrows],[C Ncolumns]) reads only the range
%   specified by [R Nrows] and [C Ncolumns] where (R,C) is the upper-left
%   corner of the data to be read and Nrows and Ncolumns are the number of
%   rows and columns to read.
%
%   D = READCSV('filename',R,C,DLM) reads data from the formatted file
%   using DLM as delimiter.
%
%   READCSV fills empty delimited fields with zero. Data files where
%   the lines end with a comma will produce a result with an extra last
%   column filled with zeros.
%
%   See also TEXTSCAN, CSVWRITE.

%  Created by Léa Strobino.
%  Copyright 2017 hepia. All rights reserved.

if nargin < 2
  rows = [1 Inf];
elseif length(rows) == 1
  rows = [rows Inf];
end
if nargin < 3
  columns = [1 Inf];
elseif length(columns) == 1
  columns = [columns Inf];
end
if nargin < 4
  delimiter = '';
end
[path,name,ext] = fileparts(filename);
if isempty(path)
  path = pwd();
end
if isempty(ext)
  ext = '.csv';
end
filename = fullfile(path,[name ext]);
h = fopen(filename,'r');
if h > 0
  i = 0;
  line = '';
  while i < rows(1) || (~isempty(line) && (line(1) == '%'))
    header = line;
    line = fgets(h);
    i = i+1;
  end
  if isempty(delimiter)
    delimiter = ',';
    if ~any(line == delimiter)
      delimiter = ';';
    end
  end
  if isempty(header)
    header = {};
  else
    if header(1) == '%'
      header = header(2:end);
    end
    header = regexp(header,['([^"' delimiter ']*)|"([^"])*"' delimiter '?'],'tokens');
    if ~isempty(header)
      header = cellfun(@strtrim,header);
    end
  end
  frewind(h);
  if isinf(columns(2))
    f = '';
  else
    f = [repmat('%*s',1,columns(1)-1) repmat('%f',1,columns(2)) '%*[^\n]'];
  end
  try
    d = textscan(h,f,rows(2),...
      'CollectOutput',1,...
      'CommentStyle','%',...
      'Delimiter',delimiter,...
      'EmptyValue',0,...
      'HeaderColumns',columns(1)-1,...
      'HeaderLines',rows(1)-1,...
      'ReturnOnError',0);
  catch e
    fclose(h);
    if strcmp(e.identifier,'MATLAB:textscan:EmptyFormatString')
      d = [];
    else
      m = regexp(e.message,'^Mismatch between file and format string\.\n(.*)$','tokens','once');
      if ~isempty(m)
        error('readcsv:FormatStringMismatch','%s',m{1});
      else
        rethrow(e);
      end
    end
  end
  if isempty(d)
    d = [];
  else
    d = d{1};
  end
  fclose(h);
else
  error('readcsv:FileNotFound','"%s": no such file.',filename);
end
