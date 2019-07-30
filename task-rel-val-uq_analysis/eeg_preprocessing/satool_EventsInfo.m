% satool_EventsInfo() - Count the number of events for each marker types. Draw
% two figure: one representing the timing of each marker, one representing
% the inter marker timing for each event type.
%
% Usage:
%   >>  EEG = satool_EEGinfo(EEG);
%
% Inputs:
%   EEG     - input EEG structure
%    
% Outputs:
%   EEG     - output EEG structure
%
% See also: 
%   EEGLAB 

% Copyright (C) 2012 Sara Assecondi 2012-11-16
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


function [EEG] = satool_EventsInfo(EEG,reportfullpath)

if nargin < 2, 
    fid = 1;                        % write output on screen
    fprintf('Writing output to screen\n')
else fid = fopen(reportfullpath,'w+');   % write output on file
    fprintf('Writing output to file %s\n',reportfullpath)
end

fprintf(fid,'#---------------------------------------------------\n');
fprintf(fid,'#.Genearal dataset information......................\n');
fprintf(fid,'#.filename..................:%s\n',EEG.filename);
fprintf(fid,'#.filepath..................:%s\n',EEG.filepath);
fprintf(fid,'#.setname...................:%s\n',EEG.setname);
fprintf(fid,'#.number of channels........:%d\n',EEG.nbchan);
fprintf(fid,'#.number of epochs..........:%d\n',EEG.trials);
fprintf(fid,'#.number of points..........:%d\n',EEG.pnts);
fprintf(fid,'#.sampling frequency........:%d\n',EEG.srate);
fprintf(fid,'#.number of events..........:%d\n',length(EEG.event));
fprintf(fid,'#---------------------------------------------------\n');
fprintf(fid,'Type\tCount\t\n');



% CALCULATE STATISTICS AND WRITE IN FILE
% ----------------------------------------
[types,numbers] = eeg_eventtypes(EEG);
% sort events for better plotting layout
[~,idx] = sort(str2double(types));
types   = types(idx);
numbers = numbers(idx);
clear idx

nTypes  = length(types);
times   = [1:EEG.pnts]/EEG.srate;

h = figure('Name','Marker timing');
cmap = colormap(autumn(nTypes));

for iType = 1:nTypes
    fprintf(fid,'%s\t%d\t\n',types{iType},numbers(iType));
    % MARKER TIMING
    % --------------
    if isnumeric([EEG.event.type])
        thisMrk = ([EEG.event.type]== str2num(types{iType}));
    elseif ischar([EEG.event.type])
        thisMrk = strcmp({EEG.event.type},types{iType});
    end
    
    thisLat = ceil([EEG.event(thisMrk).latency]); % latency are supposed to be points=integer
    plot(times(thisLat),(nTypes-iType+1)*ones(size(thisLat)),'color',cmap(iType,:),...
        'Marker','o','MarkerFaceColor',cmap(iType,:),'MarkerSize',5,'LineStyle','None');
    hold on
    
end
set(gca,'YLim',[0 nTypes+1+0.5],'XLim',[times(1) times(end)],...
    'YTick',[1:nTypes],'YTickLabel',flipud(types),...
    'XGrid','On','XMinorGrid','On','YGrid','On')

xlabel('time (s)')
title(EEG.setname,'Interpreter','None')

if fid > 1
    % CLOSE REPORT FILE
    % -------------------
    [path,name,~] = fileparts(reportfullpath);
    fclose(fid);
    %export_fig([path filesep name '_fig.pdf'],'-pdf','-nocrop','-transparent','-r300',h)
    saveas(h, [path filesep name '_fig.pdf']);
    disp(['A new EventList file was created at <a href="matlab: open(''' reportfullpath ''')">' reportfullpath '</a>'])
end
return
