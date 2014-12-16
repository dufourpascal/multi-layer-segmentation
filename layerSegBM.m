function [ binaryMask, surfaceBMFine ] = layerSegBM( surfaceBMCoarse, ...
  volumeProb, volumeEdgeCost, confidence )
%layerSegILM Summary of this function goes here
%   Detailed explanation goes here

%% setup
[sz, sy, sx] = size(volumeEdgeCost);
% sz = 1 %debug only one BScan
binaryMask = zeros(sz, sy, sx);

% infCost = 10000000;
edgeDx = 1;
edgeDz = 15;
regularizingStrengthX = 50.0;
regularizingStrengthZ = 5.0;

%% sub volume
rangeAbove = 60;
rangeBelow = 60;

%% set unary cost
disp('setting unary costs');
% size(surfaceILMCoarse)
% size(volumeProb)
[costs, topSurface, bottomSurface, topIds, bottomIds] = computeUnaryTerms( surfaceBMCoarse, rangeAbove, rangeBelow, volumeProb );

%% intra-column edges
intraColEdges = computeIntraColEdges( volumeEdgeCost, topIds, bottomIds, topSurface );

%% inter-column edges
interColEdges = computeInterColEdges(topIds, bottomIds, topSurface, bottomSurface, edgeDx, edgeDz);

%% regularizing edges in horizontal direction (assuming regular volue)
regularizingEdges = computeHorizontalConnectivity(regularizingStrengthX, regularizingStrengthZ, topIds, bottomIds, confidence);
%% creating graph
nNodes = size(costs,2);

edges = [intraColEdges; interColEdges; regularizingEdges];
nEdges = size(edges, 1);

disp('creating graph');
graph = BK_Create(nNodes, nEdges);
disp('setting unary cost');
BK_SetUnary(graph, costs)
disp('setting pairwise cost');
BK_SetPairwise(graph,edges);

%% solving graph
disp('solving');
tic;
energy = BK_Minimize(graph);
toc

%% reformat labelling
disp('getting labelling');
labelling = BK_GetLabeling(graph) -1; %lowest label is 0
BK_Delete(graph);
disp(['nr of labels == 0: ', num2str(size(find(labelling == 0)))]);
disp(['nr of labels == 1: ', num2str(size(find(labelling == 1)))]);
% size(labelling)
surfaceBMFine = bottomSurface;

for z = 1:sz
  for x = 1:sx
    
    startY = topSurface(z,x);
    endY   = bottomSurface(z,x);

    yInd = startY;
    for ind = topIds(z,x):bottomIds(z,x)
      if labelling(ind) == 1;
        surfaceBMFine(z,x) = yInd;
        break;
      end
      yInd = yInd+1;
    end
    
    binaryMask(z,1:startY,x) = 2;
    binaryMask(z,startY:endY,x) = labelling(topIds(z,x):bottomIds(z,x));
    binaryMask(z,endY:sy,x) = 2;
    
  end
end

end

