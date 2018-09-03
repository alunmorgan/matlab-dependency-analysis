#!/bin/bash

# Setting up to use current bash profile so as to get the correct environment variables.
. ~/.bash_profile

exit_cleanup() {
    echo "On exit"
    rm -rf $temp_dir
}
# The location of any in house 'builtin functions' that should be excluded from analysis.
inhouse="''"

#output locations
out_dir="''" #filesystem location on the web server.
out_web="''" #equivalent web address

orig_place=$(pwd)
# Check out the current head code for the Auto_documentation and general folders which contain the codebase scanning functions.

#First create the required folders.
temp_dir=$(mktemp -d --tmpdir code_scan.XXXXXX)
rep_loc_ad=$temp_dir/docs
rep_loc=$temp_dir/loc
mkdir $rep_loc_ad $rep_loc
trap exit_cleanup EXIT

echo 'Locations'
echo 'original place '$orig_place
echo 'Auto documentation folder '$rep_loc_ad
echo 'Target folder '$rep_loc

# Now check out the code.
cd $rep_loc_ad
git clone https://github.com/alunmorgan/matlab-dependency-analysis.git
cd $orig_place
# check out the  target repositories.
cd $rep_loc
mkdir rep1
cd rep1
git clone https://github.com/alunmorgan/matlab-dependency-analysis.git
cd $orig_place

# Put matlab code here
module load matlab/R2016a

cat <<EOF >$temp_dir/exec.m
orig_path=path;
addpath $rep_loc_ad/matlab-dependency-analysis;
addpath $rep_loc_ad/matlab-dependency-analysis/support_files
core_paths = get_core_paths($inhouse);
path(core_paths);
addpath $rep_loc_ad/matlab-dependency-analysis;
addpath $rep_loc_ad/matlab-dependency-analysis/support_files;
addpath $rep_loc;
update_codebase_dependencies('$rep_loc', $out_dir, $out_web, $inhouse);
path(orig_path);
quit
EOF

cd $temp_dir
matlab -nodisplay -r "exec"
