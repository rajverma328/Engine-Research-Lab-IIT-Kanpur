clear all
close all
warning('off')
%%%%%%%%%%%%%%%%%%%%%%%%% taking input %%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter length calibration factor (mm/pixel)','Enter timne rate','spray height in pixels'};
dlgtitle = 'Input';
dims = [1 50];
definput = {'1','0.1','465'};  %(197/7.5)^-1 as provided
answer = inputdlg(prompt,dlgtitle,dims,definput);
calibration_factor = str2double(answer(1));
frame_rate = str2double(answer(2));
widd = str2double(answer(3));
%%%%%%%%%%%%%%%%%%%%%%%%% asking file name %%%%%%%%%%%%%%%%%%%%%%%%%
data_filename = uigetdir; % filename for all folders
path = strcat(data_filename,"\");
tif_files = dir(fullfile(path,'*.bmp')); %check once
l = length(tif_files);
xcl = strcat(data_filename,'\','results.xlsx');
height = [];
width = [];
cangle = 0;
centang = 0;
area = 0;
time = frame_rate;
destdirectory1 = strcat(path,'binary_images');
mkdir(destdirectory1);
cola = {'A2' 'B2' 'C2' 'D2' 'E2' 'F2' 'G2' 'H2'};
imgt = imread(fullfile(path,tif_files(1).name));
imgt = rgb2gray(imgt);
imgt = imgt<240;
[rows ,cols ,~] = size(imgt);
imgt = imcrop(imgt,[10, 10, cols-20, rows-20]);
height = [height;cord_of_sprayx(imgt)];
width = [width;cord_of_sprayy(imgt)];
for cnt = 2:l
    time = [time;(cnt)*frame_rate];
    img = imread(fullfile(path,tif_files(cnt).name));
    img = rgb2gray(img);
    img = img<240 & img >10;
    img = imcrop(img,[10, 10, cols-20, rows-20]);
    img = img-imgt;
    thisimage1 = strcat('processed_binary_',tif_files(cnt).name);
    fulldestination = fullfile(destdirectory1, thisimage1);  %name file relative to that directory
    imwrite(img, fulldestination);
    height = [height;cord_of_sprayx(img)];
    width = [width;cord_of_sprayy(img)];
    pos = find(img(width(cnt),:),1);
    ang = atan((width(1)-width(cnt))/(height(1)-pos));
    ang2 = atan(465-width(cnt)/(height(1)-pos));
    cangle = [cangle;rad2deg(ang)];
    centang= [centang;rad2deg(ang2)];
    area = [area;bwarea(img)*calibration_factor*calibration_factor];
end
threshh = height(1);
threshw = width(1);
height = (-height+threshh)*calibration_factor;
width = (-width+threshh)*calibration_factor;
speedh = diff(height)/frame_rate;
speedw = diff(width)/frame_rate;
speedar = diff(area)/frame_rate;
sheet = "Results";
Results_Names={'time','Height','Width','Cone angle','H speed','W speed','area','area_speed'};
xlswrite(string(xcl),Results_Names(1),sheet,'A1');
xlswrite(string(xcl),Results_Names(2),sheet,'B1');
xlswrite(string(xcl),Results_Names(3),sheet,'C1');
xlswrite(string(xcl),Results_Names(4),sheet,'D1');
xlswrite(string(xcl),Results_Names(5),sheet,'E1');
xlswrite(string(xcl),Results_Names(6),sheet,'F1');
xlswrite(string(xcl),Results_Names(7),sheet,'G1');
xlswrite(string(xcl),Results_Names(8),sheet,'H1');
        
xlswrite(string(xcl),time,sheet,string(cola(1)));
xlswrite(string(xcl),height,sheet,string(cola(2)));
xlswrite(string(xcl),width,sheet,string(cola(3)));
xlswrite(string(xcl),centang,sheet,string(cola(4)));
xlswrite(string(xcl),speedh,sheet,string(cola(5)));
xlswrite(string(xcl),speedw,sheet,string(cola(6)));
xlswrite(string(xcl),area,sheet,string(cola(7)));
xlswrite(string(xcl),speedar,sheet,string(cola(8)));

function a = cord_of_sprayx(img1)
    [~, columns] = find(img1);
    a = min(columns);
end
function a = cord_of_sprayy(img1)
    [rows, ~] = find(img1);
    a = min(rows);
end
