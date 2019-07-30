
function [checks] = makeCheckerBoard(rcycles,tcycles,rsize,hi_index,lo_index,bg_index)
% rcycles = number of stripes out
% tcycles = number of stripes around
xysize = rsize(4);
xylim = 2*pi*rcycles; % one turn of the circle - rcycles = number of stripes/circles outward
[x,y] = meshgrid(-xylim:2*xylim/(xysize-1):xylim, - ...
xylim:2*xylim/(xysize-1):xylim); % cartesian coords the size of the circle numbered for rcycles
at = atan2(y,x); % create the polar coordinates - i.e. use the ratio of x and y to get the polar angle across the four quadrants % inverse tangent gives you the angle not the distance
checks(:,:,1) = ((1+sign(sin(at*tcycles)+eps) .* ...
sign(sin(sqrt(x.^2+y.^2))))/2) * (hi_index-lo_index) + lo_index; % colour index - creates a sinewave stripe pattern and scales it to the values of the colours
checks(:,:,3) = ((1+sign(sin(at*tcycles)+eps) .* ...
sign(sin(sqrt(x.^2+y.^2))))/2) * (lo_index-hi_index) + hi_index;
circle = x.^2 + y.^2 <= xylim^2; % creates a 0/1 - defines hypoteneuse of triangle - i.e. distance from center
checks(:,:,1) = circle .* checks(:,:,1) + bg_index * ~circle; % colour the screen either black or white in the circle, and grey around the edge
checks(:,:,2) = circle*255;
checks(:,:,3) = circle .* checks(:,:,3) + bg_index * ~circle;
checks(:,:,4) = circle*255;
