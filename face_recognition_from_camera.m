function face_recognition_from_camera()

    % get the classifier 
    classifier = loadCompactModel('face_recognition_classifier');
    
    [label,NegLoss,PBScore] = predict(faceClassifier,queryFeatures);
    

    % Create the face detector object using Viola-Jones algorithm.
    % Refs: 
    %   https://www.vocal.com/video/face-detection-using-viola-jones-algorithm/
    %   https://en.wikipedia.org/wiki/Viola%E2%80%93Jones_object_detection_framework
    faceDetector = vision.CascadeObjectDetector();

    % Create the point tracker object 
    pointTracker = vision.PointTracker('MaxBidirectionalError',2);

    % Create the webcam object
    cam = webcam(1);

    % Capture one frame to get its size 
    videoFrame = snapshot(cam);
    frameSize = size(videoFrame);

    % Create the video player object 
    videoPlayer = vision.VideoPlayer('Position', [100, 100 [frameSize(2), frameSize(1)] + 30]); 
    %videoPlayer2 = vision.VideoPlayer('Position', [100, 100 [frameSize(2), frameSize(1)] + 30]); 
    
    runLoop = true; 
    numPts = 0;
    
    faceBoxes = [];
    names = [];
    pointTrackerArray = [];
    bboxesArray = [];
    oldPointsArray = [];
    
    while runLoop
       
        %Get the next frame 
        videoFrame = snapshot(cam);
        videoFrameGray = rgb2gray(videoFrame);
        
        % Each box [x,y,w,h] . If n boxes , size = (n, 4)
        bboxes = faceDetector.step(videoFrameGray);
        checkOldBoxes = zeros(1, size(bboxes,1));
        
        % When having boxes 
        if ~empty(bboxes)
            
            % Iterate through each box and check whether it is old 
            % by checking random (x,y) in xyPoints array if it exists in
            % specific box . Let it be 1 in 'checkOldBoxes' 
            if ~empty(names)
                
                % Each array of xyPoints
                for i = 1 : size(names, 1)
                    r = randi([1 size(names(1),1)], 1, 1);
                    for eachBox = 1 : size(names,1)
                        x = bboxes(eachBox, 1);
                        y = bboxes(eachBox, 2);
                        w = bboxes(eachBox, 3);
                        h = bboxes(eachBox, 4);
                        randomPoint = oldPointsArray(i, r);
                        
                        % if it is inside this box 
                        if randomPoint(1) <= x + w && randomPoint(1) >= x && randomPoint(2) <= y+h && randomPoint(2) >= y
                            checkOldBoxes(eachBox) = 1;
                            break;
                        end
                    end
                end
                
                deleteIndices = [];
                % Calculate for each person
                for i = 1 : size(names, 1)
                    
                    % TRACKING MODE
                    pointTracker = pointTrackerArray(i); 
                    [xyPoints, isFound] = step(pointTracker, videoFrameGray);
                    visiblePoints = xyPoints(isFound, :);
                    oldInliers = oldPoints(isFound, :);

                    numPts = size(visiblePoints, 1);

                    if numPts >= 10 
                        % Estimate the geometric transformation between the old
                        % points and the new points 
                        [xform, oldInliers, visiblePoints] = estimateGeometricTransform(... % ... just for enter 
                            oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

                        % Apply the transformation to the bounding box 
                        bboxPoints = bboxesArray(i);
                        bboxPoints = transformPointsForward(xform, bboxPoints);

                        min_x = min(bboxPoints(1,:));
                        max_x = max(bboxPoints(1,:));
                        min_y = min(bboxPoints(2,:));
                        max_y = max(bboxPoints(2,:));
                        
                        x = min_x;
                        y = min_y;
                        w = max_x - min_x;
                        h = max_y - min_y;
                        
                        % Display
                        videoFrame = insertObjectAnnotation(videoFrame,'rectangle',[x,y,w,h],char(names(i)));
           
                        % Display tracked points 
                        %videoFrame = insertMarker(videoFrame, visiblePoints, '+', 'Color', 'white');

                        % Reset the points 
                        oldPointsArray(i,:) = visiblePoints;
                        setPoints(pointTracker, oldPointsArray(i,:));
                    else
                        deleteIndices = cat(1, deleteIndices, i );
                    end
                end
                
                % If the tracking points is below 10 , we no longer track
                % it 
                for i = 1 : size(deleteIndices,1)
                    index = deleteIndices(i);
                    faceBoxes(index,:) = [];
                    names(index,:) = [];
                    pointTrackerArray(index,:) = [];
                    bboxesArray(index, :) = [];
                    oldPointsArray(index, :) = [];
                end
                
                
                % Get new Face 
                for i = 1 : size(checkOldBoxes,1)
                    if checkOldBoxes(i) == 0 
                        % Find corner points inside the detected region  
                        points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox);

                        % Re-initialize the point tracker 
                        xyPoints = points.Location;
                        numPts = size(xyPoints,1);
                        release(pointTracker);
                        initialize(pointTracker, xyPoints, videoFrameGray);
                        pointTrackerArray = cat(1, pointTrackerArray, pointTracker);

                        % Save a copy of the points 
                        oldPointsArray(i,:) = xyPoints;

                        % Convert the rectangle represented as [x, y, w, h]
                        % into an M-by-2 matrix of [x,y] coordinates of the 
                        % corners. This is needed to be able to transform 
                        % the bounding box to display the orientation of 
                        % the face 
                        bboxPoints = bbox2points(bbox); 

                        % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
                        % format required by insertShape 
                        bboxPolygon = reshape(bboxPoints', 1 , []);

                        % Display a bounding box around the detected face 
                        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);

                        % Display detected corners 
                        videoFrame = insertMarker(videoFrame, xyPoints, '+', 'Color', 'white');
              
                    end
                end
                
            end
            
        end
        
        
        if numPts < 10
           %Detection mode [x,y, w,h]
           
           
           if ~isempty(bboxes)
                for i = 1 : size(bboxes,1) 
                    
                    bbox = bboxes(i,:);
                    
                    % Find corner points inside the detected region  
                    points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox);

                    % Re-initialize the point tracker 
                    xyPoints = points.Location;
                    numPts = size(xyPoints,1);
                    fprintf(' [INFO] numPts = %d \n', numPts); 
                    release(pointTracker);
                    initialize(pointTracker, xyPoints, videoFrameGray);

                    % Save a copy of the points 
                    oldPoints = xyPoints;

                    % Convert the rectangle represented as [x, y, w, h]
                    % into an M-by-2 matrix of [x,y] coordinates of the 
                    % corners. This is needed to be able to transform 
                    % the bounding box to display the orientation of 
                    % the face 
                    bboxPoints = bbox2points(bbox); 

                    % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
                    % format required by insertShape 
                    bboxPolygon = reshape(bboxPoints', 1 , []);

                    % Display a bounding box around the detected face 
                    videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);

                    % Display detected corners 
                    videoFrame = insertMarker(videoFrame, xyPoints, '+', 'Color', 'white');
              
               end
              
           end
           
        else
            % Tracking mode.
            fprintf(' [MODE] Tracking mode \n');
            [xyPoints, isFound] = step(pointTracker, videoFrameGray);
            visiblePoints = xyPoints(isFound, :);
            oldInliers = oldPoints(isFound, :);
            
            numPts = size(visiblePoints, 1);
            fprintf(' [INFO] numPts = %d \n', numPts);
            
            if numPts >= 10 
                % Estimate the geometric transformation between the old
                % points and the new points 
                [xform, oldInliers, visiblePoints] = estimateGeometricTransform(... % ... just for enter 
                    oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
                    
                % Apply the transformation to the bounding box 
                bboxPoints = transformPointsForward(xform, bboxPoints);
                
                % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4
                % y4]
                % format required by insertShape
                bboxPolygon = reshape(bboxPoints', 1, []);
                
                % Display a bounding box around the face being tracked 
                videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);
                
                % Display tracked points 
                videoFrame = insertMarker(videoFrame, visiblePoints, '+', 'Color', 'white');
                
                % detect SURF Features  
                %boxPoints = detectSURFFeatures(videoFrameGray);
                %boxPoints = selectStrongest(boxPoints,10);
                %videoFrame2 = insertMarker(videoFrame, boxPoints.Location, '+', 'Color', 'Red');
                
                % Reset the points 
                oldPoints = visiblePoints;
                setPoints(pointTracker, oldPoints);
                
                
            end
        end
        
        % Display the annotated video frame using the video player
        % object 
        step(videoPlayer, videoFrame);
        %step(videoPlayer2, videoFrame2);

        % Check whether the video player window has been closed 
        runLoop = isOpen(videoPlayer) ; %&& isOpen(videoPlayer2);
        
    end


    % Clean up
    clear cam;
    release(videoPlayer);
    %release(videoPlayer2);
    release(pointTracker);
    release(faceDetector);
    


end