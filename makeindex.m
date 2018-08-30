function [repo_data] = makeindex(sudo_builtin_loc, tree)
% works out the interrelationships of  code trees
% finds dependency and parentage of a function
% as well as global variable dependancies.
% if one inputs is given only looks in the current directory.
% if two argument are given it takes that path and also traverses subdirectories.
% Example: [repo_data] = makeindex(sudo_builtin_loc, tree)

if nargin == 2
    [file_list, dir_path] = dir_list_gen_tree(tree,'.m', 1);
elseif nargin == 1
    [file_list, dir_path]=dir_list_gen(pwd,'.m',1);
else
    error('makeindex requires 1 or 2 inputs depending on whether you are looking in 1 directory or a directory tree.')
end %if
% Removing the contents from the list.
dir_path(strncmp('Contents.m',file_list, 10))= [];
file_list(strncmp('Contents.m',file_list,10))= [];
l_length =size(file_list,1);

%Adding general repository information
repo_data.repo_info.location = tree;

repo_data.tree(1:l_length,1) = ...
    struct('val','','dir_path','','description','','globals','',...
    'variables','','calledby','','funcs_called','', ...
    'last_modified_date', '', 'last_modified_by', '');

% changing path to only use the core system paths.
% This allows in house builtins to be distinguished from code to test.
orig_path = path;
core_paths = get_core_paths(sudo_builtin_loc);


