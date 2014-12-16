function [ costs, topIds, bottomIds ] = computeUnaryTermsInVolume(volumeProb)
%computeUnaryTermsInVolume Summary of this function goes here
%   Detailed explanation goes here

[sz, sy, sx] = size(volumeProb);
infCost = 10000000;

topIds = zeros(sz,sx);
bottomIds = zeros(sz,sx);

nodeId = 1;
for z = 1:sz
  for x = 1:sx
    colData = volumeProb(z,:,x);
    topNodeId = nodeId;
    bottomNodeId = nodeId+sy-1;
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
  end
  

end

%truncate cost to actually used range
costs = costs(:,1:nodeId-1);

end

