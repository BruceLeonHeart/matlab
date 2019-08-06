function Offsets = OpenDriveGetLaneOffset(laneSection,laneSectionIdx)
m = 0;
Offsets = struct('idx',[],'s',[],'id',[],'type',[],'offset',[]);

s = str2double(laneSection.Attributes.s);

if isfield(laneSection,"left")
    lane = laneSection.left.lane;
    for m1 = 1:length(lane)
        crtlane = getSingleObject(lane,m1);
        crtlanewidth = crtlane.width;  %width集合
        crtlanewidthLength = length(crtlanewidth);
        for m2 = 1:crtlanewidthLength
            crtlanewidthSingle = getSingleObject(crtlanewidth,m2); %width单体
            m = m + 1;
            Offsets(m).idx = laneSectionIdx;
            Offsets(m).s = s + str2double(crtlanewidthSingle.Attributes.sOffset);
            Offsets(m).id = str2double(crtlane.Attributes.id);
            Offsets(m).type = crtlane.Attributes.type;
            a = str2double(crtlanewidthSingle.Attributes.a);
            b = str2double(crtlanewidthSingle.Attributes.b);
            c = str2double(crtlanewidthSingle.Attributes.c);
            d = str2double(crtlanewidthSingle.Attributes.d);
            Offsets(m).offset = [a b c d];
        end
    end
end

if isfield(laneSection,"right")
    lane = laneSection.right.lane;
    for m1 = 1:length(lane)
        crtlane = getSingleObject(lane,m1);
        crtlanewidth = crtlane.width;  %width集合
        crtlanewidthLength = length(crtlanewidth);
        for m2 = 1:crtlanewidthLength
            crtlanewidthSingle = getSingleObject(crtlanewidth,m2); %width单体
            m = m + 1;
            Offsets(m).idx = laneSectionIdx;
            Offsets(m).s = s + str2double(crtlanewidthSingle.Attributes.sOffset);
            Offsets(m).id = str2double(crtlane.Attributes.id);
            Offsets(m).type = crtlane.Attributes.type;
            a = str2double(crtlanewidthSingle.Attributes.a);
            b = str2double(crtlanewidthSingle.Attributes.b);
            c = str2double(crtlanewidthSingle.Attributes.c);
            d = str2double(crtlanewidthSingle.Attributes.d);
            Offsets(m).offset = [a b c d];
        end
    end
end
    
end


