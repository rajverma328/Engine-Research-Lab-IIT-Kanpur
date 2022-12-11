clear all
close all
warning('off')
%%%%%%%%%%%%%%%%%%%%%%%%% taking input %%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter length calibration factor (mm/pixel)','Enter frame rate in f.p.s.','width of spray in pixels'};
dlgtitle = 'Input';
dims = [1 50];
definput = {'0.05543','10000','20'};  %(197/7.5)^-1 as provided
answer = inputdlg(prompt,dlgtitle,dims,definput);
calibration_factor = str2double(answer(1));
frame_rate = str2double(answer(2));
widd = str2double(answer(3));
area_cal_fac = calibration_factor*calibration_factor;
frame_rate = frame_rate/1000; %frames per milli second
widd = widd/2;

%%%%%%%%%%%%%%%%%%%%%%%%% asking file name %%%%%%%%%%%%%%%%%%%%%%%%%
data_filename = uigetdir; % filename for all folders
topLevelFolder = data_filename;  % Get a list of all files and folders in this folder.
files = dir(topLevelFolder);    % Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];   % Extract only those that are directories.
subFolders = files(dirFlags);   % A structure with extra info. Get only the folder names into a cell array.
subFolderNames = {subFolders(3:end).name}; % Start at 3 to skip .

