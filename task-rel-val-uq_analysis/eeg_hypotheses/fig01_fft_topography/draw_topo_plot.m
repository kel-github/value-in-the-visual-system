function [] = draw_topo_plot( data, spl, type, scale )
%MAKE TOPO PLOT - present pwr differences between configs on realistic head
%model, using previously made spl file

% data is a 1 x 64 vector
% spl is the path to a pre-made spl file 
if type == 1
    % data is normalised to be between 0 and 1
    headplot( data, ...
        spl, 'electrodes', 'on', 'view', 'back', 'maplimits', scale, ...
        'lighting', 'on', 'colormap', colormap('jet'));
    cbar('vert', 1:64, scale)
elseif type == 2
    
    load([pwd '/' 'BESA_64_chanlocs'], 'chanlocs');
    topoplot( data, ...
        chanlocs );
end

end

