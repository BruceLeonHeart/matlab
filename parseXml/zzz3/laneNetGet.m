function [JunctionNet,RoadNet] = laneNetGet(openDriveObj)


% global roads;
% global junctions;          
roads = openDriveObj.road;
junctions = openDriveObj.junction;
RoadNet = struct();
JunctionNet = [];
%处理road
for i = 1:length(roads)
    crtRoad = getSingleObject(roads,i);
    RoadNet(i).id = str2double(crtRoad.Attributes.id);
    if isfield(crtRoad,'link')
       preNode =  crtRoad.link.predecessor;
       sucNode =  crtRoad.link.successor;
       geometryBlock = crtRoad.planView.geometry;
       RoadNet(i).pre =  preNodehandle(preNode);
       RoadNet(i).next = nextNodehandle(sucNode);
       RoadNet(i).geoNums = length(geometryBlock);
       
    end
end

%处理junction
for j = 1:length(junctions)
    crtJunction = getSingleObject(junctions,j);
    connections = crtJunction.connection;
    for a = 1:length(connections)
        crtCon = getSingleObject(connections,a);
        imcomingRoad = str2double(crtCon.Attributes.incomingRoad);
        connectingRoad = str2double(crtCon.Attributes.connectingRoad);
        contactPoint = crtCon.Attributes.contactPoint;
        if contactPoint == "start"
            contactFlag = 1;
        else
            contactFlag = -1;
        end
        laneLinks = crtCon.laneLink;
        for b = 1:length(laneLinks)
            crtlaneLink = getSingleObject(laneLinks,b);
            from = str2double(crtlaneLink.Attributes.from);
            to = str2double(crtlaneLink.Attributes.to);
            JunctionNet = [JunctionNet;imcomingRoad,from,connectingRoad,to,contactFlag];
        end     
    end  
end






end

%处理前继节点
function pre = preNodehandle(preNode)
    pre = [];
    if preNode.Attributes.elementType == "road"
        pre = [pre,str2double(preNode.Attributes.elementId)];
    end
end

%处理后续节点
function next = nextNodehandle(nextNode)
    next = [];
    if nextNode.Attributes.elementType == "road"
        next = [next,str2double(nextNode.Attributes.elementId)];
    end
end

%RoadNet通过id检索示例本身
function self = findselfById(RoadNet,mId)
    for i = 1:length(RoadNet)
        if RoadNet(i).id == mId
            self = RoadNet(i);
            break;
        end
    end
end