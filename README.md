
[=] SUMMARY : (for its detail , see below) 
- Face Detection using Viola-Jones algorithm 
- Data Gathering (144 x 144 for each face image)
- Training ( Features Extraction using Histogram of Oriented Gradient and using SVM for classifying) 
- Face Recognition and Face Tracking using KLT algorithm (can run in real-time)

### INPUT :
- Video Frames from camera
- Picture

### Face Detection
Viola–Jones algorithm
- Haar Cascade Classifier (pre-trained classifier) : All human faces share some similar properties.
    + Location and size: eyes , mouth , bridge of nose 
    + Value: oriented gradients of pixel intensities 
- Summed area table (Integral Image) 
- Learning algorithm 
- Cascade 
- Use the file: "face_detection_video.m"


### Data Gathering 
- Each face image has the fixed size 144 x 144 
- In this project, you can create dataset from pictures with conditions : each picture has only 1 potential face 
or from camera 
- Use the files "face_creating_dataset_from_camera.m" or "face_creating_dataset_from_pictures.m"


### Training
- Features Extraction : using Histogram of Oriented Gradients (HOG) 
- Classifier : using SVM for multi-class
- Use the file "face_training.m" => save Classifier to the file "face_recognition_classifier.mat"


### Face Recognition and Face Tracking 
- Face Recognition : load from the Classifier we have trained earlier "face_recognition_classifier.mat"
- Face Tracking : using KLT algorithm or SURF 
- Use the file "face_recognition_simple_from_camera.m"


[========================================================================================================]

### How to use 
- Firstly, you should test your camera and make sure your camera works properly. Run file "test_camera.m"
- If you want to detect face from your camera . Run file "face_detection_video.m" 
- Data Gathering: 
   + From collected images  
   + From camera (auto)

### Status : 
- Still in developing ... 



