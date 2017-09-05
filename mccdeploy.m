%MCCDEPLOY Invoke MATLAB to C/C++ Compiler.
%
%   MCCDEPLOY('fun','destination',{'file 1','file 2',...},'args')
%
%   Prepare fun.m for deployment outside of the MATLAB environment.
%   Generate wrapper files in C or C++ and build standalone binary files.
%   The created application won't contain information of the MATLAB prefdir.
%
%   Write any resulting files into the 'destination' directory.
%
%   Add {'file 1','file 2',...} to the CTF archive. If the specified files are
%   m, mex or p files, these functions will not be exported in the resulting
%   target.
%
%   The compilation search path will be cleared of all directories except the
%   following core directories:
%     <matlabroot>/toolbox/matlab
%     <matlabroot>/toolbox/local
%     <matlabroot>/toolbox/compiler
%   It will also retains all subdirectories of the above list that appear on
%   the MATLAB path at compile time.
%
%   See also MCC.

%  Created by Léa Strobino.
%  Copyright 2017 hepia. All rights reserved.

function mccdeploy(file,dest,dependencies,args)

if nargin < 2 || isempty(dest)
  dest = '.';
end
if nargin < 3
  dependencies = {};
end
if nargin < 4
  args = '';
end

% Copy all files
build = tempname();
mkdir(build);
try
  copyfile(file,build);
  for i = 1:length(dependencies)
    copyfile(dependencies{i},build);
  end
catch e
  rmdir(build,'s');
  rethrow(e);
end
[~,f,e] = fileparts(file);
file = [f e];

% Clear functions, startup & prefdir
clear functions %#ok<*CLFUNC>
f = inmem();
for i = 1:length(f)
  if mislocked(f{i})
    munlock(f{i});
  end
end
clear functions
try %#ok<TRYNC>
  startup = which('startup');
  movefile(startup,[startup '_'],'f');
  movefile(prefdir,[prefdir '_'],'f');
end

% mcc
wd = cd();
cd(build);
mccerror = [];
try
  [~,~] = mkdir([wd '/' dest]);
  eval(['mcc -v -e ' file ' -a . -d ''' wd '/' dest ''' -N ' args]);
catch e
  mccerror = e;
end

% Delete temporary files
try %#ok<TRYNC>
  [~] = rmdir(prefdir,'s');
  movefile([startup '_'],startup,'f');
  movefile([prefdir '_'],prefdir,'f');
end
cd(wd);
delete(...
  [dest '/mccExcludedFiles.log'],...
  [dest '/readme.txt'],...
  [dest '/requiredMCRProducts.txt'],...
  [dest '/run_*.sh']);
rmdir(build,'s');

if ~isempty(mccerror)
  rethrow(mccerror);
end
