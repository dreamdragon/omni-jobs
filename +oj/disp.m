function [] = oj_disp(results, varargin)
% Nicely display an opusjobs results structarray as a data table.
%
% OJ_DISP(RESULTS)
% 
% 
 
% check fields for special properties
[maxwidth varargin] = getpropval(varargin, 'maxwidth', 20);
[precision varargin] = getpropval(varargin, 'precision', '%-7.5g');

% first row: header row
if isempty(varargin)
  fields = fieldnames(results)'; % Decode field names
  for j = 1:numel(fields)
      if ~isfield(results, fields{j})
          fields{j} = oj_encode(fields{j});
      else
          fields{j} = oj_decode(fields{j});
      end
  end
else
  fields = varargin;
end

displaydat = oj_get(results, 'mixed', fields{:});
if numel(fields) == 0
  error('Programmer''s error. Should not be possible to specify no fields.');
end

displaydat = horzcat(cell(rows(displaydat),1), displaydat);
for j = 1:rows(displaydat)
    displaydat{j,1} = j;
end
fields = horzcat({'#'},fields);

for i = 1:numel(fields)
  minwidths(i) = numel(fields{i});
end

[str, colwidth] = oj_cell2str(displaydat, 'minwidth', minwidths, ...
                           'maxwidth', maxwidth, 'precision', precision);

title = ' ';
for i = 1:numel(fields)
  strf = sprintf('%%-%d.%ds ', colwidth(i), colwidth(i)); 
  title = [title sprintf(strf, fields{i})];
end
title = [title; repmat('-', 1, cols(title))];

disp(title);
disp(str);
