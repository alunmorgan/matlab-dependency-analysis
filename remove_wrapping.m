function linebyline = remove_wrapping(linebyline)
% Reconstructs wrapped lines onto a single line.
% Example: linebyline = remove_wrapping(linebyline)
lc = size(linebyline,1);
for ms = 1:lc-1
    % counting from the bottom
    wne = lc - (ms - 1);
    expr = '\.\.\.\s*$';
    if isempty(regexp(linebyline{wne - 1},expr,'ONCE')) == 0
        linebyline{wne - 1} = regexprep(linebyline{wne - 1},expr, '');
        linebyline{wne - 1} = strcat(linebyline{wne - 1},linebyline{wne});
        linebyline(wne) = [];
    end %if
end %for

