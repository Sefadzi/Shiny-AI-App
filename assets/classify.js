// callback function
function modelLoaded() {
  console.log('Model Loaded!');
}

// Initialize the Image Classifier method with MobileNet
const classifier = ml5.imageClassifier('MobileNet', modelLoaded);

// handler to process data from js to shiny
//create handler


Shiny.addCustomMessageHandler('classify', function(data){
  // Classify bird
  classifier.classify(document.getElementById("bird"), (err, results) => {
    Shiny.setInputValue("classification:ml5.class", results);
  });
});