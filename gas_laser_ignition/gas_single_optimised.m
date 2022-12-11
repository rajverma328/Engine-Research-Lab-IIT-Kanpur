clear all
close all
t=0;
Area_limit=500;
r = [0,0,0,0];
r1 = 0;
%%%%%%%%%%%%%%%%%%%%%%%%% taking input %%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter length calibration factor (mm/pixel)','Enter frame rate in f.p.s.','Enter radius callibration value'};
dlgtitle = 'Input';
dims = [1 50];
definput = {'1','10000','17'};  %(197/7.5)^-1 as provided
answer = inputdlg(prompt,dlgtitle,dims,definput);
calibration_factor = str2double(answer(1));
frame_rate = str2double(answer(2));
rcor = str2double(answer(3));
area_cal_fac = calibration_factor*calibration_factor;
frame_rate = frame_rate/1000; %frames per milli second
frame_rate = 1/frame_rate;
data_filename = uigetdir;

path = strcat(data_filename,"\");
tif_files = dir(fullfile(path,'*.tif'));
l = length(tif_files);
bg_img1 = rgb2gray(imread(fullfile(path,tif_files(1).name)));
[rows ,cols ,~] = size(bg_img1);
bg_img = medfilt2(bg_img1,[3 3]);
bg_img = edge(bg_img,'sobel');

cent = [floor(cols/2) , floor(rows/2)];
for i = cent(1):cols    % +ve x axis
    if bg_img(cent(2),i) == 1
        break;
    end
    r(1) = r(1)+1;
end
for i = cent(1):cols    % -ve x axis
    if bg_img(cent(2),cent(1)-(i-cent(1))) == 1
        break;
    end
    r(2) = r(2)-1;
end
x = floor((r(1)+r(2))/2);
cent = [cent(1)+x,cent(2)];
for i = cent(2):rows    % +ve y axis
    if bg_img(i,cent(1)) == 1
        break;
    end
    r(3) = r(3)+1;
end
for i = cent(2):rows    % -ve y axis
    if bg_img(cent(2)-(i-cent(2)),cent(1)) == 1
        break;
    end
    r(4) = r(4)-1;
end
y = floor((r(3)+r(4))/2);
cent = [cent(1),cent(2)+y];
for i = cent(1):cols    % +ve x axis
    if bg_img(cent(2),i) == 1
        break;
    end
    r1 = r1+1;
end

figure('Name','Bg_image_calivration','NumberTitle','off')
imshow(bg_img)
h = images.roi.Circle(gca,'Center',[cent(1) cent(2)],'Radius',r1-rcor);
mask = ~createMask(h);
figure('Name','mask','NumberTitle','off')
imshow(mask)

area = 0;
check = -1;
peri = 0;
coa = [];
xp = [];
xn = [];
yp = [];
yn = [];
t = [];

for cnt = 1:l
    img = imread(fullfile(path,tif_files(cnt).name));
    gray = rgb2gray(img);
    gray = gray - bg_img1;
    gray = medfilt2(gray);
    gray = gray>100;
    gray = gray(:);
    if max(gray)>0
        check = cnt+1;
        break;
    end
end

for cnt = check:l %replace by l to iterate 
    t = [t;cnt*frame_rate];
    img = imread(fullfile(path,tif_files(cnt).name));
    gray2 = rgb2gray(img);
    if cnt < check+2
        gray = medfilt2(gray2);
        BWfinal = edge(gray,'sobel');
        BWfinal = BWfinal - mask;
        BWfinal = BWfinal>0;
    else
        gray1 = bg_img1-gray2;  
        gray = medfilt2(gray1);
        BWfinal = edge(gray,'sobel');
    end
    CH1 = bwconvhull(BWfinal);
    figure(3)
    subplot(1,2,1)
    imshowpair(BWfinal,CH1)
    subplot(1,2,2)
    imshowpair(gray2,CH1)
    dumy = regionprops(CH1,"Area","Centroid","Perimeter");
    area = [area; dumy.Area];
    peri = [peri; dumy.Perimeter];
    coa = [coa; dumy.Centroid];
    xp = [xp; cord_of_sprayxpos(CH1)-cent(1)];
    xn = [xn; cent(1)-cord_of_sprayxneg(CH1)];
    yp = [yp; cent(2)-cord_of_sprayypos(CH1)];
    yn = [yn; cord_of_sprayyneg(CH1)-cent(2)];
end
figure('Name','area','NumberTitle','off')
plot(area)
figure('Name','perimeter','NumberTitle','off')
plot(peri)

speedxp = (xp(2:end)-xp(1:end-1))/frame_rate; 
speedxn = (xn(2:end)-xn(1:end-1))/frame_rate;
speedyp = (yp(2:end)-yp(1:end-1))/frame_rate;
speedyn = (yn(2:end)-yn(1:end-1))/frame_rate;
figure('Name','Speed of wavefront','NumberTitle','off')
subplot(2,2,1)
plot(speedxp)
subplot(2,2,2)
plot(speedxn)
subplot(2,2,3)
plot(speedyp)
subplot(2,2,4)
plot(speedyn)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cord. of spray front function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function a = cord_of_sprayxpos(img1)
    [~, columns] = find(img1);
    a = max(columns);
end

function a = cord_of_sprayypos(img1)
    [rows, ~] = find(img1);
    a = max(rows);
end

function a = cord_of_sprayxneg(img1)
    [~, columns] = find(img1);
    a = min(columns);
end

function a = cord_of_sprayyneg(img1)
    [rows, ~] = find(img1);
    a = min(rows);
end