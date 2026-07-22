function [dydt, aux] = rhsTwoSite(t, y, scenario, p)
%RHSTWOSITE Two-compartment right-hand side (site A loaded, site B contralateral).
%
%   Duplicates M1-M7 per site while SHARING the single M8 systemic pool.
%   Each site receives its own M_L and F_L from scenario.boutsA / .boutsB.
%
%   This architecture turns site specificity into a testable mathematical
%   claim (innovation N3): a systemic intervention cannot create a
%   side-to-side difference, whereas local loading can.  It maps directly
%   onto Haapasalo's within-subject design -- same person, same calcium pool,
%   different local mechanics.
%
%   Inputs / outputs as RHSFULL, with the 31-state layout of
%   STATEVECTOR("two").
%
%   *** NOT IMPLEMENTED -- scheduled for phase P5 (M1-M8) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "rhsTwoSite is a phase-P5 deliverable (M1-M8) and is not implemented yet.");
end
