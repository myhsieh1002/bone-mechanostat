function d = boneStructure(state, eta, xi, v_form, v_res, p)
%BONESTRUCTURE M7 -- three-surface structural evolution.
%
%     dr_p/dt  = v_form eta_p - v_res xi_p                       [m/day]
%     dr_e/dt  = v_res  xi_e  - v_form eta_e                      [m/day]
%     df_bm/dt = (S_v(f_bm)/w) (v_form eta_i - v_res xi_i)        [1/day]
%
%   r_e increasing means endocortical resorption, i.e. a thinning cortex.
%   Tracking r_p and r_e separately is what lets the model reproduce
%   Haapasalo's finding that the playing arm's marrow cavity ALSO enlarged
%   (+19%) -- periosteal apposition outpacing endocortical change.
%
%   Inputs
%     state  (1,1) struct  r_p [m], r_e [m], f_bm [-]
%     eta    (1,3) double  formation split                        [-]
%     xi     (1,3) double  resorption split                       [-]
%     v_form (1,1) double  k_form * B                             [m/day]
%     v_res  (1,1) double  k_res  * C                             [m/day]
%     p      (1,1) struct  parameters
%   Output
%     d  (1,1) struct  .r_p .r_e .f_bm derivatives
%
%   *** NOT IMPLEMENTED -- scheduled for phase P3 (M7) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "boneStructure is a phase-P3 deliverable (M7) and is not implemented yet.");
end
