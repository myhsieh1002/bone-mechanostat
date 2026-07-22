function dirPath = getResultsDir(subdir)
%GETRESULTSDIR Local (non-iCloud) directory for simulation output.
%
%   DIRPATH = GETRESULTSDIR() returns the project's results directory,
%   creating it if necessary.
%   DIRPATH = GETRESULTSDIR(SUBDIR) returns (and creates) a named
%   subdirectory, e.g. GETRESULTSDIR("E1_doseSurface").
%
%   Why this exists (PROJECT_PLAN v1.4 §7.1): the source tree lives on
%   iCloud Drive.  MATLAB .mat files written there can be evicted to
%   placeholder stubs by iCloud, after which LOAD fails -- and the offline
%   surrogates (shearSurrogate, doseSurrogate) are exactly the kind of large
%   .mat file iCloud likes to evict.  Results therefore go to local disk.
%   Only code, parameter CSVs and documents stay in the synced tree.
%
%   Input
%     subdir   (1,1) string  Optional subdirectory name.  Default "".
%
%   Output
%     dirPath  (1,1) string  Absolute path, guaranteed to exist.
%
%   See also PROJECTROOT.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

arguments
    subdir (1,1) string = ""
end

base = fullfile(string(java.lang.System.getProperty('user.home')), ...
                "Documents", "MATLAB", "bone-mechanostat-results");

if strlength(subdir) > 0
    dirPath = fullfile(base, subdir);
else
    dirPath = base;
end

if ~isfolder(dirPath)
    mkdir(dirPath);
end
end
