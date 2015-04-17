function [ regularizingEdges ] = computeHorizontalConnectivity( ...
  regularizingStrengthX, regularizingStrengthZ, ...
  topIds, bottomIds, topOffset, confidenceMap )
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
    
    conf = 1.0 - confidenceMap(z,x);
%     conf = 1.0 / max(0.01, confidenceMap(z,x));
    strengthX = regularizingStrengthX * conf;
    strengthZ = regularizingStrengthZ * conf;
    
    di = 0;
    compX = - round( topOffset(z,x-1) - topOffset(z,x) );
%     surf(surfaceTop);
%     pause
    if z > 1
      compZ = - round( topOffset(z-1,x) - topOffset(z,x) );
    end
    
    for i = startId:endId
      %x direction
      targetId = topIds(z,x-1)+di + compX;
      
      if(targetId > topIds(z,x-1) && targetId < bottomIds(z,x-1))
        regularizingEdges(edgeGlobalId,:) = [i, targetId, 0, strengthX, strengthX, 0];
        edgeGlobalId = edgeGlobalId+1;
      end
      
      if z > 1
        targetId = topIds(z-1,x)+di + compZ;
        
        if(targetId > topIds(z-1,x) && targetId < bottomIds(z-1,x))
          regularizingEdges(edgeGlobalId,:) = [i, targetId, 0, strengthZ, strengthZ, 0];
          edgeGlobalId = edgeGlobalId+1;
        end
      end
      
      di = di+1;
    end
    
  end
end

regularizingEdges = regularizingEdges(1:edgeGlobalId-1, :);

end

