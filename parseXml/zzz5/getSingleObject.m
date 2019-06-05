function single = getSingleObject(obj,idx)
%在obj为cell或者struct时，返回单例
if length(obj) == 1
    single = obj(1);
else
    single = obj{1,idx};
end
end
