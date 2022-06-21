function [faceCenters,faceNormals] = calculateFaceNormals(faces,vert)

% initialize arrays
faceCenters = zeros(size(faces,1),3);
faceNormals = zeros(size(faces,1),3);

parfor ii = 1:size(faceNormals,1)
    
    iFaceVert = faces(ii,:);
%     P1 = vert(iFaceVert(1),:)';
%     P2 = vert(iFaceVert(2),:)';
%     P3 = vert(iFaceVert(3),:)';
    
    % relative vectors between vertices (unit vector)
    u1 = vert(iFaceVert(2),:)' - vert(iFaceVert(1),:)';%u1 = u1/norm(u1);% from P1 to P2
    u2 = vert(iFaceVert(3),:)' - vert(iFaceVert(1),:)';u2 = u2/norm(u2);% from P1 to P3
    
    % normal vector to the relative vectors
    u1x = [  0     -u1(3)    u1(2);
            u1(3)     0     -u1(1);
           -u1(2)   u1(1)     0];
    n = u1x*u2;
    faceNormals(ii,:) = n(:)'/norm(n);
    
    % center vector is the average of the three vertices
    faceCenters(ii,:) = sum(vert(iFaceVert,:))/3;
     
end
