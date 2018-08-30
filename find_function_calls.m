function funcs = find_function_calls(code, varibs, core_paths, orig_path)
% Parses the code line by line and identifies function calls.
%
% Args:
%       code (cell): Code to be analysed.
%       varibs (cell): List of known variables.
%       core_paths (cell): location of sudo builtin functions , not to be
%                          considered for analysis.
%       orig_path (cell): The original list of paths. Before analysis began.
% Example: funcs = find_function_calls(code, varibs, core_paths, orig_path)

% setting up some sets for the regular expressions
not_words = '[\s-+*\/\(\)\[\]\{\}\;\:,]';
for msen = 1:length(code)
    code_lines_func =  code{msen};
    
    % splitting each line into words
    %         code_lines_func  = regexprep(code_lines_func, not_words, ',');
    [funcs_temp] = splitting_lines(code_lines_func);
    
    if exist('funcs','var') == 1
        funcs = char(funcs,funcs_temp);
    else
        funcs = funcs_temp;
    end %if
end %for
clear funcs_temp code_lines_func

if exist('funcs','var') == 1 && isempty(funcs)  == 0
    funcs = cellstr(funcs);
    %removing commas and brackets and spaces
    funcs = regexprep(funcs, not_words, '');
    %removing substructure of strucs
    funcs = regexprep(funcs, '\..*', '');
    funcs = unique(funcs);
    % removing known variables from the list
    funcs = setdiff(funcs,varibs);
    % removing the current function from the list
    function_loc = find_position_in_cell_lst(regexp(code,'^\s*function\s'));
    if ~isempty(function_loc)
        [f_name,~] = regexp(code(function_loc),...
            '^\s*function\s+(?:\[.*\]\s*=\s*|[a-zA-Z0-9_]+\s*=\s*)?([a-zA-Z0-9_]*)(?:\(.*\))?','tokens','match');
        f_name = f_name{1}{1};
        funcs(strcmp(funcs,f_name)) = [];
    end %if
    %removing function from the list
    funcs = regexprep(funcs, 'function', '');
    %removing NaN from the list
    funcs = regexprep(funcs, 'NaN', '');
    % removing builtin functions from the list
    bn = zeros(1,length(funcs));
    % turning off warnings prior to the next bit of code
    w_state = warning('query', 'all');
    warning('off', 'all');
    % changing path to only use the core system paths.
    path(core_paths);
    
    for qr = 1:length(funcs)
        if isempty(funcs{qr}) == 1
            % no function
            continue
        end %if
        if exist(funcs{qr},'builtin') == 5
            %function is builtin
        elseif exist(funcs{qr},'file') == 2
            % function is on the search path (this means that the
            % directory tree being analysed must be removed from the
            % path beforehand (done at begining))
        else
            %function is home made
            bn(qr) = 1;
        end %if
    end %for
    %restoring the previous warning state
    warning(w_state);
    funcs(bn ==0) = [];
%     % Restoring original path
    path(orig_path)
end %if

