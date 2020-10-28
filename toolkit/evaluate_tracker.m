function [score] = evaluate_tracker(trackerResults,groundTruth)
%EVALUATE_TRACKER Evaluate bounding boxes from tracker
%   Detailed explanation goes here
scores = zeros(length(trackerResults),1);
for k = 1:length(trackerResults)
    trackerBox = trackerResults(k,:);
    truthBox = groundTruth(k,:);
    % Calculate Intersection-Over-Union for the current estimate
    frameScore = iou(trackerBox, truthBox);
    scores(k) = frameScore;
end
score = mean(scores);

