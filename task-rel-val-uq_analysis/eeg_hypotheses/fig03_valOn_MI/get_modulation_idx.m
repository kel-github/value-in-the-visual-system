function [ mi ] = get_modulation_idx( data, freqs, neighbours, 
% written by K. Garner, 2019
% calculate modularion index (L_trial - R_trial) / (L_trial + R_trial)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inputs
% ---------------------------------------------------------
% data = chans x frequency x times x trials
% freqs = frequencies to extract
% neighbours = how many frequency neighbours to include (0 if none)
% chans_to_average = which channels should be averaged over - this should
% be a nchan x nfrq x nform matrix, where nform is how many physical
% displays made up the experiment/have had channels selected for
% onsets = a structure generated from the preprocessing and saved with the
% participants tf data. Contains the info about conditions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract correct frequencies
% ---------------------------------------------------------
t_frqs = onsets.freqs;
tmp = dsearchn( freqs', t_frqs );
frq_idx = [];
for i = 1:numel(tmp)
    frq_idx = [frq_idx, tmp(i)-neigbours:tmp(i)+neighbours];
end
clear tmp

data = data( frq_idx, :, : );

