% INFORMATION THEORY AND CODING PROJECT (F2+TF2)
% (3,1) REPETITION CODE
% TEAM MEMBERS:
% SHIKHAR CHANDRA (18BEC0146), SRIVATHSAN V K K (18BEC0341), HARISH K(18BEC0353)

N=50000; %Length of data bit stream
m = randi([0 1],1,N); %Random 0s and 1s
c=[];
%Repetition Coding
for i=1:N
c=[c m(i) m(i) m(i)]; %Repeated symbol 3 times
end
x=[];
%BPSK Mapping
for i=1:length(c)
if c(i)==0
x(i)= -1;
else
x(i)= 1;
end
end
r=1/3; %Code rate
rep = 3;%Block size
BER_sim=[];
BER_th_C = [];
BER_UC = [];
BER_sim_SDD=[];
for EbN0dB=0:10
EbN0=10.^(EbN0dB/10);
sigma = sqrt(1/(2*r*EbN0)); %Noise Standard deviation
n = sigma.*randn(1,length(x));%Random Noise(AWGN) with adjusted variance
y=x+n; %Received symbol = Transmitted + Noise
c_cap=(y>0);%If y is positive, c_cap=1, otherwise c_cap=0
m_cap=[];
% Hard Decision Coding (decision of a bit is not dependent on other bits)
m_cap_SDD=[];%Soft Decision Coding (Dependent on neighbouring bits)
for j=1:(length(c_cap)/rep)
code = c_cap((j-1)*rep+1:j*rep); %Storing one block of symbols in single variable (3 bits)
if sum(code)>=2
code1=1;
else
code1=0;
end
m_cap = [m_cap code1];
code_SDD=y((j-1)*rep+1:j*rep);
if sum(code_SDD)>0
code2=1;
else
code2=0;
end
m_cap_SDD=[m_cap_SDD code2];
end
noe = sum(m~=m_cap); %Number of Errors HDD
ber_sim1 = noe/N;
BER_sim=[BER_sim ber_sim1]; %Appending the BER values in an array
noe1= sum(m~=m_cap_SDD); %Number of Errors SDD
ber_sim2= noe1/N;
BER_sim_SDD=[BER_sim_SDD ber_sim2]; %Appending the BER values in an array
p = qfunc(sqrt(2*r*EbN0)); %Single bit Probability of Error in Coded BPSK
ber_th_q= 3*p*p*(1-p)+p^3; %2-bit Error + 3-bit Error
BER_th_C = [BER_th_C ber_th_q]; %Theoretical BER for Coded BPSK
BER_UC = [BER_UC 0.5*erfc(sqrt(EbN0))]; %BER for Uncoded BPSK
end
EbN0dB = 0:10;
semilogy(EbN0dB,BER_sim,'r*-',EbN0dB,BER_th_C,'b--',EbN0dB,BER_UC,'go-',EbN0dB,BER_title("BER Analysis of (3,1) Repetition Code");
xlabel('Eb/N0(dB)');
ylabel('BER');grid on;
legend("Simulated HDD","Theoretical","Uncoded","Simulated SDD");
axis([min(EbN0dB) max(EbN0dB) 10^-4 10^0]);