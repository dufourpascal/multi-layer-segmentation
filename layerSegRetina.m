function [surfaceGCL, surfaceINL, surfaceONL, surfaceRPE] = layerSegRetina( surfaceBM, ...
  surfaceILM, volumeProb, errorMap )
%layerSegILM Summary of this function goes here
%   Detailed explanation goes here

%% setup
[sz, sy, sx, ~] = size(volumeProb);


% infCost = 10000000;
edgeDx1 = 2;
edgeDz1 = 15;
edgeDx2 = 3;
edgeDz2 = 20;
edgeDx3 = 4;
edgeDz3 = 30;
% edgeDx4 = 5;
% edgeDz4 = 30;
edgeDx4 = 5;
edgeDz4 = 30;
% regularizingStrengthX = 2000.0;
% regularizingStrengthZ = 200.0;

%% set unary cost
disp('setting unary costs');
% size(surfaceILMCoarse)
% size(volumeProb)
confidence = errorMap;
% confidence = ones(sz, sx); % no confidence available

%% compute boundary map strength
probabilityLabel1 = squeeze(volumeProb(:,:,:,1));
probabilityLabel2 = squeeze(volumeProb(:,:,:,2)) + probabilityLabel1;
probabilityLabel3 = squeeze(volumeProb(:,:,:,3)) + probabilityLabel2;
% probabilityLabel4 = squeeze(volumeProb(:,:,:,4)) + probabilityLabel3;
probabilityLabel4 = 1.0 - squeeze(volumeProb(:,:,:,5));


filterbank = makeLMFilters;
disp('label1');
edgeLabelH = squeeze(convolute3dRawVolume(probabilityLabel1,   filterbank(:,:,1)));
edgeLabelR = squeeze(convolute3dRawVolume(probabilityLabel1,   filterbank(:,:,2)));
edgeLabelL = squeeze(convolute3dRawVolume(probabilityLabel1, - filterbank(:,:,6)));
edgeLabel1 = min(edgeLabelH, edgeLabelR);
edgeLabel1 = min(edgeLabel1,  edgeLabelL);

edgeLabelH = squeeze(convolute3dRawVolume(probabilityLabel2,   filterbank(:,:,1)));
edgeLabelR = squeeze(convolute3dRawVolume(probabilityLabel2,   filterbank(:,:,2)));
edgeLabelL = squeeze(convolute3dRawVolume(probabilityLabel2, - filterbank(:,:,6)));
edgeLabel2 = min(edgeLabelH, edgeLabelR);
edgeLabel2 = min(edgeLabel2,  edgeLabelL);

edgeLabelH = squeeze(convolute3dRawVolume(probabilityLabel3,   filterbank(:,:,1)));
edgeLabelR = squeeze(convolute3dRawVolume(probabilityLabel3,   filterbank(:,:,2)));
edgeLabelL = squeeze(convolute3dRawVolume(probabilityLabel3, - filterbank(:,:,6)));
edgeLabel3 = min(edgeLabelH, edgeLabelR);
edgeLabel3 = min(edgeLabel3,  edgeLabelL);

%test
% edgeLabel2 = edgeLabel2 - edgeLabel3;

edgeLabelH = squeeze(convolute3dRawVolume(probabilityLabel4,   filterbank(:,:,1)));
edgeLabelR = squeeze(convolute3dRawVolume(probabilityLabel4,   filterbank(:,:,2)));
edgeLabelL = squeeze(convolute3dRawVolume(probabilityLabel4, - filterbank(:,:,6)));
edgeLabel4 = min(edgeLabelH, edgeLabelR);
edgeLabel4 = min(edgeLabel4,  edgeLabelL);

% imgT = [squeeze(edgeLabel2(10,:,1:150)), squeeze(edgeLabel3(10,:,151:300)), squeeze(edgeLabel4(10,:,301:512)) ];
% imagesc(imgT); colormap('gray');
% pause;

%% sub volume label 1 (NFL) vs rest
edgeCostStrength = 500;
regStrengthX = 1.0;
regStrengthZ = 0.1;
[costs1, topIds1, bottomIds1, topOffset1] = computeUnaryTermsInRegion(surfaceILM, surfaceBM, probabilityLabel1);
intraColEdges1 = computeIntraColEdges( edgeCostStrength .* edgeLabel1, topIds1, bottomIds1, surfaceILM );
interColEdges1 = computeInterColEdges(topIds1, bottomIds1, surfaceILM, surfaceBM, edgeDx1, edgeDz1);
regularizingEdges1 = computeHorizontalConnectivity(regStrengthX, regStrengthZ, topIds1, bottomIds1, topOffset1, confidence);

