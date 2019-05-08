function  pathPlan() 
fileObj = xml2struct('demo_prescan.xml');
openDriveObj = fileObj.OpenDRIVE;
roadObj = openDriveObj.road;
roadNum = length(roadObj);
junctionObj = openDriveObj.junction;
junctionNum = length(junctionObj);
linkedRoad = zeros(roadNum);
for i =1:junctionNum
    tempJunc = junctionObj{1,i};
    tempConns = tempJunc.connection;
    for j = 1:length(tempConns)
        from = str2double(tempConns{1,j}.Attributes.incomingRoad);
        to = str2double(tempConns{1,j}.Attributes.connectingRoad);
        linkedRoad(from,to) = 1;
    end
end


 
for i = 1:roadNum
    
    if str2double(roadObj{1,i}.Attributes.junction) ~= -1
         q = str2double(roadObj{1,i}.link.successor.Attributes.elementId);
         linkedRoad(i,q) = 1;
     end
end

end

