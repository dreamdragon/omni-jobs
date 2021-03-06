function [stats] = report(stats, varargin)
% Print a status report on a batch job directory.
%
% Usage:
%  
%   stats = oj_report(jobsdir, ...)
%   oj_report(stats, ...)
%
% Given the name of a directory, calls OJ.STATS to compute
% statistics of running jobs and displays the output in an
% easy-to-parse format. 
%
% ** IMPORTANT ** This function is pretty old and out-of-date. It
% tends to think jobs have crashed even when they are still running
% if anything is output to stderr. 
%
% Options: See options of OJ.STATS.
%
% SEE ALSO
%   oj.stats, oj.quickbatch

% ======================================================================
% Copyright (c) 2012 David Weiss
% 
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject to
% the following conditions:
% 
% The above copyright notice and this permission notice shall be
% included in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
% LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
% OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
% WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
% ======================================================================

defaults.usetotal = false;
defaults.detailed = false;
defaults.onlyerror = false;
defaults.onlyrunning = false;
defaults.showresubmit = false;

[args unused] = propval(varargin, defaults);

if ~isstruct(stats)    
  if isstr(stats)
    stats = oj.stats(stats, unused{:});    
  else
    error(['Input must be a string (JOBSDIR) or a structarray ' ...
           '(STATS).']);
  end    
end

if args.usetotal
  fprintf('There are %d jobs total.\n', numel(stats));
end
fprintf('%d jobs have been submitted.\n', count([stats.submitted]));
fprintf('%d jobs have been started.\n', count([stats.started]));
fprintf('%d jobs have completed succesfully.\n', count([stats.completed]));
fprintf('%d jobs have crashed.\n', count([stats.crashed]));
fprintf('%d jobs are still running.\n', count([stats.running]));
fprintf('%d jobs are MIA.\n', count([stats.mia]));

% Output estimated time to completion:

if (count([stats.completed]) > 0)
  
% number of jobs remaining
if args.usetotal
  totaljobs = numel(stats);
else
  totaljobs = count([stats.submitted]);
end
remainingjobs = totaljobs - count([stats.crashed]) - ...
    count([stats.completed]);

% average running time of completed jobs:
idx = find([stats.completed]);
avgtime = mean([stats(idx).run_time]);

% compute estimated time remaining:
totaltime = avgtime * remainingjobs;

% adjust for current runtime
idx = find([stats.running]);
totaltime = totaltime - sum([stats(idx).run_time]);

if totaltime > 0
  
  fprintf('\nApproximately %g hours computation time remaining.\n', ...          
          totaltime/3600);

  fprintf('(%d jobs remaining x %g hrs/job = %g hours.)\n', ...
          remainingjobs, avgtime/3600, remainingjobs*avgtime/3600);
  
  fprintf('(%d running jobs accumulated %g hrs so far.)\n', ...
          count(idx), sum([stats(idx).run_time])/3600);
  
  eta = estimate(totaltime./count(idx));
%   eta = totaltime/count(idx)/3600;
%   if (eta < 1)
%     eta = sprintf('%g minutes', eta*60);
%   else
%     eta = sprintf('%g hours', eta);
%  end
  
  fprintf('ETA: %s. (Assuming %d batch nodes available.)\n', ...
          eta, count(idx));
  
elseif count([stats.running]) == 0
  
  fprintf('\nAll jobs in queue processed. (Avg runtime: %g minutes.)\n', ...
          avgtime/60);

elseif totaltime < 0
  
  fprintf('\nQueue completion is %g minutes overdue.\n', ...
            -totaltime/60);
  fprintf('(Average runtime: %g minutes.)\n', avgtime/60);
  
else
  fprintf('\nAvg runtime: %g minutes.\n', avgtime/60);
end

end

function printjob( stats )

if stats.complete == 1
  status = 'COMPLETE';
elseif stats.error == 1
  status = 'ERROR';
elseif stats.started == 1

  if stats.hangtime > 15/60 
    status = 'RUNNING - MAYBE HANGING';
  elseif stats.hangtime > 1
    status = 'HANGING';
  else
    status = 'RUNNING';
  end
  
else
  status = 'WAITING';
end 

fprintf('Job name:%s\n', stats.jobname);
fprintf('Job status: %s\n', status);

if stats.submitted == 1  
  fprintf('Submitted:\tYes');
  
  if stats.started == 0
    fprintf('\n');
    fprintf('Started:\tNo\n');
  else
    fprintf('\tStart Time:\t%s\tElapsed:\t%g hours\n', stats.starttime, ...
          stats.elapsed);
    fprintf('Started:\tYes\tLast Modified:\t%s\tHangtime:\t%g hours\n', ...
            stats.lastmodified, stats.hangtime);
    
    if stats.error == 1
      fprintf('Error State:\tYes\tError Message:\n\n');
      display(stats.errormsg);
      fprintf('\n');
      
    else
      fprintf('Error State:\tNo\n');
    end    
    
    if stats.complete == 1
      fprintf('Completed:\tYes\tFinished:\t%s\tRuntime:\t%g hours\n', ...
              stats.finished, stats.runtime);
    else
      fprintf('Completed:\tNo\n');
    end
  end
  
else 
  fprintf('Submitted:\tNo\n');
end

fprintf('\n');
  
  
    
  








