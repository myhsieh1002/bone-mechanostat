function root = projectRoot()
%PROJECTROOT Absolute path of the bone-mechanostat project root.
%
%   ROOT = PROJECTROOT() returns the directory that contains src/, data/,
%   tests/ and experiments/.  All file access in this project must go
%   through this function -- never hard-code absolute paths, and never rely
%   on PWD (the MATLAB MCP session starts in ~/Documents/MATLAB).
%
%   Output
%     root  (1,1) string  Absolute path, no trailing separator.
%
%   See also GETRESULTSDIR, GETDEFAULTPARAMS.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

thisFile = mfilename('fullpath');            % .../src/projectRoot
root = string(fileparts(fileparts(thisFile)));  % strip /src
end
