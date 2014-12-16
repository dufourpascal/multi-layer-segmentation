function [ interColEdges ] = computeInterColEdges( topIds, bottomIds, topSurface, bottomSurface, maxDx, maxDz )
%COMPUTEINTERCOLEDGES Summary of this function goes here
%   Detailed explanation goes here

infCost = 10000000;

[sz, sx] = size(topIds);

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
    topY = topSurface(z,x);
%     bottomY = bottomSurface(z,x);
    
    di = 0;
    for i = startId:endId
      yPosSource = topY+di;
      yPosTarget = yPosSource + maxDx;
      di = di+1;
      
      % check if edge is possible
      
      if x > 1
        %can add edge to the left
        topYLeft = topSurface(z,x-1);
        bottomYLeft = bottomSurface(z,x-1);
        yPosTarget = max(yPosTarget, topYLeft);
        yPosTarget = min(yPosTarget, bottomYLeft);
        dyTarget = yPosTarget - topYLeft;
        leftNodeTarget = topIds(z,x-1) + dyTarget;
        
        %add edge
        interColEdges(edgeGlobalId,:) = [i, leftNodeTarget, 0, 0, infCost, 0];
        edgeGlobalId = edgeGlobalId+1;
      end
      
      if x < sx
        %can add edge to the right
        topYRight = topSurface(z,x+1);
        bottomYRight = bottomSurface(z,x+1);
        yPosTarget = max(yPosTarget, topYRight);
        yPosTarget = min(yPosTarget, bottomYRight);
        dyTarget = yPosTarget - topYRight;
        rightNodeTarget = topIds(z,x+1) + dyTarget;
        
        %add edge
        interColEdges(edgeGlobalId,:) = [i, rightNodeTarget, 0, 0, infCost, 0];
        edgeGlobalId = edgeGlobalId+1;
      end
      
      
      yPosTarget = yPosSource + maxDz;
      if z > 1
        %can add edge to south/down
        topYSouth = topSurface(z-1,x);
        bottomYSouth = bottomSurface(z-1,x);
        yPosTarget = max(yPosTarget, topYSouth);
        yPosTarget = min(yPosTarget, bottomYSouth);
        dyTarget = yPosTarget - topYSouth;
        southNodeTarget = topIds(z-1,x) + dyTarget;
        
        %add edge
        interColEdges(edgeGlobalId,:) = [i, southNodeTarget, 0, 0, infCost, 0];
        edgeGlobalId = edgeGlobalId+1;
      end
      
      if z < sz
        %can add edge to north/up
        topYNorth = topSurface(z+1,x);
        bottomYNorth = bottomSurface(z+1,x);
        yPosTarget = max(yPosTarget, topYNorth);
        yPosTarget = min(yPosTarget, bottomYNorth);
        dyTarget = yPosTarget - topYNorth;
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

