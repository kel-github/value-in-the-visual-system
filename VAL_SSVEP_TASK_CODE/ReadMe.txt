Description of files:

colour_lum_test_iiyama27in144hz_Hills109_DupDisp_2016_02_08.m - is just code I used to test the luminance of the stimuli used in the experiment (not need for us)

gen_change_mat.m - this generates a 'change matrix' for each trial - rows = frames, columns = stimulus parameters. I use this strategy of programming frame by frame changes when there is a lot changing in a short time to ensure high temporal precision (i.e. SSVEP experiment)

get_trial_log_v1.m/v2.m - generates a trial matrix for the session - ensures counterbalancing etc

lab_close_sa.m - function used to close the trigger sent to the eeg amplifier
lab_init_sa.m - function used to start the trigger sent to the eeg amplifier
lab_put_code_sa.m - function to send specific trigger code to amplifier

makeCheckerBoard.m this 'draws' two radial gratings into separate matrices that can then be drawn to the screen using psychtoolbox functions

run_freq_val_exp_SA.m - script to run experiment for testing (now defunct)
run_freq_val_exp_save_timings_test_timings_v1_1.m/v1_2.m/v1_3.m/v1_4.m - these all run the experimental code, with options to save the actual timings, and whether to display a stimulus that allows a diode test of timings. v1_3 and v1_4 were actually used to run the experiment (v1_3 = 12.1 and 15.1 hz, v1_4 = 7.5 and 5.5 hz)

run_pre_training_v1_3.m/v1_4.m - runs practice for participant

trial_gen_code_v1.m - superceded by get_trial_log_v1.m/v2.m