function msg = getMsgFromLaneSection(laneSection)
msg = [];

if isfield(laneSection,"left")
    lane = laneSection.left.lane;
    for m1 = 1:length(lane)
        crtlane = getSingleObject(lane,m1);
        if crtlane.Attributes.type == "driving"
            id = str2double(crtlane.Attributes.id);
%             nextlaneid = str2double(crtlane.link.successor.Attributes.id);
            offset = str2double(crtlane.width.Attributes.a);
            msg=[msg;id,offset];
            break;
        end
    end
end

if isfield(laneSection,"right")
    lane = laneSection.right.lane;
    for m2 = 1:length(lane)
        crtlane = getSingleObject(lane,m2);
        if crtlane.Attributes.type == "driving"
            id = str2double(crtlane.Attributes.id);
%             nextlaneid = str2double(crtlane.link.successor.Attributes.id);
            offset = str2double(crtlane.width.Attributes.a);
            msg=[msg;id,offset];
            break;
        end
    end
end
    
if isfield(laneSection,"center")
end
end

