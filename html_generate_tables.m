function inst_temp = html_generate_tables(node, pic_loc, html_loc)
% Generate the html for tables showing the parents and children of 
% the named function.
%
% Example: inst_temp = html_generate_tables(node, pic_loc, html_loc)

inst_temp = cell(1,1);
% getting the description for this node
desc = node.description;
desc = regexprep(desc, '^\s*(?:e|E)xample[:]*', '<br /><i style="color:red;">Example</i>:<br />');
desc = regexprep(desc, '\%[\%]+\%', '<br />');
desc = regexprep(desc, '^\s*(\[.+\])\s*=\s*', '<b>$1</b> = ');
desc = regexprep(desc, '^\s*([\w]+)\s*=\s*', '<b>$1</b> = ');
desc = regexprep(desc, '^\s*([\w]+\s*=)\s*<br />', '$1 ');
desc = regexprep(desc, '^\s*(\[.+\]\s*=)\s*<br />', '$1 ');
desc = regexprep(desc, '(.*)$', '$1<br>');
if length(desc) >1
    dt = desc{1};
    for wan = 2:length(desc)
       dt = strcat(dt,desc{wan}); 
    end %for
desc = cellstr(dt);    
end %if

    inst_temp = cat(1,inst_temp,'<tr><td colspan="3"></td></tr>');
    % if there is a subfunction called then reference the function diagram.
    if ~isempty(node.children) 
       ct = cellstr(strcat('<a href="',pic_loc,'/',...
           node.name_cell, '.svg">(code_tree)</a>'));
    else
        ct = '';
    end %if
    inst_temp = cat(1,inst_temp,cellstr(strcat('<tr> <td bgcolor = "#B0B0B0"> <B>',...
    '<a name="',node.name_cell,'">',node.name_cell,'</a> </B>',ct,'<br> Last modified&nbsp;',...
        node.modified_date,' by&nbsp;',node.modified_by,' </td> <td colspan="2" bgcolor="#E8E8E8">',...
        desc, '</td> </tr> ')));
clear desc
if ~isempty(node.parents) || ~isempty(node.children)
    inst_temp = cat(1,inst_temp,cellstr('<tr><td></td>'));
    inst_temp = cat(1,inst_temp,cellstr(strcat('<td bgcolor="#C0C0C0"> <B>Used by these functions:</B></td>')));
    inst_temp = cat(1,inst_temp,cellstr(strcat('<td bgcolor="#C0C0C0"> <B>Calls these functions:</B></td>')));
    inst_temp = cat(1,inst_temp,cellstr('</tr>'));
    if length(node.parents) > length(node.children)
        l_loop = length(node.parents);
    else
        l_loop = length(node.children);
    end %if
    for qwd = 1:l_loop
        inst_temp = cat(1,inst_temp,'<tr><td></td>');
        if qwd <= length(node.parents)
            inst_temp = cat(1,inst_temp,strcat( ...
            '<td bgcolor="#F0F0F0"><a href=',html_loc,'/' ,...
            regexprep(node.parents_loc{qwd},'@','&gt;'),'.html#'...
            ,node.parents{qwd},'>',node.parents{qwd},'</a></td>'));
        else
            inst_temp = cat(1,inst_temp,strcat( '<td  bgcolor="#F0F0F0"></td>'));
        end %if
        if qwd <= length(node.children)
            inst_temp = cat(1,inst_temp,strcat( ...
            '<td  bgcolor="#F0F0F0"><a href=',html_loc,'/' ,...
            regexprep(node.children_loc{qwd},'@','&gt;'),'.html#',...
            node.children{qwd},'>',node.children{qwd},'</a></td>'));
        else
            inst_temp = cat(1,inst_temp,strcat( '<td  bgcolor="#F0F0F0"></td>'));
        end %if
        inst_temp = cat(1,inst_temp,'</tr>');
    end %for
    clear qwd
end %if
inst_temp = inst_temp(2:end);

