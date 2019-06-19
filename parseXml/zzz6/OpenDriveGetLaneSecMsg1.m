function msg = OpenDriveGetLaneSecMsg1(laneSection)

msg = struct('idx',[],'laneSecIdx',[],'s',[],'id',[],'type',[],'offset',[],'speed',[]);
idx = 0;
s = str2double(laneSection.Attributes.s);
if isfield(laneSection,"center")
    lane = laneSection.center.lane;
    for m0 = 1:length(lane)
        idx = idx + 1;
        crtlane = getSingleObject(lane,m0);
        msg(idx).idx = idx; 
        msg(idx).s = s; 
        msg(idx).id = str2double(crtlane.Attributes.id);
        msg(idx).type = crtlane.Attributes.type;
       
    end
end

if isfield(laneSection,"left")
    lane = laneSection.left.lane;
    for m1 = 1:length(lane)
        crtlane = getSingleObject(lane,m1);
        tmpType = crtlane.Attributes.type;
        if strcmp(tmpType,'driving')%这里遇到了type为parking的时候，offset不唯一的情况
            crtwidths = crtlane.width;
            if length(crtwidths) == 1 && str2double(crtwidths.Attributes.sOffset) == 0
                idx = idx + 1;
                msg(idx).idx = idx; 
                a = str2double(crtwidths.Attributes.a);
                b = str2double(crtwidths.Attributes.b);
                c = str2double(crtwidths.Attributes.c);
                d = str2double(crtwidths.Attributes.d);
                msg(idx).offset = [a,b,c,d];
                msg(idx).s = s + str2double(crtwidths.Attributes.sOffset); 
                msg(idx).id = str2double(crtlane.Attributes.id);
                msg(idx).type = crtlane.Attributes.type;
                if isfield(crtlane,'speed')
                    msg(idx).speed = str2double(crtlane.speed.Attributes.max);
                end
            elseif length(crtwidths) > 1
                for k = 1 : length(crtwidths)
                    idx = idx + 1;
                    crtwidth = getSingleObject(crtwidths,k);
                    msg(idx).idx = idx; 
                    a = str2double(crtwidth.Attributes.a);
                    b = str2double(crtwidth.Attributes.b);
                    c = str2double(crtwidth.Attributes.c);
                    d = str2double(crtwidth.Attributes.d);
                    msg(idx).s = s + str2double(crtwidth.Attributes.sOffset); 
                    msg(idx).id = str2double(crtlane.Attributes.id);
                    msg(idx).type = crtlane.Attributes.type;
                    if isfield(crtlane,'speed')
                        msg(idx).speed = str2double(crtlane.speed.Attributes.max);
                    end
                    msg(idx).offset = [a,b,c,d];                   
                end
            end
        end

       
    end
end

if isfield(laneSection,"right")
    lane = laneSection.right.lane;
    for m1 = 1:length(lane)
        crtlane = getSingleObject(lane,m1);
        tmpType = crtlane.Attributes.type;
        if strcmp(tmpType,'driving')%这里遇到了type为parking的时候，offset不唯一的情况
            crtwidths = crtlane.width;
            if length(crtwidths) == 1 && str2double(crtwidths.Attributes.sOffset) == 0
                idx = idx + 1;
                msg(idx).idx = idx; 
                a = str2double(crtwidths.Attributes.a);
                b = str2double(crtwidths.Attributes.b);
                c = str2double(crtwidths.Attributes.c);
                d = str2double(crtwidths.Attributes.d);
                msg(idx).offset = [a,b,c,d];
                msg(idx).s = s + str2double(crtwidths.Attributes.sOffset); 
                msg(idx).id = str2double(crtlane.Attributes.id);
                msg(idx).type = crtlane.Attributes.type;
                if isfield(crtlane,'speed')
                    msg(idx).speed = str2double(crtlane.speed.Attributes.max);
                end
            elseif length(crtwidths) > 1
                for k = 1 : length(crtwidths)
                    idx = idx + 1;
                    crtwidth = getSingleObject(crtwidths,k);
                    msg(idx).idx = idx; 
                    a = str2double(crtwidth.Attributes.a);
                    b = str2double(crtwidth.Attributes.b);
                    c = str2double(crtwidth.Attributes.c);
                    d = str2double(crtwidth.Attributes.d);
                    msg(idx).s = s + str2double(crtwidth.Attributes.sOffset); 
                    msg(idx).id = str2double(crtlane.Attributes.id);
                    msg(idx).type = crtlane.Attributes.type;
                    if isfield(crtlane,'speed')
                        msg(idx).speed = str2double(crtlane.speed.Attributes.max);
                    end
                    msg(idx).offset = [a,b,c,d];                   
                end
            end
        end

       
    end
        
end
    
end