disp('Processing m files...');
func_ind = 1;
for m_file_ind=1:l_length
    fprintf('.');
    clear funcs_cell linebyline function_list function_loc function_pos ...
        f_list_sz
    % opening file
    f_temp = fullfile(dir_path{m_file_ind},file_list{m_file_ind});
    tempfn = fopen(f_temp);
    % Read file
    linebyline=textscan(tempfn,'%s','delimiter', '\n');
    linebyline = linebyline{1};
    % Close file
    fclose(tempfn);
    
    % Finding the modification dates of the file.
    [~, f_info_temp] = system(['svn info ''', f_temp,'''']);
    [~,f_auth]=regexp(f_info_temp, '^.*Last Changed Author:\s+(.*?)\s+.*$', 'match', 'Tokens');
    if ~isempty(f_auth)
        f_auth = f_auth{1}{1};
        [~,f_dates_temp]=regexp(f_info_temp, '^.*Last Changed Date\:\s+([0-9]+\-[0-9]+\-[0-9]+).*$', 'match', 'Tokens');
        f_dates_temp = f_dates_temp{1}{1};
        f_date = [f_dates_temp(9:10), '/',f_dates_temp(6:7), '/', f_dates_temp(1:4)];
    else
        f_auth = 'Unknown';
        f_date = 'Unknown';
    end %if
    % Removing the code wrapping
    linebyline = remove_wrapping(linebyline);
    
    % finding how many functions are in the file
    [function_list, function_loc] = find_functions(linebyline);
    
    % If there are no functions in the file then it is a script and the
    % sudo-function name is taken from the filename.
    if isempty(function_list) == 1
        % File contains a script
        function_list{1} = file_list{m_file_ind}(1:end-2);
        function_loc = 1;
    end %if
    
    % for each function
    for num_func = 1:size(function_list,1)
        clear varibs var_temp funcs funcs_temp linebyline_temp ...
            code_lines code_lines_var code_lines_func
        desc_temp = {};
        % Selecting the code for a single function.
        repo_data.tree(func_ind,1).dir_path = dir_path{m_file_ind};
        repo_data.tree(func_ind,1).val = function_list{num_func};
        if num_func == size(function_list,1)
            linebyline_temp = ...
                linebyline(function_loc(num_func):end);
        else
            linebyline_temp = ...
                linebyline(function_loc(num_func):function_loc(num_func +1)-1);
        end %if
        % separate out the comments, code, and function call
        non_comment_loc = find_position_in_cell_lst(regexp(linebyline_temp, '^\s*[^\%].*'));
        empty_lines_loc = find(cellfun('isempty',linebyline_temp));
        comment_loc = find_position_in_cell_lst(regexp(linebyline_temp, '^\s*[\%].*'));
        f_loc = find_position_in_cell_lst(regexp(linebyline_temp, '^\s*function.*'));
        % removing the function call index from the code indicies.
        non_comment_loc = setdiff(non_comment_loc, f_loc);
        if isempty(non_comment_loc)
            % No code in this section. So Skip it.
            continue
        end %if
        % finding the description
        if non_comment_loc(1) ~= 1 && ~isempty(comment_loc)
            if isempty(empty_lines_loc)
                comment_end = non_comment_loc(1) -1;
            elseif isempty(non_comment_loc)
                comment_end = empty_lines_loc(1) -1;
            else
                comment_end =  min(non_comment_loc(1),empty_lines_loc(1)) -1;
            end %if
            desc_temp = linebyline_temp(comment_loc(1):comment_end);
        end %if
        
        if ~isempty(desc_temp)
            desc_temp = regexprep(desc_temp, '^\s*\%\s*', '');
            repo_data.tree(func_ind,1).description = desc_temp;
        else
            % replacing empty descriptions with a set message
            repo_data.tree(func_ind,1).description = {' <B>No Description</B> '};
        end %if
        
        %% Analysing and conditioning the code section
        %--------------------------------------------------------------
        code = linebyline_temp;
        % Remove comment lines
        code(find_position_in_cell_lst(regexp(code, '^\s*[\%].*'))) = [];
        % Remove whitespace lines lines
        code(find_position_in_cell_lst(regexp(code, '^\s*$'))) = [];
        
        % removing all lines starting with axis, hold or pause
        code(find_position_in_cell_lst(regexp(code, '^\s*axis\s','ONCE'))) = [];
        code(find_position_in_cell_lst(regexp(code, '^\s*hold\s','ONCE'))) = [];
        code(find_position_in_cell_lst(regexp(code, '^\s*pause\s','ONCE'))) = [];
        
        %removing inline comments
        code = regexprep(code, '\%.*$', '');
        % removing the silencing ;
        code  = regexprep(code, ';\s*;*$', '');
        % If line is empty, remove it
        code(cellfun('isempty',code)) = [];
        fe =length(code);
        for je = 1:fe
            % removing eval from around the function
            if isempty(regexp(code{je}, '^\s*eval\(','ONCE')) == 0
                code{je}  = regexprep(code{je}, '^\s*eval\(', '');
                code{je}  = regexprep(code{je}, ['^\s*\[\s*' ''''], '');
                code{je}  = regexprep(code{je}, ['''' '\]*\);*\s*$'], '');
                code{je}  = regexprep(code{je}, '''', '');
            end %if
        end %for
        % removing the looping/conditional commands
        code  = regexprep(code, '^\s*for(?:[\s;]|\s*$)', '');
        code  = regexprep(code, '^\s*elseif(?:[\s;]|\s*$)', '');
        code  = regexprep(code, '^\s*else(?:[\s;]|\s*$)', '');
        code  = regexprep(code, '^\s*if(?:[\s;]|\s*$)', '');
        code  = regexprep(code, '^\s*while[\s;]', '');
        code  = regexprep(code, '^\s*end(?:[\s;]|\s*$)', '');
        code  = regexprep(code, '^\s*continue(?:[\s;]|\s*$)', '');
        code  = regexprep(code, '^\s*break(?:[\s;]|\s*$)', '');
        code  = regexprep(code, '^\s*try(?:[\s;]|\s*$)', '');
        code  = regexprep(code, '^\s*catch(?:[\s;]|\s*$)', '');
        code  = regexprep(code, '^\s*return(?:[\s;]|\s*$)', '');
        
        
        % Removing parameters (i.e. of the form ('sfyyk'))
        code = regexprep(code, ['\(' '\s*' '''' '[^'']*' '''' '\s*' '\)'], '\(\)');
        code = regexprep(code, ['\[' '\s*' '''' '[^'']*' '''' '\s*' '\]'], '\[\]');
        code = regexprep(code, ['\{' '\s*' '''' '[^'']*' '''' '\s*' '\}'], '\{\}');
        code = regexprep(code, ['\(' '\s*' '''' '[^'']*' '''' '\s*,'], '\(,');
        code = regexprep(code, ['\[' '\s*' '''' '[^'']*' '''' '\s*,'], '\[,');
        code = regexprep(code, ['\{' '\s*' '''' '[^'']*' '''' '\s*,'], '\{,');
        code = regexprep(code, ['\(' '\s*' '''' '[^'']*' ''''], '\(');
        code = regexprep(code, ['\[' '\s*' '''' '[^'']*' ''''], '\[');
        code = regexprep(code, ['\{' '\s*' '''' '[^'']*' ''''], '\{');
        code = regexprep(code, [',\s*' '''' '[^'']*' '''' '\s*' '\)'], ',\)');
        code = regexprep(code, [',\s*' '''' '[^'']*' '''' '\s*' '\]'], ',\]');
        code = regexprep(code, [',\s*' '''' '[^'']*' '''' '\s*' '\}'], ',\}');
        code = regexprep(code, ['''' '[^'']*' '''' '\s*' '\)'], '\)');
        code = regexprep(code, ['''' '[^'']*' '''' '\s*' '\]'], '\]');
        code = regexprep(code, ['''' '[^'']*' '''' '\s*' '\}'], '\}');
        code = regexprep(code, ['[\s]' '''' '[^'']*' '''' '[\s]'], ' ');
        code = regexprep(code, ['[=]' '''' '[^'']*' '''' '[\s]'], '=');
        code = regexprep(code, ['[\s]' '''' '[^'']*' '''$'], ' ');
        code = regexprep(code, ['[=]' '''' '[^'']*' '''$'], '=');
        code = regexprep(code, [',\s*' '''' '[^'']*' '''' '\s*,'], ',,');
        
        % duplicating up as the regexp command does not find
        % overlaying patterns.
        code  = regexprep(code, ',', ',,');
        code  = regexprep(code, ' ', '  ');
        code  = regexprep(code, '\(', ['\(' ',']);
        code  = regexprep(code, '\[', ['\[' ',']);
        code  = regexprep(code, '\{', ['\{' ',']);
        code  = regexprep(code, '\)', [',' '\)']);
        code  = regexprep(code, '\]', [',' '\]']);
        code  = regexprep(code, '\}', [',' '\}']);
        % removing all empty lines
        code(cellfun('isempty',code)) = [];
        %--------------------------------------------------------------
        %% finding the global variables used by the function
        globs = find_global_variables(code);
        repo_data.tree(func_ind,1).globals = globs;
        
        %% Finding the Variables
        %----------------------------------------------------------------
        varibs = find_variables(code);
        repo_data.tree(func_ind,1).variables = varibs;
        
        %% Finding all the functions
        %-------------------------------------------------------------
        funcs = find_function_calls(code, varibs, core_paths, orig_path);
        % Some of the files are some sort of binary or at least
        % encoded. This causes funcs to return as a matrix, which will
        % break the later analysis.
        if ~iscell(funcs)
            funcs = {};
        end %if
        repo_data.tree(func_ind,1).funcs_called = funcs;

        %% Adding the modification info to the structure.
        repo_data.tree(func_ind,1).last_modified_date = f_date;
        repo_data.tree(func_ind,1).last_modified_by = f_auth;
        repo_data.tree(func_ind,1).containing_m_file = file_list{m_file_ind};
        
        func_ind = func_ind + 1;
    end %for
end %for
fprintf('\n')
%--------------------------------------------------------
%% Working out the functions calling each functions
repo_data.tree = find_dependencies(repo_data.tree);
