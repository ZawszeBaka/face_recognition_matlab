% install USB webcam 
% 

function test_camera()

    webcamlist;
    cam = webcam(1); % integrated webcam 
    preview(cam);
    cam.AvailableResolutions
   
    img = snapshot(cam);
    gray = rgb2gray(img);
    imshow(gray);
    
    closePreview(cam);
    clear('cam')


end
