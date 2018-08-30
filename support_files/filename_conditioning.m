function name_list = filename_conditioning(name_list)
% removes empty entries and replaces spaces and - with _ from a cell array
% of strings (can cope with nested cells).
hs = [];
fw = 1;
ch = 0;
if ischar(name_list) == 1
    name_list = {name_list};
    ch = 1;
end
for nad = 1:length(name_list)
    tmp_name = name_list{nad};
    if iscell(tmp_name) == 1
        tmp_name = filename_conditioning(tmp_name);
    else
        % replace spaces with _
        tmp_name = regexprep(tmp_name,' ','_');
        % replace - with _
        tmp_name = regexprep(tmp_name,'-','_');
         %     if there is no name left mark entry for removal
        if isempty(tmp_name) == 1 || ...
                size(tmp_name,1) == 0 ||...
                size(tmp_name,2) == 0
            hs(fw) = nad;
            fw = fw + 1;
            continue
        end
        % if _ is at the begining remove.
        if strcmp(tmp_name(1),'_') == 1
            tmp_name(1) = [];
        end
        %     if there is no name left mark entry for removal
        if isempty(tmp_name) == 1;
            hs(fw) = nad;
            fw = fw + 1;
            continue
        end
    end
    name_list{nad} = tmp_name;
    clear tmp_name
    
end
% remove empty cells
name_list(hs) = [];
if ch == 1
    if isempty(name_list) ==1
        name_list = '';
    else
    name_list = name_list{1};
    end
end
