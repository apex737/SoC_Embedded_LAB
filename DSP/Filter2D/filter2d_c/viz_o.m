% --- img_out.txt 읽기 (256x256, 공백/줄바꿈 구분) ---
set(0,'defaultfigurevisible','off');      % headless
graphics_toolkit('gnuplot'); 

fid = fopen('img_out.txt', 'r');
D = textscan(fid, '%f');      % 공백/개행을 delimiter로 자동 처리
fclose(fid);

vout = D{1};
img_out = reshape(vout(1:256*256), 256, 256);
img_out = uint8(img_out);

imshow(img_out); 
colormap gray; 
axis image off;
title('img\_out (filtered)');
print('-dpng', 'img_o.png', '-r300');  % 파일 저장
