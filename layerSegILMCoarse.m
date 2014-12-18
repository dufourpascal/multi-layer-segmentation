function surfaceILMCoarse = layerSegILMCoarse( volumeProb, volumeEdgeCost )
%layerSegILM Summary of this function goes here
%   Detailed explanation goes here

%% setup
[sz, sy, sx] = size(volumeEdgeCost);
% sz = 1 %debug only one BScan
% binaryMask = zeros(sz, sy, sx);

% infCost = 10000000;
edgeDx = 2;
edgeDz = 3;

%% set unary cost
disp('setting unary costs');
[costs, topIds, bottomIds] = computeUnaryTermsInVolume(volumeProb);
%% intra-column edges
intraColEdges = computeIntraColEdgesInVolume( volumeEdgeCost, topIds, bottomIds );

%% inter-column edges
interColEdges = computeInterColEdgesInVolume(topIds, bottomIds, edgeDx, edgeDz);

%% regularizing edges
regStrengthX = 0.5;
regStrengthZ = 0.5;
confidence = ones(sz,sx);
regularizingEdges = computeHorizontalConnectivity(regStrengthX, regStrengthZ, topIds, bottomIds, confidence);

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
surfaceILMCoarse = zeros(sz,sx);
for z = 1:sz
  for x = 1:sx
    
%     startY = 1;
%     endY   = sy;

    yInd = 1;
    for ind = topIds(z,x):bottomIds(z,x)
      if labelling(ind) == 1;
        surfaceILMCoarse(z,x) = yInd;
        break;
      end
      yInd = yInd+1;
    end
    
%     binaryMask(z,:,x) = labelling(topIds(z,x):bottomIds(z,x));
    
  end
end

end

