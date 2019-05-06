function  pathPlan() 
fileObj = xml2struct('demo_prescan.xml');
openDriveObj = fileObj.OpenDRIVE;
roadObj = openDriveObj.road;
roadNum = length(roadObj);
linkedRoad = zeros(roadNum); 
for i = 1:roadNum
    if str2double(roadObj{1,i}.Attributes.junction) ~= -1
         q = str2double(roadObj{1,i}.link.successor.Attributes.elementId);
         linkedRoad(i,q) = 1;
     end
end

end

