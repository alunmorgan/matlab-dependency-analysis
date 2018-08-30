function funcs_dot_lang(nodes, html_loc, out_dir, cols, unique_places)
% converts the file relationship data into the dot attributed graph language
%for use in visualisation
%
% Example: funcs_dot_lang(nodes, html_loc, out_dir, cols, unique_places)

%% Generating the dot files
for nw = 1:length(nodes)
    clear cols_used
    top_level_name = char(nodes(nw).name_cell);
    top_level_name = regexprep(top_level_name, '_', '\\n');
    inst = cell(1);
    inst{1,1} = ['digraph "', top_level_name , '" {'];
    inst{2,1} = '';
    inst{3,1} = 'concentrate=true';
    inst{4,1} = 'fontcolor=black';
    inst{5,1} = 'overlap=false';
    inst{6,1} = 'splines=true';
    inst{7,1} = 'sep=0.2';
    inst{8,1} = ['root="',top_level_name,'"'];
    inst{9,1} = 'nodesep=0.2';
    inst{10,1} = 'ranksep=0.2';
    inst{11,1} = 'K=0.01';
    [inst, cols_used] = code_tree_walk(nodes(nw).number,nodes,inst,{}, html_loc);
    
    unique_paths = regexprep(unique_places, '@', '/');
    cols_used = unique(cols_used);
    place_names ='';
    for ehf = 1:length(cols_used)
        unique_loc =  unique_paths{find_position_in_cell_lst(strfind(cols, cols_used{ehf}(2:end)))};
        inst{end+1,1} = ['"', unique_loc,...
            '"[fillcolor="',cols_used{ehf},'", style=filled,len=0, shape=box];'];
        if ehf == 1
            place_names = [place_names, ' "',unique_loc, '"'];
        else
            place_names = [place_names, '-> "',unique_loc, '"'];
        end %if
    end %for
    inst{end+1,1} = ['subgraph cluster_0 {node [shape=rectangle,fontname=Bold] ',...
        place_names, '[dir=both color="white"] label="Colour codes"}'];
    inst = cat(1,inst,cellstr('}'));
    % Writing the file
    write_out_data(inst, fullfile(out_dir, [char(nodes(nw).name_cell) '.dot']))
end %for
