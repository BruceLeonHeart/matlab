classdef OpenDrive

    properties
        mHeader Header;
        mRoadList;
        mJunctionList;
        
    end
    
    methods
        function obj = OpenDrive(inputArg1,inputArg2,inputArg3)
            obj.mHeader = inputArg1;
            obj.mHeader = inputArg2;
            obj.mHeader = inputArg3;        
        end
        
    end
end
