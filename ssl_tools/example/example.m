clc;clear;close all;

addpath(genpath('./../'));
addpath('./wav files');
%% Input File & Mic config
fileName = 'male_female_mixture.wav';  
micPos = ... 
...%  mic1	 mic2   mic3   mic4   mic5   mic6   mic7  mic8
    [ 0.037 -0.034 -0.056 -0.056 -0.037  0.034  0.056 0.056;  % x
      0.056  0.056  0.037 -0.034 -0.056 -0.056 -0.037 0.034;  % y
    -0.038   0.038 -0.038  0.038 -0.038  0.038 -0.038 0.038]; % z


azBound = [-180 180]; % ��λ��������Χ
elBound = [-90 90];   % ������������Χ����ֻ��ˮƽ�棺��elBound=0;
gridRes = 1;          % ��λ��/�����ǵķֱ���
alphaRes = 5;          % Resolution (? of the 2D reference system defined for each microphone pair

% method = 'SRP-PHAT';
% method = 'SNR-MVDR';
% method = 'SNR-FWMVDR';
method = 'MUSIC';
wlen = 512;
window = hann(wlen);
noverlap = 0.5*wlen;
nfft = 512;
nsrc = 2;          % ��Դ����
c = 343;        % ����
freqRange = [];         % �����Ƶ�ʷ�Χ []Ϊ����Ƶ��
pooling = 'max';      % ��ξۺϸ�֡�Ľ��������֡ȡ�������{'max' 'sum'}
%% ��ȡ��Ƶ�ļ�(fix)
[x,fs] = audioread(fileName);
[nSample,nChannel]=size(x);
if nChannel>nSample, error('ERROR:�����ź�ΪnSample x nChannel'); end
[~,nMic,~] = size(micPos);
if nChannel~=nMic, error('ERROR:��˷���Ӧ���ź�ͨ�������'); end
%% �������(fix)
Param = pre_paramInit(c,window, noverlap, nfft,pooling,azBound,elBound,gridRes,alphaRes,fs,freqRange,micPos);
%% ��λ(fix)
if strfind(method,'SRP')
    specGlobal = doa_srp(x,method, Param);
elseif strfind(method,'SNR')
    specGlobal = doa_mvdr(x,method,Param);
elseif strfind(method,'MUSIC')
    specGlobal = doa_music(x,Param,nsrc);
else 
end
% save('n.mat','specGlobal');
% ppfSpec2D = (reshape(specGlobal,length(Param.azimuth),length(Param.elevation)))';
% imagesc(ppfSpec2D)
%% ����Ƕ�
minAngle                   = 10;         % ����ʱ����֮����С�н�
specDisplay                = 1;          % �Ƿ�չʾ�Ƕ���{1,0}
% pfEstAngles = post_sslResult(specGlobal, nsrc, Param.azimuth, Param.elevation, minAngle);
% ���ƽ���
% [pfEstAngles,figHandle] = post_findPeaks(specGlobal, Param.azimuth, Param.elevation, Param.azimuthGrid, Param.elevationGrid, nsrc, minAngle, specDisplay);
[pfEstAngles,figHandle] = post_findPeaks(specGlobal, Param.azimuth, Param.elevation, Param.azimuthGrid, Param.elevationGrid, nsrc, minAngle, specDisplay);

azEst = pfEstAngles(:,1)';
elEst = pfEstAngles(:,2)';
for i = 1:nsrc
    fprintf('Estimated source %d : \n Azimuth (Theta): %.0f \t Elevation (Phi): %.0f \n\n',i,azEst(i),elEst(i));
end