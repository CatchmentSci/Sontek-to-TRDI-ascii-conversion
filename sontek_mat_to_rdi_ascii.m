function sontek_mat_to_rdi_ascii(zPathName,zFileName, workingDir)

% Inputs:
% zPathName = The path containing the sontek .mat files e.g. ['C:\Users\Matt\Downloads\']
% zFileName = The the sontek .mat file to be converted e.g. {'20060305155411r.mat'}
% workingDir = The location where outputs and required git files will be
% saved to e.g. ['C:\Users\Test\Downloads\ADCP\Outputs\']

% Outputs:
% An ascii format file will be exported to the zPathName directory

% This script uses a forked version of the VMT git observatory. For full 
% details on licences, etc. please visit: https://github.com/frank-engel-usgs/VMT

% Ensure that all files from within the 'Sontek-to-TRDI-ascii-conversion' 
% repository are available on the MATLAB path before running the script

% M.T.Perks, 20210201

% Clone the required repository [VMT]
cd (workingDir);
!git clone https://github.com/CatchmentSci/VMT.git
addpath(genpath(workingDir));

t1 = char(zFileName);
zFileNameOut = [workingDir t1(1:end-4) '_ASC.txt']; % this is what the exported ascii will be called
[~,~,~,A,~] = VMT_ReadFiles_SonTek(zPathName,zFileName); % load in the sontek data

A.Wat.vMag = replace_num(A.Wat.vMag,NaN,-32768);
A.Wat.vDir = replace_num(A.Wat.vDir,NaN,-32768);
A.Wat.vEast = replace_num(A.Wat.vEast,NaN,-32768);
A.Wat.vNorth = replace_num(A.Wat.vNorth,NaN,-32768);
A.Wat.vVert = replace_num(A.Wat.vVert,NaN,-32768);
A.Wat.vError = replace_num(A.Wat.vError,NaN,-32768);
A.Wat.backscatter = replace_num(A.Wat.backscatter,NaN,255);
A.Wat.percentGood = replace_num(A.Wat.percentGood,NaN,100); % assigning all values as 100 (doesn't appear to cause any issues, needs testing)
A.Q.unit = replace_num(A.Q.unit,NaN,2147483647); % assigning unit q as 2147483647 as no data available (may cause issues, needs testing)
A.Sup.nPings = replace_num(A.Sup.nPings,NaN,1); % assigning number of pings per ensemble as zeros as no data available (may cause issues, needs testing)
A.Sup.timeDelta_sec100 = replace_num(A.Sup.timeDelta_sec100,NaN,0); % assigning time per ensemble as zero if no data available
A.Sup.wm = replace_num(A.Sup.wm,NaN,0); % assigning profile mode as 0 if no data
A.Sup.noEnsInSeg = replace_num(A.Sup.noEnsInSeg,NaN,1); % number of ensembles in segment as one
A.Nav.bvError = replace_num(A.Nav.bvError,NaN,0);
A.Nav.dmg = replace_num(A.Nav.dmg,NaN,0); % could possibly be replaced with length?
A.Q.startDepth = replace_num(A.Q.startDepth,NaN,0);
A.Q.endDepth = replace_num(A.Q.endDepth,NaN,0);

header  = char({
    'Ascii file generated using sontek_mat_to_rdi_ascii'; ... % comment line1
    'This is WinRiver II comment line #2'; ... % comment line2
    ['    ' num2str([A.Sup.binSize_cm(1), A.Sup.blank_cm, A.Sup.draft_cm, A.Sup.nBins, A.Sup.nPings, A.Sup.timeDelta_sec100, A.Sup.wm])]  ... % Row C
    });


for a = 1:length(A.Sup.ensNo)
    t_var = cellstr(A.Sup.units); % velocity measurement units
    t_var2 = cellstr(A.Sup.intUnits); % intensity units
    
    collated_data = {
        ['    ' num2str([A.Sup.month(a), A.Sup.day(a), A.Sup.hour(a), A.Sup.minute(a), A.Sup.second(a), A.Sup.sec100(a), A.Sup.ensNo(a), A.Sup.noEnsInSeg(a), A.Sensor.pitch_deg(a), A.Sensor.roll_deg(a), A.Sensor.heading_deg(a), A.Sensor.temp_degC(a)])]; % row 1
        [num2str([A.Nav.bvEast(a), A.Nav.bvNorth(a), A.Nav.bvVert(a), A.Nav.bvError(a), 0, 0, 0, 0, A.Nav.depth(a,1), A.Nav.depth(a,2), A.Nav.depth(a,3), A.Nav.depth(a,4)])]; % row 2 - Only using beams 1-4, ignoring beam 5 as no room in rdi template
        [num2str([A.Nav.length(a), A.Sup.timeElapsed_sec(a), A.Nav.totDistNorth(a), A.Nav.totDistEast(a), A.Nav.dmg(a)])]; % row 3
        [num2str([30000.0000000, 30000.0000000, -32768, -32768, 0.0])]; % row 4 - GPS navigation data (duplicate to no example where no GPS data was available)
        [num2str([A.Q.meas(a), A.Q.top(a), A.Q.bot(a), A.Q.start(a), A.Q.startDist(a), A.Q.end(a), A.Q.endDist(a), A.Q.startDepth(a), A.Q.endDepth(a)])]; % row 5 - note mod to parseSonTekVMT.m to filter Q by idx for all series
        [num2str([A.Sup.nBins]), ' ', t_var{a}, ' ' A.Sup.vRef, t_var2{a}, A.Sup.intScaleFact_dbpcnt(a), A.Sup.absorption_dbpm(a)] % row 6
        };
    
    collated_data2 = num2str([
        A.Wat.binDepth(:,a), A.Wat.vMag(:,a), A.Wat.vDir(:,a), A.Wat.vEast(:,a), A.Wat.vNorth(:,a), A.Wat.vVert(:,a), A.Wat.vError(:,a), A.Wat.backscatter(:,a,1), A.Wat.backscatter(:,a,2), A.Wat.backscatter(:,a,3), A.Wat.backscatter(:,a,4), A.Wat.percentGood(:,a), A.Q.unit(:,a)
        ]);
    
    if a == 1
        dlmwrite(zFileNameOut,header,'delimiter','','-append');
    end
    dlmwrite(zFileNameOut,char(collated_data),'delimiter','','-append');
    dlmwrite(zFileNameOut,char(collated_data2),'delimiter','','-append');
    
    clear collated_data collated_data2
    
end
fclose('all');


