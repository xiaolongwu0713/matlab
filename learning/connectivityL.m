rng default
rng(50)

cfg             = [];
cfg.ntrials     = 500;
cfg.triallength = 1;

cfg.fsample     = 200;
cfg.nsignal     = 3;
cfg.method      = 'ar';

cfg.params(:,:,1) = [ 0.8    0    0 ;
                        0  0.9  0.5 ;
                      0.4    0  0.5];

cfg.params(:,:,2) = [-0.5    0    0 ;
                        0 -0.8    0 ;
                        0    0 -0.2];

cfg.noisecov      = [ 0.3    0    0 ;
                        0    1    0 ;
                        0    0  0.2];

data              = ft_connectivitysimulation(cfg);
%%

figure
plot(data.time{1}, data.trial{1})
legend(data.label)
xlabel('time (s)')

%%
cfg         = [];
cfg.order   = 5;
cfg.toolbox = 'bsmart';
mdata       = ft_mvaranalysis(cfg, data);

%%
cfg        = [];
cfg.method = 'mvar';
mfreq      = ft_freqanalysis(cfg, mdata);

%%
cfg           = [];
cfg.method    = 'mtmfft';
cfg.taper     = 'dpss';
cfg.output    = 'fourier';
cfg.tapsmofrq = 2;
freq          = ft_freqanalysis(cfg, data);

%%
cfg           = [];
cfg.method    = 'coh';
coh           = ft_connectivityanalysis(cfg, freq);
cohm          = ft_connectivityanalysis(cfg, mfreq);

cfg           = [];
cfg.parameter = 'cohspctrm';
cfg.zlim      = [0 1];
ft_connectivityplot(cfg, coh, cohm);

%%
cfg           = [];
cfg.method    = 'granger';
granger       = ft_connectivityanalysis(cfg, mfreq);

cfg           = [];
cfg.parameter = 'grangerspctrm';
cfg.zlim      = [0 1];
ft_connectivityplot(cfg, granger);

%%
cfg           = [];
cfg.method    = 'dtf';
dtf       = ft_connectivityanalysis(cfg, mfreq);

cfg           = [];
cfg.parameter = 'dtfspctrm';
cfg.zlim      = [0 1];
ft_connectivityplot(cfg, dtf);
