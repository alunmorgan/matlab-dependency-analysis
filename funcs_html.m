function funcs_html(nodes, dup_list, html_loc, html_path, dotty_path)
% converts the file relationship data into a set of html pages
%
% Example: funcs_html(nodes, dup_list, html_loc, html_path, dotty_path)

% writing an html file containing the duplicate file details.
fid = fopen(fullfile(html_loc ,'duplicates.html'),'w+');
if fid == -1
    warning([fullfile(html_loc ,'duplicates.html'), ' apparently does not exist!'])
else
    for be = 1:length(dup_list)
        mj = char(dup_list{be});
        fwrite(fid,mj);
        fprintf(fid,'\n','');
    end %for
    clear be mj
    fclose(fid);
end %if

for eua = length(nodes):-1:1
    node_places{eua} = regexprep(nodes(eua).place,'@','>');
%     node_colours{eua} = nodes(eua).html_colour;
end %for

[unique_places, ia, ~]= unique(node_places);
% unique_colours = node_colours(ia);

%% generating an html file for each folder.
for nw = 1:length(unique_places)
    temp_place = regexprep(unique_places{nw},'@','>');
    %% Initial setup of html file
    inst = cell(3,1);
    inst{1} = '<html><body>';
    inst{2} = cellstr(strcat('<hl><B> Location in repository: </B> ',...
        '<a href="',html_path,'/Repository.html">Repository</a>','/',...
        temp_place,'</hl><br />'));
    inst{3} = '<table border="1" cellpadding="10">';
    
    % find the nodes which are in the current folder
    n_in_place = find(strcmp(node_places, temp_place));
    for qp = 1:length(n_in_place)
        table_1_temp = html_generate_tables(nodes(n_in_place(qp)), dotty_path, html_path);
        inst = cat(1, inst, table_1_temp);
        clear table_1_temp
    end
    clear n_in_place
    inst = cat(1,inst, '</table>');
    inst = cat(1,inst, '</body></html>');
    
    %% -------------------- Writing the file ------------------------------
    if length(inst) < 5
        %        Only the header has been constructed
        % therefore there is no useful information.
        continue
    end
    write_out_data(inst, fullfile(html_loc, [temp_place '.html'])) 
end

