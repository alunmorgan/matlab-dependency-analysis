function doc_generate_folder_structure(output_loc)
% Creates the folder structure expected by the auto_documentation tools.
% 
% Args:
%       output_loc (str): Root location of output file structure.
% Example: doc_generate_folder_structure(output_loc)

if exist(output_loc,'dir') == 0
    mkdir(output_loc);
    mkdir(output_loc,'html_code');
    mkdir(output_loc,'Code_trees');
    mkdir(fullfile(output_loc, 'Code_trees'),'dot_files');
    mkdir(fullfile(output_loc, 'Code_trees'),'dotty_files');
else
    if exist(fullfile(output_loc, 'Code_trees'),'dir') == 0
        mkdir(output_loc,'Code_trees');
        mkdir(fullfile(output_loc, 'Code_trees'),'dot_files');
        mkdir(fullfile(output_loc, 'Code_trees'),'dotty_files');
    else
        if exist(fullfile(output_loc, 'Code_trees', 'dot_files'),'dir') == 0
            mkdir(fullfile(output_loc, 'Code_trees'),'dot_files');
        end %if
        if exist(fullfile(output_loc, 'Code_trees', 'dotty_files'),'dir') == 0
            mkdir(fullfile(output_loc, 'Code_trees'),'dotty_files');
        end %if
    end %if
    if exist(fullfile(output_loc, 'html_code'),'dir') == 0
        mkdir(output_loc,'html_code');
    end %if
end %if