% Initialization
clc; clear; close;
COL = 256;
ROW = 256;
% Read image
filename = "lena256.raw";
fid1 = fopen(filename,"rb"); % raw 파일 열기
temp = fread(fid1, [COL, ROW], "*uchar"); % raw 파일의 정보 읽어오기
for i = 1:COL
 for j = 1:ROW
    lena_img(i,j) = temp(j,i); 
 end
end
% Add noise
std = 0.25;
var = std^2;
add_gaussian = imnoise(temp, "gaussian", 0, var);
% Write image
fid2 = fopen("out_lena.raw", "wb"); % 저장할 파일 열기
figure(1)
imshow(add_gaussian);
fwrite(fid2, add_gaussian); % 파일 저장
fclose(fid1);
fclose(fid2);