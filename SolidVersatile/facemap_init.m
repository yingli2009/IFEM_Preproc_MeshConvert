%% Fluid/Solid - Versatile
% Transforming Abaqus mesh data into customized form
% code started: 01/25/2012
% last updated: 01/25/2012
% Jack Jubiao Yang
% Rensselaer Polytechnic Institute
%% Initiate Facemap
% facemap(iEdFc,:,ElTyp)=[Node1 Node2 Node3 Node4]
% iEgFc: Edge/Face number
% ElTyp: Element Type: 1/2/3/4: tri/quad/tetra/hex
% [Node1 ... Node4]: Nodes on this Edge/Face (>0: Node number; 0: N/A)

%% Triangle
facemap(1,:,1)=[1 2 0 0];
facemap(2,:,1)=[2 3 0 0];
facemap(3,:,1)=[3 1 0 0];
facemap(4,:,1)=[0 0 0 0];
facemap(5,:,1)=[0 0 0 0];
facemap(6,:,1)=[0 0 0 0];
%% Quadrilateral
facemap(1,:,2)=[1 2 0 0];
facemap(2,:,2)=[2 3 0 0];
facemap(3,:,2)=[3 4 0 0];
facemap(4,:,2)=[4 1 0 0];
facemap(5,:,2)=[0 0 0 0];
facemap(6,:,2)=[0 0 0 0];
%% Tetrahedron
facemap(1,:,3)=[3 2 1 0];
facemap(2,:,3)=[1 2 4 0];
facemap(3,:,3)=[2 3 4 0];
facemap(4,:,3)=[3 1 4 0];
facemap(5,:,3)=[0 0 0 0];
facemap(6,:,3)=[0 0 0 0];
%% Hexahedron
facemap(1,:,4)=[1 4 3 2];
facemap(2,:,4)=[1 2 6 5];
facemap(3,:,4)=[2 3 7 6];
facemap(4,:,4)=[3 4 8 7];
facemap(5,:,4)=[4 1 5 8];
facemap(6,:,4)=[5 6 7 8];