% ISM�㷨�������ź�DOA
clc  
clear all  
close all
%% ����
M = 12;      %��Ԫ��  
N = 200;     % ������
fs = 1000;
f0 = 100;    %����Ƶ��   
f1 = 80;     % ���Ƶ��
f2 = 120;    %���Ƶ��
c = 1500;                                    
lambda = c/f0;                               
d = lambda/2; %��Ԫ��� 
J = 33;     % �Ӵ���
SNR = 15;
num_src = 2; % ��Դ��
theat1 = 30*pi/180;                              
theat2 = 40*pi/180;                              
n = 0:1/fs:N/fs;                              
theat = [theat1 theat2]';  
dtheta = 0.5; 
thetas = -90:dtheta:90;
%% �����ź�  
nfft = 2048;  
s1 = chirp(n,80,1,120);                 % (t,f0,t1,f1) f0��0ʱ�̵�˲ʱƵ�ʣ�f1��t1ʱ�̵�˲ʱƵ��   
sa = fft(s1,nfft);                      

s2 = chirp(n+0.100,80,1,120);                
sb = fft(s2,nfft);                           
   
%% ISM�㷨 
P=1:num_src;%�����Ƕ�  
startfftindex = (nfft/2)/(fs/2)*f1; % 1024(��)->fs/2=500(Hz)��1024/500*80=163.84��    120Hz->245.76��   
endfftindex = (nfft/2)/(fs/2)*f2;
dfftindex = (endfftindex-startfftindex+1)/J;% ÿ���Ӵ��Ľ���Ƶ����
a=zeros(M,num_src);  
sump=zeros(1,length(thetas));  
for i=1:J %ÿ���Ӵ�
    %% 1. ����ÿ����Ԫ�����źŵ�һ���Ӵ���Э�������
    fftindex = ceil(startfftindex+(i-1)*dfftindex+1);%���Ӵ�������һ��Ƶ��
    f=fftindex/((nfft/2)/(fs/2)); % ��Ƶ���ӦƵ��
    s=[sa(fftindex) sb(fftindex)]';  
    for m=1:M  
        a(m,P)=exp(-j*2*pi*f*d/c*sin(theat(P))*(m-1))'; %�������� 
    end  
    R=a*(s*s')*a';  % ÿ��Ƶ���Э�������
    %% 2. ����ֵ�ֽ⣬���������ӿռ�
    [em,zm]=eig(R);  % ����ֵ�ֽ� em:��������   zm������ֵ�ԽǾ���
    [zm1,pos1]=max(zm);  %zm1 ��������ֵ
    for l=1:num_src % ȥ��������Դ��Ӧ������ֵ������������ֻ���������ӿռ�em 
        [zm2,pos2]=max(zm1);  
        zm1(:,pos2)=[];  
        em(:,pos2)=[];  
    end  
    %% 3. ����p(k)=A'*em*em'*A
    k=1;  %��ɢ�Ƕ�����
    for ii=-90:dtheta:90  
        arfa=sin(ii*pi/180)*d/c;  
        for iii=1:M  
            tao(1,iii)=(iii-1)*arfa;  
        end  
        A=[exp(-j*2*pi*f*tao)]';  
        p(k)=A'*em*em'*A;  
        k=k+1;  
    end  
    %% 4. �����Ӵ���p(k)�Ӻ�sump
    sump=sump+abs(p);  
end 
%% 5. ����ռ��� pm = 1/((1/J)*sump)
pmusic=1/J*sump;  
pm=1./pmusic; 

plot(thetas,20*log(abs(pm)));  
xlabel('�����/��');  
ylabel('�ռ���/dB');  
grid on 
