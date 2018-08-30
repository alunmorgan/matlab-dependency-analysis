function globs = find_global_variables(code)
% Example: globs = find_global_variables(code)
glob_loc = strfind(code,'global ');
globs = {};
if isempty(cell2mat(glob_loc)) == 0
    for wq = 1:length(glob_loc)
        if isempty(glob_loc{wq})
            glob_loc{wq} = 0;
        end %if
    end %for
    glob_loc = cell2mat(glob_loc);
    glob_loc = find(glob_loc > 0);
    for jkhrt = 1:length(glob_loc)
        [globs_temp] = splitting_lines(code{glob_loc(jkhrt)});
        if ~isempty(globs_temp)
            for awh = 1:size(globs_temp,1)
                globs{end+1} = globs_temp(awh,:);
            end %for
        end %if
    end %for
end %if

