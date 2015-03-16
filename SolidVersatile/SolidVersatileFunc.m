%% Solid - Versatile
% Transforming Abaqus mesh data into customized input data for IFEM
% code started: 02/21/2012
% last updated: 07/21/2014
% Jack Jubiao Yang
% Rensselaer Polytechnic Institute
%% Function Program

%% fid_out1: 'mxyz_solid.in'
temp=fgets(fid_in);
while(strncmp('*Node',temp,5)==0)
    temp=fgets(fid_in);
end
NumNodeS=0;
temp=fgets(fid_in);
if(ElemType==1||ElemType==2)
    while(strncmp('*',temp,1)==0)
        VecNum1=str2num(temp);
        NumNodeS=NumNodeS+1;
        xcoord(NumNodeS)=VecNum1(2);
        ycoord(NumNodeS)=VecNum1(3);
        fprintf(fid_out1,'%14.10f%14.10f\n',...
            xcoord(NumNodeS),ycoord(NumNodeS));
        temp=fgets(fid_in);
    end
elseif(ElemType==3||ElemType==4)
    while(strncmp('*',temp,1)==0)
        VecNum1=str2num(temp);
        NumNodeS=NumNodeS+1;
        xcoord(NumNodeS)=VecNum1(2);
        ycoord(NumNodeS)=VecNum1(3);
        zcoord(NumNodeS)=VecNum1(4);
        fprintf(fid_out1,'%14.10f%14.10f%14.10f\n',...
            xcoord(NumNodeS),ycoord(NumNodeS),zcoord(NumNodeS));
        temp=fgets(fid_in);
    end
end
disp('Total Number of Nodes:');
disp(NumNodeS);

%% fid_out2: 'mien_solid.in'; fid_out6: 'connectsolid.in'
while(strncmp('*Element',temp,8)==0)
    temp=fgets(fid_in);
end
NumElemS=0;
temp=fgets(fid_in);
while(strncmp('*',temp,1)==0)
    VecNum2=str2num(temp);
    NumElemS=NumElemS+1;
    connectS(NumElemS,:)=VecNum2(2:1+NdPerElem(ElemType));
    temp=fgets(fid_in);
end
disp('Total Number of Elments:');
disp(NumElemS);

NumParts=0;
NumElemS_P=0;
while(strncmp('*Nset, nset=sbc',temp,15)==0)
    while(strncmp('*Elset, elset=P',temp,15)==0)
        temp=fgets(fid_in);
    end
    NamePart=str2num(temp(16));
    NumParts=NumParts+1;
    disp(['The Part #' num2str(NumParts) ' detected: named Part ' num2str(NamePart)])
    length2gen=length(temp);
    if(strncmp('generate',temp(length2gen-9:length2gen),8)==1)
        temp=fgets(fid_in);
        VecNum3=str2num(temp);
        for iElemS=VecNum3(1):VecNum3(3):VecNum3(2)
            connectS(iElemS,1+NdPerElem(ElemType))=NamePart;
        end
        NumElemS_P=NumElemS_P+1+(VecNum3(2)-VecNum3(1))/VecNum3(3);
        temp=fgets(fid_in);
    else
        while(strncmp('*Nset',temp,5)==0)
            temp=fgets(fid_in);
            VecNum3=str2num(temp);
            for iElemS=1:length(VecNum3)
                connectS(VecNum3(iElemS),1+NdPerElem(ElemType))=NamePart;
            end
            NumElemS_P=NumElemS_P+length(VecNum3);
        end
    end
end
if(NumElemS~=NumElemS_P)
    disp(['There are ' num2str(NumElemS) ' elements, while only ' ...
        num2str(NumElemS_P) ' elements are defined in the parts'])
    disp('This is an error message. Please check your CAD model! Terminating...')
    return
end
for iElemS=1:NumElemS
    for inode=1:NdPerElem(ElemType)
        fprintf(fid_out2,'%8d',connectS(iElemS,inode));
        fprintf(fid_out6,'%8d',connectS(iElemS,inode));
    end
    fprintf(fid_out6,'\n');
    fprintf(fid_out2,'%8d\n',connectS(iElemS,NdPerElem(ElemType)+1));
