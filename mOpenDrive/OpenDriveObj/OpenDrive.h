#ifndef OPENDRIVE_H
#define OPENDRIVE_H

#include<string>
#include<vector>



using std::vector;
using std::string;
class Header;

class OpenDrive{
private:
    Header* mHeader;
    vector<Road> mRoadVector;
    vector<Junction> mJunctionVector;
    // vector<JunctionGroup> mJunctionGroupVector;
    // vector<Station> mStationVector;

    /**
	 * Copy constructor, makes the object non-copyable
	 */
	OpenDrive (const OpenDrive& openDrive){};
	const OpenDrive& operator=(const OpenDrive& rhs){};

public:
    OpenDrive();
	void SetHeader(unsigned short int revMajor, unsigned short int revMinor, string name, float version, string date, 
					double north, double south, double east,double west);

	unsigned int AddRoad(string name, double length, string id, string junction);
	unsigned int AddJunction(string name, string id);
	void DeleteRoad(unsigned int index);
	void DeleteJunction(unsigned int index);

	Header* GetHeader();

	vector<Road> * GetRoadVector();
	Road* GetRoad(unsigned int i);
	unsigned int GetRoadCount();

	vector<Junction> * GetJunctionVector();
	Junction* GetJunction(unsigned int i);
	unsigned int GetJunctionCount();

    void Clear();
	~OpenDrive();

};

class Header
{
private:
	unsigned short int mRevMajor;
	unsigned short int mRevMinor;
	string mName;
	float mVersion;
	string mDate;
	double mNorth;
	double mSouth;
	double mEast;
	double mWest;
public:

	Header(unsigned short int revMajor, unsigned short int revMinor, string name, float version, string date, 
		double north, double south, double east,double west);

	void GetAllParams(unsigned short int &revMajor, unsigned short int &revMinor, string &name, float &version, string &date, 
		double &north, double &south, double &east,double &west);

	void GetXYValues(double &north, double &south, double &east,double &west);

	void SetAllParams(unsigned short int revMajor, unsigned short int revMinor, string name, float version, string date, 
		double north, double south, double east,double west);
        
	void SetXYValues(double north, double south, double east,double west);
};


#endif