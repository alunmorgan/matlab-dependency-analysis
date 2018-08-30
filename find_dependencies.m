function repo_data = find_dependencies(repo_data)
% Works through the function names in repo_data and finds the dependencies
% between them.
% 
% Args:
%      repo_data (structure): all functions found by the indexing routine.
% Example: repo_data = find_dependencies(repo_data)
disp('Calculating dependencies...');
for sen=1:length(repo_data)
    calledby = cell(1);
    calledby{1} = '<B>None</B>';
    for hse=1:length(repo_data)
        %since we dont need to search through function which call the
        %present to see if they are called by the present one
        m_ind = find(strncmp(repo_data(sen,1).val, ...
                             repo_data(hse,1).funcs_called, ...
                             length(repo_data(sen,1).val)));
        if sen~=hse && isempty(m_ind) == 0
            caller_temp = cellstr(repo_data(hse,1).val);
            calledby = cat(1,calledby,caller_temp);
            clear caller_temp
        end %if
    end %for
    if size(calledby,1) > 1
        calledby = calledby(2:end);
    end %if
    repo_data(sen,1).calledby = unique(calledby);
    fprintf('.')
end %for
fprintf('\n')