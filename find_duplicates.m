function [dup_list, unique_duplicated_names, all_duplicates] = find_duplicates(nodes)
% Removing duplicate names if the file is in more than one location
% NEED TO WORK OUT HOW TO DEAL WITH THIS SITUATION.
hsdf = NaN(length(nodes),1);
for hs = 1:length(nodes)
    jd = 0;
    for se = 1:length(nodes)
        if strcmp(nodes(hs).name_cell,nodes(se).name_cell)
            jd = jd +1;
        end %if
    end %for
    if jd >1
        hsdf(hs) = jd;
    end %if
end %for
dup_inds = isnan(hsdf) ==0;
all_duplicates = nodes(dup_inds);
if isempty(all_duplicates)
    dup_list = [];
    unique_duplicated_names = [];
    all_duplicates = [];
else
    for nf = length(all_duplicates):-1:1
        all_duplicated_names(nf) = all_duplicates(nf).name_cell;
        all_duplicated_paths{nf} = all_duplicates(nf).place;
        containing_files{nf} = all_duplicates(nf).containing_m_file;
        modified_by{nf} = all_duplicates(nf).modified_by;
        modified_when{nf} = all_duplicates(nf).modified_date;
    end %for
    unique_duplicated_names = unique(all_duplicated_names);
    dup_list = {'Duplicated function names found<br>'};
    for hksej = 1:length(unique_duplicated_names)
        dup_list{end+1,1} = ['<B>',unique_duplicated_names{hksej},'</B><br>'];
        is_duplicate = strcmp(unique_duplicated_names{hksej}, all_duplicated_names);
        temp1 = all_duplicated_paths(is_duplicate == 1);
        temp2 = containing_files(is_duplicate == 1);
        temp3 = modified_by(is_duplicate == 1);
        temp4 = modified_when(is_duplicate == 1);
        for heha = 1:length(temp1)
            dup_list{end+1,1} = strcat(temp1{heha},' -', ...
                ' in  <I>', temp2{heha}, '</I>', ...
                ' last modified by <B>', temp3{heha}, '</B>',...
                ' on ', temp4{heha},...
                '<br>') ;
        end %for
        clear temp
        dup_list{end+1,1} = ' ';
    end %for
end %if