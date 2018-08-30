function generate_top_level_html(html_path, dotty_path,  html_loc)
% Generates the html for the top level page of teh matalb code analysis.
%
% Example: generate_top_level_html(html_path, dotty_path,  html_loc)

tl_file_data = cell(7,1);
tl_file_data{1} = ['<html><body><hl><B> Last updated: ',datestr(now), '</B><br />'];
tl_file_data{2} = '<html><body><hl><B> Duplicated names: </B><br />';
tl_file_data{3} = cellstr(strcat('<a href="',html_path,'/duplicates.html">Duplicates</a>'));
tl_file_data{4} = '<br>';
tl_file_data{5} = '<html><body><hl><B> Folders in repository: </B><br />';
tl_file_data{6} = ['<object data="', dotty_path, '/Repository.svg" type-"image/svg+xml">'];
tl_file_data{7} = '';
 
write_out_data(tl_file_data, fullfile(html_loc, 'Repository.html'))

