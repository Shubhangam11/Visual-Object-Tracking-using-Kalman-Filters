function [frames, groundTruth, initialObject] = read_dataset(datasetName)
%READ_FRAMES Summary of this function goes here
%   Detailed explanation goes here
frameFolder = ['datasets/' datasetName '/frames'];
if ~isfolder(frameFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', frameFolder);
  uiwait(warndlg(errorMessage));
  return;
end
jpegFiles = dir([frameFolder '/*.jpg']);
fprintf(1, 'Now reading frames for %s\n', datasetName);
numFrames = length(jpegFiles);
frames = cell(numFrames,1);
for k = 1:numFrames
  fileName = jpegFiles(k).name;
  image = imread([frameFolder, '/', fileName]);
  frames{k} = image;
end

fprintf(1, 'Now reading ground truth for %s\n', datasetName);
groundTruth = csvread(['datasets/' datasetName '/groundtruth.txt']);

initialObject = groundTruth(1,:);

end

