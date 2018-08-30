function nodes = remove_duplicates(nodes, unique_duplicated_names, all_duplicates)
% remove all but one of the duplicated nodes.
% Example: nodes = remove_duplicates(nodes, unique_duplicated_names, all_duplicates)

jfd = 1;
grp = [];
for seh = 1:length(unique_duplicated_names)
    for ehs = 1:length(all_duplicates)
        if strcmp(unique_duplicated_names{seh}, all_duplicates(ehs).name_cell)
            grp(jfd) = ehs;
            jfd = jfd +1;
        end %if
    end %for
    % take the last on off the list.
    jfd = jfd -1;
end %for
grp = grp(1:end-1);
hsaw = [];
for ja = length(grp):-1:1
    hsaw(ja) = all_duplicates(grp(ja)).number;
end %for
% remove the duplicates
nodes(hsaw) = [];

% now renumber each node
for sen = 1:length(nodes)
    nodes(sen).number = sen;
end %for