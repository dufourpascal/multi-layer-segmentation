function [ interColEdges ] = computeInterColEdgesInVolume( topIds, bottomIds, maxDx, maxDz )
%computeInterColEdgesInVolume Summary of this function goes here
%   Detailed explanation goes here

infCost = 10000000;

[sz, sx] = size(topIds);
sy = bottomIds(1,1) - topIds(1,1) +1;

nNodes = bottomIds(end,end);
nMaxInterColEdges = nNodes * 4;
interColEdges = zeros(nMaxInterColEdges, 6);
edgeGlobalId = 1;
for z = 1:sz
disp(['inter-col edges BScan ', num2str(z)]);
  for x = 1:sx
    % x-direction
    startId = topIds(z,x);
    endId = bottomIds(z,x);
    
    di = 1;
    for i = startId:endId
      yPosSource = di;
      yPosTarget = yPosSource + maxDx;
      di = di+1;
      
      % check if edge is possible
      
      if x > 1
        %can add edge to the left
        yPosTarget = max(yPosTarget, 1);
        yPosTarget = min(yPosTarget, sy);
        dyTarget = yPosTarget - 1;
        leftNodeTarget = topIds(z,x-1) + dyTarget;
        
        %add edge
        interColEdges(edgeGlobalId,:) = [i, leftNodeTarget, 0, 0, infCost, 0];
        edgeGlobalId = edgeGlobalId+1;
      end
      
      if x < sx
        %can add edge to the right
        yPosTarget = max(yPosTarget, 1);
        yPosTarget = min(yPosTarget, sy);
        dyTarget = yPosTarget - 1;
        rightNodeTarget = topIds(z,x+1) + dyTarget;
        
        %add edge
        interColEdges(edgeGlobalId,:) = [i, rightNodeTarget, 0, 0, infCost, 0];
        edgeGlobalId = edgeGlobalId+1;
      end
      
      
      yPosTarget = yPosSource + maxDz;
      if z > 1
        %can add edge to south/down
        yPosTarget = max(yPosTarget, 1);
        yPosTarget = min(yPosTarget, sy);
        dyTarget = yPosTarget - 1;
        southNodeTarget = topIds(z-1,x) + dyTarget;
        
        %add edge
        interColEdges(edgeGlobalId,:) = [i, southNodeTarget, 0, 0, infCost, 0];
        edgeGlobalId = edgeGlobalId+1;
      end
      
      if z < sz
        %can add edge to north/up
        yPosTarget = max(yPosTarget, 1);
        yPosTarget = min(yPosTarget, sy);
        dyTarget = yPosTarget - 1;
        northNodeTarget = topIds(z+1,x) + dyTarget;
        
        %add edge
        interColEdges(edgeGlobalId,:) = [i, northNodeTarget, 0, 0, infCost, 0];
        edgeGlobalId = edgeGlobalId+1;
      end
      
    end
    
  end
end
  
%cut globalEdges
% interColEdges(edgeGlobalId-1, :)
% interColEdges(edgeGlobalId, :)
% disp(['inter-col edges: ', num2str(size(interColEdges))]);
interColEdges = interColEdges(1:edgeGlobalId-1, :);



end

