function varargout = update_codebase_dependencies(rep_loc, output_file_loc, output_web_location, sudo_builtin_loc)
% Scans all the code finds the interdependencies and generates Wiki
% pages, html_code, code trees and latex documentation.
% If rep_loc is not a char then rep loc is assumed to be a
% previously generated codebase structure file, so only output generation
% will be done.
%
% Example: varargout = update_codebase_dependencies(rep_loc,output_loc)

if nargout > 1
    error('Too many output arguments. Should be 0 or 1')
end %if

% Find if Graphviz is installed on this system
[~, dot_loc] = system('which dot');
if regexp(dot_loc, '^which: +no dot')
    warning('dot not found no graphics will be generated. \n Please check that GraphViz is installed on this computer');
    GV_exist = 0;
else
     GV_exist = 1;
end %if


%% Generating the folder structure for the output files (if needed)
doc_generate_folder_structure(output_file_loc)

%% Finding the interrelationships
% generating the dependency matrix
if ischar(rep_loc)
    codebase_structure = makeindex(sudo_builtin_loc, rep_loc);
else
    % or passing through a pre existing one
    codebase_structure = rep_loc;
end %if
% sorting out the output
if nargout == 1
        varargout{1} = codebase_structure;
        return
elseif nargout == 0 && GV_exist == 0
    disp('No plotting tools available and no output set stopping now. \n Please re run with an output value.')
    return
end %if

[nodes, duplicates_list, node_cols, unique_places] = ...
    codebase_dependency_extraction(codebase_structure);

%% Generating output files
% Setting up paths

% Web paths
html_path =  fullfile(output_web_location,'html_code');
dotty_path =  fullfile(output_web_location,'Code_trees', 'dotty_files');
%file locations
html_loc =  fullfile(output_file_loc,'html_code');
dot_loc = fullfile(output_file_loc, 'Code_trees', 'dot_files');

% write html file for repository structure.
generate_top_level_html(html_path, dotty_path, html_loc)
funcs_html(nodes, duplicates_list, html_loc, html_path, dotty_path)

% Generate dot files for later use with graphviz
generate_repository_structure_dot_file(nodes, html_path, dot_loc)
funcs_dot_lang(nodes, html_path, dot_loc , node_cols, unique_places);

% getting the list of dot files
dot_file_list = dir_list_gen(dot_loc,'dot');

%% Going throught the list of dot files and generating dependency graphs
disp('Generating the dependency graphs.')
dl = length(dot_file_list);
for mq = dl:-1:1
    % input file
    dotty_in = dot_file_list{mq};
    % output file
    dotty_out = dotty_in;
    dotty_out = regexprep(dotty_out, '\\dot_files\\', '\\dotty_files\\');
    dotty_out = regexprep(dotty_out, '\/dot_files\/', '\/dotty_files\/');
    dotty_out_svg = regexprep(dotty_out, '.dot$', '.svg');
    dotty_cmd_svg = ['dot -Tsvg -o "',dotty_out_svg,'" "',dotty_in, '"'];
    system(dotty_cmd_svg);
    fprintf('.')
end %for
fprintf('\n')

