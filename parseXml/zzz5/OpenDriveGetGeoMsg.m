function msg = OpenDriveGetGeoMsg(geo)
msg = struct();
msg.s = str2double(geo.Attributes.s);
msg.x = str2double(geo.Attributes.x);
msg.y = str2double(geo.Attributes.y);
msg.hdg = str2double(geo.Attributes.hdg);
msg.mlength = str2double(geo.Attributes.length);
if isfield(geo,"line")
    msg.lineType = "line";
elseif isfield(geo,"arc")
    msg.lineType = "arc";
    msg.curvature = str2double(geo.arc.Attributes.curvature);
elseif isfield(geo,"spiral")
    msg.lineType = "spiral";
    msg.curvStart = str2double(geo.spiral.Attributes.curvStart);
    msg.curvEnd = str2double(geo.spiral.Attributes.curvEnd);
else
    fprintf("unknown kind Geo");
end
end