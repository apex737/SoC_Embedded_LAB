y  = load('o_fixed_v.txt');  % 필터를 통과한 시퀀스
n  = length(y);           % input.txt 샘플 개수, FFT 길이
Fs = 48000;               % 샘플링 주파수 (48kHz)
f  = (0:n-1)*(Fs/n);      % 분해능 Δf = Fs/n인 주파수 벡터
yf = fft(y);              % FFT 결과 (복소수)
fp = abs(yf).^2/n;        % 파워 스펙트럼 (정규화) = |Y(f)|² / n

set(0,'defaultfigurevisible','off');      % headless
graphics_toolkit gnuplot;                 % gnuplot로 렌더
plot(f, 10*log10(fp));                    % dB 스케일 플롯
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
title('Output Power Spectrum');
print('-dpng', 'spectrum_out.png', '-r300');  % 파일 저장
