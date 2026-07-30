function k_ot = osteocyteBurialRate(p)
%OSTEOCYTEBURIALRATE Derive k_ot so osteocyte turnover matches bone turnover.
%
%   K_OT = OSTEOCYTEBURIALRATE(P) returns the osteocyte burial rate constant
%   for which the osteocyte population turns over at exactly the rate its
%   bone does.
%
%   *** WHY THIS IS DERIVED, NOT FREE (appendix C34) ***
%   k_ot looks like a burial rate, but the baseline balance in
%   OSTEOCYTEDENSITY pins gamma_eff from it,
%
%       k_ot (n_ot_max - n_ot_0) / n_ot_0 = gamma_eff + delta_ot_0,
%
%   so what it really sets is the turnover of the whole osteocyte
%   population.  Osteocytes leave the tissue when the bone they sit in is
%   resorbed, so that turnover is not free: it must equal the bone's.  Left
%   free it did not.  Shipped at k_ot = 0.5 until v2.23, the model resorbed
%   bone at 1.93e-4 /day (V1 = 7.03 %/yr) while removing osteocytes at
%   9.9e-2 /day -- a factor of 514, and a mean osteocyte residence of 10
%   days against a bone packet lifetime of years.
%
%   Inverting the balance removes the contradiction by construction:
%
%       gamma_eff := turnoverRate(p) / 100 / 365
%       k_ot      := (gamma_eff + delta_ot_0) n_ot_0 / (n_ot_max - n_ot_0)
%
%   This is the same move BALANCEBONEFORMATION makes for k_form, and for the
%   same reason: a quantity the baseline state already determines should not
%   also be a free parameter, because calibration will then quietly fit it
%   to something else.
%
%   It also carries the compartment split for free.  TRABECULARPARAMS
%   calibrates k_res to a 20 %/yr trabecular turnover against the cortex's
%   7 %/yr, and trabecular osteocytes should turn over faster in exactly
%   that proportion -- which they now do, without a second parameter.
%
%   The derived cortical value agrees with the independent measurement to
%   12 %: Buenzli and Sims 2015 report 42 billion osteocytes in the adult
%   human skeleton with 9.1 million replenished daily, i.e. 2.167e-4 /day
%   and a residence of 12.6 years, against 1.93e-4 /day derived here.  The
%   two routes share no inputs, so that agreement is a real check -- and it
%   is why the value is derived from OUR turnover rather than pinned to
%   theirs, which is a whole-skeleton average including trabecular bone.
%
%   Input
%     p  (1,1) struct  parameters (uses k_res, xi_i_0, w_wall, f_bm_0,
%                      delta_ot_0, n_ot_0, n_ot_max)
%
%   Output
%     k_ot  (1,1) double  burial rate constant                     [1/day]
%
%   See also BALANCEBONEFORMATION, TURNOVERRATE, OSTEOCYTEDENSITY.

%   Project: bone-mechanostat (PROJECT_PLAN v2.24, appendix C34)

arguments
    p (1,1) struct
end

gammaEff = turnoverRate(p) / 100 / 365;                  % [1/day]
k_ot = (gammaEff + p.delta_ot_0) * p.n_ot_0 / (p.n_ot_max - p.n_ot_0);
end
