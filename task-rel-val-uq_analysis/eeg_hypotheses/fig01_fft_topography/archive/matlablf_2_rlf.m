function [] = matlablf_2_rlf( sIDs, path, save_loc )
% use this function to convery subject mat files to
% an aggregated csv file for further data analysis in
% R


% concatenate data
data = [];

for iSub = 1:length(sIDs)
    
    load(sprintf([path, '/', 'sub-%d', '/', 'fft/', 'p%d_bl_FFT_lf.mat'], sIDs(iSub), sIDs(iSub)));
    data = [data; sub_lf_pwr];
end

% data is in form sID, epoch, configs elecs, hz, pwr, 
fid = fopen([save_loc '/sub_level_fft_by_config.csv'], 'w');
fprintf(fid, '%s,%s,%s,%s,%s,%s\n', 'sub','ep', 'conf', 'chan','hz','pwr');
fprintf(fid, '%d,%d,%d,%d,%.4f,%.4f\n', data');
fclose(fid);

end