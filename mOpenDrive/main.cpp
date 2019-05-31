#include<iostream>
#include "OpenDrive/OpenDrive.h"
#include "OpenDrive/OpenDriveXmlParser.h"
using namespace std;

/**
 * Entry point
 */
int main(int argc, char *argv[])
{
	OpenDrive  mOpenDrive ;
	OpenDriveXmlParser *parser = new  OpenDriveXmlParser(& mOpenDrive);
	parser->ReadFile("test.xodr");
	cout<<"hello world"<<endl;
	return 0 ;
}