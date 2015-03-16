%% Fluid - Versatile
% Transforming Abaqus mesh data into customized form
% code started: 01/23/2012
% last updated: 01/25/2012
% Jubiao Yang
% Rensselaer Polytechnic Institute
%% Function program

%% fid_out1
temp=fgets(fid_in);
while(strncmp('*Node',temp,5)==0)       % looking for the start of the section of coordinates information
    temp=fgets(fid_in);
end
NumNodeF=0;
temp=fgets(fid_in);
if(ElemType==1||ElemType==2)
    while(strncmp('*',temp,1)==0)
        VecNum1=str2num(temp);
        xcoord=VecNum1(2);
        ycoord=VecNum1(3);
        fprintf(fid_out1,'%14.10f%14.10f\n',xcoord,ycoord);
        NumNodeF=NumNodeF+1;
        temp=fgets(fid_in);
    end
elseif(ElemType==3||ElemType==4)
    while(strncmp('*',temp,1)==0)
        VecNum1=str2num(temp);
        xcoord=VecNum1(2);
        ycoord=VecNum1(3);
        zcoord=VecNum1(4);
        fprintf(fid_out1,'%14.10f%14.10f%14.10f\n',xcoord,ycoord,zcoord);
        NumNodeF=NumNodeF+1;
        temp=fgets(fid_in);
    end
end
disp('Total Number of Nodes:');
disp(NumNodeF);

%% fid_out2
while(strncmp('*Element',temp,8)==0)
    temp=fgets(fid_in);
end
NumElemF=0;
temp=fgets(fid_in);
while(strncmp('*',temp,1)==0)
    VecNum2=str2num(temp);
    NumElemF=NumElemF+1;
    connectF(NumElemF,:)=VecNum2(2:1+NdPerElem(ElemType));
    for inode=1:NdPerElem(ElemType)
        fprintf(fid_out2,'%8d',connectF(NumElemF,inode));
    end
    fprintf(fid_out2,'\n');
    temp=fgets(fid_in);
end
disp('Total Number of Elments:');
disp(NumElemF);

%% fid_out3
NumBC=0;
while(strncmp('*End',temp,4)==0)
    while(strncmp('*Nset',temp,5)==0)
        temp=fgets(fid_in);
    end
    NumBC=NumBC+1;
    disp(NumBC);
    length2gen=length(temp);
    if(strncmp('generate',temp(length2gen-9:length2gen),8)==1)
        temp=fgets(fid_in);
        VecNum3=str2num(temp);
        numnodeBC(NumBC)=1+(VecNum3(2)-VecNum3(1))/VecNum3(3);
        NodeBC(NumBC,1:numnodeBC(NumBC))=VecNum3(1):VecNum3(3):VecNum3(2);
    else
        numnodeBC(NumBC)=0;
        while(strncmp('*Elset',temp,6)==0)
            temp=fgets(fid_in);
            VecNum3=str2num(temp);
            numnodeBC(NumBC)=numnodeBC(NumBC)+length(VecNum3);
            NodeBC(NumBC,numnodeBC(NumBC)-length(VecNum3)+1:numnodeBC(NumBC))=VecNum3;
        end
    end
    while(strncmp('*Elset',temp,6)==0)
        temp=fgets(fid_in);
    end
    length2gen=length(temp);
    if(strncmp('generate',temp(length2gen-9:length2gen),8)==1)
        temp=fgets(fid_in);
        VecNum4=str2num(temp);
        numelemBC(NumBC)=1+(VecNum4(2)-VecNum4(1))/VecNum4(3);
        ElmBC(NumBC,1:numelemBC(NumBC))=VecNum4(1):VecNum4(3):VecNum4(2);
        temp=fgets(fid_in);
    else
        numelemBC(NumBC)=0;
        while(strncmp('*Nset',temp,5)==0&&strncmp('*End',temp,4)==0)
            temp=fgets(fid_in);
            VecNum4=str2num(temp);
            numelemBC(NumBC)=numelemBC(NumBC)+length(VecNum4);
            ElmBC(NumBC,numelemBC(NumBC)-length(VecNum4)+1:numelemBC(NumBC))=VecNum4;
        end
    end
end
Matmrng=zeros(NumElemF,EgPerElem(ElemType));        % Tri: 3; Quad:4; Tetra: 4 - number of edges
for ibc=1:NumBC
    for ielem=1:numelemBC(ibc)
        idxelem=ElmBC(ibc,ielem);      % ID for the ielem_th element on the ibc_th BC
        for iedge=1:EgPerElem(ElemType)           % Tri: 3; Quad:4; Tetra: 4 - number of edges
            prod_length=1;
            for inodeedge=1:NdPerEdge(ElemType)        % Tri, Quad: 2; Tetra: 3 - number of nodes on each edge
                idxnode=connectF(idxelem,facemap(iedge,inodeedge,ElemType));
                prod_length=prod_length*length(find(NodeBC(ibc,:)==idxnode));
            end
            if(prod_length==1)
                Matmrng(idxelem,iedge)=ibc;
            elseif(prod_length~=0)
                disp('wtf?');
            end
        end
    end
end
for irow=1:NumElemF
    for icol=1:EgPerElem(ElemType)                % Tri: 3; Quad:4; Tetra: 4 - number of edges
        fprintf(fid_out3,'%8d',Matmrng(irow,icol));
    end
    fprintf(fid_out3,'\n');
end