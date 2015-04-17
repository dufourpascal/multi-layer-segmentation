function [ costs, topIds, bottomIds, topOffset ] = computeUnaryTermsInRegion( surfaceTop, surfaceBottom, volumeProb)
%COMPUTEUNARYTERMS Summary of this function goes here
%   Detailed explanation goes here

[sz, sy, sx] = size(volumeProb);
infCost = 10000000;

topIds = zeros(sz,sx);
bottomIds = zeros(sz,sx);
topOffset = zeros(sz,sx);

nodeId = 1;
for z = 1:sz
  for x = 1:sx
%     surfaceY = int32(estimatedSurface(z,x));
    startY = max(int32(surfaceTop(z,x)),1);
    endY   = min(int32(surfaceBottom(z,x)),sy);
    rangeY = endY-startY+1;
    
%     topSurface(z,x) = startY;
%     bottomSurface(z,x) = endY;
    
    colData = volumeProb(z,startY:endY,x);
    topNodeId = nodeId;
    bottomNodeId = nodeId+rangeY-1;
    nodeId = bottomNodeId+1;
    
    %set unary cost from classification probability
    costs(1,topNodeId:bottomNodeId) = 1.0 - colData;
    costs(2,topNodeId:bottomNodeId) = colData;
    
    %fix top and bottom nodes
    costs(1,topNodeId:topNodeId) = -infCost;
    costs(2,topNodeId:topNodeId) =  infCost;
    costs(1,bottomNodeId:bottomNodeId) =  infCost;
    costs(2,bottomNodeId:bottomNodeId) = -infCost;
    
    topIds(z,x) = topNodeId;
    bottomIds(z,x) = bottomNodeId;
    topOffset(z,x) = startY;
  end
  

end

%truncate cost to actually used range
costs = costs(:,1:nodeId-1);

end

