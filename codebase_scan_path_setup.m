function codebase_scan_path_setup(rep_loc_ad, rep_loc, inhouse)
% rep_loc_ad(str): location of the analysis code
% rep_loc(str): location of the code to be analysed.

addpath([rep_loc_ad, '/matlab-dependency-analysis']);
addpath([rep_loc_ad, '/matlab-dependency-analysis/support_files']);
core_paths = get_core_paths(inhouse);
path(core_paths);
addpath([rep_loc_ad, '/matlab-dependency-analysis']);
addpath([rep_loc_ad, '/matlab-dependency-analysis/support_files']);
addpath(rep_loc);