%% sub volume label 2 (GCL+IPL) vs down layers
edgeCostStrength = 500; %500
regStrengthX = 1.0;
regStrengthZ = 0.1;
[costs2, topIds2, bottomIds2, topOffset2] = computeUnaryTermsInRegion(surfaceILM, surfaceBM, probabilityLabel2);
intraColEdges2 = computeIntraColEdges( edgeCostStrength .* edgeLabel2, topIds2, bottomIds2, surfaceILM );
interColEdges2 = computeInterColEdges(topIds2, bottomIds2, surfaceILM, surfaceBM, edgeDx2, edgeDz2);
regularizingEdges2 = computeHorizontalConnectivity(regStrengthX, regStrengthZ, topIds2, bottomIds2, topOffset2, confidence);

%% sub volume label 3 (INL+OPL) vs ONL and RPE
edgeCostStrength = 500;
regStrengthX = 1.0;
regStrengthZ = 0.1;
[costs3, topIds3, bottomIds3, topOffset3] = computeUnaryTermsInRegion(surfaceILM, surfaceBM, probabilityLabel3);
intraColEdges3 = computeIntraColEdges( edgeCostStrength .* edgeLabel3, topIds3, bottomIds3, surfaceILM );
interColEdges3 = computeInterColEdges(topIds3, bottomIds3, surfaceILM, surfaceBM, edgeDx3, edgeDz3);
regularizingEdges3 = computeHorizontalConnectivity(regStrengthX, regStrengthZ, topIds3, bottomIds3, topOffset3, confidence);

%% sub volume label 4 (ONL) vs RPE
edgeCostStrength = 500.0;

% edgeCostL4 = edgeCostStrength .* edgeLabel4;
rsxRPE = 1.0;
rszRPE = 0.1;
[costs4, topIds4, bottomIds4, topOffset4] = computeUnaryTermsInRegion(surfaceILM, surfaceBM, probabilityLabel4);

intraColEdges4 = computeIntraColEdges( edgeCostStrength .* edgeLabel4, topIds4, bottomIds4, surfaceILM );
interColEdges4 = computeInterColEdges(topIds4, bottomIds4, surfaceILM, surfaceBM, edgeDx4, edgeDz4);
regularizingEdges4 = computeHorizontalConnectivity(rsxRPE, rszRPE, topIds4, bottomIds4, topOffset4, confidence);


%% adjust top Ids

offsetGraph2Id = bottomIds1(end);
offsetGraph3Id = bottomIds2(end) + offsetGraph2Id;
offsetGraph4Id = bottomIds3(end) + offsetGraph3Id;

topIds2 = topIds2 + offsetGraph2Id;
topIds3 = topIds3 + offsetGraph3Id;
topIds4 = topIds4 + offsetGraph4Id;

bottomIds2 = bottomIds2 + offsetGraph2Id;
bottomIds3 = bottomIds3 + offsetGraph3Id;
bottomIds4 = bottomIds4 + offsetGraph4Id;

% disp(['topids1: ', num2str(topIds1(1)), ' to ', num2str(topIds1(end)),]);
% disp(['botids1: ', num2str(bottomIds1(1)), ' to ', num2str(bottomIds1(end)),]);
% disp(['topids2: ', num2str(topIds2(1)), ' to ', num2str(topIds2(end)),]);
% disp(['botids2: ', num2str(bottomIds2(1)), ' to ', num2str(bottomIds2(end)),]);
% disp(['topids3: ', num2str(topIds3(1)), ' to ', num2str(topIds3(end)),]);
% disp(['botids3: ', num2str(bottomIds3(1)), ' to ', num2str(bottomIds3(end)),]);
% disp(['topids4: ', num2str(topIds4(1)), ' to ', num2str(topIds4(end)),]);
% disp(['botids4: ', num2str(bottomIds4(1)), ' to ', num2str(bottomIds4(end)),]);
% pause;

distance = 0;
interVolEdges1to2 = connectSubVolumes(topIds1, bottomIds1, topIds2, bottomIds2, distance);
interVolEdges2to3 = connectSubVolumes(topIds2, bottomIds2, topIds3, bottomIds3, distance);
interVolEdges3to4 = connectSubVolumes(topIds3, bottomIds3, topIds4, bottomIds4, distance);
% interVolEdges1to2 = 0;
% interVolEdges2to3 = 0;
% interVolEdges3to4 = 0;

%% connect graphs
costs = [costs1, costs2, costs3, costs4];

