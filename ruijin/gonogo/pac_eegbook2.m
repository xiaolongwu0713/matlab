%% Figure 30.7
channel1=1:10;
channel2=1:10;
%channel2plot = '1';

times2plot = -500:100:3500;
freq4phase = [2,4,6,8,10]; % Hz
freq4power = 20:10:100; 

cfc_numcycles  = 3;   % number of cycles at phase-frequency

pacz = zeros(size(times2plot));
itpc = zeros(size(times2plot));

% other wavelet parameters
time = -1:1/EEG.srate:1;
half_of_wavelet_size = (length(time)-1)/2;
n_wavelet     = length(time);
n_data        = EEG.pnts*EEG.trials;
n_convolution = n_wavelet+n_data-1;


for c1 = channel1 % phase low frequency 
    fprintf('Channle: %d.\n', c1); 
  
    for c2 = channel2 % power high frequency
        for phasef = freq4phase
            if phasef == 2
                cfc_numcycles=2;
            end
            % convert cfc times to indices
            % 1000/freq4phase means signal zhouqi(period T) in ms
            % cfc_numcycles*(1000/freq4phase): means time length in ms for cfc_numcycles periods.
            cfc_time_window     = cfc_numcycles*(1000/phasef); %300ms
            % time points in cfc_numcycles cycles
            cfc_time_window_idx = round(cfc_time_window/(1000/EEG.srate)); % 1000/EEG.srate means sampling period.
    
            freq4power_num=length(freq4power);
            one_phase=zeros(freq4power_num,size(times2plot,2));
            j=1;
            for powerf =freq4power
                fft_EEG1= fft(reshape(EEG.data(c1,:,:),1,EEG.pnts*EEG.trials),n_convolution);
                fft_EEG2= fft(reshape(EEG.data(c2,:,:),1,EEG.pnts*EEG.trials),n_convolution);

                for timei=1:length(times2plot)

                    cfc_centertime_idx  = dsearchn(EEG.times',times2plot(timei));

                    % convolution for lower frequency phase
                    wavelet            = exp(2*1i*pi*phasef.*time) .* exp(-time.^2./(2*(4/(2*pi*phasef))^2));
                    fft_wavelet        = fft(wavelet,n_convolution);
                    convolution_result = ifft(fft_wavelet.*fft_EEG1,n_convolution);
                    convolution_result = convolution_result(half_of_wavelet_size+1:end-half_of_wavelet_size);
                    lower_freq_phase   = reshape(convolution_result,EEG.pnts,EEG.trials);

                    % convolution for upper frequency power
                    wavelet            = exp(2*1i*pi*powerf.*time) .* exp(-time.^2./(2*(4/(2*pi*powerf))^2));
                    fft_wavelet        = fft(wavelet,n_convolution);
                    convolution_result = ifft(fft_wavelet.*fft_EEG2,n_convolution);
                    convolution_result = convolution_result(half_of_wavelet_size+1:end-half_of_wavelet_size);
                    upper_freq_power   = reshape(convolution_result,EEG.pnts,EEG.trials);



                    % extract temporally localized power and phase from task data (not vectorized this time)
                    if timei==41
                        power_ts = abs(upper_freq_power(cfc_centertime_idx-round(cfc_time_window_idx/2):...
                        cfc_centertime_idx+round(cfc_time_window_idx/2)-1,:)).^2; % size: 79    99
                    else
                        power_ts = abs(upper_freq_power(cfc_centertime_idx-round(cfc_time_window_idx/2):...
                        cfc_centertime_idx+round(cfc_time_window_idx/2),:)).^2;
                    end
                    
                    if timei==41
                        phase_ts = angle(lower_freq_phase(cfc_centertime_idx-round(cfc_time_window_idx/2):...
                        cfc_centertime_idx+round(cfc_time_window_idx/2)-1,:));
                    else
                        phase_ts = angle(lower_freq_phase(cfc_centertime_idx-round(cfc_time_window_idx/2):...
                        cfc_centertime_idx+round(cfc_time_window_idx/2),:));
                    end

                    % compute observed PAC
                    obsPAC = abs(mean( power_ts(:).*exp(1i*phase_ts(:)) )); % average over window and trials
                    % compute lower frequency ITPC
                    itpc(timei) = mean(abs(mean(exp(1i*phase_ts),2))); % average over trial first;

                    num_iter = 1000;
                    permutedPAC = zeros(1,num_iter);
                    for i=1:num_iter

                        % in contrast to the previous code, this time-shifts the power time series only within trials. Results are similar using either method.
                        % reason for below random point: choose the middle 80% points, not the edge points.
                        random_timepoint = randsample(round(cfc_time_window_idx*.8),EEG.trials)+round(cfc_time_window_idx*.1);
                        for triali=1:EEG.trials
                            power_ts(:,triali) = power_ts([random_timepoint(triali):end 1:random_timepoint(triali)-1],triali);
                        end

                        permutedPAC(i) = abs(mean( power_ts(:).*exp(1i*phase_ts(:)) ));
                    end

                    pacz(timei) = (obsPAC-mean(permutedPAC))/std(permutedPAC);
                end
                one_phase(j,:)=pacz;
                j=j+1;
            end
            comb=strcat('c',num2str(c1),'_',num2str(c2),'_',num2str(phasef));
            result.(comb)=one_phase;
        end
    end
end
% 
% 
% figure
% subplot(211)
% plot(times2plot,pacz,'-o','markerface','w')
% set(gca,'xlim',get(gca,'xlim').*[1.15 1.05]) % open the x-limits a bit
% 
% % this next line computes the Z-value threshold at p=0.05, correcting for multiple comparisons across time points (this is a bit conservative because of temporal autocorrelation)
% % if you don't have the matlab stats toolbox, use a zval of 2.7131 (p<0.05 correcting for 15 time points/comparisons)
% zval = norminv(1-(.05/length(times2plot)));
% 
% hold on
% plot(get(gca,'xlim'),[zval zval],'k:')
% plot(get(gca,'xlim'),[0 0],'k')
% xlabel('Time (ms)'), ylabel('PAC_z')
% 
% title([ 'PAC_z at electrode ' channel2plot ' between ' num2str(freq4power) ' Hz power and ' num2str(freq4phase) ' Hz phase' ])
