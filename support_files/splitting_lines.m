function [word_list] = splitting_lines(input_line)
% splits a line into active words
% outputs the word list

% setting up some sets for the regular expressions
not_words = '[\s-+\*\/\(\)\[\]\{\}\;\:,\\\=]';
% must start with a letter 
are_words = '[a-zA-Z][\w\.]*';

% duplicating up as the regexp command does not find
%         % overlaying patterns.
input_line  = regexprep(input_line, ',', ',,');
input_line  = regexprep(input_line, ' ', '  ');
% check if it is just one name on the line
[st, en] =  regexp(input_line,['^\s*' are_words '\s*$']) ;
% otherwise split the line
if isempty(st) == 1
    [st1, en1] =  regexp(input_line,strcat('^\s*',are_words,not_words)) ;
    [st2, en2] =  regexp(input_line,strcat(not_words,are_words,not_words)) ;
    [st3, en3] =  regexp(input_line,strcat(not_words,are_words,'\s*$')) ;
    st = [st1 st2+1 st3+1];
    en = [en1-1 en2-1 en3];
end

if isempty(st) == 0
    temp = input_line(st(1):en(1));
    for hd = 2:length(st)
        temp = char(temp,input_line(st(hd):en(hd)));
    end
    word_list = temp;
else
    word_list = [];
end