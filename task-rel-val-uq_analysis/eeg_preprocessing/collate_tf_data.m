% load each p's time freq data and collate into 1 text file
clear 
clc

sIDs = [    13071 13081 13091 13101 13111 13121 13131 13141 13151 ...
            13161 13171 13181 13191 13201 13211 13221 13241 13251, ...
            14261 14271 14281 14291 14301 14311 14321 14331 14341 ...
            14351 14361 14371 14381 14391 14401 14411 14421 ];

PLACE = 'KG BACK UP';
all_results = [];
for count_subs = 1:length(sIDs)
    
    sID = sIDs(count_subs);
    
switch PLACE
    case 'ANALYSIS'
        
        eeglab
        cPath = '~/Dropbox/BHAMPROJECTS/RelValue_StudyProgramme/Analysis/EXP_6_EEGBEHAVIOURAL_OUT/EEG_PREPROCESSING_FINALPIPELINE';
        bPath = '/Volumes/ANALYSIS/E6_EEG_RV_1/';
        dPath = sprintf('/Volumes/ANALYSIS/E6_EEG_RV_1/SUB_%d', sID); % filepath for data (subject's folder)
        rPath = [dPath '/BDF'];
        sPath = [dPath '/SET'];
        lPath = [dPath '/LOG'];
        oPath = [dPath '/OUT'];
        iPath = [dPath '/ICA'];
        RPath = [dPath '/RESS'];
        FPath = [dPath '/FFT'];
        FOPath = [bPath 'FFT_OUT'];
        mPath = [dPath '/MVPA'];
        uPath = 'Utils'; 
        
        eName = 'Biosemi_64_eeglab_elp_2.ced'; % custom electrode location file made coutesy of intel from SA
        
    case 'KG BACK UP'
        
        eeglab  
        cPath = '~/Dropbox/BHAMPROJECTS/RelValue_StudyProgramme/Analysis/EXP_6_EEGBEHAVIOURAL_OUT/EEG_PREPROCESSING_FINALPIPELINE';
        bPath = '/Volumes/KG BACK UP/E6_EEG_RV_1/';
        dPath = sprintf('/Volumes/KG BACK UP/E6_EEG_RV_1/SUB_%d', sID); % filepath for data (subject's folder)
        rPath = [dPath '/BDF'];
        sPath = [dPath '/SET'];
        lPath = [dPath '/LOG'];
        oPath = [dPath '/OUT'];
        iPath = [dPath '/ICA'];
        RPath = [dPath '/RESS'];
        FPath = [dPath '/FFT'];
        FOPath = [bPath 'FFT_OUT'];
        mPath = [dPath '/MVPA'];
        uPath = 'Utils'; 
        
        eName = 'Biosemi_64_eeglab_elp_2.ced'; % custom electrode location file made coutesy of intel from SA
end

        fPath = [bPath 'TIMEFREQ_PARIETCEN_OUT/'];
        load( sprintf([fPath 'SUB%d/sub%d-full-timefreq-all-conds-best-electrode'],sID, sID));
        all_results = [all_results; sub_dat];

end
        
        
     fPath = [bPath 'TIMEFREQ_PARIETCEN_OUT/outdata'];
    if exist(fPath, 'dir')
    else mkdir(bPath, 'TIMEFREQ_PARIETCEN_OUT/outdata');
    end
   %save( [fPath '/COND_TIMEFREQ_BLm1400tom50_2SEC_EPS_allSubs_sFFT'],  'group_ERSP_results');
    save( [fPath '/allSubs_sFFT_V6_allEpochs_ztrans_CENTPAR_20180312'],  'all_results');
    
    fID = fopen(sprintf([ fPath '/allSubs_sFFT_V6_allEpochs_ztrans_20180330.txt' ]), 'w' );
   % [s_out  g_out  cond_out ep_out val_out f_tgt freq_out t_out  tf_out  ]];
    fprintf(fID, '%4s,%3s,%5s,%5s,%4s,%4s,%4s,%4s,%3s\n', 'snum', 'grp', 'lcond', 'epoch', 'cond', 'ftgt', 'freq', 'time', 'pwr' );
    fprintf(fID, '%d,%d,%d,%d,%d,%d,%d,%f,%f\n', all_results');
    fclose(fID);       
        
        
        
        
