
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
- Features Extraction : using Histogram of Oriented Gradients (HOG) . Ref : https://www.learnopencv.com/histogram-of-oriented-gradients/
- Classifier : using SVM for multi-class
- Use the file "face_training.m" => save Classifier to the file "face_recognition_classifier.mat"


### Face Recognition and Face Tracking 
- Face Recognition : load from the Classifier we have trained earlier "face_recognition_classifier.mat"
- Face Tracking : using KLT algorithm or SURF 
- Use the file "face_recognition_simple_from_camera.m"


[========================================================================================]

### How to use 
- Firstly, you should test your camera and make sure your camera works properly. Run file 'test_camera.m'
- If you want to detect face from your camera . Run file 'face_detection_video.m'
- Data Gathering: 
   + From collected images : collect images from specific person and put all of these in 1 directory in 'dataset_notyetdetect'
with requisition:   
        + Each image has only 1 potential face 
        + 'face_creating_dataset_from_pictures.m': When you run it, you need to input 3 things ( directory of collected pictures of 1 person , id of this person , name of this person) .  The process will get these images, detect a region of face and scale into the size of 144-by-144 pixels and save to 'dataset/<id>_<name>/<numPic>.png'
   + From camera (auto): When you run it, you only need 2 inputs ( the id and name of the person in front of camera to be labeled)
   + Note that, all pictures with fixed size 144-by-144 must be saved in directory 'dataset' . The images will be saved in different sub-directory followed by the id and name of that person . Format: 'dataset/<id>_<personName>/*.png'
- Training: You need to train the classifier . Run this file 'face_training.m'. It will train all the images of all the people in the directory 'dataset' and output the classifier to the file 'face_recognition_classifier.mat' . This output is purposed for later use 
- Face Recognition and Face Tracking: run this file 'face_recognition_simple_from_camera.m'. It will take the classifier we saved earlier and classifies for this process. 

### Status : 
- Still in developing ... 
- Please report it immediately if you see bugs , we will fix and help you !! 

### Best regards


