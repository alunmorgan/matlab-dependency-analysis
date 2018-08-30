function [function_list, function_loc] = find_functions(linebyline)
% Example:  [function_list, function_loc] = find_functions(linebyline)

function_pos = regexp(linebyline,'^\s*function\s');
function_loc = 0;
for us = 1:size(function_pos,1)
    if isempty(function_pos{us}) == 0
        function_loc = cat(1,function_loc,us);
    end %if
end %for
function_loc = function_loc(2:end);
function_list = linebyline(function_loc);
%% Removing callback functions etc generated by the GUI generation process
if size(function_loc) ~= 0
    % in an if statement as otherwise complains if function_list is
    % empty
    function_list = regexprep(function_list,'^\s*function\s','');
    function_list = regexprep(function_list,'\s*\(.*\)\s*;*$','');
    function_list = regexprep(function_list,'^.*=\s*','');
    function_list = regexprep(function_list,'\s*;*\s*$','');
    uw_loc = 0;
    uw_loc = [uw_loc,isempty_cell(strfind(function_list,'_Callback'))'];
    uw_loc = [uw_loc,isempty_cell(strfind(function_list,'_CreateFcn'))'];
    uw_loc = [uw_loc,isempty_cell(strfind(function_list,'_OpeningFcn'))'];
    uw_loc = [uw_loc,isempty_cell(strfind(function_list,'_OutputFcn'))'];
    uw_loc = unique(uw_loc(2:end));
    function_list(uw_loc) = [];
    function_loc(uw_loc) = [];
    clear rem_funcs uw_loc
end %if