for index = 1:length(subFolderNames)
    blsh = '\';
    path_in = strcat(data_filename,blsh,subFolderNames(index));
    bottomLevelFolder = string(path_in);
    files_in = dir(bottomLevelFolder);    % Get a logical vector that tells which is a directory.
    dirFlags_in = [files_in.isdir];   % Extract only those that are directories.
    subFolders_in = files_in(dirFlags_in);   % A structure with extra info. Get only the folder names into a cell array.
    subFolderNames_in = {subFolders_in(3:end).name};
    s_1 = subFolderNames(index);
    xcl = strcat(path_in,'\',s_1,'.xlsx');
    cola = {'A2' 'B2' 'C2' 'D2' 'E2' 'F2' 'G2'};
    for in_index = 1 : length(subFolderNames_in)
        sheet = string(subFolderNames_in(in_index));
        path = strcat(path_in,blsh,subFolderNames_in(in_index),blsh);
        path = string(path);
        dumy = string(subFolderNames_in(in_index));
        tif_files = dir(fullfile(path,'*.tif'));
        l = length(tif_files);
        bg_img = rgb2gray(imread(fullfile(path,tif_files(1).name)));
        k = 0;
        dim = size(bg_img);
        figure(1)
        hold on
        nozz = [];
        nozzle = [];
        area = [];
        spray_speed = [];   
        coa = [];
        cowfx = [];
        cowfy = [];
        area_speed = [];
        CA = [];
        destdirectory = strcat(path,'result_images');
        mkdir(destdirectory);   %create the directory
        for cnt = 1 : l
            img{cnt} = imread(fullfile(path,tif_files(cnt).name));
            gray = rgb2gray(img{cnt});
            diff_img = bg_img - gray;
            diff_img = imfill(diff_img,'holes');
            BW = diff_img > 20;   
            se90 = strel('line',1,90);
            se0 = strel('line',1,0);
            imgThresh = imdilate(BW,[se90 se0]);
            imgFilled = bwareaopen(imgThresh,30);
            imgFilled = imfill(imgFilled, 'holes');
            seD = strel('diamond',1);
            imgFilled = imerode(imgFilled,seD);
            BWfinal = imerode(imgFilled,seD);
            area = [area; area_cal_fac*spray_area(BWfinal)];
            coa = [coa; center_of_area(BWfinal)];
            if (area(cnt) ~=0) && k == 0
                k = cnt;
                nozz(2) = cord_of_nozzley(BWfinal);
                nozz(1) = cord_of_nozzlex(BWfinal);
            end
            if cnt>1
                area_speed = [area_speed; area_cal_fac*(area(cnt)-area(cnt-1))/frame_rate];
            end
            thisimage = strcat('processed_',tif_files(cnt).name);
            fulldestination = fullfile(destdirectory, thisimage);  %name file relative to that directory
            imwrite(255-diff_img, fulldestination);  %save the file there directory
            plot(-coa(cnt,2),coa(cnt,1),'ob')
            drawnow
        end        
        
        for i = 1:length(coa(:,1))
            if isnan(coa(i,1))
                coa(i,1) = nozz(1);
                coa(i,2) = nozz(2) + widd;
            end
        end

        x1 = coa(:,1);
        y1 = coa(:,2);
        c = polyfit(x1,y1,1);
        theta = atand(c(1));
        
        x = linspace(0,dim(2));
        y = c(1)*(x) + c(2);
        plot(-y,x)
        pause(1)
        close
%         plot(area)
%         nozzle = 0;
%         for cnt = 1:l %replace by l to iterate 
%             img{cnt} = imread(fullfile(path,tif_files(cnt).name));
%             gray = rgb2gray(img{cnt});
%             diff_img = bg_img - gray;
%             diff_img = imfill(diff_img,'holes');
%             BW = diff_img > 10;     %try making it user defined
%             se90 = strel('line',1,90);
%             se0 = strel('line',1,0);
%             imgThresh = imdilate(BW,[se90 se0]);
%             imgFilled = bwareaopen(imgThresh,30);
%             imgFilled = imfill(imgFilled, 'holes');
%             BWfinal = imrotate(imgFilled,theta);
%             if cnt == k 
%                 nozzle = cord_of_nozzlex(BWfinal);
%             end
%             ax = cord_of_sprayx(BWfinal);
%             ay = cord_of_sprayy(BWfinal);
%             cowfx = [cowfx; calibration_factor*(nozzle-ax)];
%             cowfy = [cowfy; calibration_factor*(ay)];
%         end
%         speedx = (cowfx(2:end)-cowfx(1:end-1))/frame_rate;    %- added to compensate negative sign

        %%%%%%%%%%%%%%%%%%%%%%%%% writing data in excel file %%%%%%%%%%%%%%%%%%%%%%%%%
%         Results_Names={'Area','Center of Area(x)','Center of Area(y)','area speed','wave front displacement(along axis)','radial displacemet(wave front)','axial speed'};
%         xlswrite(string(xcl),Results_Names(1),sheet,'A1');
%         xlswrite(string(xcl),Results_Names(2),sheet,'B1');
%         xlswrite(string(xcl),Results_Names(3),sheet,'C1');
%         xlswrite(string(xcl),Results_Names(4),sheet,'D1');
%         xlswrite(string(xcl),Results_Names(5),sheet,'E1');
%         xlswrite(string(xcl),Results_Names(6),sheet,'F1');
%         xlswrite(string(xcl),Results_Names(7),sheet,'G1');
% 
%         xlswrite(string(xcl),area,sheet,string(cola(1)));
%         xlswrite(string(xcl),coa(:,1),sheet,string(cola(2)));
%         xlswrite(string(xcl),coa(:,2),sheet,string(cola(3)));
%         xlswrite(string(xcl),area_speed,sheet,string(cola(4)));
%         xlswrite(string(xcl),cowfx,sheet,string(cola(5)));
%         xlswrite(string(xcl),cowfy,sheet,string(cola(6)));
%         xlswrite(string(xcl),speedx,sheet,string(cola(7)));

       
        fprintf("%s data analaysis completed\n",string(subFolderNames_in(in_index)))
    end
    disp('...................................................')
    fprintf("%s data analaysis completed\n",string(subFolderNames(index)))
    disp('...................................................')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% area function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function a = spray_area(img)    
    area = (bwarea(img));  
    a = round(area,3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% center of area function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function a = center_of_area(img1)
    [y, x] = ndgrid(1:size(img1, 1), 1:size(img1, 2));
    a = mean([x(logical(img1)), y(logical(img1))]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cord. of spray front function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function a = cord_of_sprayx(img1)
    [~, columns] = find(img1);
    a = min(columns);
end

function a = cord_of_sprayy(img1)
    [rows, ~] = find(img1);
    a = min(rows);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cord. of nozzle function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function a = cord_of_nozzlex(img1)
    [~, columns] = find(img1);
    a = max(columns);
end

function a = cord_of_nozzley(img1)
    [rows, ~] = find(img1);
    a = min(rows);
end