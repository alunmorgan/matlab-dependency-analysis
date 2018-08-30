function [inst, cols] = code_tree_walk(func, nodes, inst, cols, html_loc)
% Uses the nodes structure to generate the dot syntax for the diagram
% creation.
% Args:
%       func (str): name of the current function being assessed.
%       nodes (structure): Contains the interrelationships between the nodes.
%       inst (cell): dot code fro generating graph.
%       cols (cell array): The colours associated with each node.
%       html_loc (str): The final path at which the html code will be placed.
% Returns:
%       inst (cell): dot code fro generating graph.
%       cols (cell array): The updated colours associated with each node.
% Example: [inst, cols] = code_tree_walk(func, nodes, inst, cols, html_loc)
source_node_name = char(nodes(func).name_cell);
source_node_name = regexprep(source_node_name, '_', '\\n');
inst = cat(1,inst,cellstr(strcat('"',source_node_name,'"[fillcolor="',...
    nodes(func).colour,'",style=filled,len=0.5, URL="',html_loc , '/',...
    regexprep(nodes(func).place, '@', '>') ,'.html#',nodes(func).name,'",target="_top"];')));
cols{end+1} = nodes(func).colour;
% deps = node_links(node_links(:,1) == func,2);
for kw = 1:length(nodes(func).children)
    % to stop self recursion
    if func==nodes(func).children_num(kw)
        continue
    end
    node_name = char(nodes(func).children{kw});
    node_name = regexprep(node_name, '_', '\\n');
    % This is to stop bouncing in the case that 2 functions reference each
    % other
    if isempty(isempty_cell(strfind(inst,char(strcat('"',source_node_name, '" -> "',node_name,'"')))))
        inst = cat(1,inst,cellstr(strcat('"',source_node_name, '" -> "',node_name,'"')));
        [inst, cols] = code_tree_walk(nodes(func).children_num(kw),nodes,inst, cols, html_loc);
    end
end