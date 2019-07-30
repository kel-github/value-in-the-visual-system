% draw/save checkerboard image

rcycles = 2;
tcycles = 6;
rsize = [0 0 100 100]; % 100 pixels = approx 2.5 degrees visual angle on CRT monitor 
xysize = rsize(4);
xylim = 2*pi*rcycles; % one turn of the circle - rcycles = number of stripes/circles outward
[x,y] = meshgrid(-xylim:2*xylim/(xysize-1):xylim, - ...
xylim:2*xylim/(xysize-1):xylim); % cartesian coords the size of the circle numbered for rcycles
at = atan2(y,x); % create the polar coordinates - i.e. use the ratio of x and y to get the polar angle across the four quadrants % inverse tangent gives you the angle not the distance


tmp = ((1+sign(sin(at*tcycles)+eps) .* sign(sin(sqrt(x.^2+y.^2))))/2) * 175;
circle = x.^2 + y.^2 <= xylim^2;
tmp(circle == 0) = 175;

figure;

purp_r = tmp; 
purp_r( purp_r == 0 ) = 148;
purp_g = tmp;
purp_g( purp_g == 0 ) = 131;
purp_b = tmp;
purp_b( purp_b == 0 ) = 165;
% purple one
purp = cat( 3,  purp_r/255, purp_g/255, purp_b/255 );
purp( purp == 175/255 ) = 0;
image( purp )


rose_r = tmp; 
rose_r( rose_r == 0 ) = 230;
rose_g = tmp;
rose_g( rose_g == 0 ) = 93;
rose_b = tmp;
rose_b( rose_b == 0 ) = 85;

rose = cat( 3,  rose_r/255, rose_g/255, rose_b/255 );
rose( rose == 175/255 ) = 0;
figure;
image( rose );


neut_r = tmp; 
neut_r( neut_r == 0 ) = 128;
neut_g = tmp;
neut_g( neut_g == 0 ) = 128;
neut_b = tmp;
neut_b( neut_b == 0 ) = 128;

neut = cat( 3,  neut_r/255, neut_g/255, neut_b/255 );
neut( neut == 175/255 ) = 0;
figure;
image( neut );

