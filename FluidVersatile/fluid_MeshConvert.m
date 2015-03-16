%% Fluid - Versatile
% Transforming Abaqus mesh data into customized form
% code started: 01/23/2012
% last updated: 01/25/2012
% Jubiao Yang
% Rensselaer Polytechnic Institute
%% Main program

clear all
format short e

% Mesh Element information
DimOfElem=[2 2 3 3];    % dimension of space of element
NdPerElem=[3 4 4 8];    % number of nodes per element
EgPerElem=[3 4 4 6];   % number of edges(for 2d)/faces(for 3d) per element
NdPerEdge=[2 2 3 4];    % number of nodes per edge

% call facemap_init
facemap_init

% open Abaqus .inp file and create input files for IFEM
fid_in=fopen('Job-1.inp','r');
fid_out1=fopen('mxyz.in','wt');
fid_out2=fopen('mien.in','wt');
fid_out3=fopen('mrng.in','wt');

% ask the user what type the mesh element is
disp('What type is the mesh element?');
disp('1-Tri;2-Quad;3-Tetra;4-Hex');
ElemType=input('Input corresponding number please: ');
if(length(find(ElemType==[1 2 3 4]))==1)
    % call function fluid_2d_Quad_func
    fluid_MeshConvert_func
else
    disp('Invalid Input!')
end

% close files that were opened
fclose(fid_in);
fclose(fid_out1);
fclose(fid_out2);
fclose(fid_out3);
