clear all
close all
warning('off')
%%%%%%%%%%%%%%%%%%%%%%%%% taking input %%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter length calibration factor (mm/pixel)','Enter timne rate'};
dlgtitle = 'Input';
dims = [1 50];
definput = {'1','0.1'};  %(197/7.5)^-1 as provided
answer = inputdlg(prompt,dlgtitle,dims,definput);
calibration_factor = str2double(answer(1));
frame_rate = str2double(answer(2));

%%%%%%%%%%%%%%%%%%%%%%%%% asking file name %%%%%%%%%%%%%%%%%%%%%%%%%
data_filename = uigetdir; % filename for all folders
path = strcat(data_filename,"\");
tif_files = dir(fullfile(path,'*.png')); %check once
l = length(tif_files);
xcl = strcat(data_filename,'\','results.xlsx');
height = [];
width = [];
cangle = [];
time = [];
destdirectory1 = strcat(path,'binary_images');
mkdir(destdirectory1);
destdirectory2 = strcat(path,'skeleton_images');
mkdir(destdirectory2);
cola = {'A2' 'B2' 'C2' 'D2' 'E2' 'F2' 'G2' 'H2'};
for cnt = 1:l
    time = [time;cnt*frame_rate];
    [img,m] = imread(fullfile(path,tif_files(cnt).name));
    img = ind2gray(img,m);
    img = img> 160;
    img1 = bwskel(img);
    [rows ,cols ,~] = size(img);
    t = img1(floor(rows/2),:);
    g1 = find(t,2,"last");
    height = [height; calibration_factor*(cols-g1(1))];
    t = img(floor(rows/2):rows,g1(1));
    t = 1-t;
    g = find(t,1,"first");
    width = [width; 2*(g)*calibration_factor];
    t2 = img1(floor(rows/2):rows,g1(1)-10);
    g2 = find(t,1,"first");
    tann = g2/10;
    tann = atan(tann);
    cangle = [cangle; rad2deg(tann)];
    thisimage1 = strcat('processed_binary_',tif_files(cnt).name);
    fulldestination = fullfile(destdirectory1, thisimage1);  %name file relative to that directory
    imwrite(img, fulldestination);
    thisimage2 = strcat('processed_skeleton_',tif_files(cnt).name);
    fulldestination = fullfile(destdirectory2, thisimage2);  %name file relative to that directory
    imwrite(img1 , fulldestination);
end
sheet = "Results";
Results_Names={'time','Height','Width','Cone angle'};
xlswrite(string(xcl),Results_Names(1),sheet,'A1');
xlswrite(string(xcl),Results_Names(2),sheet,'B1');
xlswrite(string(xcl),Results_Names(3),sheet,'C1');
xlswrite(string(xcl),Results_Names(4),sheet,'D1');
        
xlswrite(string(xcl),time,sheet,string(cola(1)));
xlswrite(string(xcl),height,sheet,string(cola(2)));
xlswrite(string(xcl),width,sheet,string(cola(3)));
xlswrite(string(xcl),tann,sheet,string(cola(4)));