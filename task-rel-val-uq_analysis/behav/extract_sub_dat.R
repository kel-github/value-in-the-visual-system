  ##### Writtenm by K. Garner, updated 2019
  ##### this code will - pull out participant data and collate into a data frame
  ##### summarise data and collate output for wideform (for analysis in other statistical packages)
  ##### conducts a timing check for each participant (i.e. were the monitor settings correct to 
  ##### stimulate at the correct frequencies)
  ##### will then exclude participants who score less than 65 % accuracy
  ##### will perform anovas on the resulting RT and accuracy
  ##### will plot the results (Accuracy & RT) as raincloud plots
  ##### finally, print an event file for each subject
  rm(list=ls())
  #library(plyr)
  library(ggplot2)
  library(dplyr)
  library(wesanderson)
  library(reshape2)
  source("R_rainclouds.R")
  #setwd(dirname(rstudioapi::getSourceEditorContext()$path)) 
  
  
  data.loc = "~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/behav"
  # data.loc = "/Volumes/ANALYSIS/E6_EEG_RV_1/BEHAV/"
  # get sub numbers and date strings ________________________________________________________________________________________
  tmp = read.csv(paste(data.loc, "LOGS_sub_nums_date_strs.csv", sep="/"), header = FALSE) # this file contains all the unique 
  # strings in the names of the subject log files
  num = tmp$V1
  num = as.factor(num)
  date.str.dat = tmp$V2
  rm(tmp)
  
  fname.trials = "EEG_RelVal_sub"
  fname.resps = "EEG_RelVal_resp_log_sub"
  sess = 1
  # step 1 = get behavioural data ______________________________________________________________________________________
  get.sub.dat <- function(num, date.str.dat, fname.trials, fname.resps, sess){
  
      p.results = list()
      # participant data for behav analysis__________________________________________
      # get trial structure
      trial.dat <- read.csv(paste(data.loc, "/", fname.trials, num, sess, '_', date.str.dat, '.csv', sep=""), header = F,
                            na.strings = "NaN")
      # test of trial matching 
      trial.dat$V9 = c(1:448)
      # get response data
      resps.dat <- read.csv(paste(data.loc, "/", fname.resps, num, sess, '_', date.str.dat, '.csv', sep=""), header = F,
                            na.strings = "NaN")
      resps.dat = resps.dat[,1:4]
  
      ntrials = length(trial.dat[,1])
      trial.dat$sub = rep(num, ntrials); resps.dat$sub = trial.dat$sub
  
      # define vars
      names(trial.dat) <- c("condition","block","left_val","right_val","tgt_loc","f1","f2","rew","trial","sub")
      trial.dat$sub <- as.factor(trial.dat$sub)
      trial.dat$condition <- NULL
      trial.dat$block <- NULL
      trial.dat$left_val <- as.factor(trial.dat$left_val)
      levels(trial.dat$left_val) = c("high", "low")
      trial.dat$right_val <- as.factor(trial.dat$right_val)
      levels(trial.dat$right_val) = c("high", "low")
      trial.dat$tgt_loc = as.factor(trial.dat$tgt_loc)
      levels(trial.dat$tgt_loc) = c("left","right")
      trial.dat$f1 = as.factor(trial.dat$f1)
      trial.dat$f2 = as.factor(trial.dat$f2)
      trial.dat$rew = as.factor(trial.dat$rew)
  
      trial.dat$rel <- rep(0, times=length(trial.dat$left_val))
      trial.dat$rel[trial.dat$left_val == "low" & trial.dat$right_val == "low"] = 1
      trial.dat$rel[trial.dat$left_val == "high" & trial.dat$right_val == "high"] = 2
      trial.dat$rel[trial.dat$left_val == "low" & trial.dat$right_val == "high" & trial.dat$tgt_loc == "left" | trial.dat$left_val == "high" & trial.dat$right_val == "low" & trial.dat$tgt_loc == "right" ] <- 3
      trial.dat$rel[trial.dat$left_val == "low" & trial.dat$right_val == "high" & trial.dat$tgt_loc == "right" | trial.dat$left_val == "high" & trial.dat$right_val == "low" & trial.dat$tgt_loc == "left" ] <- 4
      trial.dat$rel = as.factor(trial.dat$rel)
      levels(trial.dat$rel) = c("lvl","hvh","lvh","hvl")
      
      # Response data
      names(resps.dat) <- c("trial_num","cresp","resp","RT","sub")
      resps.dat$sub <- as.factor(resps.dat$sub)
      resps.dat$trial_num <- as.factor(resps.dat$trial_num)
      resps.dat$cresp <- as.factor(resps.dat$cresp)
      levels(resps.dat$cresp) <- c("H","N")
      resps.dat$resp <- as.factor(resps.dat$resp)
      levels(resps.dat$resp) <- c("H","N")
  
      resps.dat$freq[trial.dat$tgt_loc == "left"] = trial.dat$f1[trial.dat$tgt_loc == "left"]
      resps.dat$freq[trial.dat$tgt_loc == "right"] = trial.dat$f2[trial.dat$tgt_loc == "right"]
      resps.dat$freq = as.factor(resps.dat$freq)
      
      p.results = cbind(trial.dat, resps.dat)
  
      return(p.results)
  }
  
  p.dat = mapply(get.sub.dat, num, date.str.dat, MoreArgs = list(fname.trials =  fname.trials, 
                                                                 fname.resps = fname.resps,
                                                                 sess = sess), 
                                                                 SIMPLIFY = FALSE)
  p.dat = do.call(rbind, lapply(p.dat, data.frame, stringsAsFactors=TRUE))
  p.dat$sub.1 <- NULL
  # recode missed responses as errors
  p.dat$resp <- as.numeric(p.dat$resp)
  p.dat$resp[is.na(p.dat$resp)] = 3
  p.dat$resp <- as.factor(p.dat$resp)
  levels(p.dat$resp) = c("H", "N", "miss")
  levels(p.dat$cresp) = c("H", "N", "miss")
  
  ##### summarise data and collate output for wideform (for analysis in other statistical packages)
  ##### accuracy
  acc.by.cond = p.dat %>% group_by(sub, rel) %>%
                  summarise(acc = mean(cresp==resp))
  #### RT
  RT_min = .1
  sd_reject = 3
  rt.by.cond = rbind(p.dat %>% filter(RT > RT_min) %>%
                       filter(cresp == resp) %>%
                       group_by(sub, rel) %>%
                       filter(RT < median(RT) + sd_reject*sd(RT)) %>%
                       summarise(mu_RT=mean(RT, na.rm = TRUE)))
  ###### now join and make wideform
  acc.for.wide = dcast(acc.by.cond, sub ~ rel, value.var = "acc")
  write.csv(acc.for.wide, file=paste(data.loc, "/task-rel-val_ACC-wide.csv", sep=""))
  
  rt.for.wide = dcast(rt.by.cond, sub ~ rel, value.var = "mu_RT")
  write.csv(rt.for.wide, file=paste(data.loc, "/task-rel-val_RT-wide.csv", sep=""))
  
  ##### conducts a timing check for each participant (i.e. were the monitor settings correct to 
  ##### stimulate at the correct frequencies)
  fname.change = "EEG_RelVal_change_log_sub"
  do.time.checks <- function(sub.num, date_str, file_str, dat.loc, sess){
    
    out = list()
    tmp = read.csv(paste(dat.loc, "/", file_str, sub.num, sess, "_", date_str, ".csv", sep = ""), header = FALSE)
    idx = which(is.na(tmp$V2))
    tmp$V1 = as.numeric(tmp$V1)
    tmp$V1[tmp$V1 > 2] <- NA
    spaces = array()
    f1 = array()
    f2 = array()
    
    for (x in 2:length(idx)){
      
      trial.dat = tmp[seq( idx[x-1]+1, idx[x]-2, 1),]
      spaces = c(spaces, diff(trial.dat$V7))
      
      f1_t_cycles = max(which(diff(trial.dat$V1) != 0)) - 1
      f1_time = max(trial.dat$V6[1:(f1_t_cycles+1)])- min(trial.dat$V6)
      f1_rate = sum(diff(trial.dat$V1) != 0)
      f1 = c(f1, f1_rate/f1_time)
      
      f2_t_cycles = max(which(diff(trial.dat$V2) != 0)) - 1
      f2_time = max(trial.dat$V6[1:(f2_t_cycles+1)])- min(trial.dat$V6)
      f2_rate = sum(diff(trial.dat$V2) != 0)
      f2 = c(f2, f2_rate/f2_time)
    }
    jpeg(filename = paste(dat.loc, "/", sub.num, "_timingChecks.jpeg", sep = ""),
         width = 480, height = 480)
    par(mfrow = c(2,2))
    plot(spaces)
    abline(h = quantile(spaces[2:length(spaces)], c(.025, .975), na.rm=TRUE), lty = 2)
    plot(density(spaces[2:length(spaces)]))
    plot(seq(1, length(f1), 1), f1, col = "blue", main = paste("f1:", round(mean(f1[f1 < median(f1, na.rm = T)], na.rm = T),2), ",", round(sd(f1[f1 < median(f1, na.rm = T)], na.rm = T),2), 
                                                               "f2:", round(mean(f2[f2 > median(f2, na.rm = T)], na.rm = T),2), ",", round(sd(f2[f2 < median(f2, na.rm = T)], na.rm = T),2), sep = ""))
    plot(seq(1, length(f2), 1), f2, col = "red",  main = paste("f1:", round(mean(f1[f1 < median(f1, na.rm = T)], na.rm = T),2), ",", round(sd(f1[f1 < median(f1, na.rm = T)], na.rm = T)), 
                                                               "f2:", round(mean(f2[f2 > median(f2, na.rm = T)], na.rm = T),2), ",", round(sd(f2[f2 < median(f2, na.rm = T)], na.rm = T),2), sep = ""))
    dev.off()
    out$f1 = f1
    out$f2 = f2
    return(out)
  }
  results = list()
  results = mapply(do.time.checks, sub.num = num, date_str = date.str.dat, MoreArgs = list(file_str = fname.change, 
                                                                                           dat.loc = data.loc,
                                                                                           sess = sess))
  save(results, file=paste(data.loc, "/task-rel-val_allsubs_timing_checks.Rda", sep=""))
  
  
  ##### will then exclude participants who score less than 65 % accuracy across all conds
  min_acc = .6
  excl = acc.by.cond %>% group_by(sub) %>%
         summarise(mu_acc = mean(acc)) 
  excl.lst = excl %>% filter( mu_acc <= min_acc )
  acc.by.cond = inner_join(acc.by.cond, excl, by="sub") %>%
                filter(mu_acc > min_acc)
  rt.by.cond = inner_join(rt.by.cond, excl, by="sub") %>%
                filter(mu_acc > min_acc)
  
  ##### will perform anovas on the resulting RT and accuracy
  acc.aov = aov( acc ~ rel + Error(sub/rel), data = acc.by.cond )
  rt.aov  = aov( mu_RT ~ rel + Error(sub/rel), data = rt.by.cond)
  
  ##### will plot the results (Accuracy & RT) as raincloud plots - FINISH THIS WITH PILOT DAT N=5
  cols = wes_palette("Royal1")[c(1:4)] 
  p <- ggplot(rt.by.cond, aes(x = rel, y = mu_RT, fill = rel, colour = rel)) +
    geom_flat_violin(aes(fill = rel), position = position_nudge(x = .1, y = 0), 
                     adjust = 1.5, trim = FALSE, alpha = .5, colour = NA) +
    geom_point(aes(x = as.numeric(rel), y = mu_RT, colour = rel),
               position = position_jitter(width = .075), size = .1, shape = 20,
               alpha = .5) +
    geom_boxplot(aes(x = rel, y = mu_RT, fill = rel), outlier.shape = NA, 
    #              alpha = .5, width = .1, colour = "black") +
    # geom_line(data = sum.data, aes(x = as.numeric(cert), y=medianRT, group = rew, colour = rew)) +
    # scale_fill_manual(values=c(lo.col, hi.col)) +
    # scale_color_manual(values=c(lo.col, hi.col)) + facet_wrap(~rew*sub, nrow=2)  +
    # ylab("RT") + xlab("location probability") + ylim(c(0.3, 1)) +
    # theme(panel.border = element_blank(), panel.grid.major = element_blank(),
    #       panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
    #       # text=element_text(size=8),
    #       # axis.text.x = element_text(size=8),
    #       # axis.text.y = element_text(size=8),
    #       legend.position = "none") 
  
  p  
  
  
  
  
  # step 3 = print event files for each participant/epoch __________________________________________
  # ______________________________________________________________________________________________________________________
  # amended below to print a table that has a sanity check of the trial number printed in
  # result was that the trials are printed out correctly
  print.outputs <-  function(data, out.loc){
    out.trials = matrix(data = NA, nrow = 448, ncol = 9)
    
    out.trials[,1] = data$cresp
    out.trials[,2] = data$tgt_loc
    out.trials[,3] = data$rel
    out.trials[,4] = data$left_val
    out.trials[,5] = data$right_val
    out.trials[,6] = data$f1
    out.trials[,7] = data$f2
    out.trials[data$cresp == data$resp,8] = 1
    out.trials[data$cresp != data$resp,8] = 2
    out.trials[is.na(out.trials[,8]),8] = 9
    out.trials[,9] = data$trial
    write.table(out.trials, file = paste(out.loc,"/", "sub-", data$sub[1], "/", "log", "/", "sub-", data$sub[1], "_event-out",'.txt', sep=""), col.names = F, row.names = F)
  }
  
  out = "/home/kellygarner/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg"
  by(p.dat, p.dat$sub, print.outputs, out)
  
  
  # step 4 - subs 202 - 208 had an error in the trigger for the value onset, this code will get the info to fix it
  do.onset.checks <- function(sub.num, date_str, file_str, dat.loc, out.loc, sess, frames){
    
    tmp = read.csv(paste(dat.loc, "/", file_str, sub.num, sess, "_", date_str, ".csv", sep = ""), header = FALSE)
    idx = which(is.na(tmp$V2))
    tmp$V1 = as.numeric(tmp$V1)
    tmp$V1[tmp$V1 > 2] <- NA
    spaces = array()
    onsets = array()
    
    for (x in 2:length(idx)){
      
      trial.dat = tmp[seq( idx[x-1]+1, idx[x]-2, 1),]
      val_on = sum( diff(trial.dat$V7)[c(1:frames)] )
      onsets = c(onsets, val_on)
    }
    onsets = onsets[!is.na(onsets)]
    # get last trial
    trial.dat = tmp[ seq( idx[x]+1, nrow(tmp), 1),]
    val_on = sum( diff(trial.dat$V7)[c(1:frames)] )
    onsets = c(onsets, val_on)
    write.table(onsets, file = paste(out.loc,"/", "sub-", sub.num, "/", "log", "/", "sub-", sub.num, "_val_onset",'.txt', sep=""), col.names = F, row.names = F)
  }
  
  onsets = mapply(do.onset.checks, sub.num = num, date_str = date.str.dat, MoreArgs = list(file_str = fname.change, 
                                                                                           dat.loc = data.loc,
                                                                                           out.loc = out,
                                                                                           sess = sess,
                                                                                           frames = 150))
