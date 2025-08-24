% --- img_in.txt 읽기 (256x256, 쉼표로 구분, 행마다 마지막에 콤마가 있음) ---
set(0,'defaultfigurevisible','off');      % headless
graphics_toolkit('gnuplot'); 
fid = fopen('img_in.dat', 'r');
V = fscanf(fid, "%2x");
fclose(fid);

img_in = reshape(V(1:256*256), 256, 256);  % 256x256으로 재구성 (row-major)
img_in = uint8(img_in);                    % 0~255 정수로 캐스팅

imshow(img_in);  % 행렬의 값을 색깔로 표시; 값이 클수록 밝게
colormap gray;   % 흑백 이미지
axis image off;
title('img\_in (original)');
print('-dpng', 'img_i.png', '-r300');  % 파일 저장


% 1. fopen/fclose 함수는 c언어 뿐만 아니라 matlab/octave에서도 쓸수 있나?
% 2. textscan 함수에서 %f면 float 자료형인데 실제는 int잖아? 그리고 매개변수가 많아서 활용법도 헷갈림
% 3. C{1} 이 뭔지 모르겠음
% 4. reshape 함수 사용법? row major는 뭔뜻인지
% 5. 8번째 줄에서 img_in과 9번째 줄에서 캐스팅이후의 img_in은 어떤 상태인가?
% 6. figure, imagesc 함수 의미와 사용법
% 7. colormap gray; axis image off; 뭔지 모르겠음
% 8. 마지막은 파일 이름인가? 무슨 뜻이지?
