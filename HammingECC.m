% INFORMATION THEORY AND CODING PROJECT (F2+TF2)
% (7,4) HAMMING CODE
% TEAM MEMBERS:
% SHIKHAR CHANDRA (18BEC0146), SRIVATHSAN V K K (18BEC0341), HARISH K(18BEC0353)

close all;
clear;
clc;

N=50000; %number of input bits
n1=7;k1=4;  %Hamming (7,4)

%Hamming(7,4)
[h,g]=hammgen(n1-k1); %create hamming parity and generator matrix
dictII=mod(de2bi(0:(2^k1)-1)*g,2); %create dictionary with all possible messages and their parity bits matrix(2^k1,n1)

% Create random bit_streams messages matrix N streams-messages of size k
msg4=(sign(randn(N,k1))+1)/2;
msg4_m=msg4; %moduated messages
msg4_m(msg4_m==0)=-1; %BPSK Mapping
% create hamming coded messages
coded_w7=mod(msg4*g,2);
coded_w7(coded_w7==0)=-1; % modulation one bit per symbol
EbN0dB=[0:1:10]; %SNR vector represented in dB
EbN0=10.^(EbN0dB./10);

%BER vectors
ber_noCoding=zeros(1,length(EbN0));
ber_7sdd=zeros(1,length(EbN0));
ber_7hdd=zeros(1,length(EbN0));

for i=1:length(EbN0)
  yI=(sqrt(EbN0(i))*msg4_m)+randn(N,k1);
  yII=(sqrt(EbN0(i))*coded_w7)+randn(N,n1); % chanel out signal with AWGN (Nxn1) matrix
  for j=1:N
    %%No coding case
    yI_hd=yI(j,:);
    yI_hd(yI_hd>0)=1;
    yI_hd(yI_hd<=0)=0;
    ber_noCoding(i)=ber_noCoding(i)+length(find(yI_hd~=msg4(j,:)))/k1;

    %%Hamming (7,4)
    %Soft Decision Decoding
    for m=1:length(dictII)
      distanceII(m)=norm(yII(j,:)-dictII(m,:));%Hamming distance between received word and coded word
    end
    [minv,mini]=min(distanceII);
    decoded_w7=dictII(mini,:); %get the coded word with minimum distance
    cw7=coded_w7(j,:);
    cw7(cw7==-1)=0; %revert modulation to calculate error between decoded and original coded message
    ber_7sdd(i)=ber_7sdd(i)+length(find(decoded_w7~=cw7))/n1;

    % Hard Decision Decoding
    yII_hd=yII(j,:);
    yII_hd(yII_hd>0)=1;
    yII_hd(yII_hd<=0)=0;
    zII=h*yII_hd';% calculate syndrome
    for g1=1:length(yII_hd)
      if (zII==h(:,g1))
        yII_hd(g1)=~yII_hd(g1); %fix mistake using syndrome
      end
    end
    ber_7hdd(i)=ber_7hdd(i)+length(find(yII_hd~=cw7))/n1;
  end
end
%%Final average BER
ber_noCoding=ber_noCoding/N;
ber_7sdd=ber_7sdd/N;
ber_7hdd=ber_7hdd/N;
figure(1)
semilogy(EbN0dB,ber_noCoding,"b--")
hold on;
semilogy(EbN0dB,ber_7sdd,"r-s")
hold on;
semilogy(EbN0dB,ber_7sdd,"k-s")
grid on;
title("BER for no coding and (7,4) Hamming Code");
ylabel({"BER"});
xlabel({"Eb/N0(dB)"});
legend("No coding","Hamming7-SDD","Hamming7-HDD")
axis([min(EbN0dB) max(EbN0dB) 10^-4 10^0]);