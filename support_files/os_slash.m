function slash = os_slash
% outputs the relavent forward/back slash depending on the OS

% getting the correct slash for the operating system
if ispc == 0
    slash = '/';
else
    slash = '\';
end