end

%% fid_out3: 'sbcnode_redundant.in'; fid_out5: 'sbc_solid.in'
NumBC=0;
nodebcuniq=[];
disp('The Boundary Conditions can be defined in the following two ways:')
disp('999:Type 1; -999:Type 2; 0: not defined in Abaqus    ! defined by Xingshi Wang')
disp('10xyz    x,y,z=[1:fixed; 0:not defined]              ! newly defined by Jubiao Yang')
disp('10111 is equivalent to 999')
disp('10000 is equivalent to -999    ! commented by Jubiao Yang')
while(strncmp('*End',temp,4)==0)
    while(strncmp('*Nset',temp,5)==0)
        temp=fgets(fid_in);
    end
    NumBC=NumBC+1;
    %------- Input BC type ------------
    disp(['The Boundary #' num2str(NumBC) ' detected'])
    bctype=input('Please define the BC type on this Boundary according to the rules: ');
    while(isempty(find(bctype==[999 -999 0 10000 10001 10010 10011 10100 10101 10110 10111],1))==1)
        bctype=input('Please define the BC type on this Boundary according to the rules: ');
    end
    TypeBC(NumBC)=bctype;
    %----------------------------------
    length2gen=length(temp);
    if(strncmp('generate',temp(length2gen-9:length2gen),8)==1)
        temp=fgets(fid_in);
        VecNum4=str2num(temp);
        numnodeBC(NumBC)=1+(VecNum4(2)-VecNum4(1))/VecNum4(3);
        NodeBC(NumBC,1:numnodeBC(NumBC))=VecNum4(1):VecNum4(3):VecNum4(2);
    else
        numnodeBC(NumBC)=0;
        while(strncmp('*Elset',temp,6)==0)
            temp=fgets(fid_in);
            VecNum4=str2num(temp);
            numnodeBC(NumBC)=numnodeBC(NumBC)+length(VecNum4);
            NodeBC(NumBC,numnodeBC(NumBC)-length(VecNum4)+1:numnodeBC(NumBC))=VecNum4;
        end
    end
    nodebcuniq=[nodebcuniq NodeBC(NumBC,1:numnodeBC(NumBC))];
    for inode=1:numnodeBC(NumBC)
        fprintf(fid_out3,'%d\n',NodeBC(NumBC,inode));      % write into 'sbcnode_redundant.in'
    end
    
    while(strncmp('*Elset',temp,6)==0)
        temp=fgets(fid_in);
    end
    length2gen=length(temp);
    if(strncmp('generate',temp(length2gen-9:length2gen),8)==1)
        temp=fgets(fid_in);
        VecNum5=str2num(temp);
        numelemBC(NumBC)=1+(VecNum5(2)-VecNum5(1))/VecNum5(3);
        ElmBC(NumBC,1:numelemBC(NumBC))=VecNum5(1):VecNum5(3):VecNum5(2);
        temp=fgets(fid_in);
    else
        numelemBC(NumBC)=0;
        while(strncmp('*Nset',temp,5)==0&&strncmp('*End',temp,4)==0)
            temp=fgets(fid_in);
            VecNum5=str2num(temp);
            numelemBC(NumBC)=numelemBC(NumBC)+length(VecNum5);
            ElmBC(NumBC,numelemBC(NumBC)-length(VecNum5)+1:numelemBC(NumBC))=VecNum5;
        end
    end
    for ielem=1:numelemBC(NumBC)
        fprintf(fid_out5,'%8d',ElmBC(NumBC,ielem));
        for inode=1:NdPerElem(ElemType)
            nodeglb=connectS(ElmBC(NumBC,ielem),inode);
            flagnbc=isempty(find(nodeglb==NodeBC(NumBC,:),1));
            fprintf(fid_out5,'%8d',1-flagnbc);
        end
        fprintf(fid_out5,'%8d\n',TypeBC(NumBC));
    end
end

%% Subsection for duplicating structures after mirroring about axes and offsetting
% an existing use of this feature is to generate a pair of vocal folds
% feature added by Jack Jubiao Yang on Mar. 5, 2013
TextAxis=['x' 'y' 'z'];
DuplicateCount=0;
DuplicateOpt=-1;
while(DuplicateOpt~=0 && DuplicateOpt~=1)
    disp('Do you want to duplicate a same structure to another location?')
    DuplicateOpt=input('1-yes; 0-no:   ');
end
while(DuplicateOpt==1)
    DuplicateCount=DuplicateCount+1;
    MirrorOpt=zeros(1,DimOfElem(ElemType))-1;
    for iaxis=1:DimOfElem(ElemType)
        while(MirrorOpt(iaxis)~=0 && MirrorOpt(iaxis)~=1)
            disp(['Mirror the structure about ' TextAxis(iaxis) '-axis?'])
            MirrorOpt(iaxis)=input('1-yes; 0-no:   ');
        end
    end
    MirrorOpt=(-1).^MirrorOpt;
    disp('Then offset the structure by [x y (z)]:')
    OffsetShf=input('Please input the offset in the form of an array: ');
    % fid_out1: 'mxyz_solid.in'
    if(DimOfElem(ElemType)==2)
        for inode=1:NumNodeS
            fprintf(fid_out1,'%14.10f%14.10f\n',OffsetShf(1)+MirrorOpt(1)*xcoord(NumNodeS),...
                                                OffsetShf(2)+MirrorOpt(2)*ycoord(NumNodeS));
        end
    elseif(DimOfElem(ElemType)==3)
        for inode=1:NumNodeS
            fprintf(fid_out1,'%14.10f%14.10f%14.10f\n',OffsetShf(1)+MirrorOpt(1)*xcoord(NumNodeS),...
                                                       OffsetShf(2)+MirrorOpt(2)*ycoord(NumNodeS),...
                                                       OffsetShf(3)+MirrorOpt(3)*zcoord(NumNodeS));
        end
    end
    % fid_out2: 'mien_solid.in'; fid_out6: 'connectsolid.in'
    for iElemS=1:NumElemS
        for inode=1:NdPerElem(ElemType)
            fprintf(fid_out2,'%8d',connectS(iElemS,inode)+DuplicateCount*NumNodeS);
            fprintf(fid_out6,'%8d',connectS(iElemS,inode)+DuplicateCount*NumNodeS);
        end
        fprintf(fid_out6,'\n');
        fprintf(fid_out2,'%8d\n',connectS(iElemS,NdPerElem(ElemType)+1));
    end
    % fid_out3: 'sbcnode_redundant.in'; fid_out5: 'sbc_solid.in'
    for iBC=1:NumBC
        for inode=1:numnodeBC(NumBC)
            fprintf(fid_out3,'%d\n',NodeBC(NumBC,inode)+DuplicateCount*NumNodeS); % write into 'sbcnode_redundant.in'
        end
        nodebcuniq=[nodebcuniq NodeBC(NumBC,1:numnodeBC(NumBC))+DuplicateCount*NumNodeS];
        for ielem=1:numelemBC(NumBC)
            fprintf(fid_out5,'%8d',ElmBC(NumBC,ielem)+DuplicateCount*NumElemS);
            for inode=1:NdPerElem(ElemType)
                nodeglb=connectS(ElmBC(NumBC,ielem),inode);
                flagnbc=isempty(find(nodeglb==NodeBC(NumBC,:),1));
                fprintf(fid_out5,'%8d',1-flagnbc);
            end
            fprintf(fid_out5,'%8d\n',TypeBC(NumBC));
        end
    end
    
    DuplicateOpt=-1;
    while(DuplicateOpt~=0 && DuplicateOpt~=1)
        disp('Do you want to duplicate a same structure to another location?')
        DuplicateOpt=input('1-yes; 0-no:   ');
    end
end


%%  fid_out4: 'sbcnode_solid.in'
nodebcuniq=unique(nodebcuniq);
for inode=1:length(nodebcuniq)
    fprintf(fid_out4,'%8d\n',nodebcuniq(inode));
end