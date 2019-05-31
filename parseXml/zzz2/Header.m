classdef Header
    %HEADER 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        mRevMajor;
        mRevMinor;
        mName;
        mVersion;
        mDate;
        mNorth;
        mSouth;
        mEast;
        mWest;
    end
    
    methods

        
        function obj = Header(mRevMajor,mRevMinor,mName,mVersion,mDate,mNorth,mSouth,mEast,mWest)   
            if nargin==0
                
            else
            obj.mRevMajor =  mRevMajor;
            obj.mRevMinor =  mRevMinor;
            obj.mName = mName;
            obj.mVersion = mVersion;
            obj.mDate = mDate;
            obj.mNorth = mNorth;
            obj.mSouth = mSouth;
            obj.mEast = mEast;
            obj.mWest = mWest;
            end
        end
        

    end
end

