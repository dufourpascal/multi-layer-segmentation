function [ intraColEdges ] = computeIntraColEdges( edgeCosts, topIds, bottomIds, topSurface )
%COMPUTEINTRACOLEDGES Summary of this function goes here
%   Detailed explanation goes here

infCost = 10000000;
[sz, sy, sx] = size(edgeCosts);

%compute number of intra-col Edges
dIds = bottomIds - topIds;
nIntraColEdges = sum(sum(dIds));
intraColEdges = zeros(nIntraColEdges, 6);
edgeGlobalId = 1;

for z = 1:sz
disp(['intra-col edges BScan ', num2str(z)]);
  for x = 1:sx
    startId = topIds(z,x);
    endId = bottomIds(z,x);
    nEdges = endId - startId;
    
    eInd = startId;
    yVol = topSurface(z,x);
    for e = 1 : nEdges
      
      gradientCost = edgeCosts(z,yVol,x);
      yVol = yVol+1;
%       disp(num2str(gradientCost));
      intraColEdges(edgeGlobalId,:) = [eInd,eInd+1 0, gradientCost, infCost, 0];
      edgeGlobalId = edgeGlobalId +1;
      eInd = eInd+1;
    end
  end
end

end

