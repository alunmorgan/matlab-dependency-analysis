function core_path = get_core_paths(sudo_builtins)
% find the paths containing the root location of any in house builtin functions.
% I have assumed that anything in this root location can be treated as a 
% system builtin and every thing else is user code.
%
% Example core_path = get_core_paths('in_house_function_root')

    % getting the original search path
    orig_path = path;
    % removing all paths that do not reside in in house builtin root location.
    bks = strfind(orig_path,':');
    fd = {};
    ck = 1;
    cur_path = orig_path(1:bks(1));
    if ~isempty(strfind(cur_path, sudo_builtins))
        fd{ck} = cur_path;
        ck = ck +1;
    end %if
    for nd = 1:length(bks)-1
        cur_path =  orig_path(bks(nd)+1:bks(nd+1));
        if ~isempty(strfind(cur_path, sudo_builtins))
            fd{ck} = cur_path;
            ck = ck +1;
        end %if
    end %for
    d = char(fd);
    core_path = reshape(d',1,[]);
    core_path = regexprep(core_path,'\:\s*\/','\:\/');