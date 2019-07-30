% satool_ExistFilename() - Check whether the file with name and path
% specified in filename already exists. If so, it prompts the user with the
% choice between overwriting the exiting file or changing the filename. If
% filename (or part of it, i.e. path, name or ext) is not specified, uses a
% default file name in the current working directory, and check whether it
% already exists.
%
% Usage:
%   >>  [filename] = satool_ExistFilename(filename);
%
% Inputs:
%   filename  - full path and name of the file to check. If empty or only
%   partially provided, the following defaults are used.
%           path = pwd;
%           name = savedfile
%           ext = .txt   
% Outputs:
%   filename        - fullpath file name
%
% See also: 
%   EEGLAB 

% Copyright (C) 2012 Sara Assecondi 2012-11-16
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function filename = satool_ExistFilename(filename)

if nargin < 1,
    path = pwd;
    name = 'savedfile';
    ext = '.txt';
else [path,name,ext] = fileparts(filename);
    
    if isempty(path), path = pwd;           end
    if isempty(name), name = 'savedfile'; end
    if isempty(ext), ext = '.txt';          end
end

filename = [path filesep name ext];

flag = 1;
options.Resize='on';
while flag
    if exist(filename,'file')
        answ = inputdlg('The file name already exist: do you want to overwrite it? [y/n] ',filename,1,{''},options);
        if isempty(answ), continue
        elseif ~isempty(answ) && strcmpi(answ,'y'), flag = 0;
        elseif ~isempty(answ) && strcmpi(answ,'n'), rfile = char(inputdlg('Insert a new file name: ','',1,{filename},options));  
        end
    else flag = 0;
    end
end

fprintf('Create %s\n',filename)

return