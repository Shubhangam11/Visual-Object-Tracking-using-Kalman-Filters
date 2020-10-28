function [score] = iou(estimate,groundTruth)
%IOU Calculates the Intersection over Union of two polygons
%   Input
%       estimate: Array of coordinates of points for estimated bounding box
%       groundTruth: Array of coordinates of points for ground truth bounding box
%           both inputs of the form [x1,y1,...,xn,yn] for an n-gon
estimatePoly = polyshape(estimate(1:2:end), estimate(2:2:end));
truthPoly = polyshape(groundTruth(1:2:end), groundTruth(2:2:end));
intersectionPoly = intersect(estimatePoly, truthPoly);
intersectArea = area(intersectionPoly);
unionArea = area(estimatePoly) + area(truthPoly) - area(intersectionPoly);
score = intersectArea / unionArea;
end

