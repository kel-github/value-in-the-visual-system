# written by K. Garner, 2019
# getkellygarner@gmail.com
# (c) free to use and share, please cite

rm(list = ls())
# set working directory to source location

# PACKAGES
#-----------------------------------------------------------------------------------------
library(ggplot2)
library(dplyr)
library(reshape2)

# ENVIRONMENT
#-----------------------------------------------------------------------------------------
datPath = '/home/kellygarner/Documents/task-rel-val-uq_analysis/ANALYSIS/fft/'
# LOAD DATA
#-----------------------------------------------------------------------------------------
fPath = paste(datPath, 'sub_level_fft_by_config.csv', sep = "")
dat <- read.csv(fPath, header = TRUE)
dat$sub <- as.factor(dat$sub)
dat$ep  <- NULL # not needed
dat$conf <- as.factor(dat$conf)
levels(dat$conf) <- c("f1left", "f2left")
dat$chan <- as.factor(dat$chan)
levels(dat$chan) <- c('P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Oz', 'POz', 'Pz', 'P2' ,'P4', 'P8', 'P10', 'PO8', 'PO4', 'O2')
dat$hz.fact <- as.factor(dat$hz)
dat <- subset(dat, hz < 25)
dat <- subset(dat, hz > 15)


# FIND 3 CHANNELS w MAX POWER AT EACH KEY FREQUENCY (16.5 & 20.01) FOR EACH CONFIGURATION 
# FOR EACH SUB
#-----------------------------------------------------------------------------------------
max.chans <- dat %>% filter(hz > 16.1 & hz < 17 | hz > 19.51 & hz < 20.5) %>%
                     group_by(sub, conf, hz.fact) %>%
                     top_n(3, pwr)

best.chan.dat = merge(x=dat, y=max.chans, by=c("sub", "conf", "chan"))

mu.dat = best.chan.dat %>% group_by( sub, conf, hz.fact.x  ) %>%
                           summarise( mu = mean(pwr.x),
                                      hz = mean(hz.x))

# PLOT MU ACROSS SUBS by HZ
#-----------------------------------------------------------------------------------------
hz.plot <- ggplot(best.chan.dat, aes(x=hz.x, y=pwr.x, colour=chan, group=chan)) +
  stat_smooth(method="loess", span=0.1, se=TRUE, aes(fill=chan), alpha=0.3) +
  theme_bw() + facet_wrap(~sub*conf)


# LONG TO WIDE
#-----------------------------------------------------------------------------------------
fft.dat.wide = reshape2::dcast(mu.dat, sub ~ conf + hz.fact.x, value.var = "mu" )
write.csv(fft.dat.wide, file = paste(datPath, 'sub_level_fft_by_config-wide.csv', sep=""))
save(list=("max.chans"), file=paste(datPath, 'sub-maxChans.RData'))
