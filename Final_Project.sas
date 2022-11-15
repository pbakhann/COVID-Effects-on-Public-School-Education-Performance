
dm 'log' clear;
resetline;

****Importing two sas data sets*************;
libname project "C:\Users\bprom19\Desktop\ECON 673 HW Data\Term Project Assignment\ECMT_673_Term_Project";

*Create a temporary data set from the main library into work library for 2018_2019 result**;
data STAAR_19 (keep = campus_number year region district m_all_unsatgl_rm);
 set project.cfy19e8 (rename = (campus= campus_1 year= Test_year region=region_1 district=district_number));
 Campus_number = input(campus_1,9.);
 Year = input(Test_year, 2.);
 Region = input(region_1, 2.);
 District = input(district_number, 6.);
run;

*Create a temporary data set from the main library into work library for 2020-2021 result**;
data STAAR_21 (keep = 
campus_number 
year 
region 
district 
dname 
cname
m_all_unsatgl_rm
);
 set project.cfy21e8 (rename = (campus= campus_1 year= Test_year region=region_1 district=district_number));
 Campus_number = input(campus_1,9.);
 Year = input(Test_year, 2.);
 Region = input(region_1, 2.);
 District = input(district_number, 6.);
run;

*Import campus analyze 2018_19 file and validates the data;
PROC IMPORT OUT=campus_analyze_19 DATAFILE= "C:\Users\bprom19\Desktop\ECON 673 HW Data\Term Project Assignment\ECMT_673_Term_Project\Campus Analyze_2018-19.xlsx"
		DBMS=XLSX REPLACE;
	GETNAMES=YES;
	SHEET="2018-19 Data";
RUN;
data campus_19;
	set campus_analyze_19 (rename= (campus=campus_1 campus_type=campus_t));
	Campus_Number= input(campus_1, 9.);
    Campus_Type_Code= input(campus_t,3.);
    Campus_Type_Description = upcase(Campus_Type_Description);
    drop Campus_1;
    drop Campus_t;
run;

*Import campus analyze 2020_21 file and validates the data;
PROC IMPORT OUT=campus_analyze_21 DATAFILE= "C:\Users\bprom19\Desktop\ECON 673 HW Data\Term Project Assignment\ECMT_673_Term_Project\campus-analyze-2020-21.xlsx"
		DBMS=XLSX REPLACE;
	GETNAMES=YES;
	SHEET="2020-21 Data";
RUN;
data campus_21;
	set campus_analyze_21 (rename= (campus=campus_1 campus_type=campus_t));
	Campus_Number= input(campus_1, 9.);
    Campus_Type_Code= input(campus_t,3.);
    campus_type = substr(campus_type_description,find(campus_type_description, "-")+1);
    Campus_Type_Description= upcase(campus_type);
    drop Campus_1;
    drop Campus_t;
    drop campus_type;
run;

*Sorting data sets by campus number for merging;
proc sort data = staar_19;
by campus_number;
run; 
proc sort data = staar_21;
by campus_number;
run;

proc sort data=campus_19;
by campus_number;
run;
proc sort data=campus_21;
by campus_number;
run;

*Combine STAAR data for 2018_2019 with Campus analyze 2018_19*;
data Combine_Data_2019;
merge staar_19 campus_19;
by campus_number;
if m_all_unsatgl_rm = . then delete;
run;

PROC SQL
    SELECT * FROM 
    combine_data_2019
    Group by campus_type;
Quit;

*Combine STAAR data for 2020_21 with Campus analyze 2020_21;
data Combine_Data_2021;
merge staar_21 campus_21;
by campus_number;
if m_all_unsatgl_rm = . then delete;
drop campus_name;
run;

