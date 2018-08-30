function inds = isempty_cell(ca)
% find the indicies of a cell array which are not empty
inds = 0;
for hs = 1:length(ca)
    if isempty(ca{hs}) == 0
        inds = cat(1,inds,hs);
    end
end
inds = inds(2:end);