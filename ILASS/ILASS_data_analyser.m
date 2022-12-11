clc
clear all
close all
warning('off')
SF = 10.9366;
tresh=40;
c =0;
% filename = 'F:\OneDrive - IIT Kanpur\Desktop\ERL\results\';

data_filename = uigetdir; % filename for all folders
topLevelFolder = data_filename;  % Get a list of all files and folders in this folder.
files = dir(topLevelFolder);    % Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];   % Extract only those that are directories.
subFolders = files(dirFlags);   % A structure with extra info. Get only the folder names into a cell array.
subFolderNames = {subFolders(3:end).name}; % Start at 3 to skip . and ..
T = {'50' '100' '150' '200'};
cola = {'A' 'L' 'W' 'AH' 'AS'};
col_count = 1;
xcl = strcat(data_filename,'\results.xlsx'); 
% for k = 1 : length(subFolderNames)    %%folder name settings 
% 	fprintf('Sub folder #%d = %s\n', k, subFolderNames{k});
% end

for index = 1:length(subFolderNames)
    blsh = '\';
    path_in = strcat(data_filename,blsh,subFolderNames(index));
    bottomLevelFolder = string(path_in);
    files_in = dir(bottomLevelFolder);    % Get a logical vector that tells which is a directory.
    dirFlags_in = [files_in.isdir];   % Extract only those that are directories.
    subFolders_in = files_in(dirFlags_in);   % A structure with extra info. Get only the folder names into a cell array.
    subFolderNames_in = {subFolders_in(3:end).name};
    s_1 = subFolderNames(index);
    sheet = string(s_1);
%     for k = 1 : length(subFolderNames_in)    %%folder name settings 
% 	    fprintf('Sub folder #%d = %s\n', k, subFolderNames_in{k});
%     end
%     fprintf("..............\n");

    for in_index = 1 : length(subFolderNames_in)
        path = strcat(path_in,blsh,subFolderNames_in(in_index),blsh);
        path = string(path);
        dumy = string(subFolderNames_in(in_index));
        tif_files = dir(fullfile(path,'*.tif'));
        for cnt = 1 : 10
            img{cnt} = imread(fullfile(path,tif_files(cnt).name));     
        end
        LPL=[0];
        Sp_Area=[0];
        CAngle=[0];
        PicNo=(0:9)';
        bgd = img{1};
        b_gray=rgb2gray(bgd);
        for f = 2:10
            x = img{f};
            x_gray=rgb2gray(x);
            z_final=x_gray-b_gray;
            [r,c] = size(z_final);
            z_tresh = z_final;
            for i=1:r
                for j=1:c
                    v=z_tresh(i,j);
                    if v<=tresh
                        z_tresh(i,j)=0;
                    elseif v>tresh && v<256
                        z_tresh(i,j)=255;
                    end
                end
            end
            BW = imbinarize(z_tresh);
            P0=[523,199];
            [r,c] = size(BW);
            tot_area=0;
            for i=P0(2):r
                for j=1:P0(1)
                    v=BW(i,j);
                    tot_area=tot_area+v;
                end
            end
            if tot_area > 0
                area=0;
                tot_area;
                for i=P0(2):r
                    for j=1:P0(1)
                        v=BW(i,j);
                        area=area+v;
                        if area == floor(0.995*tot_area)
                            y1=i;
                            area_end = area;
                        end
                    end
                end
                P1=[P0(1),y1];
                area_end;
                PenetrationLength = abs(P1(2)-P0(2));
                tot_area;
                LPL=[LPL,PenetrationLength];
                Sp_Area=[Sp_Area,tot_area];
                LPL_50=0.5*PenetrationLength;
                P2(2)=P0(2)+LPL_50;
                P3(2)=P0(2)+LPL_50;
                P4(2)=P0(2)+LPL_50;
                v=0;
                c_vec=BW(floor(P2(2)),1:P0(1));
                c=find(c_vec == 1);
                if length(c)>1
                    P2(1)=c(1);
                    P3(1)=c(end);
                    P4(1)=c(1)+2*(c(end)-c(1));
                    angle = atan2(abs(det([P4-P0;P2-P0])),dot(P4-P0,P2-P0));
                    cone_angle = (180*angle)/pi;
                    CAngle=[CAngle,cone_angle];
                else
                    cone_angle=0;
                    CAngle=[CAngle,cone_angle];
                end
            else
                PenetrationLength=0;
                cone_angle=0;
                tot_area=0;
                LPL=[LPL,PenetrationLength];
                CAngle=[CAngle,cone_angle];
                Sp_Area=[Sp_Area,tot_area];
            end            
        end
        %Outputting the results
 
        P = rem(in_index,5);
        if P == 0
            P = 5;
        end
        Q = (in_index-P)/5;
        col = cola(Q+1);
        p = ((P-1)*15)+1;
        start_point1=string(append(col,num2str(p)));
        start_point2=string(append(col,num2str(p+1)));
        start_point3=string(append(col,num2str(p+2)));
        LPL=(LPL)';
        CAngle=(CAngle)';
        Sp_Area=(Sp_Area)';
        Case_Name={'',dumy,''};
        Results_Names={'Time after pulse to SADI(ms)','LPL (mm)','CA (degree)','SA (mm2)',num2str(tresh)};
        Results_Values=[round((PicNo./5.4),2),round((LPL./SF),1),round(CAngle,1),round(Sp_Area./(SF*SF),1)];
        xlRange=start_point1;
        xlswrite(xcl,Case_Name,sheet,xlRange);
        xlRange=start_point2;
        xlswrite(xcl,Results_Names,sheet,xlRange);
        xlRange=start_point3;
        xlswrite(xcl,Results_Values,sheet,xlRange);
        fprintf("%s folder data analysis completed\n",dumy); 
    end
    fprintf("....................................\n")
    fprintf("%s analysis completed\n",string(subFolderNames(index)));
    fprintf("....................................\n")
end



