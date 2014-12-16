function [ regularizingEdges ] = computeHorizontalConnectivity( ...
  regularizingStrengthX, regularizingStrengthZ, ...
  topIds, bottomIds, confidenceMap )
%COMPUTEHORIZONTALCONNECTIVITY Summary of this function goes here
%   Detailed explanation goes here

[sz, sx] = size(topIds);
nNodes = bottomIds(end,end);
nMaxRegEdges = nNodes * 2;
regularizingEdges = zeros(nMaxRegEdges, 6);
edgeGlobalId = 1;

for z = 1:sz
disp(['regularizing edges BScan ', num2str(z)]);
  for x = 2:sx
    % x-direction
    startId = topIds(z,x);
    endId = bottomIds(z,x);
    
    conf = 1.0 / max(0.01, confidenceMap(z,x));
    strengthX = regularizingStrengthX * conf;
    strengthZ = regularizingStrengthZ * conf;
    
    di = 0;
    for i = startId:endId
      targetId = topIds(z,x-1)+di;
      regularizingEdges(edgeGlobalId,:) = [i, targetId, 0, strengthX, strengthX, 0];
      edgeGlobalId = edgeGlobalId+1;
      
      if z > 1
        targetId = topIds(z-1,x)+di;
        regularizingEdges(edgeGlobalId,:) = [i, targetId, 0, strengthZ, strengthZ, 0];
        edgeGlobalId = edgeGlobalId+1;
      end
      
      di = di+1;
    end
    
  end
end

regularizingEdges = regularizingEdges(1:edgeGlobalId-1, :);

end

