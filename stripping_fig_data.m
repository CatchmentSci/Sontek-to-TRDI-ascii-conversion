fileIn = ['C:\Users\Matt\OneDrive - Newcastle University\Personal Work\Software\Sontek-to-TRDI-ascii-conversion\Fig_01.fig'];

h = openfig(fileIn);
dataObjs = findobj(h,'-property','YData');
num_lines = size(dataObjs,1);

S = [];
for i = 1:num_lines
    N = {matlab.lang.makeValidName(dataObjs(i).DisplayName)};
    S.(N{1}) = [dataObjs(i).XData; dataObjs(i).YData];
end