%adjust ids
% topIds2 = topIds2 + bottomIds1(end);
% bottomIds2 = bottomIds2+bottomIds1(end);
% topIds3 = topIds3 + bottomIds2(end);
% bottomIds3 = bottomIds3+bottomIds2(end);
% topIds4 = topIds4 + bottomIds3(end);
% bottomIds4 = bottomIds4+bottomIds3(end);
% topIds5 = topIds5 + bottomIds4(end);
% bottomIds5 = bottomIds5+bottomIds4(end);

% offsetGraph2Id = bottomIds1(end);
% offsetGraph3Id = bottomIds2(end) + offsetGraph2Id;
% offsetGraph4Id = bottomIds3(end) + offsetGraph3Id;

%aggregate edges
edges1 = [intraColEdges1; interColEdges1; regularizingEdges1];
edges2 = [intraColEdges2; interColEdges2; regularizingEdges2];
edges3 = [intraColEdges3; interColEdges3; regularizingEdges3];
edges4 = [intraColEdges4; interColEdges4; regularizingEdges4];
%compute new edge ids

edges2(:,1:2) = edges2(:,1:2) + offsetGraph2Id;
edges3(:,1:2) = edges3(:,1:2) + offsetGraph3Id;
edges4(:,1:2) = edges4(:,1:2) + offsetGraph4Id;

%% creating graph
nNodes = size(costs,2);
disp(['number of nodes: ', num2str(nNodes)]);
% edges = [edges1; edges2; edges3; edges4];
edges = [edges1; edges2; edges3; edges4; interVolEdges1to2; interVolEdges2to3; interVolEdges3to4];
nEdges = size(edges, 1);
disp(['number of edges: ', num2str(nEdges)]);

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
labellingFull = BK_GetLabeling(graph) -1; %lowest label is 0
BK_Delete(graph);
disp(['nr of labels == 0: ', num2str(size(find(labellingFull == 0)))]);
disp(['nr of labels == 1: ', num2str(size(find(labellingFull == 1)))]);
% size(labelling)

disp(['labelling full size: ', num2str(size(labellingFull))]);
disp(['labelling 1 range: 1 - ', num2str(bottomIds1(end))]);
disp(['labelling 2 range: ', num2str(offsetGraph2Id+1), ' to ', num2str(bottomIds1(end) + offsetGraph2Id)]);
disp(['labelling 3 range: ', num2str(offsetGraph3Id+1), ' to ', num2str(bottomIds1(end) + offsetGraph3Id)]);
disp(['labelling 4 range: ', num2str(offsetGraph4Id+1), ' to ', num2str(bottomIds1(end) + offsetGraph4Id)]);



labelling1 = labellingFull( 1                : bottomIds1(end));
labelling2 = labellingFull( offsetGraph2Id+1 : bottomIds1(end) + offsetGraph2Id);
labelling3 = labellingFull( offsetGraph3Id+1 : bottomIds1(end) + offsetGraph3Id);
labelling4 = labellingFull( offsetGraph4Id+1 : bottomIds1(end) + offsetGraph4Id);

surfaceGCL = surfaceBM;
surfaceINL = surfaceBM;
surfaceONL = surfaceBM;
surfaceRPE = surfaceBM;

%todo write label extraction function

%label1
for z = 1:sz
  for x = 1:sx
    startY = surfaceILM(z,x);
    yInd = startY;
    for ind = topIds1(z,x):bottomIds1(z,x)
      if labelling1(ind) == 1;
        surfaceGCL(z,x) = yInd;
        break;
      end
      yInd = yInd+1;
    end
  end
end
%label2
for z = 1:sz
  for x = 1:sx
    startY = surfaceILM(z,x);
    yInd = startY;
    for ind = topIds1(z,x):bottomIds1(z,x)
      if labelling2(ind) == 1;
        surfaceINL(z,x) = yInd;
        break;
      end
      yInd = yInd+1;
    end
  end
end
%label3
for z = 1:sz
  for x = 1:sx
    startY = surfaceILM(z,x);
    yInd = startY;
    for ind = topIds1(z,x):bottomIds1(z,x)
      if labelling3(ind) == 1;
        surfaceONL(z,x) = yInd;
        break;
      end
      yInd = yInd+1;
    end
  end
end
%label4
for z = 1:sz
  for x = 1:sx
    startY = surfaceILM(z,x);
    yInd = startY;
    for ind = topIds1(z,x):bottomIds1(z,x)
      if labelling4(ind) == 1;
        surfaceRPE(z,x) = yInd;
        break;
      end
      yInd = yInd+1;
    end
  end
end

end

