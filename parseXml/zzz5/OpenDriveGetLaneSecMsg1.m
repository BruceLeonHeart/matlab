function msg = OpenDriveGetLaneSecMsg1(laneSection)

msg = struct('s',[],'id',[],'type',[],'offset',[],'speed',[]);
idx = 1;
s = str2double(laneSection.Attributes.s);
if isfield(laneSection,"center")
    lane = laneSection.center.lane;
    for m0 = 1:length(lane)
        crtlane = getSingleObject(lane,m0);
        msg(idx).s = s; 
        msg(idx).id = str2double(crtlane.Attributes.id);
        msg(idx).type = crtlane.Attributes.type;
        idx = idx + 1;
    end
end

if isfield(laneSection,"left")
    lane = laneSection.left.lane;
    for m1 = 1:length(lane)
        crtlane = getSingleObject(lane,m1);
        msg(idx).s = s; 
        msg(idx).id = str2double(crtlane.Attributes.id);
        msg(idx).type = crtlane.Attributes.type;
        if strcmp(msg(idx).type,'driving')%这里遇到了type为parking的时候，offset不唯一的情况
            msg(idx).offset = str2double(crtlane.width.Attributes.a);
        end
        if isfield(crtlane,'speed')
            msg(idx).speed = str2double(crtlane.speed.Attributes.max);
        end
        idx = idx + 1;
    end
end

if isfield(laneSection,"right")
    lane = laneSection.right.lane;
    for m2 = 1:length(lane)
         crtlane = getSingleObject(lane,m2);
        msg(idx).s = s; 
        msg(idx).id = str2double(crtlane.Attributes.id);
        msg(idx).type = crtlane.Attributes.type;
        if strcmp(msg(idx).type,'driving')
            msg(idx).offset = str2double(crtlane.width.Attributes.a);
        end
        if isfield(crtlane,'speed')
            msg(idx).speed = str2double(crtlane.speed.Attributes.max);
        end
        idx = idx + 1;
    end
end
    
end