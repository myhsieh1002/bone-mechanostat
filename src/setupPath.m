function setupPath()
%SETUPPATH Add the project's source tree to the MATLAB path for this session.
%
%   SETUPPATH() calls ADDPATH(GENPATH(...)) on src/, experiments/ and
%   tests/.  Run it once per MATLAB session before anything else.
%
%   *** NEVER CALL SAVEPATH (PROJECT_PLAN v1.3 §7.3) ***
%   Several Claude Code sessions on this machine drive their own MATLAB
%   R2026a processes.  Their workspaces are isolated, but they SHARE one
%   preferences directory.  SAVEPATH rewrites the global pathdef.m and
%   would leak this project's paths into every other session (and vice
%   versa).  Paths are added per session, in memory, and never persisted.
%
%   See also PROJECTROOT, GETRESULTSDIR.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

root = projectRoot();
addpath(genpath(fullfile(root, "src")));
addpath(fullfile(root, "experiments"));
addpath(fullfile(root, "tests"));

fprintf("bone-mechanostat path set for this session only (savepath NOT called).\n");
fprintf("  root: %s\n", root);
end
