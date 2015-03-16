%% Solid - Versatile
% Transforming Abaqus mesh data into customized input data for IFEM
% code started: 02/21/2012
% last updated: 02/22/2012
% Jack Jubiao Yang
% Rensselaer Polytechnic Institute
%% Main program

clear all
close all

% Mesh Element information
% basic information for element types:
% triangular; quadrilateral; tetrahedral; hexahedral
DimOfElem=[2 2 3 3];      % Dimension of Element
NdPerElem=[3 4 4 8];      % Number of Nodes per Element
EgPerElem=[3 4 4 6];      % Number of Edges/Faces (for 2D/3D) per Element
NdPerEdge=[2 2 3 4];      % Number of Nodes per Edges/Faces (for 2D/3D)

% initialize Edge/Face-Node mapping information
facemap_init

% open Abaqus .inp file and create input files for IFEM
fid_in=fopen('Job-1.inp','r');
fid_out1=fopen('mxyz_solid.in','wt');
fid_out2=fopen('mien_solid.in','wt');
fid_out3=fopen('sbcnode_redundant.in','wt');
fid_out4=fopen('sbcnode_solid.in','wt');
fid_out5=fopen('sbc_solid.in','wt');
fid_out6=fopen('connectsolid.in','wt');

% ask the user what type the mesh element is
disp('What type are the mesh elements?')
disp('1-Triangular; 2-Quadrilateral; 3-Tetrahedral; 4-Hexahedral')
ElemType=input('Input corresponding number please: ');
if(length(find(ElemType==[1 2 3 4]))==1)
    % call function SolidVersatileFunc
    SolidVersatileFunc
else
    disp('Invalid Input')
end
 % close files that had been opened
 fclose(fid_in);
 fclose(fid_out1);
 fclose(fid_out2);
 fclose(fid_out3);
 fclose(fid_out4);
 fclose(fid_out5);
 fclose(fid_out6);