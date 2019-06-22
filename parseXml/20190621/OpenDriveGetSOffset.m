function  offset = OpenDriveGetSOffset(S,id,mOffsets,RoadGeoEnd)

offsetLength = length(mOffsets);
idSet = struct('idx',[],'s',[],'id',[],'type',[],'offset',[],'s_end',[]);
m = 0;
for i = 1:offsetLength
    if id == mOffsets(i).id
        m = m + 1;
        idSet(m).idx = mOffsets(i).idx;
        idSet(m).s = mOffsets(i).s;
        idSet(m).id = mOffsets(i).id;
        idSet(m).type = mOffsets(i).type;
        idSet(m).offset = mOffsets(i).offset;
    end
end
idSetLength = length(idSet);
if idSetLength == 1
    idSet(1).s_end = RoadGeoEnd;
else
    for j = 1:idSetLength
        if j == idSetLength
            idSet(j).s_end = RoadGeoEnd;
        else
            idSet(j).s_end = idSet(j +1 ).s;
        end
    end
end

crtId = idSetLength;
for m = 1:idSetLength
    if S >= idSet(m).s && S < idSet(m).s_end
        crtId = m;
        break;
    end
end

delta_s = S - idSet(crtId).s;
offset = calOffset(delta_s,idSet(crtId).offset);
end

function res = calOffset(delta_s,offset)
a = offset(1);
b = offset(2);
c = offset(3);
d = offset(4);
res = a + b * delta_s + c * delta_s.^2 + d * delta_s.^3 ;
end
