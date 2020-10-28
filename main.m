clear;
% Folder name for dataset
datasetName = 'book';
% Read in frames and ground truth tracking data
[frames, groundTruth, initialObject] = read_dataset(datasetName);
% Initial state object to pass to a tracker
state = {};
state.initialObject = initialObject;
state.initialized = false;
% Initialize matrix for rectangular bounding boxes
results = zeros(length(frames),8);
% video = VideoWriter('yourvideo.avi'); %create the video object
% open(video);

video = VideoWriter('yourvideo1.avi'); %create the video object
open(video); %open the file for writing
for i=1:length(frames) %where N is the number of images
  L= frames{i};

  writeVideo(video,L); %write the image to file
end
close(video);

   v = VideoWriter('test.avi'); %create the video object
   open(v);
for k = 1:length(frames)
    frame = frames{k};
    % Call the tracking function with the current frame and state
    % This is the function you will implement
    [state, boundingBox] =track(state, frame,k,'yourvideo1.avi');
    results(k,:) = boundingBox;
    w= (results(3)+results(1))/2;
    h= (results(6)+results(4))/2;
    [height, width] = size(state.template);
    RGB = insertShape(frame,'Rectangle',[w+(width/2) h+height/2 width height],'LineWidth',5);
    %imshow(RGB);
    writeVideo(v,RGB);
    
end

 close(v);
% Evaluate results of the tracker
score = evaluate_tracker(results, groundTruth);

% Example to draw results for qualitative analysis
draw_bounding_box(frames{1}, results(1,:));
%imshow(returnimage(frames{20}, results(20,:)));

%implay('yourvideo.avi');
