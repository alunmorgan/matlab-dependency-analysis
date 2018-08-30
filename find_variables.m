function varibs = find_variables(code)
% Example: varibs = find_variables(code)
varibs = {};
% setting up some sets for the regular expressions
not_words = '[\s-+*\/\(\)\[\]\{\}\;\:,]';
for msen = 1:length(code)
    code_lines_var  = code{msen};
    % reforming the function line so as to be recognised by the rest of
    % the code
    if isempty(regexp(code_lines_var, '^\s*function ','ONCE')) == 0
        code_lines_var  = regexprep(code_lines_var, '^\s*function','');
        code_lines_var  = regexprep(code_lines_var, '\[','');
        code_lines_var  = regexprep(code_lines_var, '\]','');
        [mes1, sds1] =  regexp(code_lines_var, '^.*=');
        [mes2, sds2] =  regexp(code_lines_var, '\(.*\)');
        if isempty(mes1) == 1 && isempty(mes2) == 0
            code_lines_var = strcat('[',code_lines_var(mes2+1:sds2-1),'] =');
        elseif isempty(mes1) == 0 && isempty(mes2) == 1
            code_lines_var = strcat('[',code_lines_var(mes1:sds1-1),'] =');
        elseif isempty(mes1) == 0 && isempty(mes2) == 0
            code_lines_var = strcat('[',code_lines_var(mes1:sds1-1),...
                ',',code_lines_var(mes2+1:sds2-1),'] =');
        end %if
    end %if
    
    % skip lines with no = except if the first word is clear
    if isempty(regexp(code_lines_var, '=','ONCE')) == 1 &&...
            isempty(regexp(code_lines_var, '^\s*clear','ONCE')) == 1
        continue
    end %if
    % reforming the clear command into  the form expected by the next
    % code
    if  isempty(regexp(code_lines_var, '^\s*clear','ONCE')) == 0
        code_lines_var  = regexprep(code_lines_var, '^\s*clear','');
        code_lines_var = strcat(code_lines_var,' =');
    end %if
    % Only takes the code to the left of the =
    code_lines_var = regexprep(code_lines_var, '^([^=]*)(=[=<>~]*)(.*)$', '$1$2');
    % skipping the lines which are boolean rather than assignments
    if length(code_lines_var) == 1 || isempty(regexp(code_lines_var(end-1:end), '=[=<>~]','ONCE')) == 0
        continue
    end %if
    % removing the trailing booeans
    code_lines_var = regexprep(code_lines_var, '=[=<>~]*$', '');
    %------------------------------------------------------
    % Splitting the lines into words
    %         code_lines_var  = regexprep(code_lines_var, not_words, ',');
    [var_temp] = splitting_lines(code_lines_var);
    
    %     if exist('varibs','var') == 1
    if ~isempty(var_temp)
        for ja = 1:size(var_temp,1)
            varibs{end+1} = var_temp(ja,:);
        end %for
    end %if
    clear var_temp code_lines_var
end %for

if isempty(varibs) == 0
    % removing commas and brackets
    varibs = regexprep(varibs, not_words, '');
    %removing substructure of strucs
    varibs = regexprep(varibs, '\..*', '');
    varibs = unique(varibs);
    if isempty(varibs{1}) == 1
        varibs = varibs(2:end);
    end %if
end %if

