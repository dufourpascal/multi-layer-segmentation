function [ connectingEdges ] = connectSubVolumes( topIds1, bottomIds1, topIds2, bottomIds2, distance )
%CONNECTSUBVOLUMES Summary of this function goes here
%   Detailed explanation goes here

infCost = 10000000;
[sz, sx] = size(topIds1);
% dIds = bottomIds1 - topIds1;
% surf(dIds);
% pause;
nMaxInterVolEdges = sum(sum( (bottomIds1 + 1) - topIds1 ));
interVolEdges = zeros(nMaxInterVolEdges, 6);
edgeGlobalId = 1;

for z = 1:sz
  disp(['inter-vol edges BScan ', num2str(z)]);
  
  for x = 1:sx
%     disp(['x ', num2str(x)]);
%     fprintf('.');

    sourceId = topIds1(z,x);
    lastSource = bottomIds1(z,x);
    
    targetId = topIds2(z,x) + distance;
    lastTarget = bottomIds2(z,x);
%     disp(['x: ', num2str(x), ', ds: ', num2str(lastSource-sourceId), ', dt: ', num2str(lastTarget-targetId)]);
    while(targetId <= lastTarget && sourceId <= lastSource)
      interVolEdges(edgeGlobalId,:) = [sourceId,targetId 0, infCost, 0, 0];
      
      if(edgeGlobalId > nMaxInterVolEdges)
        disp('warning: resizing!!!');
      end
      %increase ids
      edgeGlobalId = edgeGlobalId +1;
      sourceId = sourceId+1;
      targetId = targetId+1;
    end
  end
end

connectingEdges = interVolEdges(1:edgeGlobalId-1,:);
% disp(['last connecting edge: ', num2str(squeeze(connectingEdges(end,:)))]);

end

