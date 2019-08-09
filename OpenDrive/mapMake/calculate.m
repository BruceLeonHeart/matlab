clc;
clear;

M = csvread('1.csv',1,0);

row = size(M,1);
%数据抽取，如果线型为直线，则抽取单行；

%如果线型为圆弧，则多行抽取
for i = 1:row
    roadId = M(i,1);
    laneSectionId = M(i,2);
    refType = M(i,3); % 1--line 2--arc
    ref_start_x = M(i,4);
    ref_start_y = M(i,5);
    ref_end_x = M(i,6);
    ref_end_y = M(i,7); 
    R_start_x = M(i,8); 
    R_start_y = M(i,9); 
    R_end_x = M(i,10); 
    R_end_y = M(i,11);
    L_start_x = M(i,12); 
    L_start_y = M(i,13);
    L_end_x = M(i,14); 
    L_end_y = M(i,15);
    ds = M(i,16);
    offset = M(i,17);
    re_line_start_x = M(i,18);
    re_line_start_y = M(i,19);
    re_line_end_x = M(i,20);
    re_line_end_y = M(i,21);
    re_line_length = M(i,22);
    road_R_a = M(i,23);
    road_R_b = M(i,24);
    road_R_c = M(i,25);
    road_R_d = M(i,26);
    road_L_a = M(i,27);
    road_L_b = M(i,28);
    road_L_c = M(i,29);
    road_L_d = M(i,30);
    
    
    
    
    
end