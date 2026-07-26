function f = runExperimentFigure(scriptName)
%RUNEXPERIMENTFIGURE Run one experiment script and return the figure it made.
%
%   F = RUNEXPERIMENTFIGURE("E1_doseResponse") runs the script and returns
%   its figure handle.
%
%   *** THIS EXISTS TO ISOLATE THE WORKSPACE ***
%   RUN evaluates a script in the CALLER's workspace, so a driver looping
%   over experiments shares variables with every experiment it runs.  The
%   experiments use k, i, j, f and s as loop and scratch variables, so a
%   driver using any of those has them silently overwritten mid-loop --
%   which is exactly what happened: figures were written under the wrong
%   names and the loop index ran off the end of the list.
%
%   Wrapping RUN in a function gives the script a private workspace that is
%   discarded on return, so the caller's variables survive.
%
%   Input
%     scriptName  (1,1) string  file stem in experiments/, no extension
%
%   Output
%     f  (1,1) matlab.ui.Figure  the figure the script created
%
%   See also EXPORTFIGURESPLOS.

%   Project: bone-mechanostat (PROJECT_PLAN v2.12)

arguments
    scriptName (1,1) string
end

close all force;
run(fullfile(projectRoot(), "experiments", scriptName + ".m"));
f = gcf;
end
