function [outputArg1,outputArg2] = laneNetGet(inputArg1,inputArg2)


global roads;
global junctions;          
roads = openDriveObj.road;
junctions = openDriveObj.junction;


outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

