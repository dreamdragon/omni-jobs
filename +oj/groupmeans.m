function [groups] = groupmeans(data, fx, fys, varargin)
% Computes the mean of several fields when grouped by other fields.
% 
% SEE ALSO
%   OJ.GROUP 

[grp groups] = oj.group(data, fx{:});

for j = 1:numel(fys)

    clear y yvar ystd n
    fy = fys{j};
    for i = 1:numel(groups)
        y(i,:) = mean(oj.get(data(grp==i), fy));
        yvar(i,:) = var(oj.get(data(grp==i), fy));
        ystd(i,:) = std(oj.get(data(grp==i), fy))/sqrt(sum(grp==i));
        n(i) = sum(grp==i);
    end
    
    groups = oj.set(groups, [fy ' (Mean)'], y);
    groups = oj.set(groups, [fy ' (Ste)'], ystd);
end
groups = oj.set(groups, 'n', n